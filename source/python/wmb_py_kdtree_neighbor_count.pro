;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_kdtree_neighbor_count
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_kdtree_neighbor_count, x_coords, $
                                       y_coords, $
                                       z_coords, $
                                       search_radius, $
                                       execution_time = execution_time, $
                                       progress_bar = progress_bar, $
                                       binary_dir = binary_dir, $
                                       python_dir = python_dir


    compile_opt idl2, strictarrsubs

    if N_elements(binary_dir) eq 0 then begin
        message, 'Path to DLL is required'
    endif

    if N_elements(python_dir) eq 0 then begin
        message, 'Path to Python interpreter is required'
    endif
    
    n_points = N_elements(x_coords)

    library_name = binary_dir + 'wmb_py_functions.dll'
    function_name='wmb_py_kdtree_loc_density_portable'

    ; fix the path separators in the python directory string
    modified_python_dir = python_dir.Replace('\','/')
    
    input_python_dir = [byte(modified_python_dir), 0B]
    input_n_points = long(n_points)
    input_xc = double(x_coords)
    input_yc = double(y_coords)
    input_zc = double(z_coords)
    input_search_radius = double(search_radius)
 
    output_count = make_array(n_points, TYPE = 3, /NOZERO)

    if obj_valid(progress_bar) then begin

        labeltxt = 'Density calculation in progress: '

        progress_bar.label_text = labeltxt
        progress_bar.Update_fraction, 0.0

    endif

    ; call the dll
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_python_dir, $
                         input_n_points, $
                         input_xc, $
                         input_yc, $
                         input_zc, $
                         input_search_radius, $
                         output_count, $
                         RETURN_TYPE = 3, $
                         /VERBOSE)

    execution_time = toc(tmp_timer)

    if obj_valid(progress_bar) then begin

        progress_bar.Update_fraction, 1.0

    endif

    if tmp ne 0 then message, 'Error code ' + strtrim(string(tmp),2)

    return, output_count

end



pro wmb_py_kdtree_nc_test

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311'
    binary_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\binary\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    n_loc = 50000
    x_domain = 10.0
    y_domain = 10.0
    z_domain = 10.0
    search_radius = x_domain/20.0

    seeda = systime(/seconds)
    
    xc = randomu(seeda, n_loc) * x_domain
    yc = randomu(seeda, n_loc) * y_domain
    zc = randomu(seeda, n_loc) * z_domain
    
    timer1 = tic()
    
    count1 = wmb_py_kdtree_neighbor_count(xc, $
                                          yc, $
                                          zc, $
                                          search_radius, $
                                          execution_time = execution_time, $
                                          binary_dir = binary_dir, $
                                          python_dir = python_dir)
                                      
    exc_time1 = toc(timer1)
    
    timer2 = tic()
                                      
    count2 = dv_an_calc_localization_density(xc, $
                                             yc, $
                                             zc, $
                                             search_radius)
                                         
    exc_time2 = toc(timer2)
                                         
    print, 'Mean discrepancy: ', mean(count1-count2)
    print, 'Execution time K-D tree: ', exc_time1
    print, 'Execution time IDL: ', exc_time2

end