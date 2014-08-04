
; wmb_compare_struct
; 
; Purpose: Compare two structures including their datatypes, and field values.  
;          If the /COMPARE_FIELD_NAMES flag is set, then the function also 
;          includes the field names in the comparison. 
;          
;          If the /IGNORE_FIELD_VALUES flag is set, then the actual values
;          of the fields are not included in the comparison.
;          
;          Note that both input structures must be scalars
;          
; Return value: Returns 1 if the two structures are equal, and 0 if not.
; 


function wmb_compare_struct, str1, $
                             str2, $
                             compare_field_names = compare_names, $
                             ignore_field_values = ignore_values

    compile_opt idl2, strictarrsubs

    if N_elements(compare_names) eq 0 then compare_names = 0
    if N_elements(ignore_values) eq 0 then ignore_values = 0

    ; is this an array of structs?
    
    n_elements_str1 = product(size(str1, /dimensions), /integer)
    n_elements_str2 = product(size(str2, /dimensions), /integer)
    
    if n_elements_str1 ne n_elements_str2 then return, 0
    
    if n_elements_str1 gt 1 then begin
        
        ; compare an array of structs
        
        matched = 1
        
        tmp_str1_arr = reform(str1, n_elements_str1)
        tmp_str2_arr = reform(str2, n_elements_str2)
        
        for i = 0, n_elements_str1 - 1 do begin
            
            matched=wmb_compare_struct(tmp_str1_arr[i], $
                                       tmp_str2_arr[i], $
                                       compare_field_names = compare_names, $
                                       ignore_field_values = ignore_values)
        
            if matched eq 0 then return, 0
                
        endfor
        
    endif else begin
        
        ; compare a scalar struct
        
        tmp_str1 = str1[0]
        tmp_str2 = str2[0]
        
        ntags1 = n_tags(tmp_str1)
        ntags2 = n_tags(tmp_str2)
        
        tnames1 = tag_names(tmp_str1)
        tnames2 = tag_names(tmp_str2)
        
        if ntags1 ne ntags2 then return, 0
        
        matched = 1
        
        for i = 0, ntags1 - 1 do begin
        
            ; compare the field name
        
            tmpname1 = tnames1[i]
            tmpname2 = tnames2[i]
    
            if compare_names then if tmpname1 ne tmpname2 then return, 0
       
            ; compare the field type
     
            tmpval1 = tmp_str1.(i)
            tmpval2 = tmp_str2.(i)
            
            tmptype1 = size(tmpval1, /type)
            tmptype2 = size(tmpval2, /type)
            
            if tmptype1 ne tmptype2 then return, 0
            
            ; compare the field value
            
            if tmptype1 eq 8 then begin
            
                matched=wmb_compare_struct(tmpval1, $
                                           tmpval2, $
                                           compare_field_names=compare_names, $
                                           ignore_field_values=ignore_values)
            
            endif else if tmptype1 eq 0 then begin
            
                matched = 1
            
            endif else begin
            
                if ~ignore_values then matched = (tmpval1 eq tmpval2)
            
            endelse
        
            if matched eq 0 then return, 0
        
        endfor

    endelse

    return, matched
    
end