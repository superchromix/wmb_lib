;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_dtype_max_value
;   
;   A function which returns the maximum value of a given
;   IDL datatype.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_dtype_max_value, type, error=error

    compile_opt idl2, strictarrsubs

    error = 0

    case type of
    
        1: return, fix((2ULL^8)-1, type=1)
        2: return, fix((2ULL^15)-1, type=2)
        3: return, fix((2ULL^31)-1, type=3)
        4: return, fix(2.0^127, type=4)
        5: return, fix(2.0D^1023, type=5)
        6: return, complex(2.0^127, 2.0^127)
        
        9: return, dcomplex(2.0D^1023, 2.0D^1023)

        12: return, fix((2ULL^16)-1, type=12)
        13: return, fix((2ULL^32)-1, type=13)
        14: return, fix((2ULL^63)-1, type=14)
        15: return, fix((2ULL^64)-1, type=15)
        
        else: begin
            error = 1
            return, 0ULL
        end
        
    endcase

end
