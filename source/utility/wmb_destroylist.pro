pro wmb_destroylist, inputlist

    compile_opt idl2, strictarrsubs

    if isa(inputlist, 'LIST') then begin
    
        foreach value, inputlist do begin
        
            if isa(value, 'HASH') then dv_destroyhash, value
            if isa(value, 'LIST') then dv_destroylist, value
            if isa(value, 'POINTER') then ptr_free, value
            if isa(value, 'OBJREF') then obj_destroy, value
        
        endforeach

    endif

end