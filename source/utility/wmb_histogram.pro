;
;   wmb_histogram
;
;   Histogram with automatic bin size calculation.
;   
;   Y = wmb_histogram(X)
;

function wmb_histogram, data, $
                        binsize = binsize, $
                        output_binsize = output_binsize, $
                        locations = locations, $
                        omax = omax, $
                        omin = omin, $
                        reverse_indices = reverse_indices, $
                        x_center_locations = x_center_locations, $
                        _Extra = extra
                        

    compile_opt idl2, strictarrsubs
    
    set_opt_binsize = N_elements(binsize) eq 0
    
    input_dtype = size(data,/TYPE)   
    
    if set_opt_binsize eq 1 then begin
    
        ; an input binsize has not been specified
    
        chk_float = input_dtype eq 4
        chk_double = input_dtype eq 5

        ; if the data is integer type, convert it to float
        
        if chk_float eq 0 and chk_double eq 0 then data_mod = double(data) $
                                              else data_mod = data
        
    
        data_iqr = wmb_iqr(data_mod)
        data_nsamples = N_elements(data_mod)
        
        data_n_cubroot = data_nsamples^(1.0d/3.0d)
        
        opt_bin_size = 2 * data_iqr / data_n_cubroot
        
        ; the next operation is arbitrary
        opt_bin_size = opt_bin_size / 2.0
        
        if opt_bin_size eq 0 then opt_bin_size = 1.0
        
        output_hist = histogram(data_mod, binsize = opt_bin_size, $
                                          locations = locations, $
                                          omax = omax, $
                                          omin = omin, $
                                          reverse_indices = reverse_indices, $
                                          _Extra = extra)
        
        x_center_locations = locations + (opt_bin_size / 2.0)
        
        output_binsize = opt_bin_size
        
    endif else begin
        
        ; an input binsize has been specified
        
        output_hist = histogram(data, binsize = binsize, $
                                      locations = locations, $
                                      omax = omax, $
                                      omin = omin, $
                                      reverse_indices = reverse_indices, $
                                      _Extra = extra)

        x_center_locations = locations + (binsize / 2.0)

        output_binsize = binsize

    endelse

    return, output_hist

end
