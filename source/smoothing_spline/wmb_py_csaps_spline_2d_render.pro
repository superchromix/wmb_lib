;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_2d_render
;
;   CSAPS cubic smoothing spline
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_2d_render, x_input, $
                                        y_input, $
                                        spl_breaks_x, $
                                        spl_breaks_y, $
                                        spl_coeffs 

    compile_opt idl2, strictarrsubs

    spl_int_bound_x_sort_ind = sort(spl_breaks_x)
    spl_int_bound_y_sort_ind = sort(spl_breaks_y)
    
    spl_interval_bounds_x_sorted = spl_breaks_x[spl_int_bound_x_sort_ind]
    spl_interval_bounds_y_sorted = spl_breaks_y[spl_int_bound_y_sort_ind]

    ; for each x_input value, determine the corresponding spline interval

    tmp_n_points = N_elements(x_input)
    
    tmp_bin_edges_x = spl_interval_bounds_x_sorted
    tmp_n_bins_x = N_elements(tmp_bin_edges_x) - 1

    tmp_bin_edges_y = spl_interval_bounds_y_sorted
    tmp_n_bins_y = N_elements(tmp_bin_edges_y) - 1

    tmp_hist_x = wmb_variable_bin_histogram(x_input, $
                                            tmp_n_bins_x, $
                                            tmp_bin_edges_x, $
                                            reverse_indices = tmp_ri_x)

    tmp_hist_y = wmb_variable_bin_histogram(y_input, $
                                            tmp_n_bins_y, $
                                            tmp_bin_edges_y, $
                                            reverse_indices = tmp_ri_y)
    
    interval_index_x = lonarr(tmp_n_points)
    interval_index_x[*] = -1
    
    interval_index_y = lonarr(tmp_n_points)
    interval_index_y[*] = -1
    
    
    ; assign the X interval index for each input point
    
    for i = 0, tmp_n_bins_x-1 do begin
        
        si = tmp_ri_x[i]
        ei = tmp_ri_x[i+1] - 1
        n_ind = ei-si+1
        
        if n_ind gt 0 then begin
            
            tmp_ind = tmp_ri_x[si:ei]
            interval_index_x[tmp_ind] = i
            
        endif
        
    endfor
    
    ; add X values at the leftmost boundary (and beyond) to the first interval
    tmpind = where(x_input lt tmp_bin_edges_x[0], n_past_left_bound)
    if n_past_left_bound gt 0 then interval_index_x[tmpind] = 0
    
    ; add X values at the rightmost boundary (and beyond) to the last interval
    tmpind = where(x_input ge tmp_bin_edges_x[-1], n_past_right_bound)
    if n_past_right_bound gt 0 then interval_index_x[tmpind] = tmp_n_bins_x - 1


    ; assign the Y interval index for each input point

    for i = 0, tmp_n_bins_y-1 do begin

        si = tmp_ri_y[i]
        ei = tmp_ri_y[i+1] - 1
        n_ind = ei-si+1

        if n_ind gt 0 then begin

            tmp_ind = tmp_ri_y[si:ei]
            interval_index_y[tmp_ind] = i

        endif

    endfor

    ; add Y values at the leftmost boundary (and beyond) to the first interval
    tmpind = where(y_input lt tmp_bin_edges_y[0], n_past_left_bound)
    if n_past_left_bound gt 0 then interval_index_y[tmpind] = 0

    ; add Y values at the rightmost boundary (and beyond) to the last interval
    tmpind = where(y_input ge tmp_bin_edges_y[-1], n_past_right_bound)
    if n_past_right_bound gt 0 then interval_index_y[tmpind] = tmp_n_bins_y - 1


    z_out = double(x_input)
    z_out[*] = 0.0
    
    for i = 0, tmp_n_points-1 do begin
        
        tmpx = x_input[i]
        tmp_int_x = interval_index_x[i]
        deltax = tmpx - spl_interval_bounds_x_sorted[tmp_int_x]
        
        tmpy = y_input[i]
        tmp_int_y = interval_index_y[i]
        deltay = tmpy - spl_interval_bounds_y_sorted[tmp_int_y]
        
        tmp_sum = 0.0d
        
        for j = 0, 3 do begin
            for k = 0, 3 do begin
            
                tmp_sum += spl_coeffs[tmp_int_y, tmp_int_x, k, j] * deltax^(3-j) * deltay^(3-k)
            
            endfor
        endfor
        
        z_out[i] = tmp_sum
        
    endfor
    
    return, z_out

end