FUNCTION  ROB_QUARTICFIT,XX,YY,ZZ,ZFIT,SIG, NUMIT=THIS_MANY,FLOOR=MINVAL
;+
; NAME:
;	ROB_QUARTICFIT
;
; PURPOSE:
;	An outlier-resistant fit to Z = a + bX + cX^2 + dY +eY^2 + fX*Y.
;
; CALLING SEQUENCE:
;	COEFF = ROB_QUARTICFIT(X, Y, Z, ZFIT, SIG, [NUMIT = , FLOOR = ] )
;
;INPUTS:
;	X = Independent variable vector. DOUBLE-PRECISION RECOMMENDED
;	Y = Second independent variable vector
;	Z = Dependent variable vector
;
; RETURNS:
;	Function result = coefficient vector [a,b,c,d,e]
;	Either floating point or double precision.
;
; OPTIONAL INPUT KEYWORDS:
;	NUMIT = the number of iterations permitted. Default = 20
;	FLOOR = the minimum Z value allowed. Z<FLOOR are ignored. 
;		Default=-1.0e20
;
; OPTIONAL OUTPUT PARAMETERS:
;	ZFIT = Vector of calculated y's
;	SIG  = the robust analog of the std. deviation of the residuals
;
; RESTRICTIONS:
;	This routine works best when the number of points >> 6. Minimum=6
;
; PROCEDURE:
;	For the initial estimate, a regular least-squares fit is performed.
;	Bisquare ("Tukey's Biweight") weights are then calculated, using 
;	a limit of 6 outlier-resistant standard deviations.
;	This is done iteratively until the standard deviation, also calculated
;	using biweights, changes by less than CLOSE_ENOUGH, now set to
;	.03 X [uncertainty of the standard deviation of a normal distribution]
;
; REVISION HISTORY:
;	Written, H. Freudenreich, STX, 5/19/93. 
;	Minor modifications by H.F. 3/94
;
;-

  ON_ERROR,2

  EPS = 1.0E-20
  DEL = 5.0E-07
  MINPTS = 6

  IF N_ELEMENTS(THIS_MANY) GT 0 THEN ITMAX=THIS_MANY ELSE ITMAX=20
  IF N_ELEMENTS(MINVAL) GT 0    THEN EMPTY=MINVAL    ELSE EMPTY=-1.0e20

  NUMINPUT = N_ELEMENTS( XX )
  Q=WHERE( ZZ GT EMPTY, NPTS )
  IF NPTS LT MINPTS THEN BEGIN
     PRINT,'ROB_QUARTICFIT: No Fit Possible'
     RETURN,0.
  ENDIF

  X=XX(Q) & Y=YY(Q) & Z=ZZ(Q)

  CLOSE_ENOUGH = .03*SQRT(.5/(NPTS-1)) > DEL

; The initial estimate.

; Settle for least-squares:
  CC = QUARTICFIT( X, Y, Z, 0., ZFIT )
; If this doesn't work, fit a plane for the initial estimate:
  IF N_ELEMENTS(CC) LT 6 THEN CC=PLANEFIT( X,Y,Z,0.,ZFIT)
; If THIS doesn't work, give up!
  IF N_ELEMENTS(CC) LT 3 THEN BEGIN
     print,'ROB_QUARTICFIT: No Fit Possible'
     RETURN,0.
  ENDIF

; Get the standard deviation of the residuals, etc...
  ISTAT=ROB_CHECKFIT(Z,ZFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W)
  IF ISTAT EQ 0 THEN GOTO,AFTERFIT
  IF NGOOD LT MINPTS THEN BEGIN
     print,'ROB_QUARTICFIT: No Fit Possible'
     RETURN,0.
  ENDIF

; Loop until we converge, or give up:
  NUM_IT = 0
  DIFF = 1.0E10
  SIG_1= (100.*SIG) < 1.0E20
  WHILE( (DIFF GT CLOSE_ENOUGH) AND (NUM_IT LT ITMAX) ) DO BEGIN
     NUM_IT = NUM_IT + 1
     SIG_2 = SIG_1
     SIG_1 = SIG
   ; Re-fit:
     CC= QUARTICFIT( X, Y, Z, W, ZFIT )
     IF N_ELEMENTS(CC) EQ 1 THEN GOTO,AFTERFIT
     ISTAT=ROB_CHECKFIT(Z,ZFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W)
     IF ISTAT EQ 0 THEN GOTO,AFTERFIT
     IF NGOOD LT MINPTS THEN BEGIN
        PRINT,'ROB_QUARTICFIT: Fit Questionable'
        CC=[CC,0.]
        GOTO,AFTERFIT
     ENDIF
     DIFF = (ABS(SIG_1-SIG)/SIG) < (ABS(SIG_2-SIG)/SIG)
  ENDWHILE
;  IF NUM_IT GE ITMAX THEN PRINT,$
;    '   ROB_QUARTICFIT did not converge in 20 iterations!'

  AFTERFIT:

  IF N_ELEMENTS(CC) GT 1 THEN BEGIN
     IF NUMINPUT GT NPTS THEN $
        ZFIT = CC(0)+CC(1)*XX+CC(2)*XX^2+CC(3)*XX*YY+CC(4)*YY+CC(5)*YY^2
             ;   a  +    bX  +   cX^2   +    dXY    +   eY   +    fY^2
  ENDIF ELSE PRINT,'ROB_QUARTICFIT: No fit possible'

  RETURN,CC
END
