;
;   wmb_2d_gaussian
;
;   Returns a 2D gaussian function with the specified position, width, 
;   amplitude, etc.
;

function wmb_2d_gaussian, npixel, $
                          CENTROID = centroid, $
                          ST_DEV = st_dev,  $
                          AMPLITUDE = amplitude, $
                          BASELINE = baseline, $
                          THETA = theta, $
                          NORMALIZE = chk_normalize



    compile_opt idl2, strictarrsubs


    middle = (npixel-1)/2.0


    ; check the centroid position
    
    if N_elements(centroid) ne 2 then begin
        
        xpos = middle
        ypos = middle
        
    endif else begin
        
        xpos = centroid[0]
        ypos = centroid[1]
        
    endelse
    
    
    ; check the peak width
    
    if N_elements(st_dev) eq 0 then begin
        
        xwidth = 1.0
        ywidth = 1.0
        
    endif else if N_elements(st_dev) eq 1 then begin
        
        xwidth = st_dev
        ywidth = st_dev
        
    endif else if N_elements(st_dev) eq 2 then begin
        
        xwidth = st_dev[0]
        ywidth = st_dev[1]
        
    endif else message, 'ST_DEV: incorrect number of elements'


    ; check the rotation angle
    
    if N_elements(theta) eq 0 then begin
        
        chk_tilt = 0
        
    endif else begin
        
        chk_tilt = 1
        rot_angle = theta
        
    endelse
    
    if N_elements(amplitude) eq 0 then amplitude = 1.0
    
    if N_elements(baseline) eq 0 then baseline = 0.0
    
    
    if N_elements(chk_normalize) eq 0 then chk_normalize = 0


    xx      = fltarr( npixel, npixel )
    yy      = fltarr( npixel, npixel )

    temprow = findgen(npixel)

    ;populate the xx and yy arrays with the x and y coordinates

    for i = 0, npixel-1 do begin   

        xx[0,i] = temprow
        
    endfor

    yy = transpose(xx)


    if chk_tilt eq 1 then begin
        
        xp = ((xx-xpos) * cos(theta)) - ((yy-ypos) * sin(theta))
        yp = ((xx-xpos) * sin(theta)) + ((yy-ypos) * cos(theta))
        
        u = (xp/xwidth)^2 + (yp/ywidth)^2
        
    endif else begin
        
        xp = (xx-xpos) 
        yp = (yy-ypos)
        
        u = (xp/xwidth)^2 + (yp/ywidth)^2
        
    endelse


    outarr = amplitude * exp(-u/2.0)

    
    if chk_normalize eq 1 then outarr = outarr / total(outarr)


    outarr = outarr + baseline
    

    return, outarr

end
