;
;   wmb_find_maxima
;

function wmb_find_maxima, array, $
                          max_values = max_values, $
                          n_maxima = n_maxima, $
                          x_values_in = x_values_in, $
                          parabolic_fit_vertex_x_out = parabolic_fit_vertex_x_out, $
                          parabolic_fit_vertex_y_out = parabolic_fit_vertex_y_out, $
                          largest_maximum_index = largest_maximum_index, $
                          use_svd = use_svd


    compile_opt idl2, strictarrsubs
    
    if N_elements(use_svd) eq 0 then use_svd = 0
    x_values_specified = N_elements(x_values_in) eq N_elements(array) 
    
    if x_values_specified eq 0 then x_values_in = findgen(N_elements(array))
    
    maxima_indices = []
    max_values = []
    n_maxima = 0
    parabola_vertices_x = []
    parabola_vertices_y = []
    
    n_array_elements = N_elements(array)
    
    for i = 1, n_array_elements-2 do begin
        
        if array[i] gt array[i-1] and array[i] ge array[i+1] then begin
            
            x_in = x_values_in[i-1:i+1]
            y_in = array[i-1:i+1]
            
            if use_svd eq 0 then begin
            
                fit_result = wmb_three_point_parabola_fit(x_in, y_in, vertex_x = vertex_x, vertex_y = vertex_y)
                
            endif else begin
                
                fit_result = wmb_three_point_parabola_fit_svd(x_in, y_in, vertex_x = vertex_x, vertex_y = vertex_y)
                
            endelse
            
            maxima_indices = [maxima_indices, i]
            max_values = [max_values, array[i]]
            parabola_vertices_x = [parabola_vertices_x, vertex_x]
            parabola_vertices_y = [parabola_vertices_y, vertex_y]
            
        endif

    endfor
    
    n_maxima = N_elements(maxima_indices)
    
    parabolic_fit_vertex_x_out = parabola_vertices_x
    parabolic_fit_vertex_y_out = parabola_vertices_y
    
    max_values_sort_index = sort(max_values)
    
    largest_maximum_index = max_values_sort_index[-1]
    
    return, maxima_indices
    
end
