;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_h5f_open
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_h5f_open, filename, write = write

    compile_opt idl2, strictarrsubs
    
    ; catches file open errors
    
    error_count = 0
    error_limit = 4
    error_wait = 5
    operation_aborted = 0
    error_status = 0
    error_message = ''
    
    CATCH, error_status
    
    if error_status ne 0 then begin
        
        PRINT, 'Error index: ', error_status
        PRINT, 'Error message: ', !ERROR_STATE.MSG
        error_message = !ERROR_STATE.MSG
        error_count += 1
        
        wait, error_wait
        
        if error_count ge error_limit then begin

            ; cancel the operation
            CATCH, /CANCEL
            PRINT, 'Aborting operation'
            operation_aborted = 1
            GOTO, ABORT_OPERATION
        
        endif
        
    endif
    
    result = h5f_open(filename, write = write)
    
    return, result
    
ABORT_OPERATION:

    message, 'WMB_H5F_OPEN_ERROR: ' + error_message
    void = cgErrormsg(error_message)
    
end