
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_make_color_array
;
;   Returns an array of RGB colors, equally space in the spectrum
;   of hues.  The dimensions of the array are 3 x n_colors
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_make_color_array, n_colors, start_hue = start_hue

    compile_opt idl2, strictarrsubs

    if N_elements(start_hue) eq 0 then start_hue = 0
    
    hueincr = 360.0/n_colors
                
    hue_arr = []            
    color_arr = bytarr(3,n_colors)
    
    for i = 0, n_colors-1 do $
        hue_arr = [hue_arr, round(start_hue + i*hueincr)]
        
    foreach tmp_hue, hue_arr, tmp_index do begin
        
        hsv, 0.0, 100.0, 100.0, 100.0, tmp_hue, 0.0, hsvct
        
        top_color = reform(hsvct[255,*])
        color_arr[0,tmp_index] = top_color
        
    endforeach
    
    return, color_arr
    
end