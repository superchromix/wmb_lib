;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_IDLgrAxis object class
;
;   This file defines the wmb_IDLgrAxis object class.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc




;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_IDLgrAxis::SetProperty, _Extra = extra

    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler



 
    ; pass extra keywords

    self->IDLgrAxis::SetProperty, _Extra=extra
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_IDLgrAxis::GetProperty, xrange = xrange, $
                                yrange = yrange, $
                                _Ref_Extra=extra


    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler


    if Arg_present(xrange) ne 0 or Arg_present(yrange) ne 0 then begin
        
        ; draw the axis to a buffer in order to update the text objects
        
        self.orf_window -> GetProperty, DIMENSIONS = wdims, $
                                        RESOLUTION = wres
        
        obuf = obj_new('IDLgrBuffer', DIMENSIONS = wdims, $
                                      RESOLUTION = wres)
        
        obuf -> Draw, self.orf_view

        
        ; calculate the xrange and yrange while taking into account all of the 
        ; text objects associated with the axis
        
        self->IDLgrAxis::GetProperty, XRANGE = axis_xr, $
                                      YRANGE = axis_yr, $
                                      TICKTEXT = oticktext, $
                                      TITLE = otitletext

        xmin = axis_xr[0]
        xmax = axis_xr[1]
        ymin = axis_yr[0]
        ymax = axis_yr[1]
                             
                             
        if obj_valid(otitletext) then begin 
        
            otitletext->GetProperty, xrange = title_xr, $
                                     yrange = title_yr
        
            xmin = xmin < title_xr[0]
            xmax = xmax > title_xr[1]
            ymin = ymin < title_yr[0]
            ymax = ymax > title_yr[1]
        
        endif

        
        if obj_valid(oticktext[0]) then begin
            
            foreach tmpo, oticktext do begin
                
                tmpo -> GetProperty, xrange = tick_xr, $
                                     yrange = tick_yr
                
                xmin = xmin < tick_xr[0]
                xmax = xmax > tick_xr[1]
                ymin = ymin < tick_yr[0]
                ymax = ymax > tick_yr[1]
                
            endforeach
            
        endif

        xrange = [xmin,xmax]
        yrange = [ymin,ymax]

    endif



    ; pass extra keywords

    self->IDLgrAxis::GetProperty, _Extra=extra 
     
end





;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Init method
;
;   view_obj: View object which contains this axis.
;
;   dest_obj: Graphics window in which the axis will be drawn.
;             
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_IDLgrAxis::Init, view_obj, $
                              dest_obj, $
                              direction, $
                              _Extra = extra


    compile_opt idl2, strictarrsubs
    @dv_func_err_handler
    

    ; initialize the dv_DecoratorObj2D object

    if ~ self->IDLgrAxis::Init(direction, _Extra = extra) then begin
                                     
        message, 'Error initializing IDLgrAxis object.'
        return, 0
        
    endif


    ; set the RECOMPUTE_DIMENSIONS property for all text objects
    
    self->IDLgrAxis::GetProperty, TICKTEXT = oticktext, $
                                  TITLE = otitletext

    if obj_valid(otitletext) then begin 
        
        otitletext->SetProperty, RECOMPUTE_DIMENSIONS = 2
        
    endif 
    
    if obj_valid(oticktext[0]) then begin
            
        foreach tmpo, oticktext do tmpo->SetProperty, RECOMPUTE_DIMENSIONS = 2
        
    endif


    self.orf_view = view_obj
    self.orf_window = dest_obj

    ; finished initializing wmb_IDLgrAxis object

    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_IDLgrAxis::Cleanup

    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler

    self -> IDLgrAxis::Cleanup

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_IDLgrAxis__define.pro
;
;   This is the object class definition
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_IDLgrAxis__define

    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler

    struct = { wmb_IDLgrAxis,                            $
               INHERITS IDLgrAxis,                       $
                                                         $
               orf_view              : obj_new(),        $
               orf_window            : obj_new()         }

end

