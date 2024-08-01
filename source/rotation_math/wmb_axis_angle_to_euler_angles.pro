;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_axis_angle_to_euler_angles
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_axis_angle_to_euler_angles, axisangle_arr

    compile_opt idl2, strictarrsubs

    return, wmb_quaternion_to_euler_angles(wmb_axis_angle_to_quaternion(axisangle_arr))
    
end

