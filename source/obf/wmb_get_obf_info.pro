;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_get_obf_info.pro
;
; Read the header of an OBF file.
; 
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_get_obf_info, obf_filename, $
                      obf_header, $
                      n_stacks, $
                      stack_header_arr, $
                      data_pos_arr, $
                      stackname_arr, $
                      description_arr, $
                      stack_footer_arr, $
                      dimlabel_list_arr, $
                      col_pos_list_arr, $
                      col_label_list_arr, $
                      stack_header_pos_arr = stack_header_pos_arr, $
                      n_image_stacks = n_image_stacks, $
                      image_stack_indices = image_stack_indices, $
                      n_non_image_stacks = n_non_image_stacks, $
                      non_image_stack_indices = non_image_stack_indices, $
                      error_status = error_status, $
                      query_user = query_user

    compile_opt idl2, strictarrsubs

    if N_elements(query_user) eq 0 then query_user = 1

    error_status = 1

    get_lun, obf_uid

    openr, obf_uid, obf_filename, error=errstatus
    if errstatus ne 0 then begin
        free_lun, obf_uid
        message, 'Error opening OBF file.'
    endif

    tmp_file_header = {wmb_obf_file_header_v1}  
    tmp_stack_header = {wmb_obf_stack_header_v1}  
    tmp_stack_footer_v1 = {wmb_obf_stack_footer_v1}
    tmp_stack_footer_v2 = {wmb_obf_stack_footer_v2}    

    ; initialize the output arrays 
    
    stack_header_arr = []
    stack_header_pos_arr = []
    data_pos_arr = []
    stackname_arr = []
    description_arr = []
    stack_footer_arr = []
    dimlabel_list_arr = []
    col_pos_list_arr = []
    col_label_list_arr = []
    
    
    ; read the file header
    
    readu, obf_uid, tmp_file_header
    obf_header = tmp_file_header
    
    ; set the initial stack position
    
    stack_pos = 0
    next_stack_pos = ulong64(tmp_file_header.first_stack_pos)
    
    
    ; loop on multiple stacks in the OBF file
    n_stacks = 0
    
    while next_stack_pos gt stack_pos do begin
    
        n_stacks = n_stacks + 1
    
        ; get the stack header
        point_lun, obf_uid, next_stack_pos
        readu, obf_uid, tmp_stack_header
        stack_pos = next_stack_pos
        stack_header_pos_arr = [stack_header_pos_arr, stack_pos]
        stack_header_arr = [stack_header_arr, tmp_stack_header]
    
        ; get the data start position
        stack_header_size = 368ULL
        data_pos = stack_pos + stack_header_size $
                             + (tmp_stack_header.name_len) $
                             + (tmp_stack_header.descr_len)
        data_pos_arr = [data_pos_arr, data_pos]
    
        ; get the stack name
        namelen = tmp_stack_header.name_len
        if namelen gt 0 then begin
            stacknamebyte = bytarr(namelen)
            readu, obf_uid, stacknamebyte
            stackname = string(stacknamebyte)
        endif else begin
            stackname = ''
        endelse
        stackname_arr = [stackname_arr, stackname]
    
        ; get the stack description
        desclen = tmp_stack_header.descr_len
        if desclen gt 0 then begin
            descbyte = bytarr(desclen)
            readu, obf_uid, descbyte
            description = string(descbyte)
        endif else begin
            description = ''
        endelse
        description_arr = [description_arr, description]    
    
        ; get the stack footer, if present
        stack_version = tmp_stack_header.format_version
    
        case stack_version of
            1: tmp_stack_footer = tmp_stack_footer_v1
            2: tmp_stack_footer = tmp_stack_footer_v2
            else: tmp_stack_footer = tmp_stack_footer_v2
        endcase    
        
        ; get the data rank and data dims, which are used below
        tmprank = tmp_stack_header.rank
        tmpdims = tmp_stack_header.res
    
    
        ; the footer data is only present in stacks with format version
        ; greater or equal to 1    
        if stack_version ge 1 then begin
    
            ; get the stack footer
            data_len = tmp_stack_header.data_len_disk
            stack_footer_pos = data_pos + data_len
            point_lun, obf_uid, stack_footer_pos
            readu, obf_uid, tmp_stack_footer
            stack_footer_arr = [stack_footer_arr, tmp_stack_footer]

        
            ; get the dimension label strings
            ;
            ; dimlabel_list is a list of tmprank strings
    
            footersize = tmp_stack_footer.size
            dimlabelpos = stack_footer_pos + footersize
            point_lun, obf_uid, dimlabelpos 
               
            dimlabel_list = list(length=tmprank)
            for i = 0, tmprank-1 do begin
                dimlabel_strlen = ulong(0)
                readu, obf_uid, dimlabel_strlen
                if dimlabel_strlen gt 10000 then begin
                    if query_user eq 1 then begin
                        msgtxt = 'Misformed OBF footer'
                        result = DIALOG_MESSAGE(msgtxt, /ERROR)
                    endif
                    error_status = 1
                    return
                endif
                if dimlabel_strlen gt 0 then begin
                    tmpbytstr = bytarr(dimlabel_strlen)
                    readu, obf_uid, tmpbytstr
                    tmpstr = string(tmpbytstr)
                    dimlabel_list[i] = tmpstr
                endif else begin
                    dimlabel_list[i] = ''
                endelse
            endfor
            dimlabel_list_arr = [dimlabel_list_arr, dimlabel_list]


            ; get the numeric data labels, if present
            ;
            ; col_pos_list is a list of tmprank entries, some of 
            ; which may contain an array of doubles, corresponding to the
            ; numeric data labels
    
            col_pos_list = list(length=tmprank)
            has_col_positions = tmp_stack_footer.has_col_positions[0:tmprank-1]
            col_pos_index = where(has_col_positions ne 0, /NULL)

            ; the file read pointer should be in the correct position already
            foreach val, col_pos_index do begin
                tmparr = dblarr(tmpdims[val])
                readu, obf_uid, tmparr
                col_pos_list[val] = tmparr
            endforeach
            col_pos_list_arr = [col_pos_list_arr, col_pos_list]
        
        
            ; get the string type data labels, if present
            col_label_list = list(length=tmprank)
            has_col_labels = tmp_stack_footer.has_col_labels[0:tmprank-1]
            col_label_index = where(has_col_labels ne 0, /NULL)

            ; the file read pointer should be in the correct position already
            foreach val, col_pos_index do begin
                tmpdimlen = tmpdims[val]
                tmpstr_arr = []
                for i = 0, tmpdimlen-1 do begin
                    collabel_strlen = ulong(0)
                    readu, obf_uid, collabel_strlen
                    if collabel_strlen gt 0 then begin
                        tmpbytstr = bytarr(collabel_strlen)
                        readu, obf_uid, tmpbytstr
                        tmpstr = string(tmpbytstr)     
                    endif else begin
                        tmpstr = ''
                    endelse
                    tmpstr_arr = [tmpstr_arr, tmpstr]
                endfor
                col_label_list[val] = tmpstr_arr
            endforeach
            col_label_list_arr = [col_label_list_arr, col_label_list]

        endif else begin
    
            stack_footer_arr = [stack_footer_arr, tmp_stack_footer]
            dimlabel_list = list(length=tmprank)
            dimlabel_list_arr = [dimlabel_list_arr, dimlabel_list]
            col_pos_list = list(length=tmprank)     
            col_pos_list_arr = [col_pos_list_arr, col_pos_list]   
            col_label_list = list(length=tmprank)
            col_label_list_arr = [col_label_list_arr, col_label_list]
        
        endelse
        
        ; are there more stacks in the file?
        next_stack_pos = tmp_stack_header.next_stack_pos    

    endwhile

    close, obf_uid
    free_lun, obf_uid


    ; scan the description array for special stack descriptions
    
    non_image_stack_flag = bytarr(n_stacks)
    for i = 0, n_stacks-1 do begin
        
        tmp_stack_desc = description_arr[i]
        
        tmp_non_image = tmp_stack_desc.Contains('ISOSURFACE', /FOLD_CASE)
        
        non_image_stack_flag[i] = tmp_non_image
        
    endfor
    
    image_stack_indices = where(non_image_stack_flag eq 0, $
                                n_image_stacks, $
                                COMPLEMENT = non_image_stack_indices, $
                                NCOMPLEMENT = n_non_image_stacks)
    
    error_status = 0
    
end
