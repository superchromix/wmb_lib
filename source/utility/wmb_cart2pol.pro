;
;   wmb_cart2pol
;
;   wmb_cart2pol(X,Y) transforms corresponding elements of data
;   stored in Cartesian coordinates X,Y to polar coordinates (angle TH
;   and radius R).
;

pro wmb_cart2pol, x, y, theta, r

    compile_opt idl2, strictarrsubs
    
    theta = atan(y, x)
    r = sqrt(x^2 + y^2)

end
