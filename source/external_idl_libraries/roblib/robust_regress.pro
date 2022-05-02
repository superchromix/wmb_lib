 FUNCTION ROBUST_REGRESS,X,Y,YFIT,SIG, NUMIT=THIS_MANY, FLOOR=MINVAL
;+
; NAME:
;	ROBUST_REGRESS
;
; PURPOSE:
;	An outlier-resistant linear regression. Calls REGRESS.
;
; CALLING SEQUENCE:
;	COEFF = ROBUST_REGRESS(X,Y, YFIT,SIG, [ NUMIT = , FLOOR = ] )
;
; INPUTS:
;	X = Matrix of independent variable vectors, dimensioned 
;		(NUM_VAR,NUM_PTS), as in REGRESS
;	Y = Dependent variable vector. All Y<MINVAL are ignored.
;
; RETURNS:
;	Function result = coefficient vector. 0th element contains the constant
;	Either floating point or double precision. If the fit failed, COEFF=0.0
;	0.0 is returned; if the fit is dubious, a zero is appended to the 
;	vectors, so that is has NVAR+2 elements.
;
; OPTIONAL OUTPUT PARAMETERS:
;	YFIT = Vector of calculated y's
;	SIG  =  a robust measure of the standard deviation of the residuals
;
; OPTIONAL INPUT KEYWORDS:
;	NUMIT = the max. number of iterations. Default = 20
;	FLOOR = minimum Y value accepted. Y<FLOOR ignored. Default =-1.0e20
;
; RESTRICTIONS:
;	Should have >> NVAR+1 points for the fit to be truly outlier-resistant.
;
; PROCEDURE:
;	This iteratively: calls REGRESS, checks the dispersion of the
;	residuals, and computes weights (biweights). 
;	This is done until the standard deviation, also calculated using 
;	biweights, begins to grow or changes by less than CLOSE_ENOUGH, now set
;	to .03 X [uncertainty of the standard deviation of a normal 
;	distribution]
;
; REVISION HISTORY:
;	Written, H. Freudenreich, STX, 5/19/93
;	H.F. 3/94 --add FLOOR keyword and related modifications.
;-

  ON_ERROR,2

  DEL = 5.0E-07
  EPS = 1.0E-20
  QUESTIONABLE = 0
  IF N_ELEMENTS(THIS_MANY) GT 0 THEN ITMAX=THIS_MANY ELSE ITMAX=20
  IF N_ELEMENTS(MINVAL) GT 0    THEN EMPTY=MINVAL    ELSE EMPTY=-1.0e20

  SYZ = SIZE(X)
  NVAR = SYZ(1)
  NPTS = SYZ(2)

  QGOOD= WHERE( Y GT EMPTY, NGOOD )
  IF NGOOD LT (NVAR+1) THEN BEGIN
     PRINT,'ROBUST_REGRESS: Too Few Points!'
     RETURN,0.
  ENDIF

  CLOSE_ENOUGH = .03*SQRT(.5/(NGOOD-1)) > DEL

; Move X and Y to their centers of gravity:
  X0 = FLTARR(NVAR,NPTS)
  U=X  & V=Y

  FOR I=0,NVAR-1 DO BEGIN
    X0(I)=TOTAL(U(I,QGOOD))/NGOOD
    U(I,*)=U(I,*)-X0(I)
  ENDFOR
  Y0=TOTAL(V(QGOOD))/NGOOD
  V=V-Y0

  W=FLTARR(NPTS)
  W(*)=1.
  QBAD=WHERE( Y LE EMPTY, NBAD )
  IF NBAD GT 0 THEN W(QBAD)=0.
  CC = FLTARR(NVAR+1)

; The initial estimate.
  IF NBAD EQ 0 THEN COEF=REGRESS(U,V,W,YFIT,A0,RELATIVE_WEIGHT=1) $
               ELSE COEF=REGRESS(U,V,W,YFIT,A0) 
  CC=[A0,REFORM(COEF)] 

; The std. deviation of the residuals and weights:
  ISTAT=ROB_CHECKFIT(V(QGOOD),YFIT(QGOOD),EPS,DEL,  SIG,FRACDEV,IGOOD,IW)
  IF ISTAT EQ 0 THEN GOTO,AFTERFIT
  IF IGOOD LT (NVAR+1) THEN BEGIN
     PRINT,'ROBUST_REGRESS: Unable to fit this data. Returning 0'
     RETURN,0.
  ENDIF  
; Incorporate the weights returned by ROB_CHECKFIT:
  W(QGOOD)=IW

; Loop until we converge, or give up:
  SIG_1 = (100.*SIG) < 1.0E20
  DIFF = 1.0E10
  NUM_IT = 0
  WHILE( (DIFF GT CLOSE_ENOUGH) AND (NUM_IT LT ITMAX) ) DO BEGIN
     NUM_IT = NUM_IT + 1
     SIG_2 = SIG_1
     SIG_1 = SIG

     COEF=REGRESS(U,V,W,YFIT,A0) 
     CC=[A0,REFORM(COEF)] 

     ISTAT=ROB_CHECKFIT(V(QGOOD),YFIT(QGOOD),EPS,DEL, SIG,FRACDEV,IGOOD,IW)
     IF ISTAT EQ 0 THEN GOTO,AFTERFIT
     IF IGOOD LT (NVAR+1) THEN BEGIN
        PRINT,'ROBUST_REGRESS: Questionable Fit.'
        QUESTIONABLE = 1
        GOTO,AFTERFIT
     ENDIF  
     W(QGOOD)=IW
     DIFF = (ABS(SIG_1-SIG)/SIG) < (ABS(SIG_2-SIG)/SIG)
  ENDWHILE
;  IF NUM_IT GE ITMAX THEN PRINT,$
;    '   ROBUST_REGRESS did not converge in',ITMAX,' iterations!'

  AFTERFIT:
; Shift the surface back from its center of gravity:
  YFIT = YFIT + Y0
  FOR I=0,NVAR-1 DO CC(0)=CC(0)-CC(I+1)*X0(I)
  CC(0)=CC(0)+Y0
  IF QUESTIONABLE EQ 1 THEN CC=[CC,0.]

  IF NPTS LT N_ELEMENTS(Y) THEN BEGIN
     YFIT=FLTARR(NPTS)
     YFIT(*)=CC(0)
     FOR I=1,NVAR DO YFIT(*)=YFIT(*)+CC(I)*X(I-1,*)
  ENDIF

  RETURN,CC
END
