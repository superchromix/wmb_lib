;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the wmb_generate_obf_info script
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_generate_obf_info

    compile_opt idl2, strictarrsubs

    
    ; get a set of files to analyze
        
    msgtxt = 'Choose a top level directory which will be searched ' + $
             'recursively for obf files'
    
    fdir = DIALOG_PICKFILE(TITLE=msgtxt, /DIRECTORY, /MUST_EXIST)
                         
    if fdir ne '' then begin
                                 
        ; search for data files
        
        search_str = '*.obf'
        
        flist = file_search(fdir, search_str)
            
        chk_valid = bytarr(N_elements(flist))
                                            
        foreach tmpstr, flist, tmpind do begin
            
            tmp_valid = 1
            
            chk_valid[tmpind] = tmp_valid
            
        endforeach
                                         
        good_files_index = where(chk_valid eq 1, nfiles)
            
            
        if nfiles gt 0 then begin
            
            final_flist = flist[good_files_index]
            
            for i = 0, n_elements(final_flist)-1 do begin
            
                obf_path = final_flist[i]
            
                ; open the file
            
                result = wmb_save_obf_info(obf_path, query_user = 0)
            
                if result eq 0 then begin
                    
                    print, 'Save failed for file : ', obf_path
                    
                endif
                    
            endfor
            
        endif

    endif
                                            
end
