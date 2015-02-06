
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Helper method for testing valid indices and ranges
;   
;   positive_index is an output keyword which returns the 
;   corresponding index with a positive value
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_Indexvalid, index, $
                         dimension_size, $
                         positive_index = positive_index

    compile_opt idl2, strictarrsubs

    chkdim = dimension_size
    
    ; create a positive version of the index - note that index may be an array
    
    positive_index = index
    
    foreach val, positive_index, i do begin
    
        if val lt 0 then positive_index[i] = val + chkdim
    
    endforeach
    
    minrange = 0LL
    maxrange = chkdim - 1LL
    
    test_min_error = positive_index lt minrange
    test_max_error = positive_index gt maxrange
    
    ; convert arrays to scalars    
    test_min_error = max(test_min_error)
    test_max_error = max(test_max_error)
    
    if test_min_error || test_max_error then return, 0
    
    return, 1
    
end

