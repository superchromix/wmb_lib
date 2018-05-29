;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_sort_three_columns
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_sort_three_columns, col_a, col_b, col_c

    compile_opt idl2, strictarrsubs


    ; perform simple sort on the primary sort column

    inda = sort(col_a)

    sorted_col_a = col_a[inda]
    sorted_col_b = col_b[inda]
    sorted_col_c = col_c[inda]

    ; extract boundaries of equal values in major index (sorted_col_a)

    uind = uniq(sorted_col_a)
    uind = [ -1, uind ]   ; add first startindex (use -1 because it is
                          ; interpreted as the last index from previous item)

    nuind = n_elements(uind)

    ; perform sort on subsets of data with equal major variable
    ; note that the first element of uind is now -1

    for i=long(0), nuind-2 do begin

        i1 = uind[i]+1
        i2 = uind[i+1]

        ; if i1 and i2 are equal, then there is only one element for this value
        ; of the major index and nothing more needs to happen

        if(i2 gt i1) then begin

            subdat_b = sorted_col_b[i1:i2]
            subdat_c = sorted_col_c[i1:i2]
            sub_inda = inda[i1:i2]

            indb = wmb_sort_two_columns(subdat_b, subdat_c)
            
            inda[i1:i2] = sub_inda[indb]

        endif

    endfor

    return, inda

end
