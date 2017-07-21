;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_set_union
;
;   Returns the union of two arrays.
;   
;   Based on code published on David Fanning's IDL Coyote
;   web page (http://www.idlcoyote.com).
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_set_union, a, b

    compile_opt idl2, strictarrsubs

    superset = [a, b]
    union = superset[uniq(superset, sort(superset))]
    
    return, union

end
