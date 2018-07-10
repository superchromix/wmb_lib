;
;   wmb_iqr
;
;   Returns the interquartile range of the values in the input array.
;   
;   Y = wmb_iqr(X)
;   
;   Y is the difference between the 75th and 25th percentiles of X.
;

function wmb_iqr, input_array, quartiles = quartiles

    compile_opt idl2, strictarrsubs
    
    array_len = N_elements(input_array)

    sort_index = sort(input_array)
    
    q25_index = sort_index[floor(0.25 * array_len)]
    q50_index = sort_index[floor(0.50 * array_len)]
    q75_index = sort_index[floor(0.75 * array_len)]
    
    quartiles = [input_array[q25_index], $
                 input_array[q50_index], $
                 input_array[q75_index]]
    
    return, input_array[q75_index] - input_array[q25_index]

end
