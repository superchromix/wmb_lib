;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_sort_two_columns
;
;   Note that this function works with both arrays and lists.
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_sort_two_columns, col_a, col_b

    compile_opt idl2, strictarrsubs


    ; check if the inputs are lists
    
    input_a_list = isa(col_a, 'List')
    input_b_list = isa(col_b, 'List')
    
    if input_a_list eq 1 then col_a_mod = col_a.ToArray() $
                         else col_a_mod = temporary(col_a)

    if input_b_list eq 1 then col_b_mod = col_b.ToArray() $
                         else col_b_mod = temporary(col_b)



    ; perform simple sort on the primary sort column

    inda = sort(col_a_mod)

    sorted_col_a = col_a_mod[inda]
    sorted_col_b = col_b_mod[inda]

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
            sub_inda = inda[i1:i2]

            indb = sort(subdat_b)
            
            inda[i1:i2] = sub_inda[indb]

        endif

    endfor


    ; return the input variables to their original state
    
    if input_a_list eq 0 then col_a = temporary(col_a_mod)
    if input_b_list eq 0 then col_b = temporary(col_b_mod)


    return, inda

end
