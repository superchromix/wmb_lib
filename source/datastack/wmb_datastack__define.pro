;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_DataStack object class
;
;   This file defines the wmb_DataStack object class.
;
;   The wmb_DataStack class will store the data associated with
;   an arbitrary dataset.  The data may be stored entirely in 
;   memory, or it may be accessed dynamically from disk as needed.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_DataStack object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataStack::_overloadBracketsRightSide, isRange, sub1, $
                        sub2, sub3, sub4, sub5, sub6, sub7, sub8

    compile_opt idl2, strictarrsubs


    tmp_rank = self.ds_rank
    tmp_dims = *self.ds_dimsptr

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


    ; determine the number of indices/ranges specified
    n_inputs = N_elements(isrange)

    if n_inputs eq 0 then begin
        message, 'No array subscript specified'
        return, 0
    endif


    ; make a list of the input indices/ranges
    inputlist = list(sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8) 

   
    ; test validity of indices and ranges
    chkpass = 1
    for i = 0, n_inputs-1 do begin
        
        tmpinput = inputlist[i]
        chkdim = tmp_dims[i]
                    
        if isrange[i] eq 1 then begin
            if ~ wmb_Rangevalid(tmpinput, chkdim) then chkpass = 0
        endif else begin
            if ~ wmb_Indexvalid(tmpinput, chkdim) then chkpass = 0
        endelse
    endfor
    

    
    if chkpass eq 0 then begin
        message, 'Array subscript out of range'
        return, 0
    endif
    
    
    ; check that the correct number of subscripts have been provided
    if n_inputs ne self.ds_rank then begin
        message, 'Invalid number of array subscripts'
        return, 0
    endif
    
    
    ; convert all inputs to ranges
    tmpa = lonarr(3)
    for i = 0, n_inputs-1 do begin
        if ~ isrange[i] then begin
            tmpinput = inputlist[i]
            tmpa[0] = tmpinput
            tmpa[1] = tmpinput
            tmpa[2] = 1
            inputlist[i] = tmpa
        endif
    endfor
    
    
    ; set up explicit variables for all of the ranges
    a1 = (inputlist[0])[0]
    a2 = (inputlist[0])[1]
    a3 = (inputlist[0])[2]
    b1 = (inputlist[1])[0]
    b2 = (inputlist[1])[1]
    b3 = (inputlist[1])[2]
    c1 = (inputlist[2])[0]
    c2 = (inputlist[2])[1]
    c3 = (inputlist[2])[2]
    d1 = (inputlist[3])[0]
    d2 = (inputlist[3])[1]
    d3 = (inputlist[3])[2]
    e1 = (inputlist[4])[0]
    e2 = (inputlist[4])[1]
    e3 = (inputlist[4])[2]
    f1 = (inputlist[5])[0]
    f2 = (inputlist[5])[1]
    f3 = (inputlist[5])[2]
    g1 = (inputlist[6])[0]
    g2 = (inputlist[6])[1]
    g3 = (inputlist[6])[2]
    h1 = (inputlist[7])[0]
    h2 = (inputlist[7])[1]
    h3 = (inputlist[7])[2]
    
    
    ; determine the dimensions of the output array
    alldims = lonarr(n_inputs)
    
    for i = 0, n_inputs-1 do begin
        tmpdimsize = (*self.ds_dimsptr)[i]
        rstart = (inputlist[i])[0]
        if rstart lt 0 then rstart = tmpdimsize+rstart
        rend = (inputlist[i])[1]
        if rend lt 0 then rend = tmpdimsize+rend
        rstride = (inputlist[i])[2]
        alldims[i] = abs((rend - rstart) / rstride) + 1
    endfor


    ; test if the result will be scalar, and determine the final dimensions
    ; of the output array
    scalarout = 0
    rangedimindex = where(isrange eq 1, chkcount)
    if chkcount gt 0 then begin
        rangedims = alldims[rangedimindex]
    endif else begin
        scalarout = 1    
        rangedims = []
    endelse
    
    
    ; test if the data is accessed via a virtual array
    if self.ds_flag_varray eq 0 then begin
  
        ; the data is stored in memory and no disk access needs to be
        ; considered.  index the data array and return the output data.
        
        case n_inputs of
            
            1: od = (*self.ds_dataptr)[a1:a2:a3]

            2: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3]

            3: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3, c1:c2:c3]

            4: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3]

            5: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                       e1:e2:e3]

            6: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                       e1:e2:e3, f1:f2:f3]

            7: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                       e1:e2:e3, f1:f2:f3, g1:g2:g3]

            8: od = (*self.ds_dataptr)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                       e1:e2:e3, f1:f2:f3, g1:g2:g3, h1:h2:h3]

        endcase

    endif else begin
    
        ; if the data is accessed via a virtual array
    
        case n_inputs of
            
            1: od = (self.ds_varray)[a1:a2:a3]

            2: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3]

            3: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3, c1:c2:c3]

            4: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3]

            5: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                     e1:e2:e3]

            6: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                     e1:e2:e3, f1:f2:f3]

            7: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                     e1:e2:e3, f1:f2:f3, g1:g2:g3]

            8: od = (self.ds_varray)[a1:a2:a3, b1:b2:b3, c1:c2:c3, d1:d2:d3, $
                                     e1:e2:e3, f1:f2:f3, g1:g2:g3, h1:h2:h3]

        endcase
    
    endelse
    
    ; remove dimensions of length one that did not correspond to a range
    ; input subscript, or return a scalar if no input subscripts correspond to
    ; ranges
    
    if scalarout then begin
    
        od = od[0]
        
    endif else begin
    
        od = reform(od, rangedims, /overwrite)
        
    endelse

    return, od

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Max_Value method
;   
;   Returns the maximum value in the data stack.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_DataStack::Max_Value

    if self.ds_flag_varray eq 0 then begin

        maxvalue = max(*(self.ds_dataptr))
        
    endif else begin
        
        varray_obj = self.ds_varray
        
        maxvalue = varray_obj.Max_Value()
        
    endelse
    
    return, maxvalue

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Min_Value method
;   
;   Returns the minimum value in the data stack.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_DataStack::Min_Value

    if self.ds_flag_varray eq 0 then begin
        
        minvalue = min(*(self.ds_dataptr))
        
    endif else begin
        
        varray_obj = self.ds_varray
        
        minvalue = varray_obj.Min_Value()
        
    endelse
    
    return, minvalue

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Change_Datatype method
;   
;   Returns 1 if successful.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_DataStack::Change_Datatype, newtype

    compile_opt idl2, strictarrsubs

    if self.ds_flag_varray eq 0 then begin
        
        rawdata = *(self.ds_dataptr)
        
        newdata = fix(temporary(rawdata), type=newtype)
        
        ptr_free, self.ds_dataptr
        
        self.ds_dataptr = ptr_new(newdata, /NO_COPY)
        
        self.ds_datatype = newtype
        
    endif else begin
        
        return, 0
        
    endelse
    
    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Rebin_Data method
