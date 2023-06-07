;
;   wmb_dlm_load
;

pro wmb_dlm_load, input_filename

    compile_opt idl2, strictarrsubs

    fn_root = file_basename(input_filename)
    fn_root = wmb_file_remove_extension(fn_root)
    
    fn_root = strupcase(fn_root)
    
    help, /DLM, OUT=tmp_info
    has_dlm = max(strmatch(temporary(tmp_info), '\*\* ' + fn_root + ' *')) gt 0
    
    if has_dlm eq 0B then begin

        dlm_load, input_filename

    endif
    
end