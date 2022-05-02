FUNCTION BOOT_XYFIT, X,Y, N_SAMPLE,YINT,SLOP,SYINT,SSLOP,NUMOUT,ROBUST=whatever
;
;+
; NAME:
;	BOOT_XYFIT
;
; PURPOSE:
;	Bootstrap linear fit to data in which there are errors in both Y and X,
;	but the measurement errors are not available. Calculates the bisector 
;	of the Y vs X and X vs Y regression.
;
; CALLING SEQUENCE:
;	COEFF = BOOT_XYFIT( X,Y, NSAMPLE, YINT, SLOP, SYINT, SSLOP, NUMOUT, 
;		[ /ROBUST ] ) 
;
; INPUT ARGUMENT:
;	X = x vector
;	Y = y vector
;	N_SAMPLE = the number of bootstrap samples
;
; RETURNS:
;	COEFF = array of coefficients. Dimensions=(NDEG+1,N_SAMPLE)
;		First dimension in the order A0, A1
;
; OPTIONAL OUTPUT ARGUMENT:
;	YINT = Y intercept (average of COEFF(0,*))
;	SLOP = slope (average of (COEFF(1,*))
;	SYINT = standard error of Y intercept (std. dev. of COEFF(0,*))
;	SSLOP = standard error of slope (std. dev. of COEFF(1,*))
;	NUMOUT = actual number of samples returned. If there is an error in
;		the fit to any sample, NUMOUT is decreased by one.
;
; OPTIONAL INPUT KEYWORD:
;	ROBUST  if present, an outlier-resistant fit is performed
;
; NOTES:  
;	This program randomly selects (x,y) points and fits a line to them. The
;	line is the bisector of the Y vs X and X vs Y regressions. It does this 
;	N_SAMPLE times.
;
; WARNING:
;	At least NDEG+1 points must be input. It is best to have at least twice
;	that many for a robust fit.
;
; REVISION HISTORY:
;	Written H.T. Freudenreich, HSTX, 3/16/94. Adapted from obsolete 
;		BOOT_LINE.
;-

IF KEYWORD_SET(WHATEVER) THEN ROBUST=1 ELSE ROBUST=0

N=N_ELEMENTS(X)

IF N LT 2 THEN BEGIN
   PRINT,'BOOT_XYFIT: Too few points! Returning 0'
   RETURN,0.
ENDIF

COEFF=FLTARR(2,N_SAMPLE)

; Get the random number seeds:
R0=SYSTIME(1)*2.+1.
SEEDS=RANDOMU(R0,N_SAMPLE)*1.0E6+1.

NGOOD = -1

FOR L=0,N_SAMPLE-1 DO BEGIN
  R=SEEDS(L)
; Uniform random numbers between 0 and N-1:
  PICK=RANDOMU(R,N)
  R=FIX(PICK*N)
  U=X(R) & V=Y(R)
  IF ROBUST EQ 1 THEN BEGIN
     CC=ROBUST_LINEFIT(U,V,/BISECT)
  ENDIF ELSE BEGIN
     CC1=POLY_FIT(U,V,1)
     KK =POLY_FIT(V,U,1)
     CC2=[-KK(0)/KK(1),1./KK(1)]
     YYINT = CC1(0)  & YSLOP = CC1(1)
     XYINT = CC2(0)  & XSLOP = CC2(1)
     IF YSLOP GT XSLOP THEN BEGIN
        A1=YYINT  &  B1=YSLOP  &  R1=SQRT(1.+YSLOP^2)
        A2=XYINT  &  B2=XSLOP  &  R2=SQRT(1.+XSLOP^2)
     ENDIF ELSE BEGIN
        A2=YYINT  &  B2=YSLOP  &  R2=SQRT(1.+YSLOP^2)
        A1=XYINT  &  B1=XSLOP  &  R1=SQRT(1.+XSLOP^2)
     ENDELSE
     YINT=(R1*A2+R2*A1)/(R1+R2) 
     SLOP=(R1*B2+R2*B1)/(R1+R2)
     CC=[YINT,SLOP] 
  ENDELSE

  IF (N_ELEMENTS(CC) EQ 2) THEN BEGIN 
     NGOOD=NGOOD+1
     COEFF(*,NGOOD)=CC
  ENDIF
ENDFOR

NGOOD = NGOOD+1
IF NGOOD LT N_SAMPLE THEN BEGIN
   PRINT,'BOOT_XYFIT: Some samples rejected.'
   COEFF=COEFF(*,0:NGOOD-1)
ENDIF

YINT=TOTAL(COEFF(0,*))/NGOOD
SLOP=TOTAL(COEFF(1,*))/NGOOD
SYINT=STDEV(COEFF(0,*))
SSLOP=STDEV(COEFF(1,*))

RETURN,COEFF
END
