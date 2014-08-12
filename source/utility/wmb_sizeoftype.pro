;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_sizeoftype
;   
;   A function which returns the size (in bytes) of a given 
;   IDL data type.
;   
;   If the size of the type is undefined the function returns
;   an error.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_sizeoftype, type, error=error

    compile_opt idl2, strictarrsubs

    error = 0

    case type of
    
        0: begin
            error = 1
            return, 0ULL
        end
        
        1: return, 1ULL
        2: return, 2ULL
        3: return, 4ULL
        4: return, 4ULL
        5: return, 8ULL
        6: return, 8ULL

        7: begin
            error = 1
            return, 0ULL
        end
        
        8: begin
            error = 1
            return, 0ULL
        end
        
        9: return, 16ULL

        
        10: return, 4ULL
      
        11: begin
            error = 1
            return, 0ULL
        end      
        
        12: return, 2ULL
        13: return, 4ULL
        14: return, 8ULL
        15: return, 8ULL
        
        else: begin
            error = 1
            return, 0ULL
        end
        
    endcase

end
