;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_save_obf_info.pro
;
; Saves the header information from an OBF file into an obf_info file.
; 
; Returns 1 if successful
; 
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_save_obf_info, obf_path, query_user = query_user

    compile_opt idl2, strictarrsubs

    if N_elements(query_user) eq 0 then query_user = 0

    wmb_get_obf_info, obf_path, $
                      obf_header, $
                      obf_n_stack, $
                      obf_stack_header_arr, $
                      obf_data_pos_arr, $
                      obf_stackname_arr, $
                      obf_description_arr, $
                      obf_stack_footer_arr, $
                      obf_dimlabel_list_arr, $
                      obf_col_pos_list_arr, $
                      obf_col_label_list_arr, $
                      error_status = error_status, $
                      query_user = query_user
        
    chk_open_success = (error_status eq 0)

    if chk_open_success eq 1 then begin

        ; save the obf data in a .sav file
        
        new_fn = obf_path.substring(0,-5) + '.obf_info'
        
        obf_info_version = 1.0
        
        save, obf_info_version, $
              obf_path, $
              obf_header, $
              obf_n_stack, $
              obf_stack_header_arr, $
              obf_data_pos_arr, $
              obf_stackname_arr, $
              obf_description_arr, $
              obf_stack_footer_arr, $
              obf_dimlabel_list_arr, $
              obf_col_pos_list_arr, $
              obf_col_label_list_arr, $
              FILENAME = new_fn
              
    endif else begin
        
        return, 0
        
    endelse
    
    return, 1
    
end
                      