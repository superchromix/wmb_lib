;
;   wmb_rem
;
;   Remainder after division
;

function wmb_rem, a, b

    compile_opt idl2, strictarrsubs
    
    return, a - b * fix(a/double(b))

end
