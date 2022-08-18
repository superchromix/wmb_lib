FUNCTION LOESS,MAP,WIDTH,NDEG, NOISE, FLOOR=MINVAL, MINPTS=NUMBER, LOG=TYPE,$
 EDGE=SKIP
;+
; NAME:
;	LOESS
;
; PURPOSE:
;	Map-smoothing using the loess method (a local, weighted, polynomial fit
;	in two dimensions). Allows fits only up to degree 2 in X and Y.
;
; CALLING SEUENCE:
; 	smooth_map = LOESS( map, width, ndegree, [Noise, FLOOR = ,MINPTS =,
;			/LOG, EDGE= ] )
;
; INPUT ARGUMENT:
;	MAP = the array to smooth
;	WIDTH = the (square) width of the local neighborhood over which 
;		smoothing is performed.
;	NDEGREE = the degree of the polynomial (in X and Y) used. 1 or 2 
;		allowed.
;
; OUTPUT:
;	SMOOTH_MAP - LOESS returns the smoothed map
;
; OPTIONAL OUTPUT:
;	NOISE = the map of std. dev. (scaled from the median abs. deviation) of 
;	the surface-fit residuals in the neighborhood centered on each pixel. 
;
; OPTIONAL INPUT KEYWORDS:
;	FLOOR = the minimum value allowed. If a pixel < FLOOR it is considered
;		 vacant.  The default FLOOR = 0.0
;	MINPTS= the minimum # occupied pixels per neighborhood. 
;		Default = total/2.  If fewer pixels are occupied, no fit is 
;		made and the value of the central pixel is unchanged. MINPTS 
;		must be > 3 for 1st degree fit and > 6 for 2nd degree fit.
;	LOG  = if set, the LOG of the map is used in the local fits, then 
;		exponentiated before returning (and before calculating noise)
;	EDGE = if set, the edges of the map are not smoothed.
;
; SUBROUTINES CALLED:
;	ROBUST_PLANEFIT, ROB_QUARTICFIT, ROB_MAPFIT, ROBUST_SIGMA, MED. 
;
; NOTE ON USAGE:
;	If too many pixels within a a neighborhood are empty, the central pixel 
;	retains its old value and noise, if desired, set to -1. for that pixel.
;
; METHOD:
;	In each neighborhood: a polynomial (plane or quartic) is fitted robustly
;	(resistant to outliers). Weights are taken as functions of the deviation
;	from this fit (biweights) * a tri-cubic function of the distance of the
;	neighborhood pixels from the center of the neighborhood. Then another
;	surface is fitted using these weights. The edges are obtained from 
;	robust surface fits to a neighborhood of width (WIDTH-2)^2; no 
;	distance weighting is used on the edges.
;
; REVISION HISTORY:
;	Written, H.T. Freudenreich, HSTX, 5/27/93
;	Keywords added by H.F., 3/94
;	Added test on quadrant coverage, HF, 9/94
;-

ON_ERROR,2

EPS=1.0E-20
ITMAX=3

IF KEYWORD_SET(MINVAL) THEN EMPTY=MINVAL ELSE EMPTY=0.
IF KEYWORD_SET(TYPE)   THEN TAKE_LOG=1   ELSE TAKE_LOG=0

DEGMIN = [0,4,7] ; minimum pts needed for 1st, 2nd degree fits.
OFF=FIX(WIDTH)/2
NXY=WIDTH*WIDTH
IF KEYWORD_SET(NUMBER) THEN BEGIN
   MINPIX=NUMBER
   IF MINPIX LT DEGMIN[NDEG] THEN BEGIN
      PRINT,'LOESS: Must have at least',DEGMIN[NDEG],' occupied pixels per neighborhood'
      PRINT,'       Resetting minimum-point-number to this value.'
      MINPIX = DEGMIN[NDEG]
   ENDIF ELSE IF MINPIX GT (NXY-4) THEN BEGIN
      PRINT,'LOESS: Cannot have more than ',NXY-4,' pixels per neighborhood.'
      PRINT,'       Resetting minimum-point-number to this value.'
      MINPIX = NXY-4
   ENDIF
ENDIF ELSE MINPIX=NXY/2 >DEGMIN[NDEG]

