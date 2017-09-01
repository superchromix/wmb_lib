;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_IDL2OMAStype
;   
;   A function which converts between the OMAS data type 
;   definition and the standard IDL data type definition.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_IDL2OMAStype, idltype, error=error

    compile_opt idl2, strictarrsubs

    error = 0

    case idltype of
    
        0: begin
            error = 1
            return, 0
        end
        
        1: return, 1
        2: return, 8
        3: return, 32
        4: return, 64
        5: return, 128
        
        6: begin
            error = 1
            return, 0
        end
        
        7: begin
            error = 1
            return, 0
        end
        
        8: begin
            error = 1
            return, 0
        end
        
        9: begin
            error = 1
            return, 0
        end
        
        10: begin
            error = 1
            return, 0
        end
      
        11: begin
            error = 1
            return, 0
        end
        
        12: return, 4
        13: return, 16
        14: return, 8192
        15: return, 4096
        
        else: begin
            error = 1
            return, 0
        end
        
    endcase

end
