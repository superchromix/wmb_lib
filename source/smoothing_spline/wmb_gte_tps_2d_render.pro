;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_gte_tps_2d_render
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_gte_tps_2d_render, x_input, $
                                y_input, $
                                x_orig, $
                                y_orig, $
                                coeffs_a, $
                                coeffs_b 

    compile_opt idl2, strictarrsubs

    n_orig_points = N_elements(x_orig)
    
    if N_elements(coeffs_a) ne n_orig_points then $
        message, 'Invalid coefficients array'

    if N_elements(coeffs_b) ne 3 then $
        message, 'Invalid coefficients array'
        
    f_output = x_input
    
    for i = 0, N_elements(x_input)-1 do begin
        
        tmpx = x_input[i]
        tmpy = y_input[i]
        
        xdiff = tmpx - x_orig
        ydiff = tmpy - y_orig
        
        rsq = xdiff^2 + ydiff^2
        
        f_output[i] = coeffs_b[0] + $
                      coeffs_b[1]*tmpx + $
                      coeffs_b[2]*tmpy + $
                      total(coeffs_a * rsq * alog(rsq))
        
    endfor
        
    return, f_output

end