
; wmb_h5tb_compare_struct
; 
; Purpose: Compare two structures including their datatypes, and field values.  
;          If the /COMPARE_TAG_NAMES flag is set, then the function also 
;          includes the tag names in the comparison.
;          
; Return value: Returns 1 if the two structures are equal, and 0 if not.
; 


function wmb_h5tb_compare_struct, str1, $
                                  str2, $
                                  compare_tag_names = compare_tag_names

    if N_elements(compare_tag_names) eq 0 then compare_tag_names = 0

    ntags1 = n_tags(str1)
    ntags2 = n_tags(str2)
    
    tnames1 = tag_names(str1)
    tnames2 = tag_names(str2)
    
    if ntags1 ne ntags2 then return, 0

    matched = 1

    for i = 0, ntags1 - 1 do begin
    
        tmpname1 = tnames1[i]
        tmpname2 = tnames2[i]
        
        if compare_tag_names then if tmpname1 ne tmpname2 then return, 0
    
        tmpval1 = str1.(i)
        tmpval2 = str2.(i)
        
        tmptype1 = size(tmpval1, /type)
        tmptype2 = size(tmpval2, /type)
        
        if tmptype1 ne tmptype2 then return, 0
        
        if tmptype1 eq 8 then begin
        
            matched = wmb_compare_struct(tmpval1, $
                                         tmpval2, $
                                         compare_tag_names = compare_tag_names)
        
        endif else if tmptype1 eq 0 then begin
        
            matched = 1
        
        endif else begin
        
            matched = (tmpval1 eq tmpval2)
        
        endelse
    
        if matched eq 0 then return, 0
    
    endfor

    return, matched
    
end