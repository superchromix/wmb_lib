;
;   wmb_array_nd_index_to_1d_index
;

function wmb_array_nd_index_to_1d_index, ndim, input_array_indices, input_array_dims

    compile_opt idl2, strictarrsubs
    
    chk_type = size(input_array_indices, /TYPE)
    if chk_type eq 4 or chk_type eq 5 then message, 'Non-integer index data type'
    
    chk_type = size(input_array_dims, /TYPE)
    if chk_type eq 4 or chk_type eq 5 then message, 'Non-integer array dimensions data type'
    
    n_arr_dim = size(input_array_indices, /N_DIMENSIONS)
    
    if n_arr_dim eq 1 then n_input_indices = 1 $
                      else n_input_indices = (size(input_array_indices, /DIMENSIONS))[1]
    
    tmp_indices = reform(long64(input_array_indices), ndim, n_input_indices)
    
    tmp_dim_product = product([1, input_array_dims[0:-2]], /CUMULATIVE, /INTEGER)
        
    for i = 0, ndim-1 do tmp_indices[i,0] = tmp_indices[i,*] * tmp_dim_product[i]

    output_indices = total(tmp_indices, 1, /INTEGER)

    ;tmp_index = where(output_indices gt product(input_array_dims)-1, n_errors)
    ;if n_errors gt 0 then message, 'Algorithm failed'

    return, output_indices

end


pro test_wmb_array_nd_index_to_1d_index

    compile_opt idl2, strictarrsubs
    
    seeda = systime(/SECONDS)
    
    n_indices = 1000000
    
    arr_dims = long64([5,20,60,4,7])
    n_arr_dims = N_elements(arr_dims)
    
    tmpa = randomu(seeda,n_arr_dims,n_indices)
    
    for i = 0, n_arr_dims-1 do tmpa[i,*] *= arr_dims[i]
    
    input_nd_indices = long64(floor(tmpa))
    
    tmp_timer = tic()
    output_1d_indices_a = wmb_array_nd_index_to_1d_index(n_arr_dims,input_nd_indices,arr_dims)
    exec_time_a = toc(tmp_timer)

    tmp_timer = tic()
    output_1d_indices_b = WMB_DLM_LIB_array_nd_index_to_1d_index(n_arr_dims,input_nd_indices,arr_dims)
    exec_time_b = toc(tmp_timer)

    print, 'Exec time A', exec_time_a
    print, 'Exec time B', exec_time_b

end