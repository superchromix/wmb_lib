;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_VirtualArray object class
;
;   This file defines the wmb_VirtualArray object class.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Helper method for testing valid indices and ranges
;   
;   positive_range is an output keyword which returns the 
;   range with positive indices
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_VirtualArray::Rangevalid, range, $
                                       dimension_index, $
                                       positive_range=positive_range

    compile_opt idl2, strictarrsubs

    arr_rank = self.va_rank
    arr_dims = *self.va_dimsptr
    
    if (dimension_index lt 0) or (dimension_index ge arr_rank) then return, 0
    
    chkdim = arr_dims[dimension_index]
    
    rangestart = range[0]
    if rangestart lt 0 then rangestart = rangestart + chkdim
    rangeend = range[1]
    if rangeend lt 0 then rangeend = rangeend + chkdim
    rangestride = range[2]

    minrange = 0L
    maxrange = chkdim - 1L
    
    maxstride = abs(rangeend-rangestart) > 1
    minstride = -maxstride

    chkpass = 1
    
    if (rangestart lt minrange) or (rangestart gt maxrange) then chkpass = 0
    if (rangeend lt minrange) or (rangeend gt maxrange) then chkpass = 0
    
    if (rangestride eq 0) then chkpass=0
    if (rangestride lt minstride) or (rangestride gt maxstride) then chkpass = 0

    if (rangestart lt rangeend) and (rangestride lt 0) then chkpass = 0
    if (rangestart gt rangeend) and (rangestride gt 0) then chkpass = 0 

    positive_range = [rangestart,rangeend,rangestride]

    return, chkpass

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Helper method for testing valid indices and ranges
;   
;   positive_index is an output keyword which returns the 
;   corresponding index with a positive value
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_VirtualArray::Indexvalid, index, $
                                       dimension_index, $
                                       positive_index = positive_index

    compile_opt idl2, strictarrsubs

    arr_rank = self.va_rank
    arr_dims = *self.va_dimsptr
    
    if (dimension_index lt 0) or (dimension_index ge arr_rank) then return, 0
    
    chkdim = arr_dims[dimension_index]
    
    test_index = index
    if test_index lt 0 then test_index = test_index + chkdim
    
    minrange = 0L
    maxrange = chkdim - 1L
    
    chkpass = 1
    
    if (test_index lt minrange) or (test_index gt maxrange) then chkpass = 0
    
    positive_index = test_index
    
    return, chkpass
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_VirtualArray object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_VirtualArray::_overloadBracketsRightSide, isRange, sub1, $
                           sub2, sub3, sub4, sub5, sub6, sub7, sub8

    compile_opt idl2, strictarrsubs


    arr_rank = self.va_rank
    arr_dims = *self.va_dimsptr


    if N_elements(sub1) eq 0 then begin
        message, 'No array subscript specified'
        return, 0
    endif
    
    if N_elements(sub2) eq 0 then sub2=[0,0,1]
    if N_elements(sub3) eq 0 then sub3=[0,0,1]
    if N_elements(sub4) eq 0 then sub4=[0,0,1]
    if N_elements(sub5) eq 0 then sub5=[0,0,1]
    if N_elements(sub6) eq 0 then sub6=[0,0,1]
    if N_elements(sub7) eq 0 then sub7=[0,0,1]
    if N_elements(sub8) eq 0 then sub8=[0,0,1]


    ; check that the correct number of subscripts have been provided
    
    n_inputs = N_elements(isrange)

    if n_inputs ne arr_rank then begin
        message, 'Invalid number of array subscripts'
        return, 0
    endif
    

    ; make a list of the input indices/ranges
    
    subscript_list = list(sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8) 


    ; test validity of indices and ranges
    
    chkpass = 1

    for i = 0, n_inputs-1 do begin
        
        tmp_input = subscript_list[i]
        
        if isrange[i] eq 1 then begin
            if ~ self->Rangevalid( tmp_input, i ) then chkpass = 0
        endif else begin
            if ~ self->Indexvalid( tmp_input, i ) then chkpass = 0
        endelse
    endfor
    
    if chkpass eq 0 then begin
        message, 'Array subscript out of range'
        return, 0
    endif
    
    
    ; calculate the number of file reads required, and the list of 
    ; read positions

    wmb_varray_generate_read_sequence, isrange, $
                                       subscript_list, $
                                       arr_dims, $
                                       output_scalar, $
                                       output_dims, $
                                       n_reads, $                                       
                                       read_size, $
                                       read_start, $                                    
                                       readstart_pos_array

    

    ; make an output array of the appropriate size
    
    dtype = self.va_dtype
    od = make_array(output_dims, type=dtype, /nozero)
        
    ; calculate the read end positions
    
    readend_pos_array = readstart_pos_array + (read_size-1)
    
    
    ; for each element of the read position list, calculate in which
    ; data chunk it is contained
    
    tmp_data_chunk_size = self.va_data_chunk_size
    
    readstart_chunk_arr = readstart_pos_array / tmp_data_chunk_size
    readend_chunk_arr = readend_pos_array / tmp_data_chunk_size
    
    readstart_relative_pos = readstart_pos_array mod tmp_data_chunk_size
    readend_relative_pos = readend_pos_array mod tmp_data_chunk_size
    
    span_chunks = readstart_chunk_arr ne readend_chunk_arr


    ; read the data and transfer it to the output array
    
    tmp_write_pos = 0ULL
    loaded_chunk = -1
    
    
    foreach tmp_readstart, readstart_pos_array, indexa do begin
    
        if span_chunks[indexa] eq 0 then begin
        
            ; this read operation does not span a chunk boundary
        
            tmp_read_chunk = readstart_chunk_arr[indexa]
        
            if tmp_read_chunk ne loaded_chunk then begin
                
                tmp_data_block = (*self.va_assoc_ptr)[tmp_read_chunk]

                loaded_chunk = tmp_read_chunk
                
            endif 
        
            readstart = readstart_relative_pos[indexa]
            readend = readend_relative_pos[indexa]
        
            od[tmp_write_pos] = tmp_data_block[readstart:readend]
        
            tmp_write_pos = tmp_write_pos + read_size
            
        endif else begin
            
            ; the read operation spans a chunk boundary
            
            startchunk = readstart_chunk_arr[indexa]
            endchunk = readend_chunk_arr[indexa]
            
            nchunks_span = endchunk - startchunk + 1
            
            for i = 0, nchunks_span-1 do begin
                
                tmp_read_chunk = startchunk + i
                
                if tmp_read_chunk ne loaded_chunk then begin
                    
                    tmp_data_block = (*self.va_assoc_ptr)[tmp_read_chunk]

                    loaded_chunk = tmp_read_chunk
                    
                endif 
                
                if i eq 0 then readstart = readstart_relative_pos[indexa] $
                          else readstart = 0LL
                          
                if i eq (nchunks_span-1) then begin
                    
                    readend = readend_relative_pos[indexa]
                    
                endif else begin
                    
                    ; last element in the chunk
                    readend = tmp_data_chunk_size - 1  
                    
                endelse
                
                od[tmp_write_pos] = tmp_data_block[readstart:readend]
        
                tmp_write_pos = tmp_write_pos + ((readend - readstart) + 1)
                
            endfor
        endelse
        
    endforeach
    

    ; ensure that the output array has the correct dimensions

    if output_scalar then begin
    
        od = od[0]
        
    endif else begin
        
        od = reform(od, output_dims, /overwrite)
        
    endelse

    return, od

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_VirtualArray::SetProperty, _Extra=extra

    compile_opt idl2, strictarrsubs


    ; pass extra keywords

    self->IDL_Object::SetProperty, _Extra=extra

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_VirtualArray::GetProperty,  filename=filename, $
                                    datadims=datadims, $
                                    datatype=datatype, $                             
                                    filewritable=filewritable
                                    _Ref_Extra=extra

    compile_opt idl2, strictarrsubs


    if Arg_present(filename) ne 0 then filename=self.va_filename
    if Arg_present(datadims) ne 0 then datadims=(*self.va_dimsptr)    
    if Arg_present(datatype) ne 0 then datatype=self.va_dtype 
    if Arg_present(filewritable) ne 0 then filewritable=self.va_writeable
    
    
    ; pass extra keywords

    self->IDL_Object::GetProperty, _Extra=extra
    
