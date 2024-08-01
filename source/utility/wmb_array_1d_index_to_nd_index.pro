;
;   wmb_1d_index_to_nd_index
;

function wmb_array_1d_index_to_nd_index, ndim, input_array_indices, input_array_dims

    compile_opt idl2, strictarrsubs
    
    chk_type = size(input_array_indices, /TYPE)
    if chk_type eq 4 or chk_type eq 5 then message, 'Non-integer index data type'
    
    chk_type = size(input_array_dims, /TYPE)
    if chk_type eq 4 or chk_type eq 5 then message, 'Non-integer array dimensions data type'
    
    n_input_indices = N_elements(input_array_indices)

    tmp_indices = reform(input_array_indices, 1, n_input_indices)

    output_indices = lon64arr(ndim, n_input_indices, /NOZERO)

    tmp_dim_product = product([1LL, input_array_dims[0:-2]], /CUMULATIVE, /INTEGER)
    
    for i = ndim-1, 0, -1 do begin

        tmp_results = tmp_indices / tmp_dim_product[i]

        output_indices[i,0] = tmp_results
        
        tmp_indices -= tmp_results * tmp_dim_product[i]
        
    endfor

    return, output_indices

end


pro test_wmb_array_1d_index_to_nd_index

    compile_opt idl2, strictarrsubs
    
    ndim = 8
    
    arr_dim_sizes = [7, 49, 25, 25, 4, 4, 4, 4]
    
    tmp_timer = tic()
    
    for j = 0, (4^ndim)-1 do begin
    
        ind_array = wmb_array_1d_index_to_nd_index(ndim, j, arr_dim_sizes)
    
        tmp_md_index = wmb_array_nd_index_to_1d_index(ndim, ind_array, arr_dim_sizes)
    
    endfor
    
    exec_time = toc(tmp_timer)
    
    print, exec_time
    
    aa = lindgen(4^ndim)
    
    tmp_timer = tic()
    
    ind_array = wmb_array_1d_index_to_nd_index(ndim, aa, arr_dim_sizes)
    
    tmp_md_index = wmb_array_nd_index_to_1d_index(ndim, ind_array, arr_dim_sizes)
   
    exec_time = toc(tmp_timer)

    print, exec_time
    
end