IF TAKE_LOG EQ 1 THEN BEGIN
;  Take the log of the map, watching out for negatives and vacant pixels.
   TEMP=MAP
   Q=WHERE( MAP GT EMPTY, COUNT )
   IF COUNT LT MINPIX THEN BEGIN
      PRINT,'LOESS: Too Few Pixels!'
      RETURN,MAP
   ENDIF
   OSET = MIN(MAP[Q])+1.
   MAP[Q]=ALOG(MAP[Q]+OSET)
   Q=WHERE( TEMP LE EMPTY,COUNT )
   EMPTY = 0.
   IF COUNT GT 0 THEN MAP[Q]=-1.
ENDIF

; Set some needed constants:
SYZ=SIZE(MAP)  &  NX=SYZ[1]  &  NY=SYZ[2]
BACKGROUND=MAP
WANT_NOISE = 0
IF N_PARAMS() GT 3 THEN BEGIN
   NOISE=FLTARR(NX,NY)
   NOISE[*,*]=-1.0
   WANT_NOISE = 1
ENDIF

U=FINDGEN(WIDTH)-OFF         
XX=FLTARR(WIDTH,WIDTH)        &  YY=XX
FOR I=0,WIDTH-1 DO XX[*,I]=U  &  FOR I=0,WIDTH-1 DO YY[I,*]=U
X=REFORM(XX,NXY)              &  Y=REFORM(YY,NXY)        
XX=0                          &  YY=0

; Calculate the distance of any pixel from the center:
D = SQRT( X^2+Y^2 )
DMAX = 1.4142*OFF
; Now the "distance" weights:
WD = ( 1.-(D/DMAX)^3 )^3

FOR I=OFF,NX-OFF-1 DO BEGIN
  FOR J=OFF,NY-OFF-1 DO BEGIN
;   Extract the neighborhood:
    ZMAP=MAP[I-OFF:I+OFF,J-OFF:J+OFF]

    Q=WHERE(ZMAP GT EMPTY,N) 

    a1=zmap[off+1:width-1,off+1:width-1]
    a2=zmap[0    :off-1,  off+1:width-1]
    a3=zmap[0    :off-1,  0    :off-1]
    a4=zmap[off+1:width-1,0    :off-1]
    q1=where(a1 gt empty,n1)
    q2=where(a2 gt empty,n2)
    q3=where(a3 gt empty,n3)
    q4=where(a4 gt empty,n4)

;   Are there enough non-zero points?
    if (n ge minpix) and (n1 gt 0) and (n2 gt 0) and (n3 gt 0) and (n4 gt 0) $
    then begin

;    IF N GE MINPIX THEN BEGIN
       Z=REFORM(ZMAP,NXY)    
;      Fit a surface to the neighborhood:
       IF NDEG EQ 1 THEN $
          CC=ROBUST_PLANEFIT(X[Q],Y[Q],Z[Q],ZFIT,SIG,NUMIT=ITMAX)  $
       ELSE BEGIN
          CC=ROB_QUARTICFIT( X[Q],Y[Q],Z[Q],ZFIT,SIG,NUMIT=ITMAX)
;         If the fit was bad, we go down 1 degree.
          IF N_ELEMENTS(CC) EQ 1 THEN $
             CC=ROBUST_PLANEFIT(X[Q],Y[Q],Z[Q],ZFIT,SIG,NUMIT=ITMAX)
       ENDELSE
;      If the fit is still bad, use the median instead:
       IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
          ZFIT=FLTARR(N)
          ZFIT[*]=MED(Z[Q])
       ENDIF

;      Calculate weights from the dispersion of the residuals:
       RESID = Z[Q]-ZFIT
       IF WANT_NOISE EQ 1 THEN BEGIN
          IF (TAKE_LOG EQ 1) THEN BEGIN
             DEV = EXP(Z[Q]) - EXP(ZFIT)
             NOISE[I,J]=ROBUST_SIGMA(DEV,/ZERO)
          ENDIF ELSE NOISE[I,J] = SIG
       ENDIF
       IF SIG GT EPS THEN BEGIN
          R = ( RESID/(6.*SIG) )^2
          RESID=0
          S = WHERE(R GT 1.,COUNT) & IF COUNT GT 0 THEN R[S]=1.
          S=0
          W =(1.-R)^2

;         Now multiply by the "distance" weights:
          W = W*WD[Q]
          WSUM = TOTAL(W)
          IF WSUM LT EPS THEN BEGIN
             PRINT,'LOESS: Bad Fit at pixel ',i,j
             W[*]=1.
          ENDIF ELSE W = W/TOTAL(W)

