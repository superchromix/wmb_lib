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
            return, 0LL
        end
        
        1: return, 1LL
        2: return, 2LL
        3: return, 4LL
        4: return, 4LL
        5: return, 8LL
        6: return, 8LL

        7: begin
            error = 1
            return, 0LL
        end
        
        8: begin
            error = 1
            return, 0LL
        end
        
        9: return, 16LL

        
        10: return, 4LL
      
        11: begin
            error = 1
            return, 0LL
        end      
        
        12: return, 2LL
        13: return, 4LL
        14: return, 8LL
        15: return, 8LL
        
        else: begin
            error = 1
            return, 0LL
        end
        
    endcase

end
