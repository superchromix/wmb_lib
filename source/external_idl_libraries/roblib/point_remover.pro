FUNCTION POINT_REMOVER,MAP,WIDTH,SIGMA_MULT,ITMAX, BOTH=WHATEVER, FLOOR=MINV
;+
; NAME:
;	POINT_REMOVER
;
; PURPOSE:
;	Remove isolated HIGH SIGNAL/NOISE elements from a 2D array, replacing
;	them with a local median. This routine iterates until convergence or
;	a user-supplied maximum number. This is NOT a low-pass filter. Only
;	points passing the S/N cut are affected. 
;
; CALLING SEQUENCE:
;	NewMap = POINT_REMOVER( Map, Width, Sigma_Mult, ItMax,[ /BOTH, FLOOR= ])
;
; INPUT ARGUMENT:
;	MAP = the array to de-point
;	WIDTH = the width of the square moving neighborhood centered on the 
;		pixel in question. If half the pixels within this neighborhood
;		 are vacant, nothing is done.
;
; OPTIONAL INPUT ARGUMENT:
;	SIGMA_MULT = the number of standard deviations by which a pixel must 
;		exceed the local background for it to be replaced. DEFAULT = 2.0
;	ITMAX = the maximum number of iterations. DEFAULT = 20
;
; OPTIONAL INPUT KEYWORDS:
;	BOTH - if set, the absolute value of the difference between a pixel and 
;		its neighborhood is used, so that low pixels may also be 
;		replaced. Else, only + high points will be replaced.
;	FLOOR = the value representing an empty pixel. Default = 0.0
;
; OUTPUT:
; 	POINT_REMOVER returns the array, with point sources removed.
;
; REVISION HISTORY:
;	Written, H.T. Freudenreich, HSTX, ?/90 or 91
;	HF, 3/94, to include FLOOR and USE_ABS keywords
;-

; Fill in default parameters:
IF N_PARAMS() LT 4 THEN ITMAX=20
IF N_PARAMS() LT 3 THEN SIGMA_MULT=2.0
IF N_PARAMS() LT 2 THEN WIDTH=7

IF KEYWORD_SET(WHATEVER) THEN USE_ABS=1 ELSE USE_ABS=0
IF KEYWORD_SET(MINV)     THEN EMPTY=MINV ELSE EMPTY=0.0

; Set some needed constants:
SYZ=SIZE(MAP)
NX=SYZ(1)
NY=SYZ(2)
OFF=FIX(WIDTH)/2
MINPIX = WIDTH*WIDTH/2 ; the minimum size of the neighborhood

AMAP    = MAP
ITNUM   = 0

again:
ITNUM = ITNUM + 1
NUM_REJ = long(0)
TEMP = AMAP
FOR I=OFF,NX-OFF-1 DO BEGIN
  FOR J=OFF,NY-OFF-1 DO BEGIN
;   Extract the neighborhood:
    A=TEMP(I-OFF:I+OFF,J-OFF:J+OFF)
;   Are there enough non-zero points?
    Q=WHERE(A GT EMPTY,N) 
    IF N GT MINPIX THEN BEGIN
       A=A(Q)
;      Sort the data, get the median and interquartile range:
       A=A(SORT(A))
       N1=N/4
       N3=3*N1
       N2=N/2
;      The median:
       IF N MOD 2 NE 0 THEN BCKGD=A(N2) ELSE BCKGD=.5*(A(N2-1)+A(N2))
;      The interquartile range:
       SIGMA=(A(N3)-A(N1))/1.35
       IF SIGMA LT EMPTY THEN SIGMA=TOTAL(ABS(A-BCKGD))/.8/N
       HITE= TEMP(I,J)-BCKGD
       IF USE_ABS EQ 1 THEN HITE=ABS(HITE)
       IF HITE GT (SIGMA_MULT*SIGMA) THEN BEGIN
          AMAP(I,J) = BCKGD
          NUM_REJ = NUM_REJ + long(1)
       ENDIF
    ENDIF
  ENDFOR
ENDFOR
PRINT,'Iteration number ',ITNUM,'. Rejected ',NUM_REJ,' pixels.'
IF (NUM_REJ GT 1) AND (ITNUM LT ITMAX) THEN GOTO,AGAIN
       
RETURN,AMAP
END
