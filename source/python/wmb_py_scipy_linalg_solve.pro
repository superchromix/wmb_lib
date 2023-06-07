;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_py_scipy_linalg_solve
;   
;   scipy.linalg.solve
;
;   Possible values for assume_a : gen, sym, her, pos
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_py_scipy_linalg_solve, A, $
                                    b, $
                                    lower = lower, $
                                    overwrite_a = overwrite_a, $
                                    overwrite_b = overwrite_b, $
                                    check_finite = check_finite, $
                                    assume_a = assume_a, $
                                    transposed = transposed, $
                                    type_double = type_double, $
                                    execution_time = execution_time, $
                                    binary_dir = binary_dir, $
                                    python_dir = python_dir


    compile_opt idl2, strictarrsubs

    if N_elements(lower) eq 0 then lower = 0
    if N_elements(overwrite_a) eq 0 then overwrite_a = 0
    if N_elements(overwrite_b) eq 0 then overwrite_b = 0
    if N_elements(check_finite) eq 0 then check_finite = 0
    if N_elements(transposed) eq 0 then transposed = 0
    if N_elements(assume_a) eq 0 then assume_a = 'gen'
    if N_elements(type_double) eq 0 then type_double = 0

    if N_elements(python_dir) eq 0 then begin
        message, 'Path to Python interpreter is required'
    endif
    
    a_dtype = size(A, /TYPE)
    b_dtype = size(b, /TYPE)
    
    ; by default, the function will run with 4-byte floats
    function_dtype = 4
    
    if a_dtype eq 5 or b_dtype eq 5 or type_double eq 1 then begin
        function_dtype = 5    
    endif
    
    library_name = binary_dir + 'wmb_py_functions.dll'

    case function_dtype of
        4: function_name='wmb_py_scipy_linalg_solve_flt_portable'
        5: function_name='wmb_py_scipy_linalg_solve_dbl_portable'
    endcase

    if a_dtype eq function_dtype then begin
        a_temp = temporary(A)
        a_matrix_copied = 0
    endif else begin
        a_temp = fix(A, TYPE = function_dtype)
        a_matrix_copied = 1
    endelse
    
    if b_dtype eq function_dtype then begin
        b_temp = temporary(b)
        b_matrix_copied = 0
    endif else begin
        b_temp = fix(b, TYPE = function_dtype)
        b_matrix_copied = 1
    endelse
    
    a_matrix_nd = size(a_temp, /N_DIMENSIONS)
    a_matrix_dims = size(a_temp, /DIMENSIONS)
    
    if a_matrix_nd ne 2 then begin
        message, 'Non-square A matrix'
    endif
    
    if a_matrix_dims[0] ne a_matrix_dims[1] then begin
        message, 'Non-square A matrix'
    endif
    
    n = a_matrix_dims[0]
    
    b_matrix_nd = size(b_temp, /N_DIMENSIONS)
    b_matrix_dims = size(b_temp, /DIMENSIONS)
    
    if b_matrix_nd eq 1 then begin
        
        if b_matrix_dims[0] ne n then message, 'Invalid B matrix'
        nrhs = 1
        
    endif else if b_matrix_nd eq 2 then begin
        
        if b_matrix_dims[1] ne n then message, 'Invalid B matrix'
        nrhs = b_matrix_dims[0]
        
    endif else begin
        
        message, 'Invalid B matrix'
        
    endelse
    
    ; fix the path separators in the python directory string
    modified_python_dir = python_dir.Replace('\','/')
    
    input_python_dir = [byte(modified_python_dir), 0B]
    input_n = long(n)
    input_nrhs = long(nrhs)
    input_lower = long(lower)
    input_overwrite_a = long(overwrite_a)
    input_overwrite_b = long(overwrite_b)
    input_check_finite = long(check_finite)
    input_transposed = long(transposed)
    
    case strlowcase(assume_a) of
        'gen': input_assume_a = 0L
        'sym': input_assume_a = 1L
        'her': input_assume_a = 2L
        'pos': input_assume_a = 3L
        else: input_assume_a = 0L
    endcase
 
    output_x = make_array(nrhs, n, TYPE = function_dtype, /NOZERO)

    ; call the dll
    
    ;mytext = 'Test'
    ;result = dialog_message(mytext, /INFO)
            
    tmp_timer = tic()
            
    tmp =  call_external(library_name, $
                         function_name, $
                         input_python_dir, $
                         input_n, $
                         input_nrhs, $
                         a_temp, $
                         b_temp, $
                         input_lower, $
                         input_overwrite_a, $
                         input_overwrite_b, $
                         input_check_finite, $
                         input_assume_a, $
                         input_transposed, $
                         output_x, $
                         RETURN_TYPE = 3, $
                         /VERBOSE)

    execution_time = toc(tmp_timer)

    if tmp ne 0 then message, 'Error code ' + strtrim(string(tmp),2)

    if a_matrix_copied eq 0 then A = temporary(a_temp)
    if b_matrix_copied eq 0 then b = temporary(b_temp)

    return, output_x

end



pro wmb_py_scipy_linalg_solve_test

    compile_opt idl2, strictarrsubs

    python_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\python\Python311'
    binary_dir = 'C:\Mark\Software_development\IDL_projects\daxview\resource\binary\Release\'

    python_found = dv_find_python(python_dir = python_dir)
    if python_found eq 0 then message, 'Error: Python installation not found'

    seeda = systime(/seconds)
    
    aa = [[3, 2, 0], [1, -1, 0], [0, 5, 1]]    
    xx = [2.0, -2.0, 9.0]
    bb = aa ## xx
    
    xx_result = wmb_py_scipy_linalg_solve(aa, bb, binary_dir=binary_dir, python_dir=python_dir)
    
    print, xx_result

end