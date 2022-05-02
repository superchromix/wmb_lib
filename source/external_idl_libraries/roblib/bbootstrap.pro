FUNCTION BBOOTSTRAP,X,NSAMP, FUNCT=FUNCT, SLOW=METHOD
;
;+
; NAME:
;	BBOOTSTRAP
;
; PURPOSE:
;	1-parameter bootstrap calculation of function FUNCT
;
;CALLING SEQUENCE:
;	biwt_means = bbootstrap( data, Num_Samp,[FUNCT='biweight_mean', /SLOW] )
;		OR
;	means = bbootstrap( data, Num_Samp )
;
; INPUT:
;	DATA     = input vector 
;	Num_Samp = the number of bootstrap samples to be taken. The more the 
;		better.  Should be at least 30 if a standard deviation is to 
;		be calculated.  At least 200 if 95% confidence limits are to 
;		be calculated.
;KEYWORD:
;	FUNCT = the name of the function to be applied. If missing, AVERAGE is 
;		assumed.
;	SLOW    If present, the BALANCED bootstrap is performed. This is more
;		accurate, especially for long-tailed distributions, but is also
;		much slower and requires more memory.
; 
; RETURNS:
;         vector of NSAMP bootstrap answers. The mean, standard deviation
;         and confidence intervals can be calculated from this
;
;SUBROUTINES CALLED:
;	'FUNCT'
;	PERMUTE
;
;NOTES:  
;	This program randomly selects values to fill sets of the same size as Y,
;	Then calculates the FUNCT of each. It does this NSAMP times. If the SLOW
;	mode is requested, the balanced bootstrap method is used to obtain the 
;	samples, hence the name BBOOTSTRAP. This method is preferable to that 
;	used in BOOT_MEAN, but does require more virtual memory, and patience.
;
;	The user should choose NSAMP large enough to get a good distribution.
;	The sigma of that distribution is then the standard deviation of the 
;	mean of ANSER.
;	For example, if input X is normally distributed with a standard 
;	deviation of 1.0, the standard deviation of the vector MEAN will be 
;	~1.0/SQRT(N-1), where N is the number of values in X.
;
; WARNING:
;	At least 5 points must be input. The more, the better.
;
; REVISION HISTORY:
;	H.T. Freudenreich, HSTX, 2/95
;-

on_error,2

IF N_ELEMENTS(FUNCT) EQ 0 THEN USE_DEFAULT=1 ELSE USE_DEFAULT=0
ANSER=FLTARR(NSAMP)
N=LONG(N_ELEMENTS(X))

IF KEYWORD_SET(SLOW) THEN BEGIN

;  Concatenate everything into one long vector:
   M=LONG(NSAMP)*N
   BIGGY=FLTARR(M)
   K=N-1L
   I1=0L
   FOR I=0, NSAMP-1 DO BEGIN
     BIGGY(I1:I1+K)=X
     I1=I1+N
   ENDFOR

;  Now scramble it!
;  Select M numbers at random, repeating none.
   BIGGY=BIGGY(PERMUTE(M))

;  Now divide it into NSAMP units and perform the WHATEVER on each.
   ANSER=FLTARR(NSAMP)
   I1=0L
   IF USE_DEFAULT EQ 1 THEN BEGIN
      FOR I=0, NSAMP-1 DO BEGIN
        ANSER(I)=TOTAL( BIGGY(I1:I1+K) )
        I1=I1+N
      ENDFOR
      ANSER=ANSER/N
   ENDIF ELSE BEGIN
      FOR I=0, NSAMP-1 DO BEGIN
        ANSER(I)=CALL_FUNCTION( FUNCT, BIGGY(I1:I1+K) )
        I1=I1+N
      ENDFOR
   ENDELSE

ENDIF ELSE BEGIN

   R0=SYSTIME(1)*2.+1.
   SEEDS=RANDOMU(R0,NSAMP)*1.0E6+1.
   FOR I=0,NSAMP-1 DO BEGIN
;    Update the random number seed.
     R0=SEEDS(I)
;    Uniform random numbers between 0 and N-1:
     PICK=RANDOMU(R0,N)
     R=LONG(PICK*N)
     V=X(R)
     IF USE_DEFAULT EQ 1 THEN ANSER(I)=TOTAL(V)/N ELSE $
                              ANSER(I)=CALL_FUNCTION( FUNCT, V )
   ENDFOR
ENDELSE

RETURN,ANSER
END
