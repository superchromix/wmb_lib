;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_test_vm
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_test_vm

    compile_opt idl2, strictarrsubs
    
    test_vm = 0
    test_rdp = 0
    execute_error_check = 0
    
    ; catches errors
    
    error_count = 0
    error_status = 0
    error_message = ''
    
    CATCH, error_status
    
    if error_status ne 0 then begin
        
        ;PRINT, 'Error index: ', error_status
        ;PRINT, 'Error message: ', !ERROR_STATE.MSG
        error_message = !ERROR_STATE.MSG
        error_count += 1

        ; cancel the operation
        CATCH, /CANCEL

        execute_error_check = 1

        GOTO, ABORT_OPERATION
        
    endif
    
    test_vm = LMGR(/VM)
    if test_vm eq 1 then return, 1
    
    test_rdp = getenv('SESSIONNAME') ne 'Console'
    if test_rdp eq 1 then return, 1
    
    tmp_obj = obj_new('IDL_IDLBridge')
    tmp_msg = 'test_demo = LMGR(/DEMO)'
    tmp_obj.Execute, tmp_msg
    
    obj_destroy, tmp_obj
    
    if test_vm eq 1 or test_rdp eq 1 or execute_error_check eq 1 then begin
        
        return, 1
        
    endif else begin
        
        return, 0
        
    endelse
    
ABORT_OPERATION:

    return, 1
    
end