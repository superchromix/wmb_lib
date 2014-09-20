
; wmb_fileext
; 
; Purpose: Given a file name, determine the file extension
;          
; Return value: Returns the file extension (including the '.')
;   

function wmb_fileext, filename

    compile_opt idl2, strictarrsubs

    name = file_basename(filename)

    pos = strpos(name, '.', /reverse_search)

    if pos eq -1 then begin
    
        file_ext = ''
        
    endif else begin
    
        file_ext = strmid(name, pos)

    endelse
    
    return, file_ext

end