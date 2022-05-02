FUNCTION  ROBUST_PLANEFIT,XX,YY,ZZ,ZFIT,SIG, NUMIT=THIS_MANY,FLOOR=MINVAL
;+
;NAME:
;	ROBUST_PLANEFIT
;
;PURPOSE:
;	An outlier-resistant fit to Z = a + bX + cY
;
; CALLING SEQUENCE:
;	COEFF = ROBUST_PLANEFIT(X,Y,Z, ZFIT,SIG)
;
; INPUTS:
; X = Independent variable vector. DOUBLE-PRECISION RECOMMENDED
; Y = Second independent variable vector
; Z = Dependent variable vector
;
;OUTPUTS:
; Function result = coefficient vector [a,b,c,d,e]
; Either floating point or double precision.
;
;OPTIONAL OUTPUT PARAMETERS:
; ZFIT = Vector of calculated y's
; SIG  = the std. dev. of the residuals
;
;KEYWORDS:
; NUMIT = the number of iterations allowed. Default = 20.
; FLOOR = the minimum value accepted. Z < FLOOR is ignored. Default=-1.0e20
;
;RESTRICTIONS:
; This routine works best when the number of points >> 6. Minimum=6
;
;PROCEDURE:
; For the initial estimate, a regular least-squares fit is performed.
; Bisquare ("Tukey's Biweight") weights are then calculated and the
; fit it iterated until convergence (see ROB_CHECKFIT).
;
;AUTHOR: H. Freudenreich, HSTX, 5/19/93. 
; Minor modifications: H.F., 3/94
;-

  ON_ERROR,2

  EPS = 1.0E-20
  DEL = 5.0E-07
  MINPTS = 3

  IF N_ELEMENTS(THIS_MANY) GT 0 THEN ITMAX=THIS_MANY ELSE ITMAX=20
  IF N_ELEMENTS(MINVAL)    GT 0 THEN EMPTY=MINVAL    ELSE EMPTY=-1.0e20

  NUMINPUT = N_ELEMENTS( XX )
  Q=WHERE( ZZ GT EMPTY, NPTS )
  IF NPTS LT MINPTS THEN BEGIN
     MESSAGE,' No Fit Possible'
     RETURN,0.
  ENDIF
  X=XX(Q) & Y=YY(Q) & Z=ZZ(Q)

  CLOSE_ENOUGH = .03*SQRT(.5/(NPTS-1)) < DEL

; The initial estimate.

; Settle for least-squares:
  CC = PLANEFIT( X, Y, Z, 0., ZFIT )

; Get the standard deviation of the residuals.
  ISTAT = ROB_CHECKFIT( Z,ZFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W)
  IF ISTAT EQ 0 THEN GOTO,AFTERFIT

  IF NGOOD LT MINPTS THEN BEGIN
     PRINT,'ROBUST_PLANEFIT: No Fit Possible'
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
;    Re-fit:
     CC= PLANEFIT( X, Y, Z, W, ZFIT )
     ISTAT = ROB_CHECKFIT( Z,ZFIT,EPS,DEL,  SIG,FRACDEV,NGOOD,W)
     IF ISTAT EQ 0 THEN GOTO,AFTERFIT
     IF NGOOD LT MINPTS THEN BEGIN
        PRINT,'ROBUST_PLANEFIT: Fit Questionable'
        CC=[CC,0.]
        GOTO,AFTERFIT
     ENDIF
     DIFF = (ABS(SIG_1-SIG)/SIG) < (ABS(SIG_2-SIG)/SIG)
  ENDWHILE
;  IF NUM_IT GE ITMAX THEN PRINT,$
;    '   ROBUST_PLANEFIT did not converge in 20 iterations!'

  AFTERFIT:

  IF N_ELEMENTS(CC) GT 1 THEN BEGIN
     IF NUMINPUT GT NPTS THEN ZFIT = CC(0)+CC(1)*XX+CC(2)*YY
  ENDIF ELSE PRINT,'ROBUST_PLANEFIT: No fit possible'

  RETURN,CC
END
