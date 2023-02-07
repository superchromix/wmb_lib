
; wmb_file_remove_extension
; 
; Purpose: Given a file name, return the part of the filename excluding
; the file extension
;          
; Return value: Returns a string including the full file name up to but
; not including the last occurrence of '.'
;   

function wmb_file_remove_extension, fname, remove_all=remove_all

    compile_opt idl2, strictarrsubs
    
    if N_elements(remove_all) eq 0 then remove_all=0
    
    if fname.contains('.') eq 0 then return, fname
    
    if remove_all eq 0 then begin
    
        return, fname.substring(0,fname.lastindexof('.')-1)

    endif else begin
        
        return, fname.substring(0,fname.indexof('.')-1)
        
    endelse

end
