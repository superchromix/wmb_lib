FUNCTION TWOLINE,U,V,WX,WY

;+
; Part of FITXYERRS.
;-

EPS=1.0E-20
N=N_ELEMENTS(U)
IF WY GT WX THEN BEGIN
     S=SORT(U)
     TX=U(S)  & TY=V(S)
     X1=MED(TX(0:.5*N))  & X2=MED(TX(.5*N+1:N-1))
     Y1=MED(TY(0:.5*N))  & Y2=MED(TY(.5*N+1:N-1))
     IF ABS(X1-X2) LT EPS THEN BEGIN
         PRINT,'FITXYERRS: Initial Fit Failed. Range of X = 0.'
         RETURN,0.
     ENDIF
     SLOP=(Y1-Y2)/(X1-X2)
     YINT=Y1-SLOP*X1
ENDIF ELSE BEGIN            ; X on Y
     S=SORT(V)
     TX=V(S)  & TY=U(S)
     X1=MED(TX(0:.5*N))  & X2=MED(TX(.5*N+1:N-1))
     Y1=MED(TY(0:.5*N))  & Y2=MED(TY(.5*N+1:N-1))
     IF ABS(X1-X2) LT EPS THEN BEGIN
        PRINT,'FITXYERRS: Initial Fit Failed. Range of Y = 0.'
        RETURN,0.
     ENDIF
     TSLOP=(Y1-Y2)/(X1-X2)
     TYINT=Y1-TSLOP*X1
     IF ABS(TSLOP) LT EPS THEN TSLOP=EPS
     SLOP=1./TSLOP
     YINT=-TYINT/TSLOP
ENDELSE

RETURN,[YINT,SLOP]
END

FUNCTION FITXYERRS, Xin,Yin,EXin,EYin, N_SAMPLE,YinT,SLOP,SYinT,SSLOP,$
   NONROBUST=FITTYPE, TOLERANCE=SMALLENUF
