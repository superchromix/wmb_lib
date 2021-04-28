;
;   wmb_find_maxima
;

function wmb_find_maxima, array, max_values = max_values, n_maxima = n_maxima

    compile_opt idl2, strictarrsubs
    
    maxima_indices = []
    max_values = []
    n_maxima = 0
    
    n_array_elements = N_elements(array)
    
    for i = 1, n_array_elements-2 do begin
        
        if array[i] gt array[i-1] and array[i] ge array[i+1] then begin
            
            maxima_indices = [maxima_indices, i]
            max_values = [max_values, array[i]]
            
        endif

    endfor
    
    n_maxima = N_elements(maxima_indices)
    
    return, maxima_indices
    
end
