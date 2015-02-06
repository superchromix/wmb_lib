;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_Vector object class
;
;   This file defines the wmb_Vector object class.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Helper methods for testing valid indices and ranges
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_Vector::Rangevalid, range, positive_range=positive_range

    compile_opt idl2, strictarrsubs
        
    chkdim = self.vec_size
    
    rangestart = range[0]
    if rangestart lt 0 then rangestart = rangestart + chkdim
    rangeend = range[1]
    if rangeend lt 0 then rangeend = rangeend + chkdim
    rangestride = range[2]

    minrange = 0L
    maxrange = chkdim - 1L
    
    maxstride = abs(rangeend-rangestart) > 1
    minstride = -maxstride

    if (rangestart lt minrange) or (rangestart gt maxrange) then return, 0
    if (rangeend lt minrange) or (rangeend gt maxrange) then return, 0
    
    if (rangestride eq 0) then return, 0
    if (rangestride lt minstride) or (rangestride gt maxstride) then return, 0
    
    if (rangestart lt rangeend) and (rangestride lt 0) then return, 0
    if (rangestart gt rangeend) and (rangestride gt 0) then return, 0

    positive_range = [rangestart,rangeend,rangestride]

    return, 1

end


function wmb_Vector::Indexvalid, index, positive_index = positive_index

    compile_opt idl2, strictarrsubs

    chkdim = self.vec_size
    
    test_index = index
    if test_index lt 0 then test_index = test_index + chkdim
    
    minrange = 0L
    maxrange = chkdim - 1L
    
    if (test_index lt minrange) or (test_index gt maxrange) then return, 0
    
    positive_index = test_index
    
    return, 1
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_Vector object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_Vector::_overloadBracketsRightSide, isRange, sub1, $
                           sub2, sub3, sub4, sub5, sub6, sub7, sub8

    compile_opt idl2, strictarrsubs


    ; determine the number of indices/ranges specified
    n_inputs = N_elements(isrange)

    if n_inputs ne 1 then begin
        message, 'Error: invalid array subscript'
        return, 0
    endif

    if N_elements(sub1) eq 0 then begin
        message, 'Error: no array subscript specified'
        return, 0
    endif

    chk_range = isRange[0]
    
    
    ; test validity of indices and ranges
    chkpass = 1

    if chk_range eq 1 then begin
        if ~ self->Rangevalid(sub1, positive_range=psub1) then chkpass = 0
    endif else begin
        if ~ self->Indexvalid(sub1, positive_index=psub1) then chkpass = 0
    endelse

    if chkpass eq 0 then begin
        message, 'Error: array subscript out of range'
        return, 0
    endif
    
    
    if chk_range eq 1 then begin
        
        startrecord = psub1[0]
        endrecord = psub1[1]
        stride = psub1[2]
        
    endif else begin
        
        startrecord = psub1[0]
        endrecord = psub1[0]
        stride = 1
        
    endelse
    
    
    ; get the data from memory
    
    if chk_range eq 1 then begin
    
        databuffer = (*self.vec_data)[startrecord:endrecord:stride]
    
    endif else begin
        
        databuffer = (*self.vec_data)[startrecord]
        
    endelse
        
    
    return, databuffer
        
        
end




;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Append method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_Vector::Append, input

    compile_opt idl2, strictarrsubs

    datatype = self.vec_type
    current_size = self.vec_size
    current_capacity = self.vec_capacity
    
    if size(input,/type) ne datatype then message, 'Invalid input data type'
    
    ; are we appending an array or a single element?
    
    input_length = n_elements(input)
    
    
    ; check if the data will fit within the existing capacity, and expand
    ; the vector if necessary
    
    space_avail = current_capacity - current_size
    
    if input_length gt space_avail then begin
        
        ; determine the new array size

        required_increase = input_length-space_avail

        if self.vec_exp_growth_flag eq 0 then begin
            
            ; linear array growth
            
            growth_step = self.vec_init_capacity
            
            current_delta = 0ULL
            
            while current_delta lt required_increase do begin
                
                current_delta = current_delta + growth_step
                
            endwhile

        endif else begin

            ; exponential array growth
            
            current_delta = 0ULL
            
            tmpa = 0
            while current_delta lt required_increase do begin
                
                new_size = self.vec_capacity * (2^tmpa)
                current_delta = new_size - self.vec_capacity 
                tmpa = tmpa + 1
                
            endwhile

        endelse

        new_array_size = current_size + current_delta


        ; create the new array

        if datatype eq 8 then begin
            
            new_array = replicate(*self.vec_struct_def, new_array_size)
            
        endif else begin
            
            new_array = make_array(new_array_size, TYPE=datatype, /NOZERO)
            
        endelse
        
        
        ; transfer the existing data
        
        tmp_data = temporary(*self.vec_data)
        ptr_free, self.vec_data
        new_array[0] = temporary(tmp_data)
        
        
        ; update the vector parameters
        
        self.vec_capacity = new_array_size
        self.vec_data = ptr_new(new_array, /NO_COPY)
        
    endif


    ; append the input data to the vector
    
    tmp_data = temporary(*self.vec_data)
    ptr_free, self.vec_data
    tmp_data[self.vec_size] = input
    self.vec_data = ptr_new(tmp_data, /NO_COPY)
    
    self.vec_size = self.vec_size + input_length

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_Vector::SetProperty, _Extra=extra

    compile_opt idl2, strictarrsubs


    ; pass extra keywords

    self->IDL_Object::SetProperty, _Extra=extra

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_Vector::GetProperty,  size=size, $
                              datatype=datatype, $
                              capacity=capacity, $                             
                              _Ref_Extra=extra

    compile_opt idl2, strictarrsubs


    if Arg_present(size) ne 0 then size=self.vec_size
    if Arg_present(datatype) ne 0 then datatype=self.vec_type
    if Arg_present(capacity) ne 0 then capacity=self.vec_capacity
    
    
    ; pass extra keywords

    self->IDL_Object::GetProperty, _Extra=extra
    