end





;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Init method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_VirtualArray::Init, filename, $
                                 datadims, $
                                 datatype, $                  
                                 chunksize_bytes=chunksize_bytes, $           
                                 fileoffset_bytes=fileoffset_bytes, $
                                 fileswapendian=fileswapendian
                             

    compile_opt idl2, strictarrsubs


    ; check positional parameters

    if N_elements(filename) eq 0 then begin
        message, 'A valid filename must be specified'
        return, 0
    endif

    if N_elements(datadims) eq 0 then begin
        message, 'Invalid data dimensions'
        return, 0
    endif
    
    if N_elements(datatype) eq 0 then begin
        message, 'Invalid data type'
        return, 0
    endif
    

    ; check keyword parameters
    
    if N_elements(chunksize_bytes) eq 0 then begin
        
        ; this sets the default file read chunk size (bytes)
        
        chunksize_bytes = 524288L     ; 512KB
        
    endif
    
    tmp_chunksize_bytes = ulong64(chunksize_bytes)

    if N_elements(fileoffset_bytes) eq 0 then fileoffset_bytes = 0
    if N_elements(fileswapendian) eq 0 then fileswapendian = 0


    ; convert the data dims to ulong64
    
    tmp_datadims = ulong64(datadims)

    ; check that the datatype is compatible

    if (datatype eq 0) or (datatype eq 7) or (datatype eq 8) or $
       (datatype eq 10) or (datatype eq 11) then begin
       
        message, 'Unsupported data type.'
        return, 0
       
    endif

    ; check the file

    tmp_fileinfo = file_info(filename)

    chk_read = tmp_fileinfo.read
    chk_write = tmp_fileinfo.write
    chk_regular = tmp_fileinfo.regular
    tmp_size = tmp_fileinfo.size

    if chk_read eq 0 or chk_regular eq 0 then begin
        message, 'Invalid input file.'
        return, 0
    endif

    ; check the file size

    tmp_dimproduct = product(tmp_datadims, /integer)
    tmp_dtype_size = wmb_sizeoftype(datatype)
    expected_filesize = (tmp_dimproduct * tmp_dtype_size) + fileoffset_bytes
    
    if tmp_size lt expected_filesize then begin
        message, 'File size smaller than expected'
        return, 0
    endif

    ; check the data rank and data dimensions
    
    data_rank = N_elements(tmp_datadims)
    
    if (data_rank lt 1) or (data_rank gt 8) or $
       (tmp_dimproduct eq 0) then begin
    
        message, 'Invalid file datatype or dimensions.'
        return, 0
    endif

    ; determine the actual chunk size - we will set the read chunk size
    ; equal to a value which is a factor of the file size and close to 
    ; the requested chunk size
    
    data_size_prime_factors = []
    
    for i = 0, data_rank-1 do begin
        
        ; make a list of the prime factors of the data size
        
        tmpdim = tmp_datadims[i]
        tmpfactors = ulong64(wmb_factors(tmpdim))
        
        data_size_prime_factors = [data_size_prime_factors, tmpfactors]
        
    endfor
    
    sorted_factors_index = sort(data_size_prime_factors)
    sorted_factors = data_size_prime_factors[sorted_factors_index]
    
    ; calculate the cumulative product of the factors to see what the 
    ; options are for the chunk size
    
    factors_product = product(sorted_factors, /integer, /cumulative)

    ; calculate the chunk size in units of the data type
    
    data_chunk_size = (tmp_chunksize_bytes / tmp_dtype_size) > 1ULL
    
    ; is the requested chunksize already a factor?
    
    if product(tmp_datadims) mod data_chunk_size eq 0 then begin
        
        ; the requested chunk size works
        adjusted_data_chunk_size = data_chunk_size
        
    endif else begin
        
        ; find the factor with the closest value
        
        diff = abs(long64(factors_product)-long64(data_chunk_size))
        index = where(diff eq min(diff))
        
        adjusted_data_chunk_size = factors_product[index]
        
    endelse
    
    
    ; open the file

    get_lun, tmplun

    if chk_write eq 0 then begin
    
        openr, tmplun, filename, swap_endian=fileswapendian, $
               error=errstatus
    
    endif else begin
    
        openu, tmplun, filename, swap_endian=fileswapendian, $
               error=errstatus            
    
    endelse

    if (errstatus ne 0) then begin
        close, tmplun
        free_lun, tmplun
        message, 'Error at file open'
        return, 0
    endif
    
    
    ; create an assoc variable linked to the file, with the appropriate
    ; offset and chunk size
    
    tmparr = make_array(adjusted_data_chunk_size, TYPE=datatype, /NOZERO)
    filedata_assoc = assoc(tmplun, tmparr, fileoffset_bytes)

    filedata_assoc_ptr = ptr_new(filedata_assoc)


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   populate the self fields
;


    self.va_rank = data_rank
    self.va_dimsptr = ptr_new(tmp_datadims)
    self.va_dtype = datatype
    
    self.va_dtype_size = tmp_dtype_size
    
    self.va_filename = filename
    self.va_lun = tmplun
    self.va_offset = fileoffset_bytes
    self.va_writeable = chk_write
    self.va_data_chunk_size = adjusted_data_chunk_size
    self.va_assoc_ptr = filedata_assoc_ptr


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   we don't need to explicitly initialize IDL_Object
;

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   finished initializing wmb_VirtualArray object
;

    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;   Note that the file logical unit handling is built into
