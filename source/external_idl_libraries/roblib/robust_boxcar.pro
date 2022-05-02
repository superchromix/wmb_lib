PRO  ROBUST_BOXCAR,X,Y,NPER, U,V,SIG, CONF_INT=PERSENT
;
;+
; NAME:
;	ROBUST_BOXCAR 
;
; PURPOSE:
;	Calculate robust boxcar averages of fixed number of points. One average
;	is calculated per NPER points. (Remaining points go into the last 
;	average.)   Biweights are used. The same weights are applied to the X 
;	variable in calculating its average, so that the (X,Y) correspondence 
;	is not lost.
;
; CALLING SEQUENCE:
;	ROBUST_BOXCAR, X, Y, NPER,  U, V, SIG, [ CONF_INT = ]
;
; INPUT ARGUMENTS:
;	X = X coordinates vector
;	Y = Distribution in vector form
;	NPER = # points per average
;
; OUTPUT ARGUMENT:
;	U = vector of average X
;	V = vector of average Y
;
; OPTIONAL OUTPUT ARGUMENT:
;	SIG = standard error of V (a robust std. dev. of the mean) [OPTIONAL]
;
; OPTINAL INPUT KEYWORD:
;	CONF_INT = confidence interval in percent. If this keyword is present
;		then output SIG = the confidence interval
;
; SUBROUTINE CALLS:
;	BIWEIGHT_MEAN, which calculates the averages
;
; REVISION HISTORY:
;	Written, H. Freudenreich, STX, 1/92
;	Modifications: H.F. 3/94 -- added confidence intervals option
;-

ON_ERROR,2

N=N_ELEMENTS(X)
NSEG=N/NPER

U=FLTARR(NSEG)   &   V=FLTARR(NSEG)   &   SIG=FLTARR(NSEG)

IF KEYWORD_SET(PERSENT) THEN TINT=PERSENT*.01 ELSE TINT=-1.

J=0
FOR I=0,NSEG-2 DO BEGIN
  JEND=J+NPER-1
  R=BIWEIGHT_MEAN( Y(J:JEND), S, WEIGHTS)
  U(I) =TOTAL( X(J:JEND)*WEIGHTS )
  V(I) =R
  IF TINT GT 0. THEN SIG(I)=ABS(STUDENT_T(TINT,.7*(NPER-1)))*S/SQRT(NPER) $
                ELSE SIG(I)=S
  J=JEND+1
ENDFOR
; Remaining points are added to the last bin:
I=NSEG-1
R=BIWEIGHT_MEAN(Y(J:N-1),S, WEIGHTS)
U(I)  =TOTAL( X(J:N-1)*WEIGHTS )
V(I)  =R
IF TINT GT 0. THEN BEGIN
   M=N-J
   SIG(I)=ABS(STUDENT_T(TINT,.7*(M-1)))*S/SQRT(M)
ENDIF ELSE SIG(I)=S

RETURN
END
