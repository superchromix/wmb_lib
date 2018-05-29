;
;   wmb_diff
;
;   Y = wmb_diff(X)
;   
;   If X is a vector of length m, then Y = diff(X) returns a vector 
;   of length m-1. The elements of Y are the differences between adjacent 
;   elements of X.
;
;   Y = [X[1]-X[0], X[2]-X[1], ... X[m-1]-X[m-2]]
;

function wmb_diff, input_array

    compile_opt idl2, strictarrsubs

    return, (shift(input_array, -1) - input_array)[0:-2]
    
end