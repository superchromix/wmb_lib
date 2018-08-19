
; wmb_typecode_is_real
; 
; Returns 1 if the IDL datatype code corresponds to a real numeric type.
; 


function wmb_typecode_is_real, input_type

    return, input_type eq 4 or $
            input_type eq 5 or $
            input_type eq 6 or $
            input_type eq 9
    
end