;   the object itself.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_VirtualArray::Cleanup

    compile_opt idl2, strictarrsubs

    ptr_free, self.va_dimsptr
    
    ptr_free, self.va_assoc_ptr

    close, self.va_lun

    free_lun, self.va_lun

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   we don't need to explicitly clean up IDL_Object
;

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_VirtualArray__define.pro
;
;   This is the object class definition
;
;   data type codes returned by size():
;
;   0  Undefined
;   1  Byte (8 bit)
;   2  Integer (16 bit)
;   3  Longword integer (32 bit)
;   4  Floating point (32 bit)
;   5  Double-precision floating (64 bit)
;   6  Complex floating (64 bit)
;   7  String
;   8  Structure
;   9  Double-precision complex (128 bit)
;   10 Pointer
;   11 Object reference
;   12 Unsigned Integer (16 bit)
;   13 Unsigned Longword Integer (32 bit)
;   14 64-bit Integer (64 bit)
;   15 Unsigned 64-bit Integer (64 bit)
;   
;   Variable notes:
;                   
;   va_offset: The number of bytes to skip at the start
;              of the file.
;                     
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_VirtualArray__define

    compile_opt idl2, strictarrsubs
    

    struct = {  wmb_VirtualArray,                     $
                INHERITS IDL_Object,                  $
                                                      $
                va_rank               : fix(0),       $
                va_dimsptr            : ptr_new(),    $
                va_dtype              : fix(0),       $
                                                      $
                va_dtype_size         : fix(0),       $               
                                                      $
                va_filename           : '',           $
                va_lun                : fix(0),       $               
                va_offset             : ulong64(0),   $            
                va_writeable          : fix(0),       $
                va_data_chunk_size    : ulong64(0),   $
                va_assoc_ptr          : ptr_new()     }

end

