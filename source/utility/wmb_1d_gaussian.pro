;
;   wmb_1d_gaussian
;
;   Returns a 1D gaussian function with the specified position, width, 
;   amplitude, etc.
;

function wmb_1d_gaussian, npixel, $
                          CENTROID = centroid, $
                          ST_DEV = st_dev,  $
                          AMPLITUDE = amplitude, $
                          BASELINE = baseline, $
                          NORMALIZE = chk_normalize



    compile_opt idl2, strictarrsubs


    middle = (npixel-1)/2.0


    ; check the centroid position
    
    if N_elements(centroid) ne 1 then begin
        
        xpos = middle
        
    endif else begin
        
        xpos = centroid[0]
        
    endelse
    
    
    ; check the peak width
    
    if N_elements(st_dev) eq 0 then begin
        
        xwidth = 1.0
        
    endif else if N_elements(st_dev) eq 1 then begin
        
        xwidth = st_dev

    endif else message, 'ST_DEV: incorrect number of elements'

    if N_elements(amplitude) eq 0 then amplitude = 1.0
    
    if N_elements(baseline) eq 0 then baseline = 0.0
    
    if N_elements(chk_normalize) eq 0 then chk_normalize = 0


    ; populate the xx array with the x coordinates

    xx = findgen(npixel)

    xp = (xx-xpos) 

    u = (xp/xwidth)^2 

    outarr = amplitude * exp(-u/2.0)

    if chk_normalize eq 1 then outarr = outarr / total(outarr)

    outarr = outarr + baseline

    return, outarr

end
