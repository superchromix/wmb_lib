;
;   wmb_minimize_distance
;
;   Returns the minimum euclidean distance point between a given 
;   (measured) vector and a theoretical array of such vectors. 
;
;   The function returns the row in which the distance is 
;   minimum and the corresponding minimum distance. The squared 
;   deviations are weighted if a weight vector is provided.
;   
;   data_vectors:  A 2D array (N x E) of E data vectors of size N 
;   gauge_vectors: A 2D array (N x M) of M gauge vectors of size N
;   weights:       A 1D array of weights (size N)
;

function wmb_minimize_distance, data_vectors, $
                                gauge_vectors, $
                                weights = weights, $
                                min_dist = min_dist

    compile_opt idl2, strictarrsubs
    
    data_dims = size(data_vectors, /DIMENSIONS)
    data_ndim = size(data_vectors, /N_DIMENSIONS)
    gauge_dims = size(gauge_vectors, /DIMENSIONS)
    gauge_ndim = size(gauge_vectors, /N_DIMENSIONS)
    
    if data_ndim ne 2 then message, 'Invalid data dimensions'
    if gauge_ndim ne 2 then message, 'Invalid gauge dimensions'
    
    data_vector_len  = data_dims[0]
    gauge_vector_len = gauge_dims[0]
    n_data_points    = data_dims[1]
    n_gauge_points   = gauge_dims[1]

    if data_vector_len ne gauge_vector_len then $
        message, 'Mismached data and gauge vector sizes'
    
    if N_elements(weights) eq 0 then begin
        
        weights = fltarr(gauge_vector_len)
        weights[*] = 1.0

    endif else begin
        
        if N_elements(weights) ne gauge_vector_len then $
            message, 'Invalid weights array'
        
    endelse
    
    min_index = lonarr(n_data_points, /NOZERO)
    min_dist = fltarr(n_data_points, /NOZERO)
    tmp_dist_array = fltarr(n_gauge_points, gauge_vector_len, /NOZERO)
    
    for i = 0, n_data_points-1 do begin
        
        tmp_data = data_vectors[*,i]

        for j = 0, gauge_vector_len-1 do begin
            
            tmp_dist_array[0,j] = (reform(gauge_vectors[j,*])-tmp_data[j])^2 * weights[j]

        endfor
        
        tmp_sq_dist = total(tmp_dist_array, 2)
        
        min_dist[i] = min(tmp_sq_dist, tmp_min_index)
        min_index[i] = tmp_min_index
        
    endfor
    
    min_dist = sqrt(min_dist)
    
    return, min_index

end
