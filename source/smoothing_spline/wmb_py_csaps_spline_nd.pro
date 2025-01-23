;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_csaps_spline_nd
;   
;   CSAPS cubic smoothing spline
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_csaps_spline_nd, ndim, $
                                 grid_dims, $
                                 grid_coords, $
                                 f_data, $
                                 weights = weights, $
                                 auto_smooth = auto_smooth, $
                                 normalized_smooth = normalized_smooth, $
                                 smoothing_factor = smoothing_factor, $
                                 output_coeff_dims = output_coeff_dims, $
                                 execution_time = execution_time, $
                                 binary_dir = binary_dir, $
                                 python_dir = python_dir


    compile_opt idl2, strictarrsubs

    if N_elements(auto_smooth) eq 0 then auto_smooth = 0
    if N_elements(normalized_smooth) eq 0 then normalized_smooth = 0
    if N_elements(smoothing_factor) eq 0 then smoothing_factor = 1.0

    if N_elements(python_dir) eq 0 then begin
        message, 'Path to Python interpreter is required'
    endif
    
    ; find python installation
    
    library_name = binary_dir + 'wmb_py_functions.dll'
    function_name='wmb_py_csaps_spline_nd_portable'
    
    
    if N_elements(weights) ne N_elements(grid_coords) then begin
        
        weights_mod = grid_coords
        weights_mod[*] = 1.0
        
    endif else begin
        
        weights_mod = weights
        
    endelse
    
    
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
    input_ndim = long(ndim)
    input_dims = long(grid_dims)
    input_grid_coords = double(grid_coords)
    input_weights = double(weights_mod)
    input_fdata = double(transpose(f_data))
    input_autosmooth = long(chk_autosmooth)
    input_norm_smooth = long(normalized_smooth)

    input_smoothing_factor = dblarr(ndim)
    input_smoothing_factor[0] = smoothing_factor_mod
    
    output_spline_coeffs = dblarr(product([grid_dims-1,replicate(4,ndim)]), /NOZERO)

    ; call the dll
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_python_dir, $
                         input_ndim, $
                         input_dims, $
                         input_grid_coords, $
                         input_weights, $
                         input_fdata, $
                         input_autosmooth, $
                         input_norm_smooth, $
                         input_smoothing_factor, $
                         output_spline_coeffs, $
                         RETURN_TYPE = 3, $
                         /VERBOSE)

    execution_time = toc(tmp_timer)

    if tmp ne 0 then message, 'Error code ' + strtrim(string(tmp),2)

    if auto_smooth eq 1 then smoothing_factor = input_smoothing_factor

    output_coeff_dims = [reverse(grid_dims-1), replicate(4,ndim)]

    return, output_spline_coeffs

end



