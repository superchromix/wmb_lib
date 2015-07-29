;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_sizeofstruct
;   
;   A function which returns the size (in bytes) of a given 
;   IDL structure.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_sizeofstruct, input_struct

    compile_opt idl2, strictarrsubs

    dtype = size(input_struct, /TYPE)
    
    if dtype ne 8 then message, 'Input must be of type struct'

    n_struct_tags = n_tags(input_struct)

    struct_size = 0L

    for i = 0, n_struct_tags-1 do begin
        
        tmpdat = input_struct.(i)
        dtype = size(tmpdat, /TYPE)
        dtype_size = wmb_sizeoftype(dtype)
        struct_size = struct_size + dtype_size

    endfor

    return, struct_size

end
