FUNCTION BOOT_POLYFIT, X,Y, NDEG, N_SAMPLE, NUMOUT, ROBUST=whatever
;
;+
; NAME:
;	BOOT_POLYFIT
;
; PURPOSE:
;	Bootstrap polynomial fit to data. 
;
; CALLING SEQUENCE: 
;	COEFF = BOOT_POLYFIT( X,Y, NDEG, N_SAMPLE, [ NUMOUT,  /ROBUST ] ) 
;
;INPUT ARGUMENT:
;	X = x vector
;	Y = y vector
;	NDEG = degree of polynomial fit
;	N_SAMPLE = the number of bootstrap samples
;
; RETURNS:
;	COEFF = array of coefficients. Dimensions=(NDEG+1,N_SAMPLE)
;		First dimension in the order A0, A1, A2,...
;
; OUTPUT ARGUMENT:
;	 NUMOUT = actual number of samples returned. If there is an error in
;		the fit to any sample, NUMOUT is decreased by one.
;
; OPTIONAL INPUT KEYWORD:
;	ROBUST  if present, an outlier-resistant fit is performed
;
; EXAMPLE:
;	Takes 100 samples of a robust cubic fit to (X,Y)
;	IDL> COEFF = BOOT_POLYFIT( X,Y, 3, 100, /ROBUST) 
;
; NOTE:  
;	This program randomly selects (x,y) points and fits a curve to them. It
;	does this N_SAMPLE times.
;
; WARNING:
;	At least NDEG+1 points must be input. It is best to have at least twice
;	that many for a robust fit.
;
; REVISION HISTORY:
;	Written, H.T. Freudenreich, HSTX, 3/16/94. Adapted from obsolete 
;		BOOT_LINE.
;-

ON_ERROR,2

IF KEYWORD_SET(WHATEVER) THEN ROBUST=1 ELSE ROBUST=0

N=N_ELEMENTS(X)

IF N LT (NDEG+1) THEN BEGIN
   PRINT,'BOOT_POLYFIT: Too few points! Returning 0'
   RETURN,0.
ENDIF

COEFF=FLTARR(NDEG+1,N_SAMPLE)

; Get the random number seeds:
R0=SYSTIME(1)*2.+1.
SEEDS=RANDOMU(R0,N_SAMPLE)*1.0E6+1.

NGOOD = -1

FOR L=0,N_SAMPLE-1 DO BEGIN
  R=SEEDS(L)
; Uniform random numbers between 0 and N-1:
  PICK=RANDOMU(R,N)
  IF N LE 32767 THEN R=FIX(PICK*N) ELSE R=LONG(PICK*N)
  U=X(R) & V=Y(R)
  IF ROBUST EQ 1 THEN BEGIN
;    Use ROBUST_LINEFIT when possible because it is faster.
;    ROBUST_POLY_FIT.
     IF NDEG EQ 1 THEN CC=ROBUST_LINEFIT(U,V) ELSE CC=ROBUST_POLY_FIT(U,V,NDEG)
  ENDIF           ELSE CC=POLY_FIT(U,V,NDEG)
  IF N_ELEMENTS(CC) EQ (NDEG+1) THEN BEGIN
     NGOOD=NGOOD+1
     COEFF(*,NGOOD)=CC
  ENDIF
ENDFOR

NGOOD = NGOOD+1
IF NGOOD LT N_SAMPLE THEN BEGIN
   PRINT,'BOOT_POLYFIT: Some samples rejected.'
   COEFF=COEFF(*,0:NGOOD-1)
ENDIF
NUMOUT = NGOOD
RETURN,COEFF
END
