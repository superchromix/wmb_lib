PRO ROBUST_BINDATA,NBINS,XIN,YIN,X1,X2,X,Y,S,BINHITS,itype
;
;+
; NAME:
;	ROBUST_BINDATA
;
; PURPOSE: 
;	Groups data into NBINS bins of equal size, and finds the robust mean of
;	each bin. If there are enough pts in a bin, a line is fitted to the 
;	data.   The bootstrap method is used to determine the uncertainty of 
;	the bin averages.
;
; CALLING SEQUENCE:
;	ROBUST_BINDATA, NBINS, XIN, YIN, X1, X2, X, Y, S, BINHITS,itype
; INPUT:
;	NBINS = number of bins
;	XIN   = the input X values
;	YIN   = the input Y values
;	X1    = the low end of the range of X
;	X2    = the high end of the range of X
;	ITYPE (OPTIONAL) = use logarithmically equal bin-widths if present
;
; OUTPUTS:
;	X       = the X values of the bins
;	Y       = the y values (=-100000 if a bin is empty)
;	S       = the robust standard deviations of the bins
;	BINHITS = the number of entries per bin.
;
; NOTES:   
;
;	If a bin has fewer than 5 entries, a biweighted mean of Y is
;	calculated; X is weighted by the same weights, so the X value of the bin
;	is not necessarily bin-center. If 5 points or more, a robust line is
;	fitted to the data, and evaluated at bin-center.
;
; REVISION HISTORY:
;	Written, H.T. Freudenreich, Hughes STX, 12/3/92
;-

on_error,2
X=FLTARR(NBINS)
Y=FLTARR(NBINS)
S=FLTARR(NBINS)
BINHITS=LONARR(NBINS)
ITYPE=0

IF N_PARAMS() GT 9 THEN BEGIN
   ITYPE = 1
   IF X1 LE 0. THEN BEGIN
      PRINT,'ROBUST_BINDATA: For Log Scale, Xmin > 0.!'
      RETURN
   ENDIF
   DX = EXP( ALOG(X2/X1)/NBINS )
ENDIF ELSE DX = (X2-X1)/NBINS

NUM = -1
FOR I=0,NBINS-1 DO BEGIN
  IF ITYPE EQ 0 THEN X2=X1+DX ELSE X2=X1*DX
  NUM=NUM+1
  Q=WHERE((XIN GE X1) AND (XIN LT X2),COUNT)
  BINHITS(NUM)=COUNT
  S(NUM) = 0.
  X(NUM) = .5*(X1+X2)

  IF COUNT EQ 0 THEN BEGIN
     Y(NUM) = -1000000.
  ENDIF ELSE IF COUNT EQ 1 THEN BEGIN
     X(NUM) = XIN(Q(0))
     Y(NUM) = YIN(Q(0))
  ENDIF ELSE IF COUNT EQ 2 THEN BEGIN
     X(NUM) = (XIN(Q(0))+XIN(Q(1)))/2.
     Y(NUM) = (YIN(Q(0))+YIN(Q(1)))/2.
  ENDIF ELSE BEGIN
     IF COUNT LT 6 THEN BEGIN
        Y(NUM) = BIWEIGHT_MEAN( YIN(Q), BS, W )
        X(NUM) = TOTAL(W*XIN(Q))
        S(NUM) = BS 
     ENDIF ELSE BEGIN  
        X(NUM) = AVG(XIN(Q))
        CC=ROBUST_LINEFIT(XIN(Q),YIN(Q),YFIT)
        IF N_ELEMENTS(CC) EQ 1 THEN BEGIN
           Y(NUM)=YIN(Q)
        ENDIF ELSE BEGIN    
           Y(NUM)=CC(0)+CC(1)*X(NUM)
           S(NUM)=ROBUST_SIGMA(YIN(Q)-YFIT)/SQRT(COUNT-2.)
        ENDELSE
     ENDELSE
  ENDELSE
  X1 = X2
ENDFOR

RETURN
END