;   
;   This is analogous to the REBIN function in IDL
;   
;   Returns 1 if successful
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_DataStack::Rebin_Data, newdims, sample=sample

    compile_opt idl2, strictarrsubs

    if N_elements(sample) eq 0 then sample = 0
    
    if self.ds_flag_varray eq 0 then begin
        
        rawdata = *(self.ds_dataptr)
        
        ; check that the new dimensions are valid
        curdims = *self.ds_dimsptr
        if N_elements(curdims) ne N_elements(newdims) then return, 0
        large_dims = newdims > curdims
        small_dims = newdims < curdims
        rslt_mod = large_dims mod small_dims
        if max(rslt_mod) gt 0 then return, 0
        
        ; rebin the data
        newdata = rebin(rawdata,newdims,sample=sample)
        
        ptr_free, self.ds_dataptr
        ptr_free, self.ds_dimsptr
        
        self.ds_dataptr = ptr_new(newdata, /NO_COPY)
        self.ds_dimsptr = ptr_new(long(newdims))
        
    endif else begin
        
        return, 0
        
    endelse
    
    return, 1

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;   Setting the data property allows the entire content of the
;   datastack to be changed.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_DataStack::SetProperty, Data = indata, $
                                No_Copy = no_copy

    compile_opt idl2, strictarrsubs

    if N_elements(no_copy) eq 0 then no_copy = 0

    if N_elements(data) ne 0 then begin

        ; we are erasing the existing datastack

        if self.ds_flag_varray eq 1 then obj_destroy, self.ds_varray
        if ptr_valid(self.ds_dataptr) then ptr_free, self.ds_dataptr
            
        tmp_rank = size(indata, /N_dimensions)
        tmp_dims = size(indata, /Dimensions)
        tmp_dtype = size(indata, /Type)
        
        if (tmp_dtype eq 0) or (tmp_dtype eq 7) or (tmp_dtype eq 8) or $
           (tmp_dtype eq 10) or (tmp_dtype eq 11) then begin
           
            message, 'Unsupported data type'
           
        endif  
        
        if no_copy eq 0 then begin
        
            tmpdata = indata
            
        endif else begin
        
            tmpdata = temporary(indata)
            
        endelse
            
        tmp_dataptr = ptr_new(tmpdata, /NO_COPY)


        ; update the object data 
        
        self.ds_rank = tmp_rank
        self.ds_dimsptr = ptr_new(long(tmp_dims))
        self.ds_datatype = tmp_dtype
        self.ds_dataptr = tmp_dataptr
        self.ds_flag_varray = 0
        self.ds_varray_filename = ''
        self.ds_varray = obj_new()
        
    endif


