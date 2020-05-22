;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_quaternion_to_axis_angle
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_quaternion_to_axis_angle, input_quaternion

    compile_opt idl2, strictarrsubs

    if N_elements(input_quaternion) ne 4 then message, 'Invalid input'

    q = input_quaternion

    if size(q, /TYPE) ne 5 then q = double(q)

    qx = q[0]
    qy = q[1]
    qz = q[2]
    qw = q[3]
    
    nqxyz = norm([qx, qy, qz])
    
    u = [qx, qy, qz] / nqxyz
    
    rot_angle = 2.0D * atan(nqxyz, qw)
    
    ;print, "Rotation axis: ", u / min(abs(u))
    ;print, "Rotation angle (deg.): ", rot_angle * 180.0D / !dpi
    
    return, [u, rot_angle]
    
end

