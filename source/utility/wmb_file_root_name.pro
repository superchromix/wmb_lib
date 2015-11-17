
; wmb_file_root_name
; 
; Purpose: Given a file name, return the part of the filename excluding
; the file extension
;          
; Return value: Returns a string including the full file name up to but
; not including the last occurrence of '.'
;   

function wmb_file_root_name, fname

    compile_opt idl2, strictarrsubs
    
    return, fname.substring(0,fname.lastindexof('.')-1)

end