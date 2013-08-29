
; wmb_has_tag
; 
; Purpose: Check to see if a structure has a particular tag name.
;          
; Return value: Returns 1 if the tag name is present, and 0 if not.
; 


function wmb_has_tag, input_struct, input_tagname

    ; get the tag names
    
    tn = tag_names(input_struct)
    
    test_tag = strupcase(input_tagname)
    
    match_index = where(tn eq test_tag, tmpcnt)
    
    if tmpcnt gt 0 then return, 1
    
    return, 0
    
end