
; wmb_file_search_up
; 
; Purpose: Searches for a filename, starting from a specified start path
;          and moving up in the directory tree.
;          
; Return value: Returns the fully qualified path of the first matched file.
;               If no file is found, an empty string is returned.


function wmb_file_search_up, start_dir, filename

    compile_opt idl2, strictarrsubs


    if strmid(start_dir,0,1,/reverse_offset) eq path_sep() then begin
        
        ; strip off the last path separator of the start 
        ; directory, if present
        
        tmp_start_dir = strmid(start_dir,0,strlen(start_dir)-1)
        
    endif else tmp_start_dir = start_dir

    if strmid(filename,0,1) eq path_sep() then begin
        
        ; strip off the path separator if it is the first character 
        ; of the file name
        
        tmp_filename = strmid(filename,1)
        
    endif else tmp_filename = filename

    if strmid(start_dir,0,2) eq (path_sep() + path_sep()) then begin
        
        ; check for a network path at the start of the directory name
        
        path_prefix = (path_sep() + path_sep())
        
    endif else path_prefix = ''
    

    tmp_path = tmp_start_dir + path_sep() + tmp_filename

    tmp_qual_path = file_expand_path(tmp_path)
    
    tmp_start_dir = file_dirname(tmp_qual_path)

    dir_array = strsplit(start_dir, path_sep(), /extract)
                                         
    n_search_loc = N_elements(dir_array)
    
    search_loc_arr = strarr(n_search_loc)

    
    for i = 0, n_search_loc-1 do begin
        
        tmploc = ''
        
        for j = 0, i do begin
            
            if j eq i then tmploc = tmploc + dir_array[j] $
                      else tmploc = tmploc + dir_array[j] + path_sep()
            
        endfor
        
        search_loc_arr[(n_search_loc-1)-i] = path_prefix + tmploc
        
    endfor


    file_found = 0
    
    for i = 0, n_search_loc-1 do begin
        
        tmploc = search_loc_arr[i]
        tmppath = tmploc + path_sep() + tmp_filename
        
        result = file_search(tmppath, /fold_case, $
                                      /test_regular, $
                                      /fully_qualify_path)
                                      
        if result[0] ne '' and file_found eq 0 then begin
            
            file_found = 1
            return, result
            
        endif
        
    endfor

    ; the file was not found

    return, ''
    
end