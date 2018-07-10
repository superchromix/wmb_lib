
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_discard_outliers
;
;   Calculate the interquartile range for the input array.  Any
;   values outside the range [median-k_factor*iqr, median+k_factor*iqr] is
;   considered to be an outlier.
;
;   This criterion for discarding outliers is based on the Tukey test.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_discard_outliers, array_in, $
                               k_factor = k_factor, $
                               n_values_returned = n_values_returned, $
                               retained_values_index = retained_values_index
                               

    compile_opt idl2, strictarrsubs

    if N_elements(k_factor) eq 0 then k_factor = 1.5
    
    array_iqr = wmb_iqr(array_in, quartiles=array_quartiles)
    
    outlier_lower_lim = array_quartiles[1] - (k_factor * array_iqr)
    
    outlier_upper_lim = array_quartiles[1] + (k_factor * array_iqr)

    good_values_index = where(array_in ge outlier_lower_lim AND $
                              array_in le outlier_upper_lim, n_good_val)
                              
    retained_values_index = good_values_index
                              
    if n_good_val gt 0 then begin
        
        n_values_returned = n_good_val
        return, array_in[good_values_index]
        
    endif else begin
        
        n_values_returned = 0
        return, []
        
    endelse
    
end