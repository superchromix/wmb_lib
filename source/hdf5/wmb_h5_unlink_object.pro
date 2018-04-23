
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_h5_unlink_object_varexists
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_h5_unlink_object_varexists, loc_id, name

    compile_opt idl2, strictarrsubs

    nobjs = h5g_get_num_objs(loc_id)
    
    for i = 0, nobjs-1 do begin
    
        if h5g_get_obj_name_by_idx(loc_id, i) eq name then return, 1
        
    endfor

    return, 0
    
end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_h5_unlink_object
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_h5_unlink_object, file_id, name

    compile_opt idl2, strictarrsubs

    ; check the file id
    
    idtype = h5i_get_type(file_id)
    if idtype ne 'FILE' then message, 'Invalid HDF5 file ID'

    ; strip off the leading '/' in name if it is present
    
    if strmid(name,0,1) eq '/' then name = strmid(name,1)
    
    
    ; determine into which group we are writing the data
    
    tokens = strsplit(name, '/', /extract, /preserve_null, count=ntokens)

    n_groupnames = ntokens-1
 
    ; tokens contains an array of strings - the last string in the array
    ; is the dataset name

    slash_pos = strpos(name, '/', /reverse_search)

    if slash_pos eq -1 then fullgroupname = '/' $
                       else fullgroupname = strmid(name, 0, slash_pos)

    if slash_pos eq -1 then objname = name $
                       else objname = strmid(name, slash_pos+1)

    if objname eq '' then message, 'Invalid object name'

    ; determine the group ids and the location id that we are writing to

    loc_id = file_id

    if n_groupnames gt 0 then begin

        group_names = tokens[0:n_groupnames-1]
        
        group_ids = lonarr(n_groupnames)   
    
        for i = 0, n_groupnames-1 do begin
        
            if (wmb_h5_unlink_object_varexists(loc_id, group_names[i])) then begin
            
                ; open an existing group
                loc_id = h5g_open(loc_id, group_names[i])

            endif else begin

                message, 'Invalid group name'

            endelse
            
            group_ids[i] = loc_id
            
        endfor

    endif

    ; loc_id now points to where the data will be removed

    h5g_unlink, loc_id, objname

    if n_groupnames gt 0 then begin
    
        for i = n_groupnames-1, 0, -1 do h5g_close, group_ids[i]

    endif
      
end
