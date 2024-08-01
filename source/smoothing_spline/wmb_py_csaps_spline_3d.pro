;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_3d
;   
;   CSAPS cubic smoothing spline
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_3d, xgrid_coords, $
                                 ygrid_coords, $
                                 zgrid_coords, $
                                 f_data, $
                                 weights_x = weights_x, $
                                 weights_y = weights_y, $
                                 weights_z = weights_z, $
                                 auto_smooth = auto_smooth, $
                                 normalized_smooth = normalized_smooth, $
                                 smoothing_factor = smoothing_factor, $
                                 execution_time = execution_time, $
                                 binary_dir = binary_dir, $
                                 python_dir = python_dir


    compile_opt idl2, strictarrsubs
    
    ndim = 3

    if N_elements(auto_smooth) eq 0 then auto_smooth = 0
    if N_elements(normalized_smooth) eq 0 then normalized_smooth = 0
    if N_elements(smoothing_factor) eq 0 then smoothing_factor = 1.0

    if N_elements(python_dir) eq 0 then begin
        message, 'Path to Python interpreter is required'
    endif
    
    ; find python installation
    
    library_name = binary_dir + 'wmb_py_functions.dll'
    function_name='wmb_py_csaps_spline_3d_portable'
    
    if N_elements(weights_x) eq 0 then begin
        weights_x = xgrid_coords
        weights_x[*] = 1.0
    endif
    
    if N_elements(weights_y) eq 0 then begin
        weights_y = ygrid_coords
        weights_y[*] = 1.0
    endif

    if N_elements(weights_z) eq 0 then begin
        weights_z = zgrid_coords
        weights_z[*] = 1.0
    endif
    
    grid_xdim = N_elements(xgrid_coords)
    grid_ydim = N_elements(ygrid_coords)
    grid_zdim = N_elements(zgrid_coords)
    
    if auto_smooth eq 1 then begin
        
        chk_autosmooth = 1
        smoothing_factor_mod = dblarr(ndim)
        
    endif else begin

        chk_autosmooth = 0
        
        if N_elements(smoothing_factor) ne ndim then begin
            
            smoothing_factor_mod = dblarr(ndim)
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
    input_zdim = long(grid_zdim)
    input_xgrid_coords = double(xgrid_coords)
    input_ygrid_coords = double(ygrid_coords)
    input_zgrid_coords = double(zgrid_coords)
    input_fdata = double(transpose(f_data))
    input_weights_x = double(weights_x)
    input_weights_y = double(weights_y)
    input_weights_z = double(weights_z)
    input_autosmooth = long(chk_autosmooth)
    input_norm_smooth = long(normalized_smooth)

    input_smoothing_factor = dblarr(ndim)
    input_smoothing_factor[0] = smoothing_factor_mod
    
    output_spline_coeffs = dblarr([grid_xdim-1,grid_ydim-1,grid_zdim-1,replicate(4,ndim)], /NOZERO)

    ; call the dll
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_python_dir, $
                         input_xdim, $
                         input_ydim, $
                         input_zdim, $
                         input_xgrid_coords, $
                         input_ygrid_coords, $
                         input_zgrid_coords, $
                         input_fdata, $
                         input_weights_x, $
                         input_weights_y, $
                         input_weights_z, $
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



pro wmb_py_csaps_spline_3d_test

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    ;binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'

    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\RelWithDebInfo\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    n_grid_points_x = 5
    n_grid_points_y = 5
    n_grid_points_z = 7
    
    xstart = -5.0
    xend = 5.0
    
    ystart = -5.0
    yend = 5.0
    
    zstart = -5.0
    zend = 5.0
    
    x_sd = (xend-xstart)/4.0
    y_sd = (yend-ystart)/7.0
    z_sd = (yend-ystart)/9.0

    
    gnoise = 0.2
    bg = 1.5
    
    dx = (xend-xstart)/(n_grid_points_x-1)
    dy = (yend-ystart)/(n_grid_points_y-1)
    dz = (zend-zstart)/(n_grid_points_z-1)
    
    xgrid_coords = (lindgen(n_grid_points_x) * dx) + xstart
    ygrid_coords = (lindgen(n_grid_points_y) * dy) + ystart
    zgrid_coords = (lindgen(n_grid_points_z) * dz) + zstart
    
    output_grids = wmb_meshgrid_nd(list(xgrid_coords,ygrid_coords,zgrid_coords))
    
    xgrid = output_grids[0]
    ygrid = output_grids[1]
    zgrid = output_grids[2]
    
    f = exp(-0.5 * ((xgrid/x_sd)^2 + (ygrid/y_sd)^2) + (zgrid/z_sd)^2) $
        + randomu(seeda, n_grid_points_x, n_grid_points_y, n_grid_points_z) * gnoise + bg

    ndim = 3
    
    grid_dims = [n_grid_points_x, n_grid_points_y, n_grid_points_z]

    grid_coords = [xgrid_coords, ygrid_coords, zgrid_coords]

    spl_coeffs = wmb_py_csaps_spline_3d(xgrid_coords, $
                                        ygrid_coords, $
                                        zgrid_coords, $
                                        f, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 0.55, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)


    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords
    spl_breaks_z = zgrid_coords
    
    print, spl_coeffs[0:3]

end