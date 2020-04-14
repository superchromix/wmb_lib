;+
;   Determines if an object with a given name exists at a given location.
;   
;   :Returns:
;       1 if exists, 0 if it doesn't
;
;   :Params:
;       loc_id : in, required, type=long
;           file or group identifier
;       name : in, required, type=string
;           name of object to check

function wmb_h5_object_exists, loc_id, name

    compile_opt idl2, strictarrsubs

    ; does the name string contain a backslash?
    
    chk_backslash = name.Contains('/')
    
    if chk_backslash eq 1 then begin
        
        last_backslash_pos = name.lastindexof('/')
        
        tmp_group = strmid(name, 0, last_backslash_pos)
        tmp_name = strmid(name, last_backslash_pos+1, strlen(name) - (last_backslash_pos+1) )
        
        chk_group_exists = wmb_h5_object_exists(loc_id, tmp_group)
        if chk_group_exists eq 0 then return, 0
        
        tmp_loc_id = h5g_open(loc_id, tmp_group)
        
    endif else begin
        
        tmp_loc_id = loc_id
        tmp_name = name
        
    endelse

    nobjs = h5g_get_num_objs(tmp_loc_id)

    for i = 0, nobjs-1 do begin

        if h5g_get_obj_name_by_idx(tmp_loc_id, i) eq tmp_name then return, 1
        ;print, h5g_get_obj_name_by_idx(tmp_loc_id, i)
        
    endfor
    
    if chk_backslash eq 1 then h5g_close, tmp_loc_id

    return, 0

end