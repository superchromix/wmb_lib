
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
                             compare_field_names = compare_field_names, $
                             ignore_field_values = ignore_field_values

    compile_opt idl2, strictarrsubs

    if N_elements(compare_field_names) eq 0 then compare_field_names = 0
    if N_elements(ignore_field_values) eq 0 then ignore_field_values = 0

    if size(str1,/n_dimensions) gt 1 or size(str2,/n_dimensions) gt 1 then $
        message, 'Input must be a scalar structure'
        
    if (size(str1,/dimensions))[0] gt 1 or   $
       (size(str2,/dimensions))[0] gt 1 then $
        message, 'Input must be a scalar structure'

    ntags1 = n_tags(str1)
    ntags2 = n_tags(str2)
    
    tnames1 = tag_names(str1)
    tnames2 = tag_names(str2)
    
    if ntags1 ne ntags2 then return, 0

    matched = 1

    for i = 0, ntags1 - 1 do begin
    
        ; compare the field name
    
        tmpname1 = tnames1[i]
        tmpname2 = tnames2[i]

        if compare_field_names then if tmpname1 ne tmpname2 then return, 0
   
        ; compare the field type
 
        tmpval1 = str1.(i)
        tmpval2 = str2.(i)
        
        tmptype1 = size(tmpval1, /type)
        tmptype2 = size(tmpval2, /type)
        
        if tmptype1 ne tmptype2 then return, 0
        
        ; compare the field value
        
        if tmptype1 eq 8 then begin
        
            matched=wmb_compare_struct(tmpval1, $
                                       tmpval2, $
                                       compare_field_names=compare_field_names)
        
        endif else if tmptype1 eq 0 then begin
        
            matched = 1
        
        endif else begin
        
            if ~ignore_field_values then matched = (tmpval1 eq tmpval2)
        
        endelse
    
        if matched eq 0 then return, 0
    
    endfor

    return, matched
    
end