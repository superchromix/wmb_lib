;;    Catch and report this function's errors as appropriate.

dj_err_debug_flag = 1
dj_err_traceback = 0

IF (dj_err_debug_flag NE 1) THEN BEGIN
    Catch, error
    IF error NE 0 THEN BEGIN
        Catch, /Cancel
        Help, /Last_Message, Output=errorMsg
        void = cgErrorMsg(Traceback=dj_err_traceback)
        RETURN, -1
    ENDIF
ENDIF
