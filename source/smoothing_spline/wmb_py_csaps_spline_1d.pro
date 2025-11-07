;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_1d
;   
;   CSAPS cubic smoothing spline
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_1d, xcoords, $
                                 ydata, $
                                 weights = weights, $
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
    
    if N_elements(weights) eq 0 then begin
        weights = dblarr(N_elements(ydata))
        weights[*] = 1.0
    endif

    if N_elements(python_dir) eq 0 then begin
        message, 'Path to Python interpreter is required'
    endif
    
    ; find python installation
    
    library_name = binary_dir + 'wmb_py_functions.dll'
    function_name='wmb_py_csaps_spline_1d_portable'
        
    data_len = N_elements(xcoords)
    
    if auto_smooth eq 1 then begin
        
        chk_autosmooth = 1
        smoothing_factor = 0.0d
        
    endif else chk_autosmooth = 0
    
    ; fix the path separators in the python directory string
    modified_python_dir = python_dir.Replace('\','/')
    
    input_python_dir = [byte(modified_python_dir), 0B]
    input_xdim = long(data_len)
    input_xcoords = double(xcoords)
    input_ydata = double(ydata)
    input_weights = double(weights)
    input_autosmooth = long(chk_autosmooth)
    input_norm_smooth = long(normalized_smooth)

    input_smoothing_factor = dblarr(1)
    input_smoothing_factor[0] = smoothing_factor
    
    output_spline_coeffs = dblarr(data_len-1,4)

    ; call the dll
    
    ;mytext = 'Test'
    ;result = dialog_message(mytext, /INFO)
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_python_dir, $
                         input_xdim, $
                         input_xcoords, $
                         input_ydata, $
                         input_weights, $
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



pro wmb_py_csaps_spline_1d_test

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir_gpuspl = 'C:\Mark\Software_development\C_projects\VS_2013_projects\Gpuspline_repo\win64\Debug\'
    binary_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\binary\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    npoints = 12
    
    xstart = 0.0
    xend = 11.0
    gnoise = 0.2
    
    dx = (xend-xstart)/(npoints-1)
    
    x = (lindgen(npoints) * dx) + xstart
    
    y = exp(-(x/((xend-xstart)/4.0))^2) + randomu(seeda, npoints) * gnoise
    ;y = findgen(npoints)

    spl_coeffs = wmb_py_csaps_spline_1d(x, $
                                        y, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 1.0, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    spl_breaks = x
    
    
    npoints_render = npoints/2
    
    dx_render = (xend-xstart)/(npoints_render-1)
    
    x_render = (lindgen(npoints_render) * dx_render) + xstart
    
    ysmooth_render = wmb_py_csaps_spline_1d_render(x_render, spl_breaks, spl_coeffs) 

    ;print, spl_coeffs[0:9]

    ydat = fltarr(npoints + npoints_render)
    ydat[0] = y
    ydat[npoints] = ysmooth_render
    plot_x_dimsize = [npoints, npoints_render]
    xdat = [x, x_render]
    
    pd = obj_new('dv_PlotdataStack3D', Indata = ydat, $
                                     Nplots = 1, $
                                     Nchannels = 2, $
                                     Plot_x_dimsize = plot_x_dimsize, $
                                     X_values = xdat)
    
    result = daxview_show_data(pd, $
                               LINESTYLE=[6,0], $
                               SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)])

    ;mytext = 'Passed'
    ;result = dialog_message(mytext, /INFO)
    
    grid_spacing_x = dx
    
    std_coeffs = dv_an_proc_spline_convert_csaps_coeffs_1d(npoints, $
                                                           grid_spacing_x, $
                                                           spl_coeffs, $
                                                           spline_coeff_dims = std_spline_coeff_dims, $
                                                           binary_dir = binary_dir_gpuspl)

    spline_pixel_sizes_um = [dx]
    
    new_stack_dims = [npoints_render]

    std_spline = dv_an_proc_spline_render_1d(std_coeffs, $
                                             std_spline_coeff_dims, $
                                             spline_pixel_sizes_um, $
                                             new_stack_dims, $
                                             output_pixel_sizes, $
                                             binary_dir = binary_dir_gpuspl)

    std_spline = dv_an_proc_spline_render_idl_1d(std_coeffs, $
                                                 std_spline_coeff_dims, $
                                                 spline_pixel_sizes_um, $
                                                 new_stack_dims, $
                                                 output_pixel_sizes)
                                             
    ydat = fltarr(npoints + npoints_render)
    ydat[0] = y
    ydat[npoints] = std_spline
    plot_x_dimsize = [npoints, npoints_render]
    xdat = [x, x_render]
    
    pd = obj_new('dv_PlotdataStack3D', Indata = ydat, $
                                     Nplots = 1, $
                                     Nchannels = 2, $
                                     Plot_x_dimsize = plot_x_dimsize, $
                                     X_values = xdat)
    
    result = daxview_show_data(pd, $
                               LINESTYLE=[6,0], $
                               SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)])
                                  
                                  
    ;ydat = fltarr(npoints_render)
    ;ydat[0] = ysmooth_render - std_spline

    ;result = daxview_plot_xy_data(x_render, $
    ;                              ydat)
    