;
;+
; NAME:
;	FITXYERRS
;
; PURPOSE:
;	Linear fit to data in which there are errors in both Y and X, and 
;	possibly outliers or points with true errors much larger than the 
;	measurement errors.   It is outlier-resistant but not as resistant as 
;	ROBUST_LINEFIT.   Uncertainties are calculated using the bootstrap 
;	method.   
;
; CALLING SEQUENCE:
;	Coeff = FITXYERRS( X, Y, Ex, Ey, N_sample, [ Yint, Slope, Sig_Yint, 
;				Sig_Slope, /NONROBUST, Tolerance = ] )
;
; INPUT ARGUMENT:
;	X = Input x vector
;	Y = Input y vector
;	Ex= vector of X measurement errors
;	Ey= the vector of Y measurement errors
;	N_SAMPLE = the number of bootstrap samples. 50 to 100 usually sufficient
;			If N_SAMPLE = 1, standard errors are not returned.
;
; OPTIONAL INPUT KEYWORDS:
;	NONROBUST -   If set, "robustness" weights are not calculated.
;	TOLERANCE -   When the scatter about the fitted line, weighted by
;		measurement errors, changes by less than this fraction,
;		the fit is considered to have converged. Default=.0001
;
; OUTPUT:
;	COEFF = array of coefficients. Dimensions=(NDEG+1,N_SAMPLE)
;		First dimension in the order A0, A1
;
; OPTIONAL OUTPUT ARGUMENT:
;	Yint = Y intercept (average of COEFF(0,*))
;	Slop = slope (average of (COEFF(1,*))
;	Sig_Yint = standard error of Y intercept (std. dev. of COEFF(0,*))
;	Sig_Slop = standard error of slope (std. dev. of COEFF(1,*))
;
; METHOD:  
;	Convert to standardized variables, calculate Y vs X and X vs Y fits,
;	take a weighted mean of the two lines, the weights being a function of
;	slope. The weights of the input points are functions of their 
;	uncertainties and perpendicular distance to the fitted line. This is 
;	an iterative procedure.   To the author's knowledge, neither this nor 
;	a similar method has ever been, or may ever be, published.
;
; WARNING:
;	At least 6 points must be input. It is better to have at least 10.
;	It is best to have a large number.
;	For large datasets, try it out with N_SAMPLE of 1 first to see how long 
;	it takes.
;
; SUBROUTINES CALLED:
;	XYFIT, MED (to calculate a median)
;
; REVSION HISTORY:
;	Written,  H.T. Freudenreich, HSTX, 6/94. 
;	Corrected serious bug in computation of the Y intercept 
;		H.T. Freudenreich/Landsman HSTX, 11/95
;	
;-

ON_ERROR,2

ITMAX =  20
EPS   = 1.0E-22

N=N_ELEMENTS(Xin)

IF N LT 6 THEN BEGIN
   PRINT,'FITXYERRS: Too few points! Returning 0'
   RETURN,0.
ENDIF

IF KEYWORD_SET(SMALLENUF) THEN CONVERGENCE=SMALLENUF ELSE CONVERGENCE=.0001

; Shift the coordinate system:
X0=TOTAL(Xin)/N  &  Y0=TOTAL(Yin)/N
X=Xin-X0         &  Y=Yin-Y0
EX=EXin          &  EY=EYin

R0=SYSTIME(1)-DOUBLE(7.)  ;=random number seed

; Now convert to carefree variables by dividing by the median measurement
; errors. (If the errors are heteroscedastic, they are not quite as carefree.)

XERR = MED(EX)+EPS  &  YERR = MED(EY)+EPS
X=X/XERR            &  Y=Y/YERR
EX=EX/XERR          &  EY=EY/YERR

; Now the errors are roughly the same (exactly, if the variances are fixed).
; The slope will determine the relative weights of the Y|X and X|Y regressions.
; Initially, we don't know the slope, and so we give the most weight to the
; variable with the largest range.
AX=MED(ABS(X))      &  AY=MED(ABS(Y))
WX=AY^2/(AX^2+AY^2) &  WY=1.-WX       ; = initial weights of X|Y and Y|X fits.

; Now perform the calculation N_SAMPLE times.

COEFF=FLTARR(2,N_SAMPLE)
NGOOD = -1

; Get some randomn number seeds:
R0=SYSTIME(1)*2.+1.
SEEDS=RANDOMU(R0,N_SAMPLE)*1.0E6+1.

FOR L=0,N_SAMPLE-1 DO BEGIN

  IF L EQ 0 THEN BEGIN 
;    First time, use the actual data:
     U=X  & V=Y  & Eu=Ex  & Ev=Ey
  ENDIF ELSE BEGIN
     R=SEEDS(L)
;    Uniform random numbers between 0 and N-1:
     PICK=RANDOMU(R,N)
     R=LONG(PICK*N)
     U=X(R) & V=Y(R) & Eu=Ex(R) & Ev=Ey(R)
  ENDELSE

; Fit Y vs X and X vs Y, iteratively:
  NUMIT=0
  MIDDIST=1.0E37

; For the initial fit, divide the data into 2 groups and calculate the line
; through them. 
  CC=TWOLINE(U,V,WX,WY)

; The "robustness" weights are functions of distance from the fitted line,
; so calculate that:
  R=SQRT(1.+CC(1)^2)  & IF CC(0) GT 0. THEN R=-R
  U1=CC(1)/R  &  U2=-1./R  &  U3=CC(0)/R 
  DIST=U1*U+U2*V+U3  ; = orthog. distance to line

; Now iterate:
  FITAGAIN:
  NUMIT=NUMIT+1

  IF N_ELEMENTS(CC) EQ 2 THEN BEGIN
;    The weights will be a product of a function of the measurement errors 
;    and, for outlier-resistance, a function of orthogonal distance to the line.
;    Measurement-error weights: For the Y on X fit, the weights should be 
;    1/(Ey^2+b^2 Ex^2), where b is the slope of Y vs X. For X on Y: 
;    1/(Ex^2+Ey^2/b^2). Since we are doing both, and want to treat X and Y 
;    symmetrically, take the weighted sum. The weights are functions of
;    slope. 
                                       SLOP=CC(1)^2 > 1.0E-18  ; slope^2
     DY= Ev^2 + CC(1)^2*Eu^2 + eps  &  DX= Eu^2 + Ev^2/SLOP + eps

;    The relative weights of the Y|X and X|Y fits:
     FY = 1./(1.+CC(1)^2)         &  FX = 1.-FY  

;    Now the "measurement error" weights:
     WS=  1./DY * FY + 1./DX * FX 

;    Note:
;    (When slope==>0,  WS==>1/Ey^2         (Ex is irrelevant)
;     When slope==>oo, WS==>1/Ex^2         (Ey is irrelevant)
;     When slope==>1,  WS==>1/(Ex^2+Ey^2)  (X and Y indistinguishable))

     IF KEYWORD_SET(FITTYPE) THEN BEGIN
;       Don't need to calculate robustness weights or check for convergence.
;       Fit once and move on to the next set, if there is one.
        W=WS/TOTAL(WS)
        CC=XYFIT(U,V,W,CCX,CCY,DIST,FX,FY) 
        GOTO, DONE
     ENDIF

;    From this calculate an "adjusted" distance (distance/measurement error)
;    to be used in the robustness weights. 
     DIST=ABS(DIST)/SQRT( DY*FY + DX*FX )   ; = adjusted distance
     DX=0 & DY=0

;    Points < 1 *(mid-averaged adjusted distance from the fit line) are 
;    given equal distance weights. Beyond 1 unit of distance the weights 
;    decrease as 1/distance^2. Beyond 4 units, weights are set to 0.0.
;
;    Why the mid-averaged distance? It is more sensitive than the median but 
;    has a lower breakdown point: 25% vs 50%.

     D=DIST(SORT(DIST))
     OLDMIDDIST=MIDDIST
     MIDDIST=AVG(D(.25*N:.75*N))/.70 ; = 1 sigma if Gaussian
     IF MIDDIST LT EPS THEN BEGIN
        PRINT,'FITXYERRS: Weird data. Fit attempt failed'
        CC=0.
        GOTO,DONE
     ENDIF
     Q=WHERE(DIST LT MIDDIST,COUNT) & IF COUNT GT 0 THEN DIST(Q)=MIDDIST
     W=WS/DIST^2
     Q=WHERE(DIST GT (4.*MIDDIST),COUNT) & IF COUNT GT 0 THEN W(Q)=0.
     SUMW = TOTAL(W)
     IF SUMW EQ 0. THEN BEGIN
        PRINT,'FITXYERRS: Weird data. Fit attempt failed'
        CC=0.
        GOTO,DONE
     ENDIF
     W=W/SUMW

     IF NUMIT GT 1 THEN BEGIN
        OLDCC=CC
        DIFF=ABS(OLDMIDDIST-MIDDIST)/MIDDIST
        IF DIFF LT CONVERGENCE THEN GOTO,DONE
        IF MIDDIST GT OLDMIDDIST THEN BEGIN
           CC=OLDCC
           GOTO,DONE
        ENDIF
     ENDIF 
     IF NUMIT EQ ITMAX THEN GOTO,DONE
     IF MIDDIST LT EPS THEN GOTO,DONE

;    Fit again:                            
     OLDCC=CC
     CC=XYFIT(U,V,W,CCX,CCY,DIST,FX,FY) 

     GOTO,FITAGAIN
  ENDIF

  DONE:
; If the fit was successful, store the coefficients:
  IF (N_ELEMENTS(CC) EQ 2) THEN BEGIN 
     NGOOD=NGOOD+1
     COEFF(*,NGOOD)=CC
  ENDIF
ENDFOR

NGOOD = NGOOD+1
IF NGOOD LT N_SAMPLE THEN BEGIN
   PRINT,'FITXYERRS: Some samples rejected.'
   COEFF=COEFF(*,0:NGOOD-1)
ENDIF
; Take out the scale factors:
COEFF(0,*)=COEFF(0,*)*YERR
COEFF(1,*)=COEFF(1,*)*YERR/XERR

; Shift X and Y back to the original coordinate system and calculate the
; y-intercept, slope and their standard errors.

 SLOP = TOTAL(COEFF(1,*))/NGOOD
 COEFF(0,*) = COEFF(0,*) + Y0 - COEFF(1,*)*X0    ;Bug corrected 11/95
 YINT = TOTAL(COEFF(0,*))/NGOOD

 IF NGOOD GT 2 THEN BEGIN
   SYINT = STDEV(COEFF(0,*))
   SSLOP = STDEV(COEFF(1,*))
 ENDIF ELSE BEGIN
   SYINT=0.
   SSLOP=0.
 ENDELSE

RETURN,COEFF
END
