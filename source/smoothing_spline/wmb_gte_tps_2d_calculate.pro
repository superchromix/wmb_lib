;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_gte_tps_2d_calculate
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_gte_tps_2d_calculate, x_input, $
                              y_input, $
                              z_data, $
                              smooth_factor, $
                              output_coeffs_a, $
                              output_coeffs_b, $
                              execution_time = execution_time, $
                              binary_dir = binary_dir

    compile_opt idl2, strictarrsubs

    normalize_coords = 0

    library_name = binary_dir + 'wmb_gte.dll'
    function_name = 'wmb_gte_IntpThinPlateSpline2_portable'

    npoints = N_elements(x_input)

    input_npoints = long(npoints)
    input_xcoords = double(x_input)
    input_ycoords = double(y_input)
    input_zdata = double(z_data)
    input_smooth = double(smooth_factor)
    input_normalize_coords = fix(normalize_coords)
    output_coeffs_a = dblarr(npoints)
    output_coeffs_b = dblarr(3)

    ; call the dll
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_npoints, $
                         input_xcoords, $
                         input_ycoords, $
                         input_zdata, $
                         input_smooth, $
                         input_normalize_coords, $
                         output_coeffs_a, $
                         output_coeffs_b, $
                         /VERBOSE)

    execution_time = toc(tmp_timer)

end