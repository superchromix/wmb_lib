
; wmb_is_real
; 
; Returns 1 if the argument is a real numeric type.
; 


function wmb_is_real, input_variable

    tmp_dtype = size(input_variable, /TYPE)
    
    return, tmp_dtype eq 4 or $
            tmp_dtype eq 5 or $
            tmp_dtype eq 6 or $
            tmp_dtype eq 9
    
end