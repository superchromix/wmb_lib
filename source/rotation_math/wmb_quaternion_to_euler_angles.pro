;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_quaternion_to_euler_angles
;   
;   Euler angles are stored as [rot_x, rot_y, rot_z]
;   
;   Function assumes the order of rotations is first Z, then Y, 
;   then X.
;   
;   Quaternion is stored as [qx, qy, qz, qw]
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_quaternion_to_euler_angles, input_quaternion

    compile_opt idl2, strictarrsubs

    if N_elements(input_quaternion) ne 4 then message, 'Invalid input'

    q = input_quaternion

    if size(q, /TYPE) ne 5 then q = double(q)

    qx = q[0]
    qy = q[1]
    qz = q[2]
    qw = q[3]

    ; roll (x-axis rotation)
    sinr_cosp = 2.0d * (qw * qx + qy * qz)
    cosr_cosp = 1.0d - 2.0d * (qx * qx + qy * qy)
    roll = atan(sinr_cosp, cosr_cosp)

    ; pitch (y-axis rotation)
    sinp = sqrt(1.0d + 2.0d * (qw * qy - qx * qz))
    cosp = sqrt(1.0d - 2.0d * (qw * qy - qx * qz))
    pitch = 2.0d * atan(sinp, cosp) - (!dpi / 2.0d)

    ; yaw (z-axis rotation)
    siny_cosp = 2.0d * (qw * qz + qx * qy)
    cosy_cosp = 1.0d - 2.0d * (qy * qy + qz * qz)
    yaw = atan(siny_cosp, cosy_cosp)

    return, [roll, pitch, yaw]
    
end

