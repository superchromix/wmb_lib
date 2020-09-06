;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_write_obf_stack_header.pro
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_write_obf_stack_header_v2, obf_uid, $
                               stack_data_rank, $
                               dim_sizes, $
                               pixel_sizes, $
                               offsets, $
                               datatype, $
                               compression, $
                               stack_size_disk_bytes, $
                               next_stack_position, $
                               stack_name = stack_name, $
                               stack_description = stack_description, $
                               stack_header_position = stack_header_position, $
                               stack_data_position = stack_data_position
                                    
    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler
    
    
    if N_elements(stack_name) eq 0 then stack_name = ''
    if N_elements(stack_description) eq 0 then stack_description = ''
    
    if stack_name eq '' then begin
        
        stack_name_data = []
        stack_name_len = 0
        
    endif else begin
        
        stack_name_data = byte(stack_name)
        stack_name_len = N_elements(stack_name_data)

    endelse
    
    if stack_description eq '' then begin
        
        stack_description_data = []
        stack_description_len = 0
        
    endif else begin
        
        stack_description_data = byte(stack_description)
        stack_description_len = N_elements(stack_description_data)

    endelse
    
    
    if N_elements(dim_sizes) ne stack_data_rank then $
        message, 'Invalid dimension sizes'
        
    if N_elements(pixel_sizes) ne stack_data_rank then $
        message, 'Invalid pixel sizes'
        
    if N_elements(offsets) ne stack_data_rank then $
        message, 'Invalid offsets'
    
    
    stack_header_size = 368ULL
    
    stk_magic_header = bytarr(16)
    stk_magic_header[0] = [79B, 77B, 65B, 83B, 95B, 66B, 70B, 95B, 83B, $
                           84B, 65B, 67B, 75B, 10B, 255B, 255B]
    
    stk_res = ulonarr(15)
    stk_len = dblarr(15)
    stk_off = dblarr(15)
    
    ulon_zero_arr = ulonarr(15)
    
    stk_res[0] = dim_sizes
    stk_len[0] = dim_sizes * double(pixel_sizes)
    stk_off[0] = offsets
    
    stack_header = {wmb_obf_stack_header_v1}  
    
    stack_header.magic_header = stk_magic_header
    stack_header.format_version = 2
    stack_header.rank = stack_data_rank
    stack_header.res = stk_res
    stack_header.len = stk_len
    stack_header.off = stk_off
    stack_header.dt = dv_idl2omastype(datatype)


    stack_header.name_len = stack_name_len
    stack_header.descr_len = stack_description_len
    stack_header.reserved = 0
    stack_header.next_stack_pos = next_stack_position

    stack_header.compression_type = (compression eq 1)
    stack_header.compression_level = (compression eq 1)
    stack_header.data_len_disk = stack_size_disk_bytes

    ; store the stack header position

    point_lun, -obf_uid, stack_header_position

    ; write the stack header
    
    writeu, obf_uid, stack_header
    
    ; write the stack name
    
    if stack_name_len gt 0 then writeu, obf_uid, stack_name_data
    
    ; write the stack description
    
    if stack_description_len gt 0 then writeu, obf_uid, stack_description_data
    
    ; store the stack data position
    
    point_lun, -obf_uid, stack_data_position
    
end