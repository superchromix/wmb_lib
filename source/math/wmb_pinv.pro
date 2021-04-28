;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_pinv
;
;   Compute the (Moore-Penrose) pseudo-inverse of a matrix.
;   
;   Calculate the generalized inverse of a matrix using its
;   singular-value decomposition (SVD) and including all
;   *large* singular values.
;   
;   Based on the routine "pinv" from the Numpy library.
;   
;   Returns -1 if unsuccessful.
;   
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_pinv, a, double=flag_dbl

    compile_opt idl2, strictarrsubs

    if N_elements(flag_dbl) eq 0 then flag_dbl = 0
    
    ; check the size of the input array
    
    tmp_sz = size(a)
    
    if tmp_sz[0] ne 2 or $
       tmp_sz[1] eq 1 or $
       tmp_sz[2] eq 1 then begin
        
        message, 'Invalid input matrix', /INFORMATIONAL
        
        return, -1
        
    endif
    
    ncol = tmp_sz[1]
    
    if flag_dbl eq 0 then begin

        winv   = fltarr(ncol, ncol)
        one    = 1.0
        
    endif else begin

        winv   = dblarr(ncol, ncol)
        one    = 1.0d
        
    endelse
    
    ; singular value decomposition 
    
    svdc, a, w, u, v, DOUBLE=flag_dbl
    
    rcond = (machar(DOUBLE=flag_dbl)).EPS
    
    threshold = rcond * max(w)
    
    loc_valid = where(w gt threshold, count_valid)

    if count_valid gt 0 then begin

        valid_diagonal_elements = (lindgen(ncol))[loc_valid]*(ncol+1) 
        
        winv[valid_diagonal_elements] = one / w[loc_valid]
        
    endif else begin
        
        return, -1
        
    endelse
    
    result = v ## winv ## transpose(u)
    
    return, result
    
end
    
    