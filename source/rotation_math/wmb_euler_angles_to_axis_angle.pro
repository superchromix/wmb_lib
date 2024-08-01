;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_euler_angles_to_axis_angle
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_euler_angles_to_axis_angle, eulerangle_arr

    compile_opt idl2, strictarrsubs

    return, wmb_quaternion_to_axis_angle(wmb_euler_angles_to_quaternion(eulerangle_arr))
    
end

