FUNCTION R_DILATE,MAP,KERNEL, FLOOR=MINVAL
;
;+
;NAME:
;	R_DILATE
;
; PURPOSE:
;	Replace pixel values with the neighborhood maximum. Like DILATE, but
;	1. takes floating-point maps
;	2. ignores pixels <= a minimum value/
;
; CALLING SEQUENCE:
;	dilatedmap = R_DILATE( map, [ kernel, FLOOR = ])
;
; INPUT ARGUMENT:
;	MAP = the array to dilate
; OPTIONAL INPUT:
;	KERNEL = the byte-sized kernel that describes the shape of the 
;		neighborhood.    For example, for a 3x3 neighborhood, 
;		KERNEL=[[1,1,1],[1,1,1],[1,1,1]].    Or you could define a 
;		cross-shaped neighborhood by KERNEL = [[0,1,0],[1,1,1],[0,1,0]]
;		It should be square and of odd dimension.
; 
;          The default kernel = 7x7 with the 24 corner pixels zeroed.
;
; OPTIONAL INPUT KEYWORD:
;	 FLOOR = the minimum value of an occupied pixel. Default=0.
;
; OUTPUT:
;	DILATEDMAP - The floating-point dilated map.
;
;NOTE: 
;	The edges of the map are not filtered.
;	If too few pixels are occupied within a neighborhood, no filtering is 
;	done.   The companion routine is R_ERODE
;
; REVISION HISTORY:
;	Written, H.T. Freudenreich, HSTX, 5/19/93
;-

IF KEYWORD_SET(MINVAL) THEN EMPTY=MINVAL ELSE EMPTY=0.0

; Fill in default parameter:
IF N_PARAMS() LT 2 THEN KERNEL=[ [0,0,0,1,0,0,0],$
                                 [0,0,1,1,1,0,0],$
                                 [0,1,1,1,1,1,0],$
                                 [1,1,1,1,1,1,1],$
                                 [0,1,1,1,1,1,0],$
                                 [0,0,1,1,1,0,0],$
                                 [0,0,0,1,0,0,0]  ]
OK=WHERE(KERNEL GT 0,OK_COUNT)
MINPIX = OK_COUNT/2-1 ; the minimum size of the neighborhood
KSYZ=SIZE(KERNEL)
WIDTH=KSYZ(1)

SYZ=SIZE(MAP)
NX=SYZ(1)
NY=SYZ(2)
OFF=FIX(WIDTH)/2

AMAP = MAP
FOR I=OFF,NX-OFF-1 DO BEGIN
  FOR J=OFF,NY-OFF-1 DO BEGIN
;   Extract the neighborhood:
    A=MAP(I-OFF:I+OFF,J-OFF:J+OFF)
    A=A(OK)
;   Are there enough non-zero points?
    S=WHERE(A GT EMPTY,N) 
    IF N GT MINPIX THEN AMAP(I,J)=MAX(A(S))
  ENDFOR
ENDFOR
       
RETURN,AMAP
END
