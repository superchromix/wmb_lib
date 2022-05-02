FUNCTION CHAINSAW,MAP,WIDTH, FLOOR=MINV
;
;+
; NAME:
;	CHAINSAW
;
; PURPOSE:
;	Remove isolated HIGH elements from a 2D array, replacing them with a 
;	local surface fit. 
;
; CALLING SEQUENCE:
;	NewMap = CHAINSAW( Map, Width,( FLOOR = ] )
; INPUT ARGUMENT:
;	MAP = the array to de-point
;
;INPUT ARGUMENT:
;	WIDTH = the width of the square moving neighborhood centered on the 
;		pixel in question. If there are too few non-empty pixels 
;		within this neighborhood, nothing is done.
;
; OPTIONAL INPUT KEYWORS:
;	FLOOR = the value representing an empty pixel. Default = 0.0
;
; OUTPUT:
;	NEWMAP -  The input array, with point sources (or just exceptionally 
;		bright pixels) removed.
;
; METHOD:
;	Divides the neighborhood into 4 rectangular areas, finds the minimum 
;	of each, and fits a plane to the 4 points. The central pixel is 
;	replaced by the value of the plane at its location, unless it is 
;	already fainter. The end result is much like that of EROSION+DILATION,
;	but does not have mask-shaped artifacts. Edges of width WIDTH/2-1 are 
;	unaffected.
;
; SUBROUTINES CALLED:
;	Planefit, Med
;
; REVISIONS HISTORY:
;	Written,  H.T. Freudenreich, HSTX, 10/94
;-

ON_ERROR,2
IF KEYWORD_SET(MINV)     THEN EMPTY=MINV ELSE EMPTY=0.0

; Set some needed constants:
SYZ=SIZE(MAP)
NX=SYZ(1)  &  NY=SYZ(2)
OFF=FIX(WIDTH)/2
TOP=1.0E37

; Get coordinates of the neighborhood pixels:
U=FINDGEN(WIDTH)        &  V=FINDGEN(WIDTH)
XX=FLTARR(WIDTH,WIDTH)  &  YY=FLTARR(WIDTH,WIDTH)
FOR I=0,WIDTH-1 DO XX(*,I)=U  &  U=0
FOR I=0,WIDTH-1 DO YY(I,*)=V  &  V=0
X1=XX(OFF+1:WIDTH-1,OFF:WIDTH-1)
X2=XX(0    :OFF,    OFF+1:WIDTH-1)
X3=XX(0    :OFF-1,  0    :OFF)
X4=XX(OFF  :WIDTH-1,0    :OFF-1)
Y1=YY(OFF+1:WIDTH-1,OFF:WIDTH-1)
Y2=YY(0    :OFF,    OFF+1:WIDTH-1)
Y3=YY(0    :OFF-1,  0    :OFF)
Y4=YY(OFF  :WIDTH-1,0    :OFF-1)

QUADNUM=(WIDTH^2-1)/4
U=FLTARR(4) & V=U & Z=U

AMAP    = MAP

FOR I=OFF,NX-OFF-1 DO BEGIN
  FOR J=OFF,NY-OFF-1 DO BEGIN
;   Extract the neighborhood:
    AA=MAP(I-OFF:I+OFF,J-OFF:J+OFF)
