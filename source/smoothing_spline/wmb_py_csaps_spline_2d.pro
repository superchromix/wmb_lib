;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_2d
;   
;   CSAPS cubic smoothing spline
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_2d, xgrid_coords, $
                                 ygrid_coords, $
                                 z_data, $
                                 weights_x = weights_x, $
                                 weights_y = weights_y, $
                                 auto_smooth = auto_smooth, $
                                 normalized_smooth = normalized_smooth, $
                                 smoothing_factor = smoothing_factor, $
                                 execution_time = execution_time, $
                                 binary_dir = binary_dir, $
                                 python_dir = python_dir


    compile_opt idl2, strictarrsubs

    if N_elements(auto_smooth) eq 0 then auto_smooth = 0
    if N_elements(normalized_smooth) eq 0 then normalized_smooth = 0
    if N_elements(smoothing_factor) eq 0 then smoothing_factor = 1.0
    
    if N_elements(weights_x) eq 0 then begin
        weights_x = xgrid_coords
        weights_x[*] = 1.0
    endif
    
    if N_elements(weights_y) eq 0 then begin
        weights_y = ygrid_coords
        weights_y[*] = 1.0
    endif

    if N_elements(python_dir) eq 0 then begin
        message, 'Path to Python interpreter is required'
    endif
    
    ; find python installation
    
    library_name = binary_dir + 'wmb_py_csaps.dll'
    function_name='wmb_py_csaps_spline_2d_portable'
        
    grid_xdim = N_elements(xgrid_coords)
    grid_ydim = N_elements(ygrid_coords)
    
    if auto_smooth eq 1 then begin
        
        chk_autosmooth = 1
        smoothing_factor_mod = dblarr(2)
        
    endif else begin

        chk_autosmooth = 0
        
        if N_elements(smoothing_factor) ne 2 then begin
            
            smoothing_factor_mod = dblarr(2)
            smoothing_factor_mod[*] = smoothing_factor[0]

        endif else begin
            
            smoothing_factor_mod = double(smoothing_factor)
            
        endelse

    endelse
    
    ; fix the path separators in the python directory string
    modified_python_dir = python_dir.Replace('\','/')
    
    input_python_dir = [byte(modified_python_dir), 0B]
    input_xdim = long(grid_xdim)
    input_ydim = long(grid_ydim)
    input_xgrid_coords = double(xgrid_coords)
    input_ygrid_coords = double(ygrid_coords)
    input_zdata = double(transpose(z_data))
    input_weights_x = double(weights_x)
    input_weights_y = double(weights_y)
    input_autosmooth = long(chk_autosmooth)
    input_norm_smooth = long(normalized_smooth)

    input_smoothing_factor = dblarr(2)
    input_smoothing_factor[0] = smoothing_factor_mod
    
    output_spline_coeffs = dblarr(grid_ydim-1,grid_xdim-1,4,4)

    ; call the dll
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_python_dir, $
                         input_xdim, $
                         input_ydim, $
                         input_xgrid_coords, $
                         input_ygrid_coords, $
                         input_zdata, $
                         input_weights_x, $
                         input_weights_y, $
                         input_autosmooth, $
                         input_norm_smooth, $
                         input_smoothing_factor, $
                         output_spline_coeffs, $
                         RETURN_TYPE = 3, $
                         /VERBOSE)

    execution_time = toc(tmp_timer)

    if tmp ne 0 then message, 'Error code ' + strtrim(string(tmp),2)

    if auto_smooth eq 1 then smoothing_factor = input_smoothing_factor

    return, output_spline_coeffs

end



pro wmb_py_csaps_spline_2d_test

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_csaps_repo\win64\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    n_grid_points_x = 200
    n_grid_points_y = 50
    
    xstart = -5.0
    xend = 5.0
    
    ystart = -5.0
    yend = 5.0
    
    x_sd = (xend-xstart)/4.0
    y_sd = (yend-ystart)/7.0
    
    gnoise = 0.2
    bg = 1.5
    
    dx = (xend-xstart)/(n_grid_points_x-1)
    dy = (yend-ystart)/(n_grid_points_y-1)
    
    xgrid_coords = (lindgen(n_grid_points_x) * dx) + xstart
    ygrid_coords = (lindgen(n_grid_points_y) * dy) + ystart
    
    wmb_meshgrid, xgrid_coords, ygrid_coords, X_out, Y_out
    
    z = exp(-0.5 * ((X_out/x_sd)^2 + (Y_out/y_sd)^2)) $
        + randomu(seeda, n_grid_points_x, n_grid_points_y) * gnoise + bg

    spl_coeffs = wmb_py_csaps_spline_2d(xgrid_coords, $
                                        ygrid_coords, $
                                        z, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 0.55, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords

    zsmooth = wmb_py_csaps_spline_2d_render(X_out, Y_out, spl_breaks_x, spl_breaks_y, spl_coeffs) 

    ydat = fltarr(n_grid_points_x,2,n_grid_points_y)
    
    for i = 0, n_grid_points_y-1 do begin
        ydat[0,0,i] = z[*,i]
        ydat[0,1,i] = zsmooth[*,i]
    endfor

    result = daxview_plot_xy_data(xgrid_coords, $
                                  ydat, $
                                  LINESTYLE=[6,0], $
                                  SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)], $
                                  /AUTOSCALE_GLOBAL)

    result = daxview_plot_image(zsmooth-z)

end