;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_euler_angles_to_rotation
;
;   Euler angles are stored as [rot_x, rot_y, rot_z]
;   
;   Function assumes the order of rotations is first Z, then Y, 
;   then X.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_euler_angles_to_rotation, eulerangle_arr

    compile_opt idl2, strictarrsubs

    if N_elements(eulerangle_arr) ne 3 then message, 'Invalid input'

    EA = eulerangle_arr

    if size(EA, /TYPE) ne 5 then EA = double(EA)
  
    ;Build three rotation matrices around the x-, y- and z-axis
    
    Rx = [[1.d,0.d,0.d],$
          [0.,cos(EA[0]),-sin(EA[0])],$
          [0.,sin(EA[0]), cos(EA[0])]]
          
    Ry = [[cos(EA[1]),0.d,sin(EA[1])],$
          [0d,1.d,0.d],$
          [-sin(EA[1]),0.d,cos(EA[1])]]
        
    Rz = [[cos(EA[2]),-sin(EA[2]),0.d],$
          [sin(EA[2]), cos(EA[2]),0.d],$
          [0.d,0.d,1.d]]
  
    ;Combine these matrixes to get the final rotation matrix
    R = Rx#Ry#Rz
    
    return, R
    
end

