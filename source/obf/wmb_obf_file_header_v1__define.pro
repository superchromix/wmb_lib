;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_file_header_v1__define.pro
;
; Structure definition for the wmb_obf_file_header_v1 struct
; 
; magic_header = [79B, 77B, 65B, 83B, 95B, 66B, 70B, 10B, 255B, 255B]

pro wmb_obf_file_header_v1__define

    tags = ['magic_header', 'format_version', 'first_stack_pos', 'descr_len']

    tmps = create_struct(tags, bytarr(10), ulong(0), ulong64(0), ulong(0), $
                         NAME='wmb_obf_file_header_v1')

end