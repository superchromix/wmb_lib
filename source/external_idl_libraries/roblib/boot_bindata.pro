PRO BOOT_BINDATA,NBINS, XIN,YIN, X1,X2,NSAMP, X,Y,S,BINHITS, ITYPE
;
;+
; NAME:
;	BOOT_BINDATA
;
; PURPOSE:
;	Groups data into NBINS bins of equal size, and finds the robust mean of
;	each bin. The X value per bin is not necessarily = bin-center. The boot-
;	strap method is used. If a bin has fewer than 6 points, the biweighted
;	mean is calculated; otherwise, a robust line is fitted to the data.
;
; CALLING SEQUENCE:
;	BOOT_BINDATA, NBins, Xin, Yin, X1, X2, NSamp, X, Y, S, BinHits, [IType]
;
; INPUTS:
;	NBins = number of bins
;	Xin   = the input X values
;	Yin   = the input Y values
;	X1    = the low end of the range of X
;	X2    = the high end of the range of X
;	NSamp = the number of bootstrap samples
;	IType (OPTIONAL) = use logarithmically equal bin-widths if present
;
; OUTPUTS:
;	X       = the X values of the bins
;	Y       = the y values (=-100000 if a bin is empty)
;	S       = the robust standard deviations of the bins
;	BinHits = the number of entries per bin.
;
; NOTES:
;
;	If a bin has fewer than 6 entries, a biweighted mean of Y is
;	calculated; X is weighted by the same weights, so the X value of the bin
;	is not necessarily bin-center. If 6 points or more, a robust line is
;	fitted to the data, and evaluated at bin-center. 
;
; REVISION HISTORY
;	Written,  H.T. Freudenreich, Hughes STX, 12/3/92
;-

X=FLTARR(NBINS)
Y=FLTARR(NBINS)
S=FLTARR(NBINS)
BINHITS=LONARR(NBINS)
ITYPE=0

IF N_PARAMS() GT 10 THEN BEGIN
   ITYPE = 1
   IF X1 LE 0. THEN BEGIN
      PRINT,'BOOT_BINDATA: For Log Scale, Xmin > 0.!'
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
        BOOT_MEAN, YIN(Q), NSAMP, MEANS, /ROBUST
        IF NSAMP GT 0 THEN BEGIN
           Y(NUM) = TOTAL(MEANS)/count
           X(NUM) = TOTAL(XIN(Q))/count
           S(NUM) = STDEV(MEANS)
        ENDIF ELSE BEGIN
           Y(NUM) = MED(YIN(Q))
           X(NUM) = TOTAL(XIN(Q))/COUNT
           S(NUM) = 0.
        ENDELSE
     ENDIF ELSE BEGIN  
        X(NUM) = TOTAL(XIN(Q))/COUNT
        CC = BOOT_POLYFIT(XIN(Q),YIN(Q),1,NSAMP,NOUT,/ROBUST)
        IF NOUT EQ 1 THEN BEGIN
           Y(NUM)=YIN(Q)
        ENDIF ELSE BEGIN    
           YY=CC(0,*)+CC(1,*)*X(NUM)
           Y(NUM)=TOTAL(YY)/COUNT
           S(NUM)=STDEV(YY)
        ENDELSE
     ENDELSE
  ENDELSE
  X1 = X2
ENDFOR

RETURN
END

