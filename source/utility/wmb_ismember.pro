
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_ismember.pro
;
;   Returns an array containing 1 (true) where the data in A is 
;   found in S. Elsewhere, it returns 0 (false).
;   
;   Locb contains the lowest index in S for each value in A that 
;   is a member of S. The output array, LocS, contains -1 wherever 
;   A is not a member of S.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_ismember, a, s, locs=locs

    compile_opt idl2, strictarrsubs

    n_a_entries = N_elements(a)
    
    lia = bytarr(n_a_entries, /NOZERO)
    lib = lonarr(n_a_entries, /NOZERO)
    
    for i = 0, n_a_entries-1 do begin
        
        idx = where(s eq a[i], tmpcnt)
        lia[i] = tmpcnt gt 0
        lib[i] = idx[0]
        
    endfor

    locs = temporary(lib)

    return, lia

end

