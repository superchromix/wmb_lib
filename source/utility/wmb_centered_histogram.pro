;
;   wmb_histogram
;
;

function wmb_centered_histogram, array, $
                                 nbins = nbins, $
                                 locations = locations, $
                                 omax = omax,  $
                                 omin = omin, $
                                 reverse_indices = reverse_indices, $
                                 _extra=extra


    compile_opt idl2, strictarrsubs

    if N_elements(nbins) eq 0 then nbins = 50

    range_expansion_factor = 1.2

    arr_max = max(array, min=arr_min)
    
    arr_center = (arr_max + arr_min) / 2.0

    arr_range = double(arr_max) - arr_min

    arr_range_expanded = arr_range * range_expansion_factor

    hist_min = arr_center - (arr_range_expanded)/2.0
    hist_max = arr_center + (arr_range_expanded)/2.0
    
    hist_binsize = arr_range_expanded/nbins

    return, histogram(array, $
                      min = hist_min, $
                      max = hist_max, $
                      binsize = hist_binsize, $
                      locations = locations, $
                      omax = omax,  $
                      omin = omin, $
                      reverse_indices = reverse_indices, $
                      _Extra=extra)

end
