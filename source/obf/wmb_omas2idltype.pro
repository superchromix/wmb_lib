;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   dv_OMAS2IDLtype
;   
;   A function which converts between the OMAS data type 
;   definition and the standard IDL data type definition.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_OMAS2IDLtype, omastype, error=error

    compile_opt idl2, strictarrsubs

    error = 0

    case omastype of
    
        0: begin
            error = 1
            return, 0
        end
        
        1: return, 1
        2: return, 1
        4: return, 12
        8: return, 2
        16: return, 13
        32: return, 3
        64: return, 4
        128: return, 5
        
        1024: begin
            error = 1
            return, 0
        end
        
        2048: begin
            error = 1
            return, 0
        end
      
        4096: return, 15
        8192: return, 14
        
        else: begin
            error = 1
            return, 0
        end
        
    endcase

end
