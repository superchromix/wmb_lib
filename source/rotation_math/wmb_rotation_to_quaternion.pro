;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_rotation_to_quaternion
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_rotation_to_quaternion, input_rotation_matrix

    compile_opt idl2, strictarrsubs

    if N_elements(input_rotation_matrix) ne 9 then message, 'Invalid input'
    
    R = reform(input_rotation_matrix, 3, 3)
    
    tmp_T = R[0,0] + R[1,1] + R[2,2]
    
    if tmp_T gt 0.0D then begin
        
        tmp_S = sqrt(tmp_T + 1.0D) * 2.0D 
        
        qw = 0.25D * tmp_S
        qx = (R[1,2] - R[2,1]) / tmp_S
        qy = (R[2,0] - R[0,2]) / tmp_S
        qz = (R[0,1] - R[1,0]) / tmp_S
        
    endif else begin
        
        tmp_arr = [R[0,0], R[1,1], R[2,2]]
        tmp_max = max(tmp_arr, max_index)
        
        case max_index of
            
            0: begin
                
                tmp_S = sqrt(1.0D + R[0,0] - R[1,1] - R[2,2]) * 2.0D
                
                qw = (R[1,2] - R[2,1]) / tmp_S;
                qx = 0.25D * tmp_S;
                qy = (R[1,0] + R[0,1]) / tmp_S; 
                qz = (R[2,0] + R[0,2]) / tmp_S; 
                
            end
            
            1: begin
                
                tmp_S = sqrt(1.0D + R[1,1] - R[0,0] - R[2,2]) * 2.0D
                
                qw = (R[2,0] - R[0,2]) / tmp_S;
                qx = (R[1,0] + R[0,1]) / tmp_S; 
                qy = 0.25 * tmp_S;
                qz = (R[2,1] + R[1,2]) / tmp_S; 
                
            end
            
            2: begin
                
                tmp_S = sqrt(1.0D + R[2,2] - R[0,0] - R[1,1]) * 2.0D
                
                qw = (R[0,1] - R[1,0]) / tmp_S;
                qx = (R[2,0] + R[0,2]) / tmp_S;
                qy = (R[2,1] + R[1,2]) / tmp_S;
                qz = 0.25 * tmp_S;
                
            end

        endcase
        
    endelse
        
    q = [qx, qy, qz, qw]
    
    return, q
    
end

