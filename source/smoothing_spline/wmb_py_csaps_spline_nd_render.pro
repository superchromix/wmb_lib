;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_nd_render
;
;   CSAPS cubic smoothing spline
;   
;   Note: Spline break coords (for each dimension) must be in
;   ascending order.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_nd_render, ndim, $
                                        input_coords, $
                                        spl_break_dims, $
                                        spl_break_coords, $
                                        spl_coeffs, $
                                        spl_coeff_dims, $
                                        execution_time = execution_time

    compile_opt idl2, strictarrsubs

    tmp_timer = tic()

    n_input_coords = N_elements(input_coords) / ndim
    
    mod_coords = reform(input_coords, n_input_coords, ndim)

    spl_break_start_index = [0, (total(spl_break_dims, /CUMULATIVE, /INTEGER))[0:-2]]


    ; for each input coordinate, determine the corresponding spline interval

    spl_interval_index = lon64arr(n_input_coords, ndim)
    spl_interval_index[*] = -1

    for i = 0, ndim-1 do begin
        
        si = spl_break_start_index[i]
        ei = si + spl_break_dims[i] - 1
        
        tmp_bin_edges = spl_break_coords[si:ei]
        tmp_n_bins = N_elements(tmp_bin_edges) - 1
        
        tmp_coords = mod_coords[*,i]
        
        tmp_hist = wmb_variable_bin_histogram(tmp_coords, $
                                              tmp_n_bins, $
                                              tmp_bin_edges, $
                                              reverse_indices = tmp_ri)
        
        tmp_interval_index = lon64arr(n_input_coords)
        tmp_interval_index[*] = -1
        
        ; assign the interval index for each input point
        
        for j = 0, tmp_n_bins-1 do begin
            
            si = tmp_ri[j]
            ei = tmp_ri[j+1] - 1
            n_ind = ei-si+1
            
            if n_ind gt 0 then begin
                
                tmp_ind = tmp_ri[si:ei]
                tmp_interval_index[tmp_ind] = j
                
            endif
            
        endfor
        
        ; add X values at the leftmost boundary (and beyond) to the first interval
        tmpind = where(tmp_coords lt tmp_bin_edges[0], n_past_left_bound)
        if n_past_left_bound gt 0 then tmp_interval_index[tmpind] = 0
        
        ; add X values at the rightmost boundary (and beyond) to the last interval
        tmpind = where(tmp_coords ge tmp_bin_edges[-1], n_past_right_bound)
        if n_past_right_bound gt 0 then tmp_interval_index[tmpind] = tmp_n_bins - 1
        
        spl_interval_index[0,i] = tmp_interval_index
        
    endfor


    ; determine the interval delta for each point for each dimension
    
    delta_storage = dblarr(n_input_coords, ndim)
    
    for i = 0, ndim-1 do begin
        
        si = spl_break_start_index[i]
        ei = si + spl_break_dims[i] - 1
        
        tmp_bin_edges = spl_break_coords[si:ei]
        
        tmpx = mod_coords[*,i]
        tmp_int_x = spl_interval_index[*,i]
        deltax = tmpx - tmp_bin_edges[tmp_int_x]
        
        delta_storage[0,i] = deltax

    endfor
        
        
    ; calculate the output spline

    f_out = dblarr(n_input_coords)
    f_out[*] = 0.0
        
    tmp_fours_arr = replicate(4,ndim)
    j_index = l64indgen(4^ndim)
        
    power_index_arrays = wmb_array_1d_index_to_nd_index(ndim, j_index, tmp_fours_arr)
    rev_power_index_arrays = reverse(power_index_arrays, 1)
            
    trans_spl_interval_index = transpose(spl_interval_index)
    rev_spl_interval_index = reverse(trans_spl_interval_index, 1)

    spl_coeff_md_ind_array = lon64arr(ndim*2, (4^ndim))
    spl_coeff_md_ind_array[ndim, 0] = rev_power_index_arrays
            
    for i = 0, n_input_coords-1 do begin
        
        tmp_sum = 0.0d
        
        tmp_delta_arr = reform(delta_storage[i,*])
                
        tmp_rev_interval_arr = rev_spl_interval_index[*,i]
                
        for j = 0, ndim-1 do spl_coeff_md_ind_array[j,*] = tmp_rev_interval_arr[j]
            
        spl_coeff_lin_ind_array = wmb_array_nd_index_to_1d_index(ndim*2, spl_coeff_md_ind_array, spl_coeff_dims)
                
        for j = 0, (4^ndim)-1 do begin
 
            tmp_sum += spl_coeffs[spl_coeff_lin_ind_array[j]] * product(tmp_delta_arr^(3-power_index_arrays[*,j]))
        
        endfor
        
        f_out[i] = tmp_sum
        
    endfor
    
    execution_time = toc(tmp_timer)
    
    return, f_out

end