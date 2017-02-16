; DJ_PositionTLB
;+
; :Description:
;       This procedure will position a top-level base widget on the display.
;       For best effect, call this after all the widgets have
;       been created, but just before the widget hierarchy is realized.
;       It uses the top-level base geometry along with the display size
;       to calculate offsets for the top-level base that will position the
;       top-level base on the display.
;
; :Params:
;    TLB : in, required, type=Long
;       The widget identifier of the top-level base to position
;    normXY : in, required, type=2-element numeric array
;       A 2-element array [xNorm, yNorm], giving x and y coordinates:
;          If it is of type FLOAT or DOUBLE, it will be taken as normalized
;          coordinates in the range (0..1) indicating desired relative position
;          of the top-level base, with [0.0, 0.0] being aligned with the
;          bottom-left corner of the screen. For example, to position along the
;          top edge, midway between left and right edge, specify [0.5, 1.0].
;          If it is of any other type, it will be taken as pixel coordinate
;          position for the top-left corner of the base, with [0, 0] being at
;          the top-left corner of the screen.
;
; :Author: Dick Jackson Software Consulting Inc., www.d-jackson.com
;-

PRO DJ_PositionTLB, tlb, normXY

    screenSize = GetPrimaryScreenSize(/Exclude_Taskbar)
    geom = Widget_Info(tlb, /Geometry)

    IF (Size(normXY,/TName) EQ 'FLOAT' OR Size(normXY,/TName) EQ 'DOUBLE') $
        AND Total(normXY LT -1 OR normXY GT 2) EQ 0 THEN BEGIN ; Treat as normalized
        ; coords from BOTTOM-left
        xOffset = (screenSize[0]-geom.Scr_XSize) * normXY[0]
        yOffset = (screenSize[1]-geom.Scr_YSize) * (1.0-normXY[1])
    ENDIF ELSE BEGIN ; Take normXY to be pixel coords from TOP-left, not normalized!
        xOffset = normXY[0]
        yOffset = normXY[1]
    ENDELSE

    Widget_Control, tlb, XOffset = xOffset, YOffset = yOffset

END