;         Now fit again!
          IF NDEG EQ 1 THEN CC=PLANEFIT(   X[Q],Y[Q],Z[Q], W,ZFIT ) $
          ELSE BEGIN
             CC=QUARTICFIT( X[Q],Y[Q],Z[Q], W,ZFIT )
             IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
                CC=PLANEFIT(X[Q],Y[Q],Z[Q],W,ZFIT )
                PRINT,'LOESS: Lowered degree of fit at pixel ',i,j
             ENDIF
          ENDELSE
       ENDIF

       IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
          BACKGROUND[I,J]=MED(Z[Q])
          PRINT,'LOESS: No fit possible at pixel ',i,j,'. Using median instead'
       ENDIF ELSE BACKGROUND[I,J]=CC[0]

    ENDIF ELSE PRINT,'LOESS: Failed at ',i,',',j,' due to poor coverage'
  ENDFOR
ENDFOR

IF KEYWORD_SET(SKIP) THEN GOTO,FIN

; Now take care of the edges! Shrink the filter by 2 pixels and fit
; the area.
NWID=(WIDTH-2) > 3
NXY=NWID*NWID
OFF=NWID/2
IF KEYWORD_SET(NUMBER) THEN MINPIX=MINPIX<NXY ELSE MINPIX=(NXY/2)>DEGMIN[NDEG]

; Bottom edge:
FOR I=OFF,NX-OFF-1 DO BEGIN
  Z=MAP[I-OFF:I+OFF,0:NWID-1]
  Q=WHERE(Z GT EMPTY,N) 
  IF N GT MINPIX THEN BEGIN
     ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG )
     IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
        BACKGROUND[I,0:OFF]=ZFIT[OFF,0:OFF]
        IF WANT_NOISE EQ 1 THEN BEGIN
           IF (TAKE_LOG EQ 1) THEN BEGIN
              DEV = EXP(Z[Q]) - EXP(ZFIT)
              NOISE[I,0:OFF]=ROBUST_SIGMA(DEV,/ZERO)
           ENDIF ELSE NOISE[I,0:OFF] = SIG
        ENDIF
     ENDIF
  ENDIF
ENDFOR
; Top edge:
FOR I=OFF,NX-OFF-1 DO BEGIN
  Z=MAP[I-OFF:I+OFF,NY-NWID:NY-1]
  Q=WHERE(Z GT EMPTY,N) 
  IF N GT MINPIX THEN BEGIN
     ZFIT=ROB_MAPFIT( Z,NDEG ,CC,SIG )
     IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
        BACKGROUND[I,NY-OFF-1:NY-1]=ZFIT[OFF,NWID-OFF-1:NWID-1]
        IF WANT_NOISE EQ 1 THEN BEGIN
           IF (TAKE_LOG EQ 1) THEN BEGIN
              DEV = EXP(Z[Q]) - EXP(ZFIT)
              NOISE[I,NY-OFF-1:NY-1]=ROBUST_SIGMA(DEV,/ZERO)
           ENDIF ELSE NOISE[I,NY-OFF-1:NY-1] = SIG
        ENDIF
     ENDIF
  ENDIF
ENDFOR
; Left edge:
FOR I=OFF,NY-OFF-1 DO BEGIN
  Z=MAP[0:NWID-1,I-OFF:I+OFF]
  Q=WHERE(Z GT EMPTY,N) 
  IF N GT MINPIX THEN BEGIN
     ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG  )
     IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
        BACKGROUND[0:OFF,I]=ZFIT[0:OFF,OFF]
        IF WANT_NOISE EQ 1 THEN BEGIN
           IF (TAKE_LOG EQ 1) THEN BEGIN
              DEV = EXP(Z[Q]) - EXP(ZFIT)
              NOISE[0:OFF,I]=ROBUST_SIGMA(DEV,/ZERO)
           ENDIF ELSE NOISE[0:OFF,I] = SIG
        ENDIF
     ENDIF
  ENDIF
