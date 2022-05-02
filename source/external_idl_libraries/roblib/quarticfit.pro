FUNCTION QUARTICFIT,X,Y,Z, W, YFIT
;
;+
; NAME:
;      QUARTICFIT
;
; PURPOSE:
;      Fit a general quadratic surface: Z=a+bX+cX^2+dXY+eY+fY^2
;
; CALLING SEQUENCE:
;      coefficients = QUARTICFIT( X,Y,Z,W, YFIT )
; INPUT:
;      X = independent variable vector, may be in double precision
;      Y = independent variable vector, may be in double precision
;      Z = dependent variable vector, may be in double precision
;      W = weights (IF EQUAL, SET W=0.)
;
; RETURNS:
;      The coefficients of the fit, in the order given above.
;
; OPTIONAL OUTPUT:
;      YFIT = the calculated fit at points (X,Y)
;
; SIDE-EFFECTS:
;      Sometimes nausea and dizziness, if taken in large doses.
;
; AUTHOR:
;      H.T. Freudenreich, HSTX, 5/19/93
;-

N=N_ELEMENTS(Z)
X2=X*X  & Y2=Y*Y  & XY=X*Y

; Accumulate sums:

IF N_ELEMENTS(W) LT 7 THEN BEGIN
;  No weights!
   S=N*1.             & SX=TOTAL(X)        & SY=TOTAL(Y)        & SZ=TOTAL(Z)
   SXY=TOTAL(XY)      & SXZ=TOTAL(X*Z)     & SYZ=TOTAL(Y*Z)
   SX2=TOTAL(X2)      & SY2=TOTAL(Y2) 
   SX3=TOTAL(X2*X)    & SY3=TOTAL(Y2*Y)
   SX4=TOTAL(X2^2)    & SY4=TOTAL(Y2^2)
   SX2Y=TOTAL(X2*Y)   & SY2X=TOTAL(Y2*X)
   SX3Y=TOTAL(X2*XY)  & SY3X=TOTAL(Y2*XY)  & SX2Y2=TOTAL(X2*Y2)
   SZ=TOTAL(Z)        & SXZ=TOTAL(X*Z)     & SX2Z=TOTAL(X2*Z)   & SYZ=TOTAL(Y*Z)
   SXYZ=TOTAL(XY*Z)   & SY2Z=TOTAL(Y2*Z)
ENDIF ELSE BEGIN
;  Weights included!
   S=TOTAL(W)           & SX=TOTAL(W*X)      & SY=TOTAL(W*Y)     & SZ=TOTAL(W*Z)
   SXY=TOTAL(W*XY)      & SXZ=TOTAL(W*X*Z)   & SYZ=TOTAL(W*Y*Z)
   SX2=TOTAL(W*X2)      & SY2=TOTAL(W*Y2) 
   SX3=TOTAL(W*X2*X)    & SY3=TOTAL(W*Y2*Y)
   SX4=TOTAL(W*X2^2)    & SY4=TOTAL(W*Y2^2)
   SX2Y=TOTAL(W*X2*Y)   & SY2X=TOTAL(W*Y2*X)
   SX3Y=TOTAL(W*X2*XY)  & SY3X=TOTAL(W*Y2*XY) & SX2Y2=TOTAL(W*X2*Y2)
   SXYZ=TOTAL(W*XY*Z)   & SY2Z=TOTAL(W*Y2*Z)
   SZ =TOTAL(W*Z)       & SXZ=TOTAL(W*X*Z)    & SX2Z=TOTAL(W*X2*Z) 
   SYZ=TOTAL(W*Y*Z)
ENDELSE

M=[ [S,  SX,  SX2,  SXY,  SY,  SY2], $
    [SX, SX2, SX3,  SX2Y, SXY, SY2X], $
    [SX2,SX3, SX4,  SX3Y, SX2Y,SX2Y2],$
    [SXY,SX2Y,SX3Y, SX2Y2,SY2X,SY3X],$
    [SY, SXY, SX2Y, SY2X, SY2, SY3],$
    [SY2,SY2X,SX2Y2,SY3X, SY3, SY4]  ]

IM=INVERT(M,STATUS)
IF STATUS NE 0 THEN BEGIN
   PRINT,'QUARTICFIT: Unable to INVERT matrix'
   R=0.
   RETURN,R
ENDIF

U=[SZ,SXZ,SX2Z,SXYZ,SYZ,SY2Z]

R=IM#U

IF N_PARAMS(0) GT 4 THEN YFIT=R(0)+R(1)*X+R(2)*X2+R(3)*XY+R(4)*Y+R(5)*Y2

RETURN,R
END