end



pro wmb_py_csaps_spline_1d_test_v2

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir_gpuspl = 'C:\Mark\Software_development\C_projects\VS_2013_projects\Gpuspline_repo\win64\Debug\'
    binary_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\binary\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)

    npoints = 22

    xstart = 0.0
    xend = 21.0
    gnoise = 0.0

    gauss_center = 10.0

    dx = (xend-xstart)/(npoints-1)

    x = (lindgen(npoints) * dx) + xstart

    y = exp(-((x-gauss_center)/((xend-xstart)/4.0))^2) + randomu(seeda, npoints) * gnoise
    ;y = findgen(npoints)

    spl_coeffs = wmb_py_csaps_spline_1d(x, $
                                        y, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 1.0, $
                                        normalized_smooth = 0, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)


    std_coeffs = dv_an_proc_spline_convert_csaps_coeffs_1d(npoints, $
                                                           dx, $
                                                           spl_coeffs, $
                                                           spline_coeff_dims = std_spline_coeff_dims, $
                                                           binary_dir = binary_dir_gpuspl)

    tmp_input_data = y
    tmp_input_dims = [npoints, 1]

    bspl_coeffs = dv_an_proc_bspline_calc_coefficients_1d(tmp_input_data, $
                                                          input_dims = tmp_input_dims, $
                                                          bpline_coeff_dims = bpline_coeff_dims, $
                                                          binary_dir = binary_dir_gpuspl)


    spl_breaks = x

    npoints_render = npoints

    dx_render = (xend-xstart)/(npoints_render-1)

    x_render = (lindgen(npoints_render) * dx_render) + xstart

    ysmooth_render = wmb_py_csaps_spline_1d_render(x_render, spl_breaks, spl_coeffs)

    ;print, spl_coeffs[0:9]

    ydat = fltarr(npoints + npoints_render)
    ydat[0] = y
    ydat[npoints] = ysmooth_render
    plot_x_dimsize = [npoints, npoints_render]
    xdat = [x, x_render]

    pd = obj_new('dv_PlotdataStack3D', Indata = ydat, $
                                       Nplots = 1, $
                                       Nchannels = 2, $
                                       Plot_x_dimsize = plot_x_dimsize, $
                                       X_values = xdat)

    result = daxview_show_data(pd, $
        LINESTYLE=[6,0], $
        SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)], $
        OBJ_NAME = 'CSAPS_SPLINE')



    spline_pixel_sizes_um = [dx]

    new_stack_dims = [npoints_render]

    std_spline = dv_an_proc_spline_render_1d(std_coeffs, $
        std_spline_coeff_dims, $
        spline_pixel_sizes_um, $
        new_stack_dims, $
        output_pixel_sizes, $
        output_x_coords = output_std_x_coords, $
        binary_dir = binary_dir_gpuspl)

    ydat = fltarr(npoints + npoints_render)
    ydat[0] = y
    ydat[npoints] = std_spline
    plot_x_dimsize = [npoints, npoints_render]
    xdat = [x, (output_std_x_coords * dx) + xstart]

    pd = obj_new('dv_PlotdataStack3D', Indata = ydat, $
        Nplots = 1, $
        Nchannels = 2, $
        Plot_x_dimsize = plot_x_dimsize, $
        X_values = xdat)

    result = daxview_show_data(pd, $
        LINESTYLE=[6,0], $
        SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)], $
        OBJ_NAME = 'STD_SPLINE')

    
    bspline = dv_an_proc_bspline_render_1d(bspl_coeffs, $
                                           bpline_coeff_dims, $
                                           spline_pixel_sizes_um, $
                                           new_stack_dims, $
                                           output_pixel_sizes, $
                                           output_x_coords = output_bspl_x_coords, $
                                           binary_dir = binary_dir_gpuspl)

    ydat = fltarr(npoints + npoints_render)
    ydat[0] = y
    ydat[npoints] = bspline
    plot_x_dimsize = [npoints, npoints_render]
    xdat = [x, (output_bspl_x_coords * dx) + xstart]

    pd = obj_new('dv_PlotdataStack3D', Indata = ydat, $
        Nplots = 1, $
        Nchannels = 2, $
        Plot_x_dimsize = plot_x_dimsize, $
        X_values = xdat)

    result = daxview_show_data(pd, $
        LINESTYLE=[6,0], $
        SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)], $
        OBJ_NAME = 'BSPLINE')

    a = 1

end


