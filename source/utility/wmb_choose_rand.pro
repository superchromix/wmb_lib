;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_choose_rand
;
;   Returns an array of N unique random integer indices from 
;   a range of length M, spanning 0..(M-1)
;   
;   NB: For large ranges, the vectorized version of this code
;   is slow.  This could be alleviated using a for loop and
;   keeping track of the chosen indices.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_choose_rand, N, M, seed = seed, sorted = sorted

    compile_opt idl2, strictarrsubs

    if N_elements(seed) eq 0 then seed = systime(/seconds)
    if N_elements(sorted) eq 0 then sorted = 0

    ; Create a vector of length M with sequential numbers
    list = lindgen(M)
    
    ; Choose N unique random numbers using the random permutation function
    perm = randomu(seed,M)
    index = sort(perm)
    chosen = list[index[0:N-1]]

    if sorted eq 1 then begin
        
        chosen = chosen[sort(chosen)]
        
    endif

    return, chosen
    
end