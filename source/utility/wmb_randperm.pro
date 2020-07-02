;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_randperm
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_randperm, rangemin, rangemax, n_values, seed=seed

    compile_opt idl2, strictarrsubs

    if N_elements(seed) eq 0 then seed = systime(/SECONDS)

    rangespan = (rangemax - rangemin) + 1

    tmp_list = lindgen(rangespan) + rangemin
    
    list_len = n_elements(tmp_list)

    if n_values gt list_len then message, 'Invalid number of values'

    return, tmp_list[(sort(randomu(seed,list_len)))[0:n_values-1]]

end

