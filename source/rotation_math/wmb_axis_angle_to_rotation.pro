;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_axis_angle_to_rotation
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_axis_angle_to_rotation, axisangle_arr

    compile_opt idl2, strictarrsubs

    if N_elements(axisangle_arr) ne 4 then message, 'Invalid input'

    AA = axisangle_arr

    if size(AA, /TYPE) ne 5 then AA = double(AA)

    rotation_axis = AA[0:2]
    rotation_angle_rad = AA[3]

    u = rotation_axis / norm(rotation_axis)
    
    ux = u[0]
    uy = u[1]
    uz = u[2]
    
    uxy = ux * uy
    uxz = ux * uz
    uyz = uy * uz
    
    c = cos(rotation_angle_rad)
    s = sin(rotation_angle_rad)
    omc = (1.0D - c)
    
    R = [  [ c + ux*ux*omc,  uxy*omc - uz*s, uxz*omc + uy*s ], $
           [ uxy*omc + uz*s, c + uy*uy*omc,  uyz*omc - ux*s ], $
           [ uxz*omc - uy*s, uyz*omc + ux*s, c + uz*uz*omc  ]  ] 
    
    return, R
    
end

