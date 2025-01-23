;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_test_box_overlap
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_test_box_overlap, img_size_x, img_size_y, box_cen_x, box_cen_y, box_half_size

    compile_opt idl2, strictarrsubs

    if N_elements(box_half_size) ne 1 then message, 'Invalid box_half_size input'

    index_img = lonarr(img_size_x,img_size_y,/NOZERO)
    
    index_img[*,*] = -1
    
    n_boxes = N_elements(box_cen_x)
    
    box_overlap_check = lonarr(n_boxes)
    
    int_box_cen_x = round(box_cen_x)
    int_box_cen_y = round(box_cen_y)
    int_box_half_size = round(box_half_size)
    
    for i = 0, n_boxes-1 do begin
        
        xa = 0 > (int_box_cen_x[i] - int_box_half_size) < (img_size_x-1)
        xb = 0 > (int_box_cen_x[i] + int_box_half_size) < (img_size_x-1)
        ya = 0 > (int_box_cen_y[i] - int_box_half_size) < (img_size_y-1)
        yb = 0 > (int_box_cen_y[i] + int_box_half_size) < (img_size_y-1)
        
        tmpdat = index_img[xa:xb,ya:yb]
        tmpindarr = where(tmpdat ne -1, n_overlap_pix)
        
        if n_overlap_pix ne 0 then begin
            box_overlap_check[i] = 1
            for j = 0, n_overlap_pix-1 do box_overlap_check[tmpdat[tmpindarr[j]]] = 1
        endif
        
        index_img[xa:xb,ya:yb] = i
        
    endfor
    
    return, box_overlap_check

end