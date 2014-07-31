pro wmb_destroyhash, inputhash

    compile_opt idl2, strictarrsubs

    if isa(inputhash, 'HASH') then begin
    
        foreach value, inputhash do begin
        
            if isa(value, 'HASH') then dv_destroyhash, value
            if isa(value, 'LIST') then dv_destroylist, value
            if isa(value, 'POINTER') then ptr_free, value
            if isa(value, 'OBJREF') then obj_destroy, value
        
        endforeach

    endif

end