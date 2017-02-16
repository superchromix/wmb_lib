; DJ_CenterTLB
;+
; :Description:
;    This procedure will center a widget top-level base on the primary display.
;       For best effect, call this after all the TLB's child widgets have
;       been created, but just before the widget hierarchy is realized.
;       It uses the top-level base geometry along with the display size
;       to calculate offsets for the top-level base that will center the
;       top-level base on the display.
;
; :Params:
;    TLB : in, required, type=Long
;
; :Keywords:
;    CenterOnTLB : in, optional, type=Long
;       If provided, use the TLB passed in this keyword as the rectangle
;       on which to center the TLB given in the positional parameter.
;
; :Author: Dick Jackson Software Consulting Inc., www.d-jackson.com
;-

PRO DJ_CenterTLB, tlb, CenterOnTLB=wCenterOnTLB

    COMPILE_OPT IDL2, STRICTARRSUBS
    @DJ_ErrorCatchPro

    IF N_Elements(tlb) NE 1 THEN Message, 'Must provide one TLB. '+ $
        'Usage: DJ_CenterTLB, tlb [,CenterOnTLB=wCenterOnTLB]'
    IF N_Elements(wCenterOnTLB) EQ 1 && $
        Widget_Info(wCenterOnTLB, /Valid_ID) THEN BEGIN
        wCenterOnTLBGeom = Widget_Info(wCenterOnTLB, /Geometry)
        xCenter = wCenterOnTLBGeom.xOffset + wCenterOnTLBGeom.scr_xSize / 2
        yCenter = wCenterOnTLBGeom.yOffset + wCenterOnTLBGeom.scr_ySize / 2
    ENDIF ELSE BEGIN
        screenSize = DJ_GetPrimaryScreenSize(/Exclude_Taskbar)
        xCenter = screenSize[0] / 2
        yCenter = screenSize[1] / 2
    ENDELSE ;; group_leader is present or not

    geom = Widget_Info(tlb, /Geometry)
    xHalfSize = geom.Scr_XSize / 2
    yHalfSize = geom.Scr_YSize / 2

    Widget_Control, tlb, XOffset = xCenter-xHalfSize, $
        YOffset = yCenter-yHalfSize

END
