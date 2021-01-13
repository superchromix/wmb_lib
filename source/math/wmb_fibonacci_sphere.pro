;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_fibonacci_sphere
;   
;   Returns an array of cartesian coordinates (3 x n_samples) evenly 
;   distributed over the unit sphere.
;
;   aa=wmb_fibonacci_sphere(5000)
;   
;   bb=hist_nd(aa,min=[-2,-2,-2], max=[2,2,2], nbins=[100,100,100])
;   
;   daxview_plot_image(bb)
;   
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_fibonacci_sphere, n_samples

    compile_opt idl2, strictarrsubs

    points = fltarr(3,n_samples)
    
    phi = !dpi * (3.0 - sqrt(5.0))  ; golden angle in radians

    for i = 0, n_samples-1 do begin
        
        y = 1 - (i / float(n_samples - 1)) * 2  ; y goes from 1 to -1
        
        radius = sqrt(1.0 - y * y)  ; radius at y

        theta = phi * i  ; golden angle increment

        x = cos(theta) * radius
        z = sin(theta) * radius

        points[0,i] = [x,y,z]

    endfor

    return, points
    
end
    
    