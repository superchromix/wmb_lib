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

    chk_double = size(q,/TYPE) eq 5

    rotmat = make_array(3, 3, TYPE = chk_double ? 5 : 4)
    
    qx = q[0]
    qy = q[1]
    qz = q[2]
    qr = q[3]
    
    x2 = qx * qx
    y2 = qy * qy
    z2 = qz * qz
    r2 = qr * qr
    
    ss = (x2 + y2 + z2 + r2)
    ssss = ss*ss
    
    inv_ss = 1.0 / ss
    inv_ssss = 1.0 / ssss
    
    ; The rotation matrix will have the following form:
    ;
    ; [ [ R_00, R_01, R_02 ], 
    ;   [ R_10, R_11, R_12 ],
    ;   [ R_20, R_21, R_22 ] ]
    ;
    ; This will be stored in memory as follows:
    ; 
    ; [ R_00, R_01, R_02, R_10, R_11, R_12, R_20, R_21, R_22 ]
    ;
    ; R[0] = R_00
    ; R[1] = R_01
    ; R[2] = R_02
    ; R[3] = R_10
    ; R[4] = R_11
    ; R[5] = R_12
    ; R[6] = R_20
    ; R[7] = R_21
    ; R[8] = R_22

    ; fill diagonal terms
    R_00 = (r2 + x2 - y2 - z2) * inv_ss
    R_11 = (r2 - x2 + y2 - z2) * inv_ss
    R_22 = (r2 - x2 - y2 + z2) * inv_ss

    ; fill off-diagonal terms
    R_01 = 2 * (qx*qy - qr*qz) * inv_ss
    R_02 = 2 * (qz*qx + qr*qy) * inv_ss
    R_10 = 2 * (qx*qy + qr*qz) * inv_ss
    R_12 = 2 * (qy*qz - qr*qx) * inv_ss
    R_20 = 2 * (qz*qx - qr*qy) * inv_ss
    R_21 = 2 * (qy*qz + qr*qx) * inv_ss
    
    rotmat[0] = R_00
    rotmat[1] = R_01
    rotmat[2] = R_02
    rotmat[3] = R_10
    rotmat[4] = R_11
    rotmat[5] = R_12
    rotmat[6] = R_20
    rotmat[7] = R_21
    rotmat[8] = R_22
    
    
    if Arg_present(partial_derivatives) eq 1 then begin
        
        ; calculate the partial derivatives of the rotation matrix
        ; with respect to each element of the quaternion
        
        pd = make_array(3, 3, 4, TYPE = chk_double ? 5 : 4)
        
        g_x = make_array(3, 3, TYPE = chk_double ? 5 : 4)
        g_y = make_array(3, 3, TYPE = chk_double ? 5 : 4)
        g_z = make_array(3, 3, TYPE = chk_double ? 5 : 4)
        g_r = make_array(3, 3, TYPE = chk_double ? 5 : 4)
        

        ; gradients of diagonal terms
    
        ; derivative of R_00 = (r2 + x2 - y2 - z2) / ss;
        g_x[0] = 4 * qx*(y2 + z2) * inv_ssss
        g_y[0] = -4 * qy*(x2 + r2) * inv_ssss
        g_z[0] = -4 * qz*(x2 + r2) * inv_ssss
        g_r[0] = 4 * qr*(y2 + z2) * inv_ssss
    
        ; derivative of R_11 = (r2 - x2 + y2 - z2) / ss;
        g_x[4] = -4 * qx*(y2 + r2) * inv_ssss
        g_y[4] = 4 * qy*(x2 + z2) * inv_ssss
        g_z[4] = -4 * qz*(y2 + r2) * inv_ssss
        g_r[4] = 4 * qr*(x2 + z2) * inv_ssss

        ; derivative of R_22 = (r2 - x2 - y2 + z2) / ss;
        g_x[8] = -4 * qx*(z2 + r2) * inv_ssss
        g_y[8] = -4 * qy*(r2 + z2) * inv_ssss
        g_z[8] = 4 * qz*(x2 + y2) * inv_ssss
        g_r[8] = 4 * qr*(x2 + y2) * inv_ssss
        
        
        ; gradients of off-diagonal terms
    
        ; derivative of R_01 = 2 * (xy - rz) / ss;
        g_x[1] = 2 * qy * inv_ss - 2 * qx*R_01 * inv_ssss
        g_y[1] = 2 * qx * inv_ss - 2 * qy*R_01 * inv_ssss
        g_z[1] = -2 * qr * inv_ss - 2 * qz*R_01 * inv_ssss
        g_r[1] = -2 * qz * inv_ss - 2 * qr*R_01 * inv_ssss
    
        ; derivative of R_02 = 2 * (zx + ry) / ss;
        g_x[2] = 2 * qz * inv_ss - 2 * qx*R_02 * inv_ssss
        g_y[2] = 2 * qr * inv_ss - 2 * qy*R_02 * inv_ssss
        g_z[2] = 2 * qx * inv_ss - 2 * qz*R_02 * inv_ssss
        g_r[2] = 2 * qy * inv_ss - 2 * qr*R_02 * inv_ssss
    
        ; derivative of R_10 = 2 * (xy + rz) / ss;
        g_x[3] = 2 * qy * inv_ss - 2 * qx*R_10 * inv_ssss
        g_y[3] = 2 * qx * inv_ss - 2 * qy*R_10 * inv_ssss
        g_z[3] = 2 * qr * inv_ss - 2 * qz*R_10 * inv_ssss
        g_r[3] = 2 * qz * inv_ss - 2 * qr*R_10 * inv_ssss
    
        ; derivative of R_12 = 2 * (yz - rx) / ss;
        g_x[5] = -2 * qr * inv_ss - 2 * qx*R_12 * inv_ssss
        g_y[5] = 2 * qz * inv_ss - 2 * qy*R_12 * inv_ssss
        g_z[5] = 2 * qy * inv_ss - 2 * qz*R_12 * inv_ssss
        g_r[5] = -2 * qx * inv_ss - 2 * qr*R_12 * inv_ssss
    
        ; derivative of R_20 = 2 * (zx - ry) / ss;
        g_x[6] = 2 * qz * inv_ss - 2 * qx*R_20 * inv_ssss
        g_y[6] = -2 * qr * inv_ss - 2 * qy*R_20 * inv_ssss
        g_z[6] = 2 * qx * inv_ss - 2 * qz*R_20 * inv_ssss
        g_r[6] = -2 * qy * inv_ss - 2 * qr*R_20 * inv_ssss
    
        ; derivative of R_21 = 2 * (yz + rx) / ss;
        g_x[7] = 2 * qr * inv_ss - 2 * qx*R_21 * inv_ssss
        g_y[7] = 2 * qz * inv_ss - 2 * qy*R_21 * inv_ssss
        g_z[7] = 2 * qy * inv_ss - 2 * qz*R_21 * inv_ssss
        g_r[7] = 2 * qx * inv_ss - 2 * qr*R_21 * inv_ssss
        
        
        pd[0,0,0] = g_x
        pd[0,0,1] = g_y
        pd[0,0,2] = g_z
        pd[0,0,3] = g_r
        
        
        partial_derivatives = temporary(pd)
        
    endif
    
    return, rotmat
    
end

