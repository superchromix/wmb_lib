;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_Vector object class
;
;   This file defines the wmb_Vector object class.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_Vector object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_Vector::_overloadBracketsLeftSide, objref,  $
                                           value,   $
                                           isRange, $
                                           sub1,    $
                                           sub2,    $
                                           sub3,    $
                                           sub4,    $
                                           sub5,    $
                                           sub6,    $
                                           sub7,    $
                                           sub8

    compile_opt idl2, strictarrsubs


    ; determine the number of indices/ranges specified
    n_inputs = N_elements(isrange)

    if n_inputs ne 1 then begin
        message, 'Error: invalid array subscript'
    endif

    if N_elements(sub1) eq 0 then begin
        message, 'Error: no array subscript specified'
    endif

    chk_range = isRange[0]
    
    if chk_range eq 0 and N_elements(sub1) gt 1 then index_is_array = 1 $
                                                else index_is_array = 0
    
    ; test validity of indices and ranges
    chkpass = 1
    chkdim = self.vec_size

    if chk_range eq 1 then begin
        if ~ wmb_Rangevalid(sub1, chkdim, positive_range=psub1) then chkpass=0
    endif else begin
        if ~ wmb_Indexvalid(sub1, chkdim, positive_index=psub1) then chkpass=0
    endelse

    if chkpass eq 0 then begin
        message, 'Error: array subscript out of range'
    endif
    
    if chk_range eq 1 then begin
        
        startrecord = psub1[0]
        endrecord = psub1[1]
        stride = psub1[2]
        
    endif else begin
        
        if index_is_array eq 0 then index = psub1[0] $
                               else index = psub1
        
    endelse
    
    ; check that value is a scalar or 1D array
    value_n_dims = size(value, /N_DIMENSIONS)
    if value_n_dims gt 1 then message, 'Invalid variable dimension'
    
    ; get the size of the input data
    value_n_elts = N_elements(value)
    
    ; test if the number of elements in value matches the subscript
    
    input_scalar = value_n_elts eq 1
    
    if chk_range eq 1 then begin
        
        ; the subscript is a range - check that the number of elements 
        ; in value matches the size of the range
        
        range_size = ceil( (abs(startrecord-endrecord)+1) $
                           / float(abs(stride)), /L64)
    
        input_matches_range = range_size eq value_n_elts

    endif
    
    
    ; write the data to memory

    if chk_range eq 1 then begin
        
        if stride eq 1 then begin
        
            if input_matches_range then begin
        
                (*self.vec_data)[startrecord] = value
                
            endif else if input_scalar then begin
                
                (*self.vec_data)[startrecord:endrecord] = value
                
            endif else message, 'Array subscript does not match ' + $
                                'size of input data'
        
        endif else begin
            
            (*self.vec_data)[startrecord:endrecord:stride] = value
            
        endelse
        
    endif else begin
        
        (*self.vec_data)[index] = value
        
    endelse
 
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
    
    if chk_range eq 0 and N_elements(sub1) gt 1 then index_is_array = 1 $
                                                else index_is_array = 0
    
    ; test validity of indices and ranges
    chkpass = 1
    chkdim = self.vec_size

    if chk_range eq 1 then begin
        if ~ wmb_Rangevalid(sub1, chkdim, positive_range=psub1) then chkpass=0
    endif else begin
        if ~ wmb_Indexvalid(sub1, chkdim, positive_index=psub1) then chkpass=0
    endelse

    if chkpass eq 0 then begin
        message, 'Error: array subscript out of range'
        return, 0
    endif
    
    
    ; get the data from memory

    if chk_range eq 1 then begin
        
        startrecord = psub1[0]
        endrecord = psub1[1]
        stride = psub1[2]
        
        databuffer = (*self.vec_data)[startrecord:endrecord:stride]
        
    endif else begin
        
        if index_is_array eq 0 then begin
            
            index = psub1[0]
            
        endif else begin
            
            index = psub1

        endelse
        
        databuffer = (*self.vec_data)[index]
        
    endelse
    

    return, databuffer
 
end




;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Append method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_Vector::Append, indata, no_copy=no_copy

    compile_opt idl2, strictarrsubs

    if N_elements(no_copy) eq 0 then no_copy = 0

    ; handle the NO_COPY keyword

    if no_copy eq 0 then nocopy_input = indata $
                    else nocopy_input = temporary(indata)


    datatype = self.vec_type
    current_data_length = self.vec_size
    current_capacity = self.vec_capacity
    
    
    if size(nocopy_input,/type) ne datatype then $
        message, 'Invalid input data type'
    
    
    ; are we appending an array or a single element?
    
    input_length = n_elements(nocopy_input)
    
    
    ; check if the data will fit within the existing capacity, and expand
    ; the vector if necessary
    
    space_avail = current_capacity - current_data_length
    
    if input_length gt space_avail then begin
        
        ; determine the new array size

        required_increase = input_length - space_avail

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

        new_array_size = current_capacity + current_delta


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
    tmp_data[self.vec_size] = temporary(nocopy_input)
    
    self.vec_data = ptr_new(tmp_data, /NO_COPY)
    self.vec_size = self.vec_size + input_length

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Consolidate method
;
;   Adjusts the size of the array to fit the data exactly.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_Vector::Consolidate

    compile_opt idl2, strictarrsubs

    datatype = self.vec_type
    current_data_length = self.vec_size
    current_capacity = self.vec_capacity
    
    
    if current_data_length ne current_capacity then begin
        
        
        new_array_size = current_data_length


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

end

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_Vector::SetProperty, _Extra=extra

    compile_opt idl2, strictarrsubs


    ; pass extra keywords


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
        
        initial_capacity = 10000
        
    endif

    if N_elements(initial_capacity) ne 1 then $
        message, 'Invalid initial capacity'
    
    if N_elements(double_capacity_if_full) eq 0 then double_capacity_if_full=0

    if N_elements(structure_type_def) eq 0 then begin
        
        if datatype eq 8 then message, 'Missing structure type definition'
        
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
    
    nelts = 10
    
    mystruct = {first:0L, second:0L, third:0.0D}

    mydata = replicate(mystruct, nelts)

    mydata.first = indgen(nelts)
    mydata.second = indgen(nelts)
    mydata.third = indgen(nelts)
    
    ; create a new vector
    
    myvector = obj_new('wmb_vector', datatype=8, $
                                     structure_type_def = mystruct, $
                                     initial_capacity = 3, $
                                     double_capacity_if_full = 1)


    ; write
    
    for i = 0, 10 do begin
        
        myvector.Append, mydata
        
    endfor

    print, myvector.capacity
    
    print, myvector[*]

    print, N_elements(myvector[*])
    
end