;   Are there enough non-zero points? Is there at least 1 in each quadrant of
;   the neighborhood?
    AA(OFF,OFF)=EMPTY
    Q=WHERE(AA GT EMPTY,N) 
    IF N GT 3 THEN BEGIN
       A1=AA(OFF+1:WIDTH-1,OFF:WIDTH-1)
       A2=AA(0    :OFF,    OFF+1:WIDTH-1)
       A3=AA(0    :OFF-1,  0    :OFF)
       A4=AA(OFF  :WIDTH-1,0    :OFF-1)
       Q1=WHERE(A1 GT EMPTY,N1)
       Q2=WHERE(A2 GT EMPTY,N2)
       Q3=WHERE(A3 GT EMPTY,N3)
       Q4=WHERE(A4 GT EMPTY,N4)

       IF (N1 GT 0) AND (N2 GT 0) AND (N3 GT 0) AND (N4 GT 0) THEN BEGIN
          IF N1 LT QUADNUM THEN A1(WHERE(A1 LE EMPTY))=TOP
          IF N2 LT QUADNUM THEN A2(WHERE(A2 LE EMPTY))=TOP
          IF N3 LT QUADNUM THEN A3(WHERE(A3 LE EMPTY))=TOP
          IF N4 LT QUADNUM THEN A4(WHERE(A4 LE EMPTY))=TOP
          Q=WHERE(A1 EQ MIN(A1))
          Z(0)=A1(Q(0)) & U(0)=X1(Q(0)) & V(0)=Y1(Q(0))
          Q=WHERE(A2 EQ MIN(A2))
          Z(1)=A2(Q(0)) & U(1)=X2(Q(0)) & V(1)=Y2(Q(0))
          Q=WHERE(A3 EQ MIN(A3))  
          Z(2)=A3(Q(0)) & U(2)=X3(Q(0)) & V(2)=Y3(Q(0))
          Q=WHERE(A4 EQ MIN(A4))
          Z(3)=A4(Q(0)) & U(3)=X4(Q(0)) & V(3)=Y4(Q(0))
          WT=[N1,N2,N3,N4]/(FLOAT(N1+N2+N3+N4))
          CC=PLANEFIT( U,V,Z, WT )
          IF N_ELEMENTS(CC) LT 3 THEN BCK=MED(Z) ELSE $
          BCK=CC(0)+CC(1)*XX(OFF,OFF)+CC(2)*YY(OFF,OFF)       
          IF (AMAP(I,J) LE EMPTY) OR (AMAP(I,J) GT BCK) THEN AMAP(I,J) = BCK

;         Now, take care of the edges:
          if j eq off then begin          
             if n_elements(cc) eq 3 then $
              amap(i,0:off-1)=cc(0)+cc(1)*xx(off,0:off-1)+cc(2)*yy(off,0:off-1) $
              else amap(i,0:off-1)=bck
          endif else if j eq ny-off-1 then begin
             if n_elements(cc) eq 3 then $
             amap(i,ny-off:ny-1)=cc(0)+cc(1)*xx(off,off+1:width-1) + $
                                       cc(2)*yy(off,off+1:width-1)   $
             else amap(i,ny-off:ny-1)=bck
          endif
          if i eq off then begin
             if n_elements(cc) eq 3 then $
             amap(0:off-1,j)=cc(0)+cc(1)*xx(0:off-1,off)+cc(2)*yy(0:off-1,off) $
             else amap(0:off-1,j)=bck
             if j eq off then begin
                if n_elements(cc) eq 3 then $
                amap(0:off-1,0:off-1)=cc(0)+cc(1)*xx(0:off-1,0:off-1) + $
                                            cc(2)*yy(0:off-1,0:off-1) $
                else amap(0:off-1,0:off-1)=bck
             endif else if j eq ny-off-1 then begin
                if n_elements(cc) eq 3 then $
                amap(0:off-1,ny-off:ny-1)=cc(0)+ $
                     cc(1)*xx(0:off-1,off+1:width-1)+ $
                     cc(2)*yy(0:off-1,off+1:width-1) $
                else amap(0:off-1,ny-off:ny-1)=bck
             endif
          endif else if i eq nx-off-1 then begin
             if n_elements(cc) eq 3 then $
             amap(nx-off:nx-1,j)=cc(0)+cc(1)*xx(off+1:width-1,off) + $
                                       cc(2)*yy(off+1:width-1,off)   $
             else amap(nx-off:nx-1,j)=bck
             if j eq ny-off-1 then begin
                if n_elements(cc) eq 3 then $
                amap(nx-off:nx-1,ny-off:ny-1)=cc(0)+$
                    cc(1)*xx(off+1:width-1,off+1:width-1) + $
                    cc(2)*yy(off+1:width-1,off+1:width-1) $
                else amap(nx-off:nx-1,ny-off:ny-1)=bck
             endif else if j eq off then begin
                if n_elements(cc) eq 3 then $
                amap(nx-off:nx-1,0:off-1)=cc(0)+$
                    cc(1)*xx(off+1:width-1,0:off-1) + $
                    cc(2)*yy(off+1:width-1,0:off-1) $
                else amap(nx-off:nx-1,0:off-1)=bck
             endif
          endif

       ENDIF ELSE $
          PRINT,'CHAINSAW: Failed at ',i,',',j,'. Poor coverage.'
    ENDIF
  ENDFOR
ENDFOR

RETURN,AMAP
END
