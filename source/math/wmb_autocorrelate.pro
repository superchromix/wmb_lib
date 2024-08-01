;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_autocorrelate
;   
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_autocorrelate, x, double=double

    compile_opt idl2, strictarrsubs

    temp = FFT(x, -1, double=double)   
    
    acorr = REAL_PART(FFT(temp * CONJ(temp), 1, double=double))
    
    return, acorr
    
end
    
    