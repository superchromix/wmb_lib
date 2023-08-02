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


function wmb_choose_rand, N, M, seed = seed, sorted = sorted, execution_time = execution_time

    compile_opt idl2, strictarrsubs

    if N_elements(seed) eq 0 then seed = systime(/seconds)
    if N_elements(sorted) eq 0 then sorted = 0

    if N gt M then message, 'Invalid choice of M and N'

    large_M_cutoff = 5000000
    large_N_cutoff = 10000000
    
    method_vectorized = 1
    
    if M gt large_M_cutoff then method_vectorized = 0
    if N gt large_N_cutoff then method_vectorized = 1
    if double(N) / M gt 0.9 then method_vectorized = 1
    
    tmp_timer = tic() 
    
    if method_vectorized eq 1 then begin

        ; Create a vector of length M with sequential numbers
        list = lindgen(M)
        
        ; Choose N unique random numbers using the random permutation function
        perm = randomu(seed,M,/DOUBLE)
        index = sort(perm)
        chosen = list[index[0:N-1]]
    
        if sorted eq 1 then begin
            
            chosen = chosen[sort(chosen)]
            
        endif
        
    endif else begin
        
        chk_chosen = bytarr(M)
        chosen = lonarr(N)
        
        tmpcnt = 0LL
        
        while tmpcnt le N-1 do begin
        
            tmpind = floor(randomu(seed,/DOUBLE) * M)
            if chk_chosen[tmpind] eq 0B then begin
                
                chosen[tmpcnt] = tmpind
                chk_chosen[tmpind] = 1B
                tmpcnt++
                
            endif
        
        endwhile
        
    endelse
    
    execution_time = toc(tmp_timer)
    
    return, chosen

end