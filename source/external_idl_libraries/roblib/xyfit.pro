FUNCTION XYFIT,X,Y,W,CCX,CCY,DIST,FX,FY
;+
; NAME:
;	XYFIT
; PURPOSE:
;	Returns the bisecting line of the regressions: Y on X and X on Y.
;	OR the mean of the two lines, with FX and FY the weights.
;	CALLED BY FITXYERRS.
; CALLING SEQUENCE:
;	YFIT = XYFIT( X, Y, W, CCX, CCY, DIST, FX, FY )
; INPUTS:
;	X,Y,W = points and weights
;	FX, FY = weight given to X|Y and Y|X regressions in their average
; OUTPUT:
;	CCX = coefficients of Y on X regression
;	CCY = same for X on Y
;	DIST = perpendicular distance of points to line
; AUTHOR:
;	H.T. Freudenreich
;-

on_error,2

EPS=1.0E-20

SX=TOTAL(W*X) & SY=TOTAL(W*Y) & SXY=TOTAL(W*X*Y) & SXX=TOTAL(W*X*X) 
SYY=TOTAL(W*Y*Y) 

USE_X=1
USE_Y=1
IF N_PARAMS() EQ 8 THEN BEGIN
   IF FX LT .001 THEN USE_X=0
   IF FY LT .001 THEN USE_Y=0
ENDIF

IF USE_Y EQ 1 THEN BEGIN
   ; The Y vs X line.
   D=SXX-SX*SX
   IF ABS(D) LT EPS THEN BEGIN
      PRINT,'XYFIT: Determ=0. No fit possible.'
      RETURN,0.
   ENDIF 
   YSLOP=(SXY-SX*SY)/D      &   YYINT=(SXX*SY-SX*SXY)/D 
   SLOP=YSLOP               &   YINT=YYINT
   IF USE_X EQ 0 THEN BEGIN
      CCX=0.
      CCY=[YINT,SLOP]
      DIST=Y-(YINT+SLOP*X)
      RETURN,CCY
   ENDIF
ENDIF
IF USE_X EQ 1 THEN BEGIN
   ; Get the X vs Y line.
   D=SYY-SY*SY
   IF ABS(D) LT EPS THEN BEGIN
      PRINT,'XYFIT: Determ=0. No fit possible.'
      RETURN,0.
   ENDIF
   TSLOP=(SXY-SY*SX)/D   &   TYINT=(SYY*SX-SY*SXY)/D 
   ; Now invert it to get the form Y=a+bX:
   IF ABS(TSLOP) LT EPS THEN BEGIN
      PRINT,'XYFIT: X vs Y line uninvertable. No fit possible.'
      RETURN,0.
   ENDIF
   XSLOP=1./TSLOP       &   XYINT=-TYINT/TSLOP
   IF USE_Y EQ 0 THEN BEGIN
      CCY=0.
      CCX=[XYINT,XSLOP]
      DIST=X-(TYINT+TSLOP*Y)
      RETURN,CCX
   ENDIF
ENDIF

IF N_PARAMS() EQ 8 THEN BEGIN
;  Calculate a weighted mean line:
   YINT=FX*XYINT+FY*YYINT
   SLOP=FX*XSLOP+FY*YSLOP
ENDIF ELSE BEGIN
;  Calculate the equation of the bisector of the 2 lines:
   IF YSLOP GT XSLOP THEN BEGIN
      A1=YYINT  &  B1=YSLOP  &  R1=SQRT(1.+YSLOP^2)
      A2=XYINT  &  B2=XSLOP  &  R2=SQRT(1.+XSLOP^2)
   ENDIF ELSE BEGIN
      A2=YYINT  &  B2=YSLOP  &  R2=SQRT(1.+YSLOP^2)
      A1=XYINT  &  B1=XSLOP  &  R1=SQRT(1.+XSLOP^2)
   ENDELSE
   YINT=(R1*A2+R2*A1)/(R1+R2)
   SLOP=(R1*B2+R2*B1)/(R1+R2)
ENDELSE

R=SQRT(1.+SLOP^2)  & IF YINT GT 0. THEN R=-R
U1=SLOP/R  & U2=-1./R  &  U3=YINT/R 
DIST=U1*X+U2*Y+U3  ; = orthog. distance to line

CC=[YINT,SLOP]
CCX=[XYINT,XSLOP]  & CCY=[YINT,YSLOP]

RETURN,CC
END
