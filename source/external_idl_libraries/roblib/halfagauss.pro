FUNCTION HALFAGAUSS,DATA,PARM,X,Y, NOPLOT=NODOIT,STITLE=SUB
;
;+
; NAME:
;	HALFAGAUSS
;
; PURPOSE:
;	Histogramming a distribution that can be characterized by a Gaussian
;	with one heavy tail and returns the parameters of the Gaussian. Draws
;	the histogram, the Gaussian, and the smoothed residuals. If a plausible
;	fit to a Gaussian cannot be made (typically, if the distribution has a
;	sharp edge or insufficient data near the mode) the parameters of the
;	Gaussian are estimated. In this case an asterisk precedes the label of
;	mean and width drawn on the plot.
;
; CALLLING SEQUENCE: 
;	YFit = HALFAGAUSS( Data, Parm, X, Y, [ /NOPLOT, STITLE ] )
;
; INPUT:
;	DATA = the data to histogram. Should be large. At least 500 points;
;		10,000 is better.
; OUTPUT:
;	YFit - HALFAGAUSS returns the vector of Gaussian fit to the histogram. 
;		If the program fails, it will return a scalar, 0.0.
;
; OPTIONAL OUTPUT:
;	PARM = the parameters of the Gaussian component of the distribution:
;		[height,mode,sigma]
;	X = the locations of bin-centers
;	Y = the locations of the bin-means
;
; OPTIONAL INPUT KEYWORDS: 
;	NOPLOT - if set, a histogram is not drawn
;	STITLE - subtitle, if desired
;
;SUBROUTINES NEEDED: 
;	HISTOGAUSS,AUTOHIST,ROBUST_SIGMA,ROBUST_POLY_FIT,ROB_CHECKFIT,MED,
;	LOWESS, POLY4PEAK,FITAGAUSS and GAUSSFUNC.
;
; REVISION HISTORY:
;	Written, H.T. Freudenreich, HSTX, 5/6/94
;	2/10/95: Changed location of labels. HF
;-

on_error,2

; Histogram:
HISTOGAUSS,DATA,P,U,V,/NOPLOT
N=N_ELEMENTS(U)
IF N LT 30 THEN BEGIN
   PRINT,'HALFAGAUSS: Cannot Determine Distribution Shape Adequately'
   RETURN,0.
ENDIF
DX=U(N/2)-U(N/2-1)
V(0)=V(1)
V(N-1)=V(N-2)
; Start 1 before the first non-zero bin...
Q=WHERE(V GT 0,COUNT)
I1=Q(0)
IF I1 GT 0 THEN I1=I1-1
; ...until 1 after the last non-zero bin:
I2=Q(COUNT-1)
IF I2 LT (N-1) THEN I2=I2+1
X=U(I1:I2)
Y=V(I1:I2)

; Smooth the data and determine the mode.
Q=WHERE( X LT P(1), COUNT1) & Q=WHERE( X GT P(1), COUNT2)
COUNT=COUNT1 < COUNT2
WINDOW=(COUNT/3) > 7
HELP,COUNT1,COUNT2,WINDOW
IF WINDOW MOD 2 EQ 0 THEN WINDOW=WINDOW+1 
LY=ALOG(Y+1.)
Z=LOWESS(X,LY,WINDOW,2)
Q=WHERE(ABS(X-P(1)) GT (2.0*P(2)),COUNT)
IF COUNT GT 0 THEN Z(Q)=0.
ZMAX=MAX(Z)
Q=WHERE(Z EQ ZMAX, COUNT)
ZMAX=EXP(ZMAX)-1.
IF COUNT GT 1 THEN X0=AVG(X(Q)) ELSE X0=X(Q)
X0=X0(0)

; OK, now we have the mode--to the nearest bin. Fit a 4th degree polynomial 
; to the peak to determine it more precisely.
YMAX=MAX( Y( Q(0)-1:Q(0)+1 ) )
TX=X(Q(0)-7:Q(0)+7)  &  TY=Z(Q(0)-7:Q(0)+7)
CC=robust_POLY_FIT(TX,TY,4,TFIT)
EXT=POLY4PEAK(CC)
MODE=EXT(0)  & ZMAX2=EXP(EXT(1))-1.
IF ABS(MODE-X0) GT .1*P(2) THEN MODE=X0
IF ABS(ZMAX2-ZMAX)/ZMAX LT .1 THEN ZMAX=ZMAX2

; Now re-bin the data so that the mode falls at the edge
; of a bin. Bin data on the short side of the distribution,
; then reflect the histogram about the mode. Then fit.

