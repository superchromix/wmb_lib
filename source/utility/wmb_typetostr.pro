;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_typetostr
;   
;   A function which returns a string description of an
;   IDL data type.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_typetostr, type

    compile_opt idl2, strictarrsubs

    case type of
    
        0: return, 'UNDEFINED'
        1: return, 'BYTE8'
        2: return, 'INT16'
        3: return, 'INT32'
        4: return, 'FLOAT32'
        5: return, 'DOUBLE64'
        6: return, 'COMPLEX_FLOAT64'
        7: return, 'STRING'
        8: return, 'STRUCT'
        9: return, 'COMPLEX_DOUBLE128'
        10: return, 'POINTER_INT32'
        11: return, 'OBJREF'    
        12: return, 'UINT16'
        13: return, 'UINT32'
        14: return, 'INT64'
        15: return, 'UINT64'
        else: return, 'UNDEFINED'
        
    endcase

end
