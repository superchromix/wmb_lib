;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_stack_footer_v2__define.pro
;
; Structure definition for the wmb_obf_stack_footer_v2 struct.
; 
;

pro wmb_obf_stack_footer_v2__define

    omas_max_dimensions = 15

    tmpa = {wmb_obf_si_unit}
    
    tmpb = replicate(tmpa, omas_max_dimensions)

    tags = ['size', 'has_col_positions', 'has_col_labels', $
            'metadata_length', 'si_unit_value', 'si_unit_dimensions']

    tmps = create_struct(tags, ulong(0), $
                               ulonarr(omas_max_dimensions), $
                               ulonarr(omas_max_dimensions), $
                               ulong(0), $
                               tmpa, $
                               tmpb, $
                               NAME='wmb_obf_stack_footer_v2')

end