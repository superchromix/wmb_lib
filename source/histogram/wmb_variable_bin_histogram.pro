;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_variable_bin_histogram
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_variable_bin_histogram, data, $
                                     n_bins, $
                                     bin_edges, $
                                     reverse_indices = reverse_indices, $
                                     execution_time = execution_time
                      

    compile_opt idl2, strictarrsubs


    if ~wmb_histogram_findlib(output_library) then $
        message, 'Shared library not found'
    
    
    library_name = output_library

    tmp_timer = tic()

    function_name='variable_bin_histogram_with_indices_portable'
        
    data_len = N_elements(data)
    
    if N_elements(bin_edges) ne n_bins+1 then begin
        
        message, 'Invalid bin edges array'
        
    endif
    
    input_data = float(data)
    input_data_len = long(data_len)
    input_bin_edges = float(bin_edges)
    input_num_bins = long(n_bins)
    output_histogram = lonarr(n_bins)
    output_ri = lonarr((n_bins+1)+data_len)

    ; call the dll
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_data, $
                         input_data_len, $
                         input_bin_edges, $
                         input_num_bins, $
                         output_histogram, $
                         output_ri, $
                         RETURN_TYPE = 3, $
                         /VERBOSE)

    if tmp ne 0 then message, 'Error code ' + strtrim(string(tmp),2)

    tmp_total = total(output_histogram, /INTEGER)

    if tmp_total ne data_len then begin
        
        output_ri = output_ri[0 : n_bins + tmp_total]
        
    endif

    reverse_indices = temporary(output_ri)

    execution_time = toc(tmp_timer)

    return, output_histogram
    
end

