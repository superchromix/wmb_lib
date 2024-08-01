
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_mode
;
;   Returns the mode of a dataset
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_mode, data

    compile_opt idl2, strictarrsubs

    sortind = sort(data)
    
    data_sorted = data[sortind]
    
    uniq_indices = uniq(data_sorted)
    
    if N_elements(uniq_indices) eq 1 then return, data[0]
    
    tmp_aa = uniq_indices+1
    tmp_bb = [0, tmp_aa[0:-2]]
    n_instances = tmp_aa-tmp_bb
    
    max_count = max(n_instances, max_count_index)
    
    tmp_mode = data_sorted[uniq_indices[max_count_index]]

    return, tmp_mode
    
end