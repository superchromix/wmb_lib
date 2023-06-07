function splineCOEFF_render, x_input, x_output, spl_interval_bounds, spl_coeffs 

    compile_opt idl2, strictarrsubs

    x_input_sort_ind = sort(x_input)
    spl_int_bound_sort_ind = sort(spl_interval_bounds)
    
    x_input_sorted = x_input[x_input_sort_ind]
    spl_interval_bounds_sorted = spl_interval_bounds[spl_int_bound_sort_ind]

    ; for each x_input value, determine the corresponding spline interval

    tmp_n_points = N_elements(x_input_sorted)
    tmp_bin_edges = spl_interval_bounds_sorted
    tmp_n_bins = N_elements(tmp_bin_edges) - 1

    tmp_hist = wmb_variable_bin_histogram(x_input_sorted, $
                                          tmp_n_bins, $
                                          tmp_bin_edges, $
                                          reverse_indices = tmp_ri)
    
    interval_index = lonarr(tmp_n_points)
    interval_index[*] = -1
    
    for i = 0, tmp_n_bins-1 do begin
        
        si = tmp_ri[i]
        ei = tmp_ri[i+1] - 1
        n_ind = ei-si+1
        
        if n_ind gt 0 then begin
            
            tmp_ind = tmp_ri[si:ei]
            interval_index[tmp_ind] = i
            
        endif
        
    endfor
    
    ; add X values at the rightmost boundary (and beyond) to the last interval
    tmpind = where(x_input_sorted ge tmp_bin_edges[-1], n_past_right_bound)

    if n_past_right_bound gt 0 then begin
    
        interval_index[tmpind] = N_elements(spl_coeffs) - 1
        
    endif
    
    in_range_index = where(interval_index ne -1, n_in_range, NCOMPLEMENT=n_out_of_range)
    
    if n_in_range ne 0 then begin
        
        x_input_in_range = x_input_sorted[in_range_index]
        interval_index = interval_index[in_range_index]
        
    endif else begin
        
        message, 'No input X elements in range'
        
    endelse
    
    y_out = fltarr(n_in_range)
    
    for i = 0, n_in_range-1 do begin
        
        tmpx = x_input_in_range[i]
        tmp_int = interval_index[i]
        deltax = tmpx - spl_interval_bounds_sorted[tmp_int]
        
        tmpa = (spl_coeffs[tmp_int].a)
        tmpb = (spl_coeffs[tmp_int].b)
        tmpc = (spl_coeffs[tmp_int].c)
        tmpd = (spl_coeffs[tmp_int].d)
        
        y_out[i] = tmpd + $
                   tmpc * deltax + $
                   tmpb * deltax^2 + $
                   tmpa * deltax^3
        
    endfor
    
    x_output = x_input_in_range
    
    return, y_out

end