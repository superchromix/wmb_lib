;
;   wmb_unwrap
;
;   wmb_unwrap(P) unwraps radian phases P by changing absolute 
;   jumps greater than pi to their 2*pi complement.
;

function wmb_unwrap, p, cutoff = cutoff

    compile_opt idl2, strictarrsubs
    
    if N_elements(cutoff) eq 0 then cutoff = !pi
    
    dp = wmb_diff(p)
    
    dp_corr = dp / (2*!pi)
    
    floor_index = where(abs(wmb_rem(dp_corr, 1)) le 0.5 and dp_corr ge 0.0, fl_count)
    ceil_index = where(abs(wmb_rem(dp_corr, 1)) le 0.5 and dp_corr lt 0.0, cl_count)
    
    if fl_count gt 0 then dp_corr[floor_index] = floor(dp_corr[floor_index])
    if cl_count gt 0 then dp_corr[ceil_index]  = ceil(dp_corr[ceil_index])

    dp_corr = round(dp_corr)
    
    ; stop the jump from happening if dp < cutoff (no effect if cutoff <= pi)
    
    chk_cutoff_ind = where(abs(dp) lt cutoff, n_chk_cutoff)
    if n_chk_cutoff gt 0 then dp_corr[chk_cutoff_ind] = 0
    
    output_p = p
    
    output_p[1:-1] = output_p[1:-1] - 2*!pi*total(dp_corr, /CUMULATIVE)
    
    return, output_p

end
