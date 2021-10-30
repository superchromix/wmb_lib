;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_h5d_read
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_h5d_read, dset_id, dtype_id, file_space = file_space, memory_space = memory_space

    compile_opt idl2, strictarrsubs
    
    nparams = n_params()
    
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
    
    if nparams eq 1 then begin
        
        result = h5d_read(dset_id, file_space = file_space, memory_space = memory_space)
        
    endif else if nparams eq 2 then begin
    
        result = h5d_read(dset_id, dtype_id, file_space = file_space, memory_space = memory_space)
    
    endif else begin
        
        message, 'Invalid number of parameters'
        
    endelse
    
    return, result
    
ABORT_OPERATION:

    message, 'WMB_H5D_READ_ERROR: ' + error_message
    void = cgErrormsg(error_message)
    
end