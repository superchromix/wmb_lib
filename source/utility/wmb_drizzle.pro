;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_drizzle
;
;   Returns an array in which ...
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_drizzle, index_array, values_array

    compile_opt idl2, strictarrsubs

    mx=max(index_array)
    
    vec6=fltarr(mx+1)
    
    h1=histogram(index_array,reverse_indices=ri1,OMIN=om)
    
    h2=histogram(h1,reverse_indices=ri2,MIN=1)
    
    ;; easy case - single values w/o duplication
    
    if ri2[1] gt ri2[0] then begin 
        vec_inds=ri2[ri2[0]:ri2[1]-1] 
        vec6[om+vec_inds]=values_array[ri1[ri1[vec_inds]]]
    endif
    
    for j=1,n_elements(h2)-1 do begin 
        if ri2[j+1] eq ri2[j] then continue ;none with that many duplicates
        vec_inds=ri2[ri2[j]:ri2[j+1]-1] ;indices into h1
        vinds=om+vec_inds
        vec_inds=rebin(ri1[vec_inds],h2[j],j+1,/SAMPLE)+ $
                 rebin(transpose(lindgen(j+1)),h2[j],j+1,/SAMPLE)
        vec6[vinds]=vec6[vinds]+total(values_array[ri1[vec_inds]],2)
    endfor 
    
    return, vec6
    
end