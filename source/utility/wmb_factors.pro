
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_factors
;
;   Returns the prime factors of an integer number.  
;   
;   Based on code posted to the comp.lang.idl-pvwave newsgroup
;   by Martin Downing and Bob Stockwell.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_factors, num, factor_start = factor_start

    compile_opt idl2, strictarrsubs

    maxfac = sqrt(abs(num))
    
    if n_elements(factor_start) eq 0 then begin
        if maxfac gt 1073741824 then factor_start = long64(2) $
                                else factor_start = 2L
    endif

    ; find the lowest factor and return that plus the result of factoring 
    ; the remainder

    
    ;stop
    for f = factor_start, maxfac do begin
        if num mod f eq 0 then begin
            return, [f, wmb_factors(num/f, factor_start = f)]
        endif
    endfor

    ; or return if prime
    return, [num,1]
    
end