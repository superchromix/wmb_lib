PRO BOOT_MEAN, Y, N_SAMPLE, MEAN, ROBUST=whatever
;
;+
; NAME:
;	BOOT_MEAN
;
; PURPOSE:
;	Calculate the Bootstrap Mean. (Also see BBOOTSTRAP.)
;
; CALLING SEQUENCE:
;	BOOT_MEAN, y, N_Sample, Mean, [ /ROBUST ]
; INPUT:
;	Y = vector to average
;	N_SAMPLE = the number of bootstrap samples
; 
; OUTPUT:
;	MEAN = vector of N_SAMPLE means
;
; OPTIONAL INPUT KEYWORD:
;	ROBUST - If this argument is present, an iterative biweighted mean is 
;		returned
;
; SUBROUTINES CALLED:
;	BIWEIGHT_MEAN, ROBUST_SIGMA, MED
;
;NOTE:  
;	This program randomly selects values to fill sets of the same size as Y,
;	Then calculates the mean of each. It does this N_SAMPLE times.
;
;	The user should choose N_SAMPLE large enough to get a good distribution.
;	The sigma of that distribution is then the standard deviation of the 
;	mean of MEAN.
;	For example, if input Y is normally distributed with a standard 
;	deviation of 1.0, the standard deviation of the vector MEAN will be 
;	~1.0/SQRT(N-1), where N is the number of values in Y.
;
; WARNING:
;	At least 5 points must be input. The more, the better.
; REVISION HISTORY:
;	Written,   H.T. Freudenreich, HSTX, ?/92
;-

 IF KEYWORD_SET(WHATEVER) THEN BIWT=1 ELSE BIWT=0

 N=N_ELEMENTS(Y)

 IF N LT 5 THEN BEGIN
   PRINT,'BOOT_MEAN: Too few points! Setting N_SAMPLE to zero'
   N_SAMPLE = 0
   RETURN
 ENDIF

 MEAN=FLTARR(N_SAMPLE)

 R0=SYSTIME(1)*2.+1.
 SEEDS=RANDOMU(R0,N_SAMPLE)*1.0E6+1.

FOR L=0,N_SAMPLE-1 DO BEGIN
; Get the random number seed:      FOR VMS!
  R=SEEDS(L)
; Uniform random numbers between 0 and N-1:
  PICK=RANDOMU(R,N)
  R=FIX(PICK*N)
  V=Y(R)
  IF BIWT EQ 0 THEN MEAN(L)=TOTAL(V)/N ELSE MEAN(L)=BIWEIGHT_MEAN(V)
ENDFOR

RETURN
END
