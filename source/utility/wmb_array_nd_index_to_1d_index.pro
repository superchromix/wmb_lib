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
