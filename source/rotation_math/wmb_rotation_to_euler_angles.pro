;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_rotation_to_euler_angles
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_rotation_to_euler_angles, input_rotation_matrix

    compile_opt idl2, strictarrsubs

    return, wmb_quaternion_to_euler_angles(wmb_rotation_to_quaternion(input_rotation_matrix))
    
end

