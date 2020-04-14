;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_quaternion_to_rotation
;
;   Note that the array indices are transposed with respect to 
;   the original matlab code.
;   
;   test_coords = [[1,0],[0,1],[0,0]]
;   q=[0,0,1,1]
;   rotmat = wmb_quaternion_to_rotation(q)
;   transformed_coords = rotmat ## test_coords
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_quaternion_to_rotation, input_quaternion, $
                                     partial_derivatives = partial_derivatives

    compile_opt idl2, strictarrsubs

    if N_elements(input_quaternion) ne 4 then message, 'Invalid input'
    
    q = input_quaternion
    
    q = q / norm(q)
    
    chk_double = size(q,/TYPE) eq 5

    rotmat = make_array(3, 3, TYPE = chk_double ? 5 : 4)
    
    x = q[0]
    y = q[1]
    z = q[2]
    r = q[3]
    
    xx = x * x
    yy = y * y
    zz = z * z
    rr = r * r
    
    rotmat[0,0] = rr + xx - yy - zz
    rotmat[1,1] = rr - xx + yy - zz
    rotmat[2,2] = rr - xx - yy + zz
    
    xy = x * y
    yz = y * z
    xz = x * z
    xr = x * r
    yr = y * r
    zr = z * r
    
    rotmat[1,0] = 2 * (xy - zr)
    rotmat[2,0] = 2 * (xz + yr)
    rotmat[0,1] = 2 * (xy + zr)
    rotmat[2,1] = 2 * (yz - xr)
    rotmat[0,2] = 2 * (xz - yr)
    rotmat[1,2] = 2 * (yz + xr)

    
    if Arg_present(partial_derivatives) eq 1 then begin
        
        ; calculate the partial derivatives of the rotation matrix
        ; with respect to each element of the quaternion
        
        pd = make_array(3, 3, 4, TYPE = chk_double ? 5 : 4)
        
        ; fill off diagonal terms
        ; derivative of R[1,0] = 2 * (xy - zr);         
        pd[1,0,0] = 2 * y;
        pd[1,0,1] = 2 * x;
        pd[1,0,2] = - 2 * r;
        pd[1,0,3] = - 2 * z;
        ; derivative of R[2,0] = 2 * (xz + yr);
        pd[2,0,0] = 2 * z;
        pd[2,0,1] = 2 * r;
        pd[2,0,2] = 2 * x;
        pd[2,0,3] = 2 * y;
        ; derivative of R[0,1] = 2 * (xy + zr);
        pd[0,1,0] = 2 * y;
        pd[0,1,1] = 2 * x;
        pd[0,1,2] = 2 * r;
        pd[0,1,3] = 2 * z;
        ; derivative of R[2,1] = 2 * (yz - xr);
        pd[2,1,0] = - 2 * r;
        pd[2,1,1] = 2 * z;
        pd[2,1,2] = 2 * y;
        pd[2,1,3] = - 2 * x;
        ; derivative of R[0,2] = 2 * (xz - yr);
        pd[0,2,0] = 2 * z;
        pd[0,2,1] = - 2 * r;
        pd[0,2,2] = 2 * x;
        pd[0,2,3] = - 2 * y;
        ; derivative of R[1,2] = 2 * (yz + xr);
        pd[1,2,0] = 2 * r;
        pd[1,2,1] = 2 * z;
        pd[1,2,2] = 2 * y;
        pd[1,2,3] = 2 * x;
        
        ; fill diagonal terms
        ; derivative of R[0,0] = r2 + x2 - y2 - z2;
        pd[0,0,0] = 2 * x;
        pd[0,0,1] = - 2 * y;
        pd[0,0,2] = - 2 * z;
        pd[0,0,3] = 2 * r;
        ; derivative of R[1,1] = r2 - x2 + y2 - z2; 
        pd[1,1,0] = - 2 * x;
        pd[1,1,1] = 2 * y;
        pd[1,1,2] = - 2 * z;
        pd[1,1,3] = 2 * r;
        ; derivative of R[2,2] = r2 - x2 - y2 + z2;
        pd[2,2,0] = - 2 * x;
        pd[2,2,1] = - 2 * y;
        pd[2,2,2] = 2 * z;
        pd[2,2,3] = 2 * r;
        
        partial_derivatives = temporary(pd)
        
    endif
        
        
    return, rotmat

end