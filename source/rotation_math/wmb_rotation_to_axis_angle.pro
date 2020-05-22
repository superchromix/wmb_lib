;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_rotation_to_axis_angle
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_rotation_to_axis_angle, input_rotation_matrix

    compile_opt idl2, strictarrsubs

    return, wmb_quaternion_to_axis_angle(wmb_rotation_to_quaternion(input_rotation_matrix))
    
end

