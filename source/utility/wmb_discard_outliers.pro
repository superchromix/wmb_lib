
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_discard_outliers
;
;   Take the central 80% of the sorted array values and calculate 
;   the standard deviation of the values.  Then, discard any values
;   of the array which fall beyond a given number of standard 
;   deviations from the mean.  
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_discard_outliers, array_in, $
                               n_std_dev = n_std_dev, $
                               n_values_returned = n_values_returned, $
                               retained_values_index = retained_values_index
                               

    compile_opt idl2, strictarrsubs

    if N_elements(n_std_dev) eq 0 then n_std_dev = 6.0

    n_elts = N_elements(array_in)

    if n_elts le 3 then return, array_in

    sort_ind = sort(array_in)
    
    start_ind = ceil(n_elts * 0.1)
    end_ind = floor(n_elts * 0.9) - 1
    
    n_central_elts = (end_ind - start_ind) + 1
    
    sorted_central_values = (array_in[sort_ind])[start_ind:end_ind]
    
    result = moment(sorted_central_values, $
                    MEAN=central_mean, $
                    SDEV=central_std_dev)
        
    lower_thresh = central_mean - (central_std_dev * n_std_dev)
    upper_thresh = central_mean + (central_std_dev * n_std_dev)
    
    good_values_index = where(array_in ge lower_thresh AND $
                              array_in le upper_thresh, n_good_val)
                              
    retained_values_index = good_values_index
                              
    if n_good_val gt 0 then begin
        
        n_values_returned = n_good_val
        return, array_in[good_values_index]
        
    endif else begin
        
        n_values_returned = 0
        return, []
        
    endelse
    
end