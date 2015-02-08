;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_2D_list_array object class
;
;   This file defines the wmb_2D_list_array object class.
;
;   The wmb_2D_list_array object holds a two-dimensional array of
;   list objects - each containing data of the same type.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetNumEltsRange method
;
;   Returns the number of entries within a specified range of the array.
;   
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_2D_list_array::GetNumEltsRange, xa, xb, ya, yb

    compile_opt idl2, strictarrsubs


    xmin = min([xa,xb])
    xmax = max([xa,xb])
    ymin = min([ya,yb])
    ymax = max([ya,yb])

    if xmin lt 0 or xmax gt self.xdim-1 or $
       ymin lt 0 or ymax gt self.ydim-1 then begin

        message, 'Error: invalid array location'

    endif

    xsize = xmax-xmin+1
    ysize = ymax-ymin+1


    counta = long(0)


    for i = xmin, xmax do begin
        for j = ymin, ymax do begin

            listobj = (*self.list_arr_ptr)[i,j]
            tmp_nitems = listobj.Count()

            counta = counta + tmp_nitems

        endfor
    endfor


    return, counta

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetNumElts method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_2D_list_array::GetNumElts, x_ind, y_ind

    compile_opt idl2, strictarrsubs


    if x_ind lt 0 or x_ind gt self.xdim-1 or $
       y_ind lt 0 or y_ind gt self.ydim-1 then begin

        message, 'Error: invalid array location'

    endif

    listobj = (*self.list_arr_ptr)[x_ind,y_ind]

    return, listobj.Count()

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetEltsRange method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::GetEltsRange, xa, xb, ya, yb, n_items, outarray

    compile_opt idl2, strictarrsubs


    xdim = self.xdim
    ydim = self.ydim

    xmin = min([xa,xb])
    xmax = max([xa,xb])
    ymin = min([ya,yb])
    ymax = max([ya,yb])

    if xmin lt 0 or xmax gt xdim-1 or $
       ymin lt 0 or ymax gt ydim-1 then begin

        message, 'Error: invalid array location'

    endif

    n_items = self.GetNumEltsRange(xa, xb, ya, yb)
    
    if n_items gt 0 then begin
    
        outarray = make_array(n_items, type=self.data_type)

        counta = long(0)

        for i = xmin, xmax do begin
            for j = ymin, ymax do begin

                listobj = (*self.list_arr_ptr)[i,j]
                
                tmp_nitems = listobj.Count()

                if tmp_nitems gt 0 then begin

                    outarray[counta] = listobj.ToArray()
                    counta = counta + tmp_nitems

                endif

            endfor
        endfor

    endif

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetElements method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::GetElements, x_ind, y_ind, n_items, outarray

    compile_opt idl2, strictarrsubs


    xdim = self.xdim
    ydim = self.ydim

    if x_ind lt 0 or x_ind gt xdim-1 or $
       y_ind lt 0 or y_ind gt ydim-1 then begin

        message, 'Error: invalid array location'

    endif

    listobj = (*self.list_arr_ptr)[x_ind,y_ind]

    n_items = listobj.Count()

    if n_items gt 0 then outarray = listobj.ToArray()

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Add method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::Add, x_ind, y_ind, input_data

    compile_opt idl2, strictarrsubs


    ; is the data type initialized?
    
    input_type = size(input_data,/type)
    
    if self.data_type eq 0 then begin

        self.data_type = input_type
        
    endif else begin
        
        ; check that the input array matches the type of the currently 
        ; stored data
        
        if input_type ne self.data_type then begin
            
            ; tmp_inputarr = fix(input_type, TYPE=self.data_type)
            
            message, 'Invalid input data type'
            
        endif
        
    endelse

    xdim = self.xdim
    ydim = self.ydim

    if x_ind lt 0 or x_ind gt xdim-1 or $
       y_ind lt 0 or y_ind gt ydim-1 then begin

        message, 'Error: invalid array location'

    endif

    listobj = (*self.list_arr_ptr)[x_ind,y_ind]


    ; are we adding a single element or an array?
    
    n_dims = size(input_data, /N_dimensions)
    
    case n_dims of
        0: listobj.Add, input_data
        1: listobj.Add, input_data, /Extract
        else: message, 'Invalid input data type'
    endcase

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Reset method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::Reset

    compile_opt idl2, strictarrsubs


    xdim = self.xdim
    ydim = self.ydim

    for i = 0, xdim-1 do begin
        for j = 0, ydim-1 do begin

            listobj = (*self.list_arr_ptr)[i,j]
            listobj.Remove, /ALL

        endfor
    endfor

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::SetProperty

    compile_opt idl2, strictarrsubs



end





;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::GetProperty,  xdim=xdim, $
                                   ydim=ydim, $
                                   data_type=data_type

    compile_opt idl2, strictarrsubs

    if Arg_present(xdim) ne 0 then xdim=self.xdim
    if Arg_present(ydim) ne 0 then ydim=self.ydim
    if Arg_present(data_type) ne 0 then data_type = self.data_type

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Init method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_2D_list_array::Init, xdim, ydim, type=type


    compile_opt idl2, strictarrsubs


   ; check that the array dimensions are present

    if N_elements(xdim) eq 0 or N_elements(ydim) eq 0 then begin

        message, 'Error: array dimensions must be supplied at initialization'

    endif


    ; check for an input data type
    
    if N_elements(type) eq 0 then type = 0


    ; initialize the list objects

    listarr = objarr(xdim,ydim)

    for i = 0, xdim-1 do begin
        for j = 0, ydim-1 do begin

            listarr[i,j] = list()

        endfor
    endfor


    ; populate the self fields

    ; the array type is initialized as undefined

    self.xdim = long(xdim)
    self.ydim = long(ydim)
    self.data_type  = type
    self.list_arr_ptr = ptr_new(listarr)

    return, 1

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_2D_list_array::Cleanup

    compile_opt idl2, strictarrsubs

    OBJ_DESTROY, *self.list_arr_ptr
    ptr_free, self.list_arr_ptr

end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_2D_list_array__define.pro
;
;   This is the object class definition
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_2D_list_array__define

    compile_opt idl2, strictarrsubs

    struct = { wmb_2D_list_array,              $
                                              $
               INHERITS IDL_Object,           $
                                              $
               xdim             : long(0),    $
               ydim             : long(0),    $
               data_type        : 0,          $
               list_arr_ptr     : ptr_new()   }

end