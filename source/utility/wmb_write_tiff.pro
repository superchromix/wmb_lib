;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_write_tiff
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_write_tiff, file_name, image_data, _Extra=extra

    compile_opt idl2, strictarrsubs
    
    ; catches file open errors
    
    error_count = 0
    error_limit = 10
    error_wait = 1
    operation_aborted = 0
    error_status = 0
    error_message = ''
    
    CATCH, error_status
    
    if error_status ne 0 then begin
        
        error_message = !ERROR_STATE.MSG
        error_count = error_count + 1
        
        PRINT, 'Error index: ', error_status
        PRINT, 'Error message: ', error_message
        PRINT, 'Error count: ', error_count

        wait, error_wait
        openu, tmp_uid, file_name, /GET_LUN
        close, tmp_uid, /FORCE
        free_lun, tmp_uid
        wait, error_wait
        
        if error_count ge error_limit then begin

            ; cancel the operation
            CATCH, /CANCEL
            PRINT, 'Aborting operation'
            operation_aborted = 1
            GOTO, ABORT_OPERATION
        
        endif
        
    endif

    write_tiff, file_name, image_data, _Extra=extra
    
    return
    
ABORT_OPERATION:

    msg_txt = 'WRITE_TIFF_ERROR: ' + error_message
    void = cgErrormsg(msg_txt)
    
end