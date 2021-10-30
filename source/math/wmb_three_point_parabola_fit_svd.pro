function wmb_three_point_parabola_fit_svd, x, y, vertex_x = vertex_x, vertex_y = vertex_y

    compile_opt idl2, strictarrsubs

    x1 = x[0]
    x2 = x[1]
    x3 = x[2]
    
    y1 = y[0]
    y2 = y[1]
    y3 = y[2]

    A = [  [ x1^2, x1, 1.0 ], $
           [ x2^2, x2, 1.0 ], $
           [ x3^2, x3, 1.0 ]  ]
    
    B = [ y1, y2, y3 ]
                      
    tmp_pinv = wmb_pinv(A)
    
    result = tmp_pinv ## B

    a = result[0]
    b = result[1]
    c = result[2]

    vertex_x = -b / (2*a)
    vertex_y = ( c - ( b^2 / (4*a) ) ) 
    
    return, [a, b, c]

end