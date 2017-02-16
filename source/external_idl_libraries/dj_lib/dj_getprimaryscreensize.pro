; DJ_GetPrimaryScreenSize
;+
; :Description:
;    Handy function for getting screen size of primary monitor, optionally
;    excluding the taskbar. If no monitors exist, [0L, 0L] will be returned.
;
; :Keywords:
;    Exclude_Taskbar : in, optional, type=Boolean
;       If set, exclude taskbar as per IDLsysMonitorInfo::GetRectangles()
;
; :Author: Dick Jackson Software Consulting Inc., www.d-jackson.com
;-
FUNCTION DJ_GetPrimaryScreenSize, Exclude_Taskbar=exclude_Taskbar

    COMPILE_OPT IDL2, STRICTARRSUBS
    @DJ_ErrorCatchFun

    oMonInfo = Obj_New('IDLsysMonitorInfo')
    rects = oMonInfo -> GetRectangles(Exclude_Taskbar=exclude_Taskbar)
    pmi = oMonInfo -> GetPrimaryMonitorIndex()
    Obj_Destroy, oMonInfo
    RETURN, pmi EQ -1 ? [0L, 0L] : $ ; No monitors: return [0, 0]
        rects[[2, 3], pmi]          ; Else: w & h of primary monitor avbl. space

END