;
;   wmb_ifftshift
;
;   Replicates the functionality of the Matlab function "ifftshift"
;

function wmb_ifftshift, input_array

    compile_opt idl2, strictarrsubs

    array_size = size(input_array, /DIMENSIONS)
    
    return, shift(input_array, -array_size/2) 
    
end