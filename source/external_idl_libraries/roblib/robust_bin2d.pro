PRO ROBUST_BIN2D,NX,NY, X0,X1, Y0,Y1, X,Y,DATA, MAP,NUM,SIGGMA
;+
; NAME:
;	ROBUST_BIN2D
;
; PURPOSE:
;	Bins data in a 2-dimensional array suitable for surface or contour 
;	plots.  Cells with more than 2 entries are robustly averaged to remove
;	outliers.
;
; CALLING SEQUENCE:
;	ROBUST_BIN2D,NX,NY,X0,X1,Y0,Y1,X,Y,DATA,Z,NUM,SIGGMA
;
; INPUTS:
;	NX = Number of bins in the X direction
;	NY = Number of bins in the Y direction
;	X0 = Lower bound on X
;	X1 = Higher bound on X
;	Y0 = Lower bound on Y
;	Y1 = Higher bound on Y
;	X = Independent variable vector, floating-point
;	Y = Dependent variable vector
;	DATA = Vector of quantity to be binned. X, Y, DATA must have same 
;		length.
;
; OUTPUTS:
;	Z   = 2-dimensional array containing the average Z per bin
;	NUM = 2-dimensional array containing the number of entries per bin.
;	SIGGMA = (OPTIONAL) standard deviation per pixel (not OF THE MEAN).
;
; SUBROUTINES CALLED:
;	RESISTANT_MEAN, MED
;
; REVISION HISTORY:
;	Written by H.T. Freudenreich, ?/1990
;	Modified: H.F., 3/94 to return SIGGMA
;- 

ON_ERROR,2

BINMAX = 255
A    = FLTARR(BINMAX)
Z    = FLTARR(BINMAX,NX,NY)
NUM  = INTARR(NX,NY)
MAP  = FLTARR(NX,NY)

IF N_PARAMS() GT 11 THEN BEGIN
   GETSIG=1
   SIGGMA=FLTARR(NX,NY)
ENDIF ELSE GETSIG=0

; Bin the data:
DELX = (X1-X0)/NX   
DELY = (Y1-Y0)/NY   

FOR I = 0L, N_ELEMENTS(DATA)-1 DO BEGIN
  IX =  (X(I)-X0)/DELX
  IY =  (Y(I)-Y0)/DELY 
  IF( (IX GE 0) AND (IY GE 0) AND (IX LT NX) AND (IY LT NY) )THEN BEGIN
     IF( NUM(IX,IY) LT BINMAX )THEN BEGIN
       Z(NUM(IX,IY),IX,IY) = DATA(I)
       NUM(IX,IY)          = NUM(IX,IY)+1
     ENDIF ELSE PRINT,'ROBUST_BIN2D: Exceeded maximum entries per bin'
  ENDIF
ENDFOR

; Average each non-empty bin:
FOR I = 0, NX-1 DO BEGIN
  FOR J = 0, NY-1 DO BEGIN
    MAP[I,J] = Z(I,J,0)
    IF( NUM(I,J) GT 1 )THEN BEGIN
       IF( NUM(I,J) EQ 2 )THEN BEGIN
          MAP[I,J] = (Z(0,I,J)+Z(1,I,J))*.5
       ENDIF ELSE IF( NUM(I,J) EQ 3 )THEN BEGIN
          A = Z(0:2,I,J)
          A = A(SORT(A))
          MAP[I,J] = A(2)
       ENDIF ELSE BEGIN
          A = Z(0:NUM(I,J)-1,I,J)
          MEAN = BIWEIGHT_MEAN(A,SIG) ;(slow)
;          RESISTANT_MEAN,A,2.,MEAN,SIG,NUMR ;(faster)
          MAP[I,J] = MEAN
          IF GETSIG EQ 1 THEN SIGGMA(I,J)=SIG
       ENDELSE
    ENDIF
  ENDFOR
ENDFOR

RETURN
END