pro wmb_py_csaps_spline_nd_test

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'
    ;binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\RelWithDebugInfo\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    n_grid_points_x = 8
    n_grid_points_y = 8
    n_grid_points_z = 10
    n_grid_points_t = 8
    n_grid_points_u = 7
    n_grid_points_v = 6
    
    xstart = -5.0
    xend = 5.0
    
    ystart = -5.0
    yend = 5.0
    
    zstart = -5.0
    zend = 5.0
    
    tstart = -5.0
    tend = 5.0
    
    ustart = -5.0
    uend = 5.0
    
    vstart = -5.0
    vend = 5.0
    
    x_sd = (xend-xstart)/4.0
    y_sd = (yend-ystart)/7.0
    z_sd = (yend-ystart)/9.0
    t_sd = (tend-tstart)/4.0
    u_sd = (uend-ustart)/7.0
    v_sd = (vend-vstart)/9.0
    
    gnoise = 0.2
    bg = 1.5
    
    dx = (xend-xstart)/(n_grid_points_x-1)
    dy = (yend-ystart)/(n_grid_points_y-1)
    dz = (zend-zstart)/(n_grid_points_z-1)
    dt = (tend-tstart)/(n_grid_points_t-1)
    du = (uend-ustart)/(n_grid_points_u-1)
    dv = (vend-vstart)/(n_grid_points_v-1)
    
    xgrid_coords = (lindgen(n_grid_points_x) * dx) + xstart
    ygrid_coords = (lindgen(n_grid_points_y) * dy) + ystart
    zgrid_coords = (lindgen(n_grid_points_z) * dz) + zstart
    tgrid_coords = (lindgen(n_grid_points_t) * dt) + tstart
    ugrid_coords = (lindgen(n_grid_points_u) * du) + ustart
    vgrid_coords = (lindgen(n_grid_points_v) * dv) + vstart
    
    output_grids = wmb_meshgrid_nd(list(xgrid_coords,ygrid_coords,zgrid_coords,tgrid_coords,ugrid_coords,vgrid_coords))
    
    xgrid = output_grids[0]
    ygrid = output_grids[1]
    zgrid = output_grids[2]
    tgrid = output_grids[3]
    ugrid = output_grids[4]
    vgrid = output_grids[5]
    
    f = exp(-0.5 * ((xgrid/x_sd)^2 + (ygrid/y_sd)^2 + (zgrid/z_sd)^2 + (tgrid/t_sd)^2 + (ugrid/u_sd)^2 + (vgrid/v_sd)^2)) $
        + randomu(seeda, n_grid_points_x, n_grid_points_y, n_grid_points_z, n_grid_points_t, n_grid_points_u, n_grid_points_v) * gnoise + bg

    ndim = 6
    
    grid_dims = [n_grid_points_x, n_grid_points_y, n_grid_points_z, n_grid_points_t, n_grid_points_u, n_grid_points_v]

    grid_coords = [xgrid_coords, ygrid_coords, zgrid_coords, tgrid_coords, ugrid_coords, vgrid_coords]

    spl_coeffs = wmb_py_csaps_spline_nd(ndim, $
                                        grid_dims, $
                                        grid_coords, $
                                        f, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 0.85, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    spl_coeffs = reform(spl_coeffs, [reverse(grid_dims-1), replicate(4,ndim)], /OVERWRITE)

    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords
    spl_breaks_z = zgrid_coords
    spl_breaks_t = tgrid_coords
    spl_breaks_u = ugrid_coords
    spl_breaks_v = vgrid_coords
    
    ;print, spl_coeffs[0:3]
    
    print, execution_time

end

pro wmb_py_csaps_spline_nd_test_v2

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'

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

                                        
    ndim = 2
    grid_dims = [n_grid_points_x, n_grid_points_y]
    grid_coords = [xgrid_coords, ygrid_coords]

    spl_coeffs = wmb_py_csaps_spline_nd(ndim, $
                                        grid_dims, $
                                        grid_coords, $
                                        z, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 0.55, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    spl_coeffs = reform(spl_coeffs, [reverse(grid_dims-1), replicate(4,ndim)], /OVERWRITE)

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

pro wmb_py_csaps_spline_nd_test_v3

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    n_grid_points_x = 20
    n_grid_points_y = 50
    n_grid_points_z = 50
    
    xstart = -5.0
    xend = 5.0
    
    ystart = -5.0
    yend = 5.0
    
    zstart = -5.0
    zend = 5.0
    
    x_sd = (xend-xstart)/4.0
    y_sd = (yend-ystart)/7.0
    z_sd = (zend-zstart)/3.0
    
    gnoise = 0.2
    bg = 1.5
    
    dx = (xend-xstart)/(n_grid_points_x-1)
    dy = (yend-ystart)/(n_grid_points_y-1)
    dz = (zend-zstart)/(n_grid_points_z-1)
    
    xgrid_coords = (lindgen(n_grid_points_x) * dx) + xstart
    ygrid_coords = (lindgen(n_grid_points_y) * dy) + ystart
    zgrid_coords = (lindgen(n_grid_points_z) * dz) + zstart
    
    dim_vectors = list(xgrid_coords,ygrid_coords,zgrid_coords)
    
    tmp_meshgrid = wmb_meshgrid_nd(dim_vectors)
    
    X_out = tmp_meshgrid[0]
    Y_out = tmp_meshgrid[1]
    Z_out = tmp_meshgrid[2]
    
    f = exp(-0.5 * ((X_out/x_sd)^2 + (Y_out/y_sd)^2 + (Z_out/z_sd)^2)) $
        + randomu(seeda, n_grid_points_x, n_grid_points_y, n_grid_points_z) * gnoise + bg

                                        
    ndim = 3
    grid_dims = [n_grid_points_x, n_grid_points_y, n_grid_points_z]
    grid_coords = [xgrid_coords, ygrid_coords, zgrid_coords]

    spl_coeffs = wmb_py_csaps_spline_nd(ndim, $
                                        grid_dims, $
                                        grid_coords, $
                                        f, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 0.55, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        output_coeff_dims = spl_coeff_dims, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    spl_coeffs = reform(spl_coeffs, spl_coeff_dims, /OVERWRITE)

    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords
    spl_breaks_z = zgrid_coords

    fsmooth = wmb_py_csaps_spline_3d_render(X_out, Y_out, Z_out, spl_breaks_x, spl_breaks_y, spl_breaks_z, spl_coeffs) 

    ydat = fltarr(n_grid_points_x,2,n_grid_points_y)
    
    for i = 0, n_grid_points_y-1 do begin
        ydat[0,0,i] = f[*,i, n_grid_points_z/2]
        ydat[0,1,i] = fsmooth[*,i,n_grid_points_z/2]
    endfor

    result = daxview_plot_xy_data(xgrid_coords, $
                                  ydat, $
                                  LINESTYLE=[6,0], $
                                  SYMBOL=[obj_new('IDLgrSymbol', 6), obj_new('IDLgrSymbol', 0)], $
                                  /AUTOSCALE_GLOBAL)

    result = daxview_plot_image(fsmooth, OBJ_NAME='Render 3D')
    result = daxview_plot_image(f)
    

    n_coords = N_elements(X_out)
    
    render_input_coords = fltarr(n_coords, ndim)
    render_input_coords[0,0] = reform(X_out, n_coords)
    render_input_coords[0,1] = reform(Y_out, n_coords)
    render_input_coords[0,2] = reform(Z_out, n_coords)
    
    render_spl_break_dims = [N_elements(spl_breaks_x), N_elements(spl_breaks_y), N_elements(spl_breaks_z)]
    
    render_spl_break_coords = [spl_breaks_x, spl_breaks_y, spl_breaks_z]
    
    render_spl_coeffs = reform(spl_coeffs, N_elements(spl_coeffs))
    
    fsmooth_nd = wmb_py_csaps_spline_nd_render(ndim, $
                                               render_input_coords, $
                                               render_spl_break_dims, $
                                               render_spl_break_coords, $
                                               render_spl_coeffs, $
                                               spl_coeff_dims)

    fsmooth_nd = reform(fsmooth_nd, grid_dims, /OVERWRITE)
    
    result = daxview_plot_image(fsmooth_nd, OBJ_NAME='Render ND')

end


pro wmb_py_csaps_spline_nd_test_v4

    compile_opt idl2, strictarrsubs

    default_data_path = 'M:\ultra_nanoscale\Yiming_li_data\Astigmatism_beads_stacks_2um\'

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    npsfs = 4
    
    outpath = default_data_path
    
    for i = 0, npsfs-1 do begin
        
        fn = dialog_pickfile(/READ, PATH=outpath, GET_PATH=outpath, FILTER='*.obf')
        
        if fn eq '' then return
        
        cd, outpath
        
        tmp_if = obj_new('dv_ImageDataFileHandler', fn)
        tmp_id = dv_open_imagestack4d_obf(tmp_if)
        
        if i eq 0 then begin
            
            stackdims = tmp_id.dimsizes
            
            psf_data = fltarr([stackdims,npsfs])
            
        endif
        
        psf_data[0,0,0,i] = tmp_id[*,*,*,0]
        
        obj_destroy, tmp_id
        obj_destroy, tmp_if
        
    endfor


    ndim = 4    
    xgrid_coords = findgen(stackdims[0])
    ygrid_coords = findgen(stackdims[1])
    zgrid_coords = findgen(stackdims[2])
    psfgrid_coords = findgen(npsfs)

    grid_dims = [stackdims[0], stackdims[1], stackdims[2], npsfs]
    grid_coords = [xgrid_coords, ygrid_coords, zgrid_coords, psfgrid_coords]

    spl_coeffs = wmb_py_csaps_spline_nd(ndim, $
                                        grid_dims, $
                                        grid_coords, $
                                        psf_data, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 1.0, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        output_coeff_dims = spl_coeff_dims, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    print, 'SPL coeff exec time: ', execution_time



    psf_resample_factor = 2.0

    new_n_psf = npsfs * psf_resample_factor
    render_psf_coords = findgen(new_n_psf) /  psf_resample_factor


    dim_vectors = list(xgrid_coords,ygrid_coords,zgrid_coords,render_psf_coords)
    
    tmp_meshgrid = wmb_meshgrid_nd(dim_vectors)
    
    X_out = tmp_meshgrid[0]
    Y_out = tmp_meshgrid[1]
    Z_out = tmp_meshgrid[2]
    PSFaxis_out = tmp_meshgrid[3]

    n_coords = N_elements(X_out)
    
    render_input_coords = fltarr(n_coords, ndim)
    render_input_coords[0,0] = reform(X_out, n_coords)
    render_input_coords[0,1] = reform(Y_out, n_coords)
    render_input_coords[0,2] = reform(Z_out, n_coords)
    render_input_coords[0,3] = reform(PSFaxis_out, n_coords)
    
    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords
    spl_breaks_z = zgrid_coords
    spl_breaks_psf = psfgrid_coords
    
    render_spl_break_dims = [N_elements(spl_breaks_x), N_elements(spl_breaks_y), N_elements(spl_breaks_z), N_elements(spl_breaks_psf)]
    
    render_spl_break_coords = [spl_breaks_x, spl_breaks_y, spl_breaks_z, spl_breaks_psf]
    
    render_spl_coeffs = reform(spl_coeffs, N_elements(spl_coeffs))
    
    fsmooth_nd = wmb_py_csaps_spline_nd_render(ndim, $
                                               render_input_coords, $
                                               render_spl_break_dims, $
                                               render_spl_break_coords, $
                                               render_spl_coeffs, $
                                               spl_coeff_dims, $
                                               execution_time = execution_time)

    print, 'Render exec time: ', execution_time

    mod_grid_dims = [stackdims[0], stackdims[1], stackdims[2], new_n_psf]

    fsmooth_nd = reform(fsmooth_nd, mod_grid_dims, /OVERWRITE)
    
    imgdat_nd = obj_new('dv_ImageStackND', Indata=fsmooth_nd, $
                                           Nstackdims=4, $
                                           Nchannels=1, $
                                           DimSizes=mod_grid_dims, $
                                           DimLabels=['X','Y','Z','X1'])
    
    result = daxview_show_data(imgdat_nd)
    
end


pro wmb_py_csaps_spline_nd_test_v5

    compile_opt idl2, strictarrsubs

    default_data_path = 'M:\ultra_nanoscale\Yiming_li_data\Astigmatism_beads_stacks_2um\'

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    npsf_x = 4
    npsf_y = 4
    
    outpath = default_data_path
    
    fn_list = dialog_pickfile(/READ, PATH=outpath, GET_PATH=outpath, FILTER='*.obf', /MULTIPLE_FILES)
        
    if fn_list[0] eq '' then return
        
    cd, outpath
        
    nfiles = N_elements(fn_list)
    
    if nfiles ne npsf_x*npsf_y then begin
        
        print, 'Incorrect number of files selected'
        return
        
    endif
    
    for i = 0, npsf_x-1 do begin
        for j = 0, npsf_y-1 do begin
        
            fn = fn_list[(i*npsf_y) + j]
        
            tmp_if = obj_new('dv_ImageDataFileHandler', fn)
            tmp_id = dv_open_imagestack4d_obf(tmp_if)
            
            if i eq 0 then begin
                
                stackdims = tmp_id.dimsizes
                
                psf_data = fltarr([stackdims,npsf_x,npsf_y])
                
            endif
            
            tmp_psf = float(tmp_id[*,*,*,0])
            
            tmp_psf = tmp_psf / max(tmp_psf)
            
            tmp_psf = tmp_psf * 1000.0
            
            psf_data[0,0,0,i,j] = tmp_psf
            
            obj_destroy, tmp_id
            obj_destroy, tmp_if
        
        endfor
    endfor


    ndim = 5
    xgrid_coords = findgen(stackdims[0])
    ygrid_coords = findgen(stackdims[1])
    zgrid_coords = findgen(stackdims[2])
    psfgrid_coords_x = findgen(npsf_x)
    psfgrid_coords_y = findgen(npsf_y)

    grid_dims = [stackdims[0], stackdims[1], stackdims[2], npsf_x, npsf_y]
    grid_coords = [xgrid_coords, ygrid_coords, zgrid_coords, psfgrid_coords_x, psfgrid_coords_y]

    spl_coeffs = wmb_py_csaps_spline_nd(ndim, $
                                        grid_dims, $
                                        grid_coords, $
                                        psf_data, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 1.0, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        output_coeff_dims = spl_coeff_dims, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    print, 'SPL coeff exec time: ', execution_time


    psf_resample_factor = 1.0

    new_n_psf_x = npsf_x * psf_resample_factor
    render_psf_coords_x = findgen(new_n_psf_x) /  psf_resample_factor
    
    new_n_psf_y = npsf_y * psf_resample_factor
    render_psf_coords_y = findgen(new_n_psf_y) /  psf_resample_factor


    dim_vectors = list(xgrid_coords,ygrid_coords,zgrid_coords,render_psf_coords_x,render_psf_coords_y)
    
    tmp_meshgrid = wmb_meshgrid_nd(dim_vectors)
    
    X_out = tmp_meshgrid[0]
    Y_out = tmp_meshgrid[1]
    Z_out = tmp_meshgrid[2]
    PSFaxis_x_out = tmp_meshgrid[3]
    PSFaxis_y_out = tmp_meshgrid[4]
    

    n_coords = N_elements(X_out)
    
    render_input_coords = fltarr(n_coords, ndim)
    render_input_coords[0,0] = reform(X_out, n_coords)
    render_input_coords[0,1] = reform(Y_out, n_coords)
    render_input_coords[0,2] = reform(Z_out, n_coords)
    render_input_coords[0,3] = reform(PSFaxis_x_out, n_coords)
    render_input_coords[0,4] = reform(PSFaxis_y_out, n_coords)
    
    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords
    spl_breaks_z = zgrid_coords
    spl_breaks_psf_x = psfgrid_coords_x
    spl_breaks_psf_y = psfgrid_coords_y
    
    render_spl_break_dims = [N_elements(spl_breaks_x), N_elements(spl_breaks_y), N_elements(spl_breaks_z), N_elements(spl_breaks_psf_x), N_elements(spl_breaks_psf_y)]
    
    render_spl_break_coords = [spl_breaks_x, spl_breaks_y, spl_breaks_z, spl_breaks_psf_x, spl_breaks_psf_y]
    
    render_spl_coeffs = reform(spl_coeffs, N_elements(spl_coeffs))
    
    fsmooth_nd = wmb_py_csaps_spline_nd_render(ndim, $
                                               render_input_coords, $
                                               render_spl_break_dims, $
                                               render_spl_break_coords, $
                                               render_spl_coeffs, $
                                               spl_coeff_dims, $
                                               execution_time = execution_time)

    print, 'Render exec time: ', execution_time

    mod_grid_dims = [stackdims[0], stackdims[1], stackdims[2], new_n_psf_x, new_n_psf_y]

    fsmooth_nd = reform(fsmooth_nd, mod_grid_dims, /OVERWRITE)
    
    imgdat_nd = obj_new('dv_ImageStackND', Indata=fsmooth_nd, $
                                           Nstackdims=5, $
                                           Nchannels=1, $
                                           DimSizes=mod_grid_dims, $
                                           DimLabels=['X','Y','Z','X1','Y1'])
    
    result = daxview_show_data(imgdat_nd)
    
end


pro wmb_py_csaps_spline_nd_test_v6

    compile_opt idl2, strictarrsubs

    default_data_path = 'M:\ultra_nanoscale\Yiming_li_data\Astigmatism_beads_stacks_2um\'

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311\'
    binary_dir = 'C:\Mark\Software_development\C_projects\VS_2019_projects\wmb_py_functions_repo\win64\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    npsf_x = 4
    npsf_y = 4
    
    outpath = default_data_path
    
    psf_data_fn = dialog_pickfile(/READ, PATH=outpath, GET_PATH=outpath, FILTER='*.h5')
        
    if psf_data_fn eq '' then return
        
    cd, outpath
        
    fid = h5f_open(psf_data_fn)
        
    n_beads = wmb_h5_getdata(fid, 'n_beads')
    bead_filename = wmb_h5_getdata(fid, 'bead_filename')
    bead_peak_data = wmb_h5_getdata(fid, 'bead_peak_data')
    bead_psf_dims = wmb_h5_getdata(fid, 'bead_psf_dims')
    bead_halfsize = wmb_h5_getdata(fid, 'bead_halfsize')
    bead_psf_data = wmb_h5_getdata(fid, 'bead_psf_data')

    h5f_close, fid

    tmpdat = fltarr(2,n_beads)
    
    tmpdat[0,*] = reform(bead_peak_data.chm_pkfit_x)
    tmpdat[1,*] = reform(bead_peak_data.chm_pkfit_y)

    tmp_nbin = [npsf_x,npsf_y]

    bead_pos_hist = hist_nd(tmpdat, NBINS=tmp_nbin, REVERSE_INDICES=ri)
    
    stackdims = bead_psf_dims
    psf_data = fltarr([bead_psf_dims,npsf_x,npsf_y])
    
    ; get the PSF data
    
    for j = 0, npsf_y-1 do begin
        for i = 0, npsf_x-1 do begin
        
            ; get the indices of beads in this bin
            
            ind = i + npsf_x*j
            
            n_bin_indices = ri[ind+1] - ri[ind] - 1
            if n_bin_indices eq 0 then message, 'No bin indices found'
            
            tmp_indices = ri[ri[ind]:ri[ind+1]-1]
            
            tmp_pk_data = bead_peak_data[tmp_indices]
            
            tmp_pk_ampl = tmp_pk_data.chm_pkfit_ampl
            
            sort_ind = sort(tmp_pk_ampl)
            
            tmp_pk_ampl_sorted = tmp_pk_ampl[sort_ind]
            tmp_pk_indices_sorted = tmp_indices[sort_ind]
            
            picked_pk_index = tmp_pk_indices_sorted[n_bin_indices/2]
            
            picked_psf_data = bead_peak_data[picked_pk_index]
            
            print, 'PSF ' + strtrim(string(ind),2) + ': ',  picked_psf_data
            
            tmp_psf_data = bead_psf_data[*,*,*,picked_pk_index]

            tmp_psf_data = tmp_psf_data / max(tmp_psf_data)
            
            tmp_psf_data = tmp_psf_data * 1000.0
            
            psf_data[0,0,0,i,j] = tmp_psf_data

        endfor
    endfor

    ; remove the last element in the Z stack and downsample
    
    mod_psf_data = psf_data[*,*,0:-2,*,*]
    
    mod_stackdims = stackdims
    mod_stackdims[2] = mod_stackdims[2] - 1
    
    z_rebin_factor = 10

    rebin_psf_data = rebin(mod_psf_data,mod_stackdims[0],mod_stackdims[1],mod_stackdims[2]/z_rebin_factor,npsf_x,npsf_y)
    
    mod_stackdims[2] = mod_stackdims[2] / z_rebin_factor

    ndim = 5
    xgrid_coords = findgen(mod_stackdims[0])
    ygrid_coords = findgen(mod_stackdims[1])
    zgrid_coords = findgen(mod_stackdims[2])
    psfgrid_coords_x = findgen(npsf_x)
    psfgrid_coords_y = findgen(npsf_y)

    grid_dims = [mod_stackdims[0], mod_stackdims[1], mod_stackdims[2], npsf_x, npsf_y]
    grid_coords = [xgrid_coords, ygrid_coords, zgrid_coords, psfgrid_coords_x, psfgrid_coords_y]

    spl_coeffs = wmb_py_csaps_spline_nd(ndim, $
                                        grid_dims, $
                                        grid_coords, $
                                        rebin_psf_data, $
                                        auto_smooth = 0, $
                                        smoothing_factor = 1.0, $
                                        normalized_smooth = 1, $
                                        execution_time = execution_time, $
                                        output_coeff_dims = spl_coeff_dims, $
                                        binary_dir = binary_dir, $
                                        python_dir = python_dir)

    print, 'SPL coeff exec time: ', execution_time


    psf_resample_factor = 1.0

    new_n_psf_x = npsf_x * psf_resample_factor
    render_psf_coords_x = findgen(new_n_psf_x) /  psf_resample_factor
    
    new_n_psf_y = npsf_y * psf_resample_factor
    render_psf_coords_y = findgen(new_n_psf_y) /  psf_resample_factor


    dim_vectors = list(xgrid_coords,ygrid_coords,zgrid_coords,render_psf_coords_x,render_psf_coords_y)
    
    tmp_meshgrid = wmb_meshgrid_nd(dim_vectors)
    
    X_out = tmp_meshgrid[0]
    Y_out = tmp_meshgrid[1]
    Z_out = tmp_meshgrid[2]
    PSFaxis_x_out = tmp_meshgrid[3]
    PSFaxis_y_out = tmp_meshgrid[4]
    

    n_coords = N_elements(X_out)
    
    render_input_coords = fltarr(n_coords, ndim)
    render_input_coords[0,0] = reform(X_out, n_coords)
    render_input_coords[0,1] = reform(Y_out, n_coords)
    render_input_coords[0,2] = reform(Z_out, n_coords)
    render_input_coords[0,3] = reform(PSFaxis_x_out, n_coords)
    render_input_coords[0,4] = reform(PSFaxis_y_out, n_coords)
    
    spl_breaks_x = xgrid_coords
    spl_breaks_y = ygrid_coords
    spl_breaks_z = zgrid_coords
    spl_breaks_psf_x = psfgrid_coords_x
    spl_breaks_psf_y = psfgrid_coords_y
    
    render_spl_break_dims = [N_elements(spl_breaks_x), N_elements(spl_breaks_y), N_elements(spl_breaks_z), N_elements(spl_breaks_psf_x), N_elements(spl_breaks_psf_y)]
    
    render_spl_break_coords = [spl_breaks_x, spl_breaks_y, spl_breaks_z, spl_breaks_psf_x, spl_breaks_psf_y]
    
    render_spl_coeffs = reform(spl_coeffs, N_elements(spl_coeffs))
    
    fsmooth_nd = wmb_py_csaps_spline_nd_render(ndim, $
                                               render_input_coords, $
                                               render_spl_break_dims, $
                                               render_spl_break_coords, $
                                               render_spl_coeffs, $
                                               spl_coeff_dims, $
                                               execution_time = execution_time)

    print, 'Render exec time: ', execution_time

    mod_grid_dims = [mod_stackdims[0], mod_stackdims[1], mod_stackdims[2], new_n_psf_x, new_n_psf_y]

    fsmooth_nd = reform(fsmooth_nd, mod_grid_dims, /OVERWRITE)
    
    imgdat_nd = obj_new('dv_ImageStackND', Indata=fsmooth_nd, $
                                           Nstackdims=5, $
                                           Nchannels=1, $
                                           DimSizes=mod_grid_dims, $
                                           DimLabels=['X','Y','Z','X1','Y1'])
    
    result = daxview_show_data(imgdat_nd)
    
end