XMEAN=AVG(DATA)
XMED=MED(DATA)
IF XMED LT XMEAN THEN BEGIN  ; tail is on the right
   RIGHT=1
   Q=WHERE(X LE MODE,NB)
   IF NB LT 20 THEN BEGIN ; we want at least 20 bins.
      DX=DX*NB/20.
      NB=20
   ENDIF
   TX=FLTARR(NB)  &  TY=FLTARR(NB)     
   X2=MODE  
   FOR I=NB-1,0,-1 DO BEGIN
     X1=X2-DX
     Q=WHERE((DATA LE X2) AND (DATA GT X1),COUNT)
     TX(I)=X1+DX/2.  &  TY(I)=COUNT
     X2=X2-DX
   ENDFOR
   M=2*NB
   XX=FLTARR(M)  &  YY=XX
   X1=TX         &  Y1=TY
   Y2=REVERSE(Y1)
   YY=[Y1,Y2]
   XX(0:NB-1)=X1
   FOR I=NB,M-1 DO XX(I)=XX(I-1)+DX
;  Now estimate the width:
   Q=WHERE(DATA LE MODE,COUNT) &  D=DATA(Q)
   S=SORT(D) &  D=D(S)
   I1=long(.2*COUNT+.5)  &  SIG1=(MODE-D(I1))/1.282
   I2=long(.5*COUNT+.5)  &  SIG2=(MODE-D(I2))/0.674
   I3=long(.8*COUNT+.5)  &  SIG3=(MODE-D(I3))/0.253
   SIG=(SIG1+SIG2+SIG3)/3.   
ENDIF ELSE BEGIN          ; tail is on the left
   RIGHT=0
   Q=WHERE(X GE MODE,NB)
   IF NB LT 20 THEN BEGIN
      DX=DX*NB/20.
      NB=20
   ENDIF
   TX=FLTARR(NB)  &  TY=FLTARR(NB)     
   X1=MODE  
   FOR I=0,NB-1 DO BEGIN
     X2=X1+DX
     Q=WHERE((DATA LT X2) AND (DATA GE X1),COUNT)
     TX(I)=X1+DX/2.  &  TY(I)=COUNT
     X1=X1+DX
   ENDFOR
   M=2*NB
   XX=FLTARR(M)  &  YY=XX
   X2=TX         &  Y2=TY
   Y1=REVERSE(Y2)
   YY=[Y1,Y2]
   XX(NB:M-1)=X2
   FOR I=NB-1,0,-1 DO XX(I)=XX(I+1)-DX
   Q=WHERE(DATA GE MODE,COUNT) &  D=DATA(Q)
   S=SORT(D) &  D=D(S)
   I1=long(.2*COUNT+.5)  &   SIG1=-(MODE-D(I1))/1.282
   I2=long(.5*COUNT+.5)  &   SIG2=-(MODE-D(I2))/0.674
   I3=long(.8*COUNT+.5)  &   SIG3=-(MODE-D(I3))/0.253
   SIG=(SIG1+SIG2+SIG3)/3.   
ENDELSE

; Now fit:
PARM0=[zMAX,MODE,SIG]
PARM=parm0 
YFIT=FITAGAUSS(XX,YY,PARM)
IF ABS(PARM(0)-ZMAX)/ZMAX GT .1 THEN BEGIN
   PRINT,'HALFAGAUSS: Probable Error in Gaussian Fit. Using Estimate Instead'
   PARM=PARM0
   NOFIT=1
ENDIF ELSE NOFIT=0

YFIT=PARM(0)*EXP(-(X-PARM(1))^2/(2.*PARM(2)^2))

; Plot if so desired:
IF KEYWORD_SET(NODOIT) THEN RETURN,YFIT

WINDOW=(N/10) 
IF WINDOW MOD 2 EQ 0 THEN WINDOW=WINDOW+1 
Z=LOWESS(X,Y-YFIT,WINDOW,2) ; smooth the residuals
z=z>0.
IF KEYWORD_SET(SUB) THEN ST=SUB ELSE ST=' '
PLOT,X,Y,YRAN=[MIN(Y),MAX(Y)*1.15],PSYM=10,SUBTI=ST   ; plot histogram
OPLOT,X,YFIT,line=2         ; over-plot Gaussian
OPLOT,X,Z,line=2            ; over-plot residuals
MU=STRING(PARM(1),'(F10.5)'); annotate
SI=STRING(PARM(2),'(F9.5)')
LABL='Gaussian Mn, Width='+mu+' '+si
IF NOFIT EQ 1 THEN LABL='*'+LABL

x1=x(0)
dy=(!y.crange(1)-!y.crange(0))/20. 
y1=!y.crange(1)-dy
XYOUTS,X1,Y1,LABL,CHARSIZE=.9

TOTGAUSS=TOTAL(YY)
TOT=N_ELEMENTS(DATA)
CTOT=STRING(TOT,'(I7)')
CGAU=STRING(TOTGAUSS,'(I7)')
LABL='# Total, # in Gaussian='+ctot+' '+cgau
XYOUTS,X1,Y1-2*dy,LABL,CHARSIZE=.9
RETURN,YFIT
END
