;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_euler_angles_to_quaternion
;   
;   Euler angles are stored as [rot_x, rot_y, rot_z]
;   
;   Function assumes the order of rotations is first Z, then Y, 
;   then X.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_euler_angles_to_quaternion, eulerangle_arr

    compile_opt idl2, strictarrsubs

    if N_elements(eulerangle_arr) ne 3 then message, 'Invalid input'

    EA = eulerangle_arr

    if size(EA, /TYPE) ne 5 then EA = double(EA)
    
    roll = EA[0]
    pitch = EA[1]
    yaw = EA[2]

    cr = cos(roll * 0.5d)
    sr = sin(roll * 0.5d)
    cp = cos(pitch * 0.5d)
    sp = sin(pitch * 0.5d)
    cy = cos(yaw * 0.5d)
    sy = sin(yaw * 0.5d)

    qw = (cr * cp * cy) + (sr * sp * sy)
    qx = (sr * cp * cy) - (cr * sp * sy)
    qy = (cr * sp * cy) + (sr * cp * sy)
    qz = (cr * cp * sy) - (sr * sp * cy)

    return, [qx, qy, qz, qw]
    
end

