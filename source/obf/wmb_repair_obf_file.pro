;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_repair_obf_file
; 
; Repairs the header and footer of OBF files which contain a single image 
; stack, which may have been interrupted during writing.
;
; Returns 1 if successful.
; 
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_repair_obf_file, obf_filename = obf_filename, $
                              template_obf_filename = template_obf_filename, $
                              default_path = default_path

    compile_opt idl2, strictarrsubs

    catch, error_status
    
    if error_status ne 0 then begin
        ; the program encountered an error - hence the file was not repaired
        return, 0
    endif

    query_user = 0

    if N_elements(obf_filename) eq 0 or $
       N_elements(template_obf_filename) eq 0 then begin
        
        query_user = 1
    
    endif

    if query_user eq 1 then begin
        
        msgtxt = 'Choose the OBF file to repair'
        
        obf_fn = DIALOG_PICKFILE(title=msgtxt, $
                                 filter='*.obf', $
                                 path=default_path, $
                                 get_path=output_path, $
                                 /MUST_EXIST)
                                 
        if obf_fn eq '' then return, 0

        msgtxt = 'Choose an OBF file to serve as a template'
                                 
        template_fn = DIALOG_PICKFILE(title=msgtxt, $
                                      path=output_path, $
                                      filter='*.obf', $
                                      /READ)
                                 
        if template_fn eq '' then return, 0
        
        obf_filename = obf_fn
        template_obf_filename = template_fn
        
    endif

    repair_successful = 0

    ; read the template file
    
    wmb_get_obf_info, template_obf_filename, t_obf_header, t_n_stack, $
                      t_stack_header_arr, $
                      t_data_pos_arr, t_stackname_arr, t_description_arr, $
                      t_stack_footer_arr, t_dimlabel_list_arr, $
                      t_col_pos_list_arr, t_col_label_list_arr, $
                      error_status = t_error_status, query_user = 0
    
    if t_error_status ne 0 then return, 0

    template_stack_header = t_stack_header_arr[0]
    template_stack_footer = t_stack_footer_arr[0]

    get_lun, obf_uid

    openu, obf_uid, obf_filename, error=errstatus
    if errstatus ne 0 then begin
        free_lun, obf_uid
        message, 'Error opening OBF file.', /INFORMATIONAL
        return, 0
    endif

    file_size_bytes = (file_info(obf_filename)).size

    tmp_file_header = {wmb_obf_file_header_v1}
    tmp_stack_header = {wmb_obf_stack_header_v1}
    tmp_stack_footer_v1 = {wmb_obf_stack_footer_v1}
    tmp_stack_footer_v2 = {wmb_obf_stack_footer_v2}

    ; read the file header

    readu, obf_uid, tmp_file_header
    obf_header = tmp_file_header
    
    ; get the initial stack position
    stack_pos = ulong64(tmp_file_header.first_stack_pos)
    
    ; get the stack header
    point_lun, obf_uid, stack_pos
    readu, obf_uid, tmp_stack_header

    ; get the data start position
    stack_header_size = 368ULL
    data_pos = stack_pos + stack_header_size $
                         + (tmp_stack_header.name_len) $
                         + (tmp_stack_header.descr_len)
        
    ; get the stack name
    namelen = tmp_stack_header.name_len
    if namelen gt 0 then begin
        stacknamebyte = bytarr(namelen)
        readu, obf_uid, stacknamebyte
        stackname = string(namelen)
    endif else begin
        stackname = ''
    endelse
    
    ; get the stack description
    desclen = tmp_stack_header.descr_len
    if desclen gt 0 then begin
        descbyte = bytarr(desclen)
        readu, obf_uid, descbyte
        description = string(descbyte)
    endif else begin
        description = ''
    endelse
        
    ; get the stack footer, if present
    stack_version = tmp_stack_header.format_version

    ; this version of the repair tool works only for stack version 2
    
    if stack_version ne 2 then return, 0

    case stack_version of
        1: tmp_stack_footer = tmp_stack_footer_v1
        2: tmp_stack_footer = tmp_stack_footer_v2
        else: tmp_stack_footer = tmp_stack_footer_v2
    endcase    
    
    ; get the data rank and data dims, which are used below
    tmprank = tmp_stack_header.rank
    tmpdims = tmp_stack_header.res
    
    stack_footer_size_v2 = 1408ULL
    stack_extra_size = stack_footer_size_v2 + (tmprank*4)
    
    ; is the data length written correctly?

    point_lun, -obf_uid, cur_read_pos
    file_data_len = file_size_bytes - (cur_read_pos + stack_extra_size)
    
    data_len_header = tmp_stack_header.data_len_disk
       
    if data_len_header ne file_data_len then begin
        
        ; the data length is not written correctly, and most likely 
        ; the footer is not present
        
        ; if the rank is 3 or 4, then assume this is a stack of 2d images
        ; which is missing its last dimension
        
        if tmprank eq 3 or tmprank eq 4 then begin
            
            tmp_img_size = product(tmpdims[0:1],/INTEGER)
            idl_dtype = wmb_OMAS2IDLtype(tmp_stack_header.dt)
            tmp_img_size = tmp_img_size * wmb_sizeoftype(idl_dtype)
            
            ; how many images are present?
            
            n_images = floor(file_data_len/tmp_img_size)
            
            corrected_data_len = n_images * tmp_img_size
            corrected_dims = tmpdims
            corrected_dims[2] = n_images
            
            tmp_stack_header.res = corrected_dims
            tmp_stack_header.data_len_disk = corrected_data_len
            
            ; rewrite the stack header
            point_lun, obf_uid, stack_pos
            writeu, obf_uid, tmp_stack_header
            
            ; write the stack footer
            data_len = tmp_stack_header.data_len_disk
            stack_footer_pos = data_pos + data_len
                
            point_lun, obf_uid, stack_footer_pos
            
            template_si_unit_value = template_stack_footer.si_unit_value
            template_si_unit_dims = template_stack_footer.si_unit_dimensions
            
            value_scalefactor = template_si_unit_value.scalefactor
            
            value_unit = 0
            dimension_units = lonarr(tmprank)
            
            for i = 0, tmprank-1 do begin
                
                chk_s = wmb_obf_si_get_second()
                chk_um = wmb_obf_si_get_micrometer()
                
                t_dim = template_si_unit_dims[i]
                if wmb_compare_struct(t_dim,chk_um) then dimension_units[i] = 1
                if wmb_compare_struct(t_dim,chk_s) then dimension_units[i] = 2
                
            endfor
            
            wmb_write_obf_stack_footer_v2, obf_uid, $
                                   tmprank, $
                                   value_unit, $
                                   dimension_units, $
                                   value_scalefactor = value_scalefactor, $
                                   next_stack_header_position = 0
                    
            truncate_lun, obf_uid
                    
            repair_successful = 1
                    
        endif
        
    endif
                
    free_lun, obf_uid

    return, repair_successful

end
