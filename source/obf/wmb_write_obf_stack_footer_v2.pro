;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_write_obf_stack_footer_v2.pro
;
; units:  0: dimensionless
;         1: micrometers
;         2: seconds
;         
; value_scaling_factor: allows the scale factor field of the value unit
;                       to be stored
;                       
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_write_obf_stack_footer_v2, obf_uid, $
                      rank, $
                      value_unit, $
                      dimension_units, $
                      value_scalefactor = value_scalefactor, $
                      next_stack_header_position = next_stack_header_position
                              
                                    
    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler
    
    
    if N_elements(value_unit) ne 1 then message, 'Invalid value unit'
    
    if N_elements(dimension_units) ne rank then $
        message, 'Invalid dimension units'
   
    flag_edit_value_scalefactor = 0
   
    if N_elements(value_scalefactor) eq 1 then flag_edit_value_scalefactor = 1
    
    
    stack_footer_size = 1408ULL

    ulon_zero_arr = ulonarr(15)


    ft_val_unit = {wmb_obf_si_unit}
    
    case value_unit of
        0: ft_val_unit = wmb_obf_si_get_dimensionless()
        1: ft_val_unit = wmb_obf_si_get_micrometer()
        2: ft_val_unit = wmb_obf_si_get_second() 
    endcase

    if flag_edit_value_scalefactor eq 1 then begin
        
        ft_val_unit.scalefactor = value_scalefactor
        
    endif


    ft_dim_units = replicate({wmb_obf_si_unit},15)
    
    for i = 0, rank-1 do begin
        case dimension_units[i] of
            0: ft_dim_units[i] = wmb_obf_si_get_dimensionless()
            1: ft_dim_units[i] = wmb_obf_si_get_micrometer()
            2: ft_dim_units[i] = wmb_obf_si_get_second() 
        endcase
    endfor

    
    stack_footer = {wmb_obf_stack_footer_v2} 
    
    stack_footer.size = stack_footer_size
    stack_footer.has_col_positions = ulon_zero_arr
    stack_footer.has_col_labels = ulon_zero_arr
    stack_footer.metadata_length = 0
    stack_footer.si_unit_value = ft_val_unit
    stack_footer.si_unit_dimensions = ft_dim_units
    
    ; write the footer
    
    writeu, obf_uid, stack_footer
        
    ; write the label lengths
    
    writeu, obf_uid, ulonarr(rank)
        
    ; store the position of the next stack header
    
    point_lun, -obf_uid, next_stack_header_position

end