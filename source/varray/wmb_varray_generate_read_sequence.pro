
pro wmb_varray_generate_read_sequence, isrange, $
                                       subscript_list, $
                                       arr_dims, $
                                       output_scalar, $
                                       output_dims, $
                                       n_reads, $                                       
                                       read_size, $
                                       read_start, $
                                       n_steps_index = n_steps_index, $
                                       step_size_index = step_size_index, $                                       
                                       read_pos_list = read_pos_list


    compile_opt idl2, strictarrsubs

    n_subscripts = N_elements(isrange)
    
    arr_rank = N_elements(arr_dims)
    
    if n_subscripts ne arr_rank then begin
        message, 'Invalid number of subscripts'
        return
    endif

    ; determine the dimensions of the output array and convert all 
    ; inputs to positive ranges
    
    read_data_dims = ulon64arr(n_subscripts)
    
    range_start = ulon64arr(n_subscripts)
    range_end = ulon64arr(n_subscripts)
    range_stride = ulon64arr(n_subscripts)    
    
    range_span_flag = bytarr(n_subscripts)
    
    
    for i = 0, n_subscripts-1 do begin

        chkdim = arr_dims[i]
        tmp_input = subscript_list[i]

        if ~isrange[i] then begin

            ; an index

            tmp_start = tmp_input
            tmp_end = tmp_input
            tmp_stride = 1

        endif else begin
            
            ; a range
            
            tmp_start = tmp_input[0]
            tmp_end = tmp_input[1]
            tmp_stride = tmp_input[2]
                         
        endelse
        
        if tmp_start lt 0 then tmp_start = tmp_start + chkdim
        if tmp_end lt 0 then tmp_end = tmp_end + chkdim
        
        range_start[i] = tmp_start
        range_end[i] = tmp_end
        range_stride[i] = tmp_stride
        
        range_span_flag[i] = ((tmp_end - tmp_start) + 1) eq chkdim and $
                             (tmp_stride eq 1)
            
        read_data_dims[i] = abs((tmp_end - tmp_start) / tmp_stride) + 1
        
    endfor
    
    
    ; for simple file access, this object does not allow stride values 
    ; other than unity
    
    tmp_index = where(range_stride ne 1, tmp_count)
    if tmp_count ne 0 then begin
        message, 'Non-unity stride values are not supported'
        return
    endif
    

    ; test if the result will be scalar, and determine the final dimensions
    ; of the output array
    
    tmp_output_scalar = 0
    
    rangedimindex = where(isrange eq 1, chkcount)
    
    if chkcount gt 0 then begin
        
        tmp_output_dims = read_data_dims[rangedimindex]
        
    endif else begin
        
        tmp_output_scalar = 1    
        tmp_output_dims = [1]
        
    endelse

    
    ; determine the number of reads and the read chunk size
    
    tmp_n_reads = 1ULL
    chk_contiguous = 1
    first_non_contiguous_dim = -1
    read_chunk_size = 1ULL

    for i = 0, n_subscripts-1 do begin
    
        if chk_contiguous eq 1 then begin
    
            ; we are in the contiguous part of the range
    
            if range_span_flag[i] eq 1 then begin
                
                read_chunk_size = read_chunk_size * read_data_dims[i]
                
            endif else begin
                
                if range_stride[i] eq 1 then begin
                    
                    read_chunk_size = read_chunk_size * read_data_dims[i]
                    
                endif 
                
                ; we have reached the end of the contiguous part       
                chk_contiguous = 0
                
            endelse
        
        endif else begin
            
            ; we are in the non-contiguous part of the range
            
            tmp_n_reads = tmp_n_reads * read_data_dims[i]
            
            ; if this is the first dimension in the non-contiguous part, 
            ; record this
            
            if first_non_contiguous_dim eq -1 then begin
                
                first_non_contiguous_dim = i
                
            endif
            
        endelse

    endfor
    

    dimension_span_size = product(arr_dims, /integer, /cumulative)
    dimension_span_multiplier = shift(dimension_span_size,1)
    dimension_span_multiplier[0] = 1
   
    first_read_index = range_start
    
    first_read_pos = total(first_read_index * dimension_span_multiplier, $
                           /integer)
    
    
    ; calculate the sequence of steps needed to traverse the array
    
    output_num_steps = []        
    output_step_size = []
    tmp_read_pos_list = []
    
    if tmp_n_reads ne 1 then begin
       
        last_total_jump_size = 0

        for i = first_non_contiguous_dim, n_subscripts-1 do begin
    
            tmp_start = range_start[i]
            tmp_end = range_end[i]
        
            if read_data_dims[i] gt 1 then begin
                
                if N_elements(output_num_steps) eq 0 then begin
                
                    ; the first step
                
                    output_num_steps = [(tmp_end - tmp_start)]
                    output_step_size = [dimension_span_multiplier[i]]
                
                    last_total_jump_size = total( output_num_steps * $
                                                  output_step_size, $
                                                  /integer)
                     
                endif else begin
                    
                    ; a higher order step sequence
                    
                    tmp_next_num_steps = (tmp_end - tmp_start) 
                    
                    tmp_next_step_size = dimension_span_multiplier[i] $
                                         - last_total_jump_size
                    
                    tmparr1 = [1, output_num_steps]
                    tmparr2 = [tmp_next_step_size, output_step_size]
                    
                    tmparr3 = []
                    tmparr4 = []
                    
                    for j = 0, tmp_next_num_steps-1 do begin
                        
                        tmparr3 = [tmparr3,tmparr1]
                        tmparr4 = [tmparr4,tmparr2]
                        
                    endfor
                    
                    output_num_steps = [output_num_steps, tmparr3]
                    output_step_size = [output_step_size, tmparr4]
                    
                    last_total_jump_size = total( output_num_steps * $
                                                  output_step_size, $
                                                  /integer)
                    
                endelse
    
            endif
        endfor
        
        if Arg_present(read_pos_list) then begin
        
            tmp_steplist = ulon64arr(total(output_num_steps,/integer)+1)
            tmp_steplist[0] = first_read_pos
            cnta = 1ULL
            
            foreach tmp_stepsize, output_step_size, indexa do begin
                
                tmpnum = output_num_steps[indexa]
                tmparr = replicate(tmp_stepsize, tmpnum)
                tmp_steplist[cnta] = temporary(tmparr)
                cnta = cnta + tmpnum
                
            endforeach

            tmp_read_pos_list = total(temporary(tmp_steplist), $
                                      /cumulative, $
                                      /integer)

        endif
        
    endif else begin
        
        ; tmp_n_reads equals one
        
        tmp_read_pos_list = [first_read_pos]
        
    endelse


    output_scalar = tmp_output_scalar
    output_dims = tmp_output_dims
    read_size = read_chunk_size
    read_start = first_read_pos
    n_reads = tmp_n_reads

    n_steps_index = output_num_steps
    step_size_index = output_step_size
    
    if Arg_present(read_pos_list) then begin
        
        read_pos_list = temporary(tmp_read_pos_list)
        
    endif

end