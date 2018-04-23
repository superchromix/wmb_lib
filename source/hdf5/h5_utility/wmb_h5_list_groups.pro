;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_h5_list_groups
;
; Returns a 1D array of strings, containing the group names within
; an HDF5 file.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_h5_list_groups, filename, n_groups = n_groups

    compile_opt idl2, strictarrsubs

    n_groups = 0

    wmb_h5_list, filename, filter='group', output=list_output
    
    list_dims = size(list_output, /DIMENSIONS)
    list_ndims = size(list_output, /N_DIMENSIONS)
    
    if list_ndims eq 1 then return, []
    
    chk_grp_index = where(list_output[0,1:-1] eq 'group', n_groups)
    
    if n_groups eq 0 then return, []
    
    group_list_arr = reform(list_output[1,chk_grp_index + 1])
    
    ; strip off the leading '/'
    
    foreach group_str, group_list_arr, tmp_index do begin
        
        tmpstr = strtrim(strmid(group_str, 1),2)
        group_list_arr[tmp_index] = tmpstr
        
    endforeach
    
    return, group_list_arr
    
end
