FUNCTION ROBUST_CORR,X,Y
;
;+
; NAME:
;	ROBUST_CORR
;
; PURPOSE:
;	Derive an outlier-resistant measure of the correlation coefficient of
;	variables X and Y.
;
; CALLING SEQUENCE:
;	Correl_coeff = ROBUST_CORR( X, Y )
;
; INPUT ARGUMENTS:
;	X = Vector of quantity X
;	Y = Vector of quantity Y
;
; RETURNS:
;	Estimate of correlation coefficient. In the absence of outliers this
;	equals the true correlation coefficient.
;
; CALLS:
;	Function ROBUST_LINEFIT to perfom an outlier-resistant fit. 
;	Function ROBUST_SIGMA to calculate a resistant analog to the
;	standard deviation. 
;	Also: ROB_CHECKFIT, MED
;
; REVISION HISTORY:
;	Written,   H. Freudenreich, STX, 8/90
;-


; First, perform an outlier-resistant linear fit:
CC=ROBUST_LINEFIT(X,Y)
U = Y-CC(1)*X

; Now calculate a resistant measure of dispersion for both variables:
SSX = ROBUST_SIGMA(X)
SSU = ROBUST_SIGMA(U)

; The correlation coefficient:
N=N_ELEMENTS(X)
CORRX = SSX^2*N
CORRU = SSU^2*N
CORR = 1./SQRT( 1.+CORRU/(CC(1)*CC(1)*CORRX) )
CORR = CORR*CC(1)/ABS(CC(1))

RETURN,CORR
END
