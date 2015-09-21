
; wmb_merge_structarr
; 
; Merge two arrays of structures
;
; If structure 1 has fields {field1:0, field2:'a'} and structre 2 has
; fields {field3:0}, then this function joins the two arrays of 
; structures and returns an array of structures with the 
; fields {field1:0, field2:'a', field3:0}.

function wmb_merge_struct_arr, str_arr1, str_arr2

    compile_opt idl2, strictarrsubs

    tmp_str1 = str_arr1[0]
    tmp_str2 = str_arr2[0]
    
    n_fields1 = n_tags(tmp_str1)
    n_fields2 = n_tags(tmp_str2)
    
    tmp_newstr = create_struct(tmp_str1, tmp_str2)
    
    n_elts1 = n_elements(str_arr1)
    n_elts2 = n_elements(str_arr2)
    
    if n_elts1 ne n_elts2 then message, 'Structure array sizes do not match'
    
    out_struct_arr = replicate(tmp_newstr, n_elts1)
    
    for i = 0, n_fields1-1 do out_struct_arr.(i) = str_arr1.(i)
        
    for i = 0, n_fields2-1 do out_struct_arr.(i + n_fields1) = str_arr2.(i)

    return, out_struct_arr
    
end