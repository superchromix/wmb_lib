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
    
    library_name = binary_dir + 'wmb_py_csaps.dll'
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
    binary_dir = 'C:\Mark\Software_Development\IDL_projects\daxview\resource\binary\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    npoints = 100
    
    xstart = -5.0
    xend = 5.0
    gnoise = 0.2
    
    dx = (xend-xstart)/(npoints-1)
    
    x = (lindgen(npoints) * dx) + xstart
    
    y = exp(-(x/((xend-xstart)/4.0))^2) + randomu(seeda, npoints) * gnoise
    ;y = findgen(npoints)

    spl_coeffs = wmb_py_csaps_spline_1d(x, $
                                        y, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 0.35, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    spl_breaks = x
    
    ysmooth = wmb_py_csaps_spline_1d_render(x, spl_breaks, spl_coeffs) 

    ;print, spl_coeffs[0:9]

    ydat = fltarr(npoints,2)
    ydat[0,0] = y
    ydat[0,1] = ysmooth
    result = daxview_plot_xy_data(x, $
                                  ydat, $
                                  LINESTYLE=[6,0], $
                                  SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)])

    ;mytext = 'Passed'
    ;result = dialog_message(mytext, /INFO)

end