ENDFOR
; Right edge:
FOR I=OFF,NY-OFF-1 DO BEGIN
  Z=MAP[NX-NWID:NX-1,I-OFF:I+OFF]
  Q=WHERE(Z GT EMPTY,N) 
  IF N GT MINPIX THEN BEGIN
     ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG  )
     IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
        BACKGROUND[NX-OFF-1:NX-1,I]=ZFIT[NWID-OFF-1:NWID-1,OFF]
        IF WANT_NOISE EQ 1 THEN BEGIN
           IF (TAKE_LOG EQ 1) THEN BEGIN
              DEV = EXP(Z[Q]) - EXP(ZFIT)
              NOISE[NX-OFF-1:NX-1,I]=ROBUST_SIGMA(DEV,/ZERO)
           ENDIF ELSE NOISE[NX-OFF-1:NX-1,I] = SIG
        ENDIF
     ENDIF
  ENDIF
ENDFOR

; Lower-left corner: x
Z=MAP[0:NWID-1,0:NWID-1]
Q=WHERE(Z GT EMPTY,N) 
IF N GT MINPIX THEN BEGIN
  ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG  )
  IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
     BACKGROUND[0:OFF,0:OFF]=ZFIT[0:OFF,0:OFF]
     IF WANT_NOISE EQ 1 THEN BEGIN
        IF (TAKE_LOG EQ 1) THEN BEGIN
           DEV = EXP(Z[Q]) - EXP(ZFIT)
           NOISE[0:OFF,0:OFF]=ROBUST_SIGMA(DEV,/ZERO)
        ENDIF ELSE NOISE[0:OFF,0:OFF] = SIG
     ENDIF
  ENDIF
ENDIF
; Upper-left corner: x
Z=MAP[0:NWID-1,NY-NWID:NY-1]
Q=WHERE(Z GT EMPTY,N) 
IF N GT MINPIX THEN BEGIN
  ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG  )
  IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
     BACKGROUND[0:OFF,NY-OFF-1:NY-1]=ZFIT[0:OFF,OFF:NWID-1]
     IF WANT_NOISE EQ 1 THEN BEGIN
        IF (TAKE_LOG EQ 1) THEN BEGIN
           DEV = EXP(Z[Q]) - EXP(ZFIT)
           NOISE[0:OFF,NY-OFF-1:NY-1]=ROBUST_SIGMA(DEV,/ZERO)
        ENDIF ELSE NOISE[0:OFF,NY-OFF-1:NY-1] = SIG
     ENDIF
  ENDIF
ENDIF
; Upper-RIGHT corner: x
Z=MAP[NX-NWID:NX-1,NY-NWID:NY-1]
Q=WHERE(Z GT EMPTY,N) 
IF N GT MINPIX THEN BEGIN
  ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG  )
  IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
     BACKGROUND[NX-OFF-1:NX-1,NY-OFF-1:NY-1]=ZFIT[OFF:NWID-1,OFF:NWID-1]
     IF WANT_NOISE EQ 1 THEN BEGIN
        IF (TAKE_LOG EQ 1) THEN BEGIN
           DEV = EXP(Z[Q]) - EXP(ZFIT)
           NOISE[NX-OFF-1:NX-1,NY-OFF-1:NY-1]=ROBUST_SIGMA(DEV,/ZERO)
        ENDIF ELSE NOISE[NX-OFF-1:NX-1,NY-OFF-1:NY-1] = SIG
     ENDIF
  ENDIF
ENDIF
; Lower-RIGHT corner: x
Z=MAP[NX-NWID:NX-1,0:NWID-1]
Q=WHERE(Z GT EMPTY,N)
IF N GT MINPIX THEN BEGIN
  ZFIT=ROB_MAPFIT( Z,NDEG,CC,SIG  )
  IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
     BACKGROUND[NX-OFF-1:NX-1,0:OFF]=ZFIT[OFF:NWID-1,0:OFF]
     IF WANT_NOISE EQ 1 THEN BEGIN
        IF (TAKE_LOG EQ 1) THEN BEGIN
           DEV = EXP(Z[Q]) - EXP(ZFIT)
           NOISE[NX-OFF-1:NX-1,0:OFF]=ROBUST_SIGMA(DEV,/ZERO)
        ENDIF ELSE NOISE[NX-OFF-1:NX-1,0:OFF] = SIG
     ENDIF
  ENDIF
ENDIF

FIN:

IF TAKE_LOG EQ 1 THEN BEGIN
   Q=WHERE(BACKGROUND LE EMPTY,COUNT)
   MAP=TEMP
   BACKGROUND=EXP(BACKGROUND)-OSET
   IF COUNT GT 0 THEN BACKGROUND[Q]=MAP[Q]
ENDIF

RETURN,BACKGROUND
END
