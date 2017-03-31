;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_stack_header_v1__define.pro
;
; Structure definition for the wmb_obf_stack_header_v1 struct.
; 
; Note that as of OMAS version 0.1, OMAS_MAX_DIMENSIONS=15
; 
; magic_header = [79B, 77B, 65B, 83B, 95B, 66B, 70B, 95B, 83B, $
;                 84B, 65B, 67B, 75B, 10B, 255B, 255B]
;

pro wmb_obf_stack_header_v1__define

    omas_max_dimensions = 15

    tags = ['magic_header', 'format_version', 'rank', 'res', 'len', 'off', $
            'dt', 'compression_type', 'compression_level', 'name_len', $
            'descr_len', 'reserved', 'data_len_disk', 'next_stack_pos']

    tmps = create_struct(tags, bytarr(16), $
                               ulong(0), $
                               ulong(0), $
                               ulonarr(omas_max_dimensions), $
                               dblarr(omas_max_dimensions), $
                               dblarr(omas_max_dimensions), $
                               long(0), $
                               ulong(0), $
                               ulong(0), $
                               ulong(0), $
                               ulong(0), $
                               ulong64(0), $
                               ulong64(0), $
                               ulong64(0), $
                               NAME='wmb_obf_stack_header_v1')

end