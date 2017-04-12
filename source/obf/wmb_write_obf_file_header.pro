;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_write_obf_file_header.pro
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_write_obf_file_header, obf_uid, $
                               stack_header_position = stack_header_position
                     
    compile_opt idl2, strictarrsubs
    
    file_header_size = 26ULL
    
    file_magic_header = bytarr(10)
    file_magic_header[0] = [79B, 77B, 65B, 83B, 95B, 66B, 70B, 10B, 255B, 255B]
       
    file_header = {wmb_obf_file_header_v1}  
  
    file_header.magic_header = file_magic_header
    file_header.format_version = 0
    file_header.first_stack_pos = file_header_size
    file_header.descr_len = 0
    
    ; write the file header
    writeu, obf_uid, file_header
    
    point_lun, -obf_uid, stack_header_position
    
end