end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataStack::GetProperty,  Rank = rank, $
                                 Datadims = datadims, $
                                 DataType = datatype, $
                                 Varray_flag = varray_flag, $
                                 Varray_filename = varray_filename

    compile_opt idl2, strictarrsubs

    if Arg_present(rank) ne 0 then rank=self.ds_rank
    if Arg_present(datadims) ne 0 then datadims=long(*self.ds_dimsptr)    
    if Arg_present(datatype) ne 0 then datatype=self.ds_datatype 
    
    if Arg_present(varray_flag) ne 0 then varray_flag=self.ds_flag_varray
    
    if Arg_present(varray_filename) ne 0 then $
                   varray_filename=self.ds_varray_filename
    
    
end





;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Init method
;
;   The datadims keyword gives the option of reforming the data
;   to a given dimension.  This is useful for preserving
;   dimensions of length 1, for example.
;   
;   If the NO_COPY keyword is set to 1, the input data variable 
;   will be undefined after the object is created.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataStack::Init, Indata=indata, $
                              No_Copy=no_copy, $
                              Datadims=datadims, $                             
                              Filename=filename, $
                              Filedtype=filedtype, $     
                              Filechunksize=filechunksize, $                        
                              Fileoffset=fileoffset, $
                              Fileswapendian=fileswapendian
                             



    compile_opt idl2, strictarrsubs


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Check that the positional parameters are present.
;


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Check which keyword parameters are present. 
;

    if ( N_elements(indata) eq 0 and N_elements(filename) eq 0 ) or $
       ( N_elements(indata) ne 0 and N_elements(filename) ne 0 )then begin

        message, 'DataStack initialization error: either input data or ' + $
                 'a filename (one or the other) must be specified.'
                 
        return, 0
        
    endif

    
    if N_elements(no_copy) eq 0 then no_copy = 0
    if N_elements(filename) eq 0 then filename = ''
    if N_elements(filedtype) eq 0 then filedtype = 0
    if N_elements(fileoffset) eq 0 then fileoffset = 0
    if N_elements(fileswapendian) eq 0 then fileswapendian = 0
            
    
    if N_elements(indata) ne 0 then inittype = 'inputvar' $
                               else inittype = 'file'
               
        
    
    case inittype of
    
        'inputvar': begin
    
            ; the object has been initialized with a data variable - measure its
            ; dimensions and store a pointer to the data
            
            tmp_rank = size(indata, /N_dimensions)
            tmp_dims = size(indata, /Dimensions)
            tmp_dtype = size(indata, /Type)
            
            ; the datadims keyword gives the option of reforming the data
            ; to a given dimension
            
            if N_elements(datadims) ne 0 then begin
            
                tmp_dims_prod = product(tmp_dims,/integer)
                datadims_prod = product(datadims,/integer)
                if datadims_prod ne tmp_dims_prod then $
                        message, 'Invalid data dimensions'
                        
                indata = reform(indata,datadims,/overwrite)
                tmp_rank = size(indata, /N_dimensions)
                tmp_dims = size(indata, /Dimensions)
            
            endif
            
            
            if (tmp_dtype eq 0) or (tmp_dtype eq 7) or (tmp_dtype eq 8) or $
               (tmp_dtype eq 10) or (tmp_dtype eq 11) then begin
               
                message, 'Unsupported data type.'
                return, 0
               
            endif            
            
            
            if no_copy eq 0 then begin
            
                tmpdata = indata
                
            endif else begin
            
                tmpdata = temporary(indata)
                
            endelse
                
                
            tmp_dataptr = ptr_new(tmpdata, /NO_COPY)
            tmp_varray = obj_new()
            tmp_flag_varray = 0       
            
        end


        'file': begin
        
            ; the object has been initialized with a file name, dimensions, and 
            ; data type - create a virtual array object which will be used
            ; to access the data

            if N_elements(datadims) eq 0 then begin
                message, 'Data dimensions must be specified when ' + $
                         'initializing a virtual data stack'
                return, 0
            endif

            filedims = datadims

            tmp_rank = N_elements(filedims)
            tmp_dims = filedims
            tmp_dtype = filedtype
            
            tmp_dataptr = ptr_new()
            
            tmp_varray = obj_new('wmb_virtualarray', $
                                 filename, $
                                 filedims, $
                                 filedtype, $
                                 chunksize_bytes = filechunksize, $
                                 fileoffset_bytes = fileoffset, $
                                 fileswapendian = fileswapendian)
                                 
            tmp_flag_varray = 1 
            
        end
    
    endcase
    

    
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   populate the self fields
;

    self.ds_rank = tmp_rank
    self.ds_dimsptr = ptr_new(long(tmp_dims))
    self.ds_datatype = tmp_dtype
    
    self.ds_dataptr = tmp_dataptr
    
    self.ds_flag_varray = tmp_flag_varray
    self.ds_varray_filename = filename
    self.ds_varray = tmp_varray

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   finished initializing wmb_DataStack object
;

    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataStack::Cleanup

    compile_opt idl2, strictarrsubs

    ptr_free, self.ds_dimsptr
    ptr_free, self.ds_dataptr
    if self.ds_flag_varray then obj_destroy, self.ds_varray

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_DataStack__define.pro
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
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataStack__define

    compile_opt idl2, strictarrsubs
    

    struct = { wmb_DataStack,                            $
               INHERITS IDL_Object,                      $
                                                         $
               ds_rank            : fix(0),              $
               ds_dimsptr         : ptr_new(),           $
               ds_datatype        : fix(0),              $
                                                         $
               ds_dataptr         : ptr_new(),           $
                                                         $
               ds_flag_varray     : fix(0),              $
               ds_varray_filename : '',                  $
               ds_varray          : obj_new()            }

end

