;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_axis_angle_to_quaternion
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_axis_angle_to_quaternion, axisangle_arr

    compile_opt idl2, strictarrsubs

    if N_elements(axisangle_arr) ne 4 then message, 'Invalid input'

    AA = axisangle_arr

    if size(AA, /TYPE) ne 5 then AA = double(AA)

    rotation_axis = AA[0:2]
    rotation_angle_rad = AA[3]
    
    u = rotation_axis / norm(rotation_axis)
    
    half_angle = rotation_angle_rad/2.0D
    
    qw = cos(half_angle)
    qx = u[0] * sin(half_angle)
    qy = u[1] * sin(half_angle)
    qz = u[2] * sin(half_angle)

    return, [qx, qy, qz, qw]
    
end

