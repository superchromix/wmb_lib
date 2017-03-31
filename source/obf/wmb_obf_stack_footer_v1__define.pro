;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_stack_footer_v1__define.pro
;
; Structure definition for the wmb_obf_stack_footer_v1 struct.
; 
; Note that as of OMAS version 0.1, OMAS_MAX_DIMENSIONS=15
; 
; 
;

pro wmb_obf_stack_footer_v1__define

    omas_max_dimensions = 15

    tags = ['size', 'has_col_positions', 'has_col_labels']

    tmps = create_struct(tags, ulong(0), $
                               ulonarr(omas_max_dimensions), $
                               ulonarr(omas_max_dimensions), $
                               NAME='wmb_obf_stack_footer_v1')

end