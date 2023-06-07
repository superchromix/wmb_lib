;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_1d_render
;
;   CSAPS cubic smoothing spline
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_1d_render, x_input, spl_breaks, spl_coeffs 

    compile_opt idl2, strictarrsubs

    spl_int_bound_sort_ind = sort(spl_breaks)
    spl_interval_bounds_sorted = spl_breaks[spl_int_bound_sort_ind]

    ; for each x_input value, determine the corresponding spline interval

    tmp_n_points = N_elements(x_input)
    tmp_bin_edges = spl_interval_bounds_sorted
    tmp_n_bins = N_elements(tmp_bin_edges) - 1

    tmp_hist = wmb_variable_bin_histogram(x_input, $
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
    
    ; add X values at the leftmost boundary (and beyond) to the first interval
    tmpind = where(x_input lt tmp_bin_edges[0], n_past_left_bound)
    if n_past_left_bound gt 0 then interval_index[tmpind] = 0

    ; add X values at the rightmost boundary (and beyond) to the last interval
    tmpind = where(x_input ge tmp_bin_edges[-1], n_past_right_bound)
    if n_past_right_bound gt 0 then interval_index[tmpind] = tmp_n_bins - 1
    

    y_out = fltarr(tmp_n_points)
    
    for i = 0, tmp_n_points-1 do begin
        
        tmpx = x_input[i]
        tmp_int = interval_index[i]
        deltax = tmpx - spl_interval_bounds_sorted[tmp_int]
        
        tmpa = spl_coeffs[tmp_int,0]
        tmpb = spl_coeffs[tmp_int,1]
        tmpc = spl_coeffs[tmp_int,2]
        tmpd = spl_coeffs[tmp_int,3]
        
        y_out[i] = tmpd + $
                   tmpc * deltax + $
                   tmpb * deltax^2 + $
                   tmpa * deltax^3
        
    endfor
    
    return, y_out

end