end





;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Init method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_Vector::Init, datatype = datatype, $
                           initial_capacity = initial_capacity, $           
                           double_capacity_if_full = double_capacity_if_full, $
                           structure_type_def = structure_type_def
                             

    compile_opt idl2, strictarrsubs


    ; check keyword parameters
    
    if N_elements(datatype) ne 1 then begin
        
        message, 'Invalid data type'
        
    endif

    if datatype lt 0 or datatype gt 15 then message, 'Invalid data type'

    
    if N_elements(initial_capacity) eq 0 then begin
        
        ; this sets the default initial capacity
        
        initial_capacity = 1000
        
    endif

    if N_elements(initial_capacity) ne 1 then $
        message, 'Invalid initial capacity'
    
    if N_elements(double_capacity_if_full) eq 0 then double_capacity_if_full=0

    if N_elements(structure_type_def) eq 0 then begin
        
        structure_type_def = {}

    endif else begin
        
        ; verify the datatype
        
        if size(structure_type_def,/type) ne 8 then $
            message, 'Invalid structure type definition'

    endelse


    ; create the initial storage array
    
    if datatype eq 8 then begin
        
        if structure_type_def eq {} then $
            message, 'Invalid structure type definition'
        
        tmp_data = replicate(structure_type_def, initial_capacity)
        
    endif else begin
        
        tmp_data = make_array(initial_capacity, TYPE=datatype, /NOZERO)
        
    endelse


    self.vec_size = 0
    self.vec_capacity = initial_capacity
    self.vec_data = ptr_new(tmp_data)
    self.vec_type = datatype
    self.vec_struct_def = ptr_new(structure_type_def)
    self.vec_init_capacity = initial_capacity
    self.vec_exp_growth_flag = double_capacity_if_full


    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_Vector::Cleanup

    compile_opt idl2, strictarrsubs

    ptr_free, self.vec_data
    ptr_free, self.vec_struct_def

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_Vector__define.pro
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
;   vec_struct_def:  If the vector datatype is structures, this
;                    variable stores a pointer to the structure
;                    definition.
;                     
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_Vector__define

    compile_opt idl2, strictarrsubs
    

    struct = {  wmb_Vector,                           $
                INHERITS IDL_Object,                  $
                                                      $
                vec_size              : ulong64(0),   $
                vec_capacity          : ulong64(0),   $
                                                      $
                vec_data              : ptr_new(),    $               
                                                      $
                vec_type              : 0,            $
                vec_struct_def        : ptr_new(),    $
                vec_init_capacity     : ulong64(0),   $
                vec_exp_growth_flag   : 0             }


end


pro wmb_vector_test


    ; test data
    
    nelts = 1000
    
    mystruct = {first:0L, second:0L, third:0.0D}

    mydata = replicate(mystruct, nelts)

    ; create a new vector
    
    myvector = obj_new('wmb_vector', datatype=8, $
                                     structure_type_def = mystruct, $
                                     initial_capacity = 10000, $
                                     double_capacity_if_full = 1)

    mylist = list()

    ; write

    ;tic, /PROFILER
    
    for i = 0, 1000 do begin
        
        myvector.Append, mydata
        
    endfor

    ;toc
    
    ;tic, /PROFILER
    
    for i = 0, 1000 do begin
        
        mylist.Add, mydata, /EXTRACT
        
    endfor
    
    ;toc

    ; read
    
    ;tic, /PROFILER
    
    for i = 0, 100 do begin
        
        mydata = myvector[10000:50000]
        
    endfor

    ;toc
    
    ;tic, /PROFILER
    
    for i = 0, 100 do begin
        
        tmplist = mylist[10000:50000]
        mydata = tmplist.ToArray()
        
    endfor
    
    ;toc

end
