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
            return, 0
        end
        
        1: return, 1
        2: return, 2
        3: return, 4
        4: return, 4
        5: return, 8
        6: return, 8

        7: begin
            error = 1
            return, 0
        end
        
        8: begin
            error = 1
            return, 0
        end
        
        9: return, 16

        
        10: return, 4
      
        11: begin
            error = 1
            return, 0
        end      
        
        12: return, 2
        13: return, 4
        14: return, 8
        15: return, 8
        
        else: begin
            error = 1
            return, 0
        end
        
    endcase

end
