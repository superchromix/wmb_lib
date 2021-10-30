function wmb_three_point_parabola_fit, x, y, vertex_x = vertex_x, vertex_y = vertex_y

    compile_opt idl2, strictarrsubs

    x1 = x[0]
    x2 = x[1]
    x3 = x[2]
    
    y1 = y[0]
    y2 = y[1]
    y3 = y[2]

    denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
    a = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2))
    b = (x3^2 * (y1 - y2) + x2^2 * (y3 - y1) + x1^2 * (y2 - y3))
    c = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3)

    vertex_x = -b / (2*a)
    vertex_y = ( c - ( b^2 / (4*a) ) ) / denom

    return, [a, b, c]

end