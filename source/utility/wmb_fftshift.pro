;
;   wmb_fftshift
;
;   Replicates the functionality of the Matlab function "fftshift"
;

function wmb_fftshift, input_array

    compile_opt idl2, strictarrsubs

    array_size = size(input_array, /DIMENSIONS)
    
    return, shift(input_array, array_size/2) 
    
end