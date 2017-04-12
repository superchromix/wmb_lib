
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_convert_to_base_unit.pro
;
;

pro wmb_obf_si_convert_to_base_unit, input_value, $
                                     input_unit, $
                                     output_value, $
                                     output_unit

    compile_opt idl2, strictarrsubs
        
    tmp_scale = input_unit.scalefactor
    output_value = double(input_value) * tmp_scale
    
    output_unit = input_unit
    output_unit.scalefactor = 1.0d
    
end