;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_center_tlb_on_parent
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_center_tlb_on_parent, tlb, $
                              grpleader, $
                              xoffset = in_xoff, $
                              yoffset = in_yoff, $
                              align_top_right = align_top_right

    compile_opt idl2, strictarrsubs

    if N_elements(in_xoff) eq 0 then in_xoff = 0
    if N_elements(in_yoff) eq 0 then in_yoff = 0
    if N_elements(align_top_right) eq 0 then align_top_right = 0

    if widget_info(tlb, /valid_id) eq 0 then begin

        message, 'First parameter must be a valid widget ID.'

    endif

    if widget_info(grpleader, /valid_id) eq 0 then begin

        message, 'Second parameter must be a valid widget ID.'

    endif

    gl_tlb = wmb_find_tlb(grpleader)

    gl_geo = widget_info(gl_tlb, /GEOMETRY)
    tlbgeo = Widget_Info(tlb, /GEOMETRY)    
    
    tlb_xpad = tlbgeo.xpad
    tlb_ypad = tlbgeo.ypad
    
    gl_xsize = gl_geo.scr_xsize
    gl_ysize = gl_geo.scr_ysize
    
    gl_xoff  = gl_geo.xoffset    
    gl_yoff  = gl_geo.yoffset
    
    gl_xcen = gl_xoff + (gl_xsize/2.0)
    gl_ycen = gl_yoff + (gl_ysize/2.0)

    tlb_xsize = tlbgeo.scr_xsize
    tlb_ysize = tlbgeo.scr_ysize

    newtlbxoff = gl_xcen - (tlb_xsize/2.0)
    newtlbyoff = gl_ycen - (tlb_ysize/2.0)

    calc_xoff = newtlbxoff 
    calc_yoff = newtlbyoff 

    if align_top_right eq 1 then begin
        
        gl_x_tr = gl_xoff + gl_xsize
        gl_y_tr = gl_yoff
        
        newtlbxoff = gl_x_tr
        newtlbyoff = gl_y_tr
        
        calc_xoff = newtlbxoff 
        calc_yoff = newtlbyoff 
        
    endif
    
    ; don't let the new window fall off the right side of the screen
    
    new_tlb_x_max = newtlbxoff + tlb_xsize
    
    oMonInfo = Obj_New('IDLsysMonitorInfo')
    n_monitors = oMonInfo -> GetNumberOfMonitors()
    rects = oMonInfo -> GetRectangles(/Exclude_Taskbar)
    
    if n_monitors eq 1 then begin
        
        screen_xmax = rects[0] + rects[2]
        
    endif else begin

        screen_xmin = rects[0,*]
        screen_xsize = rects[2,*]
        
        rects_screen_xmax = screen_xmin + screen_xsize
        
        screen_xmax = max(rects_screen_xmax)
        
    endelse

    new_tlb_x_max = new_tlb_x_max < screen_xmax
    
    newtlbxoff = new_tlb_x_max - tlb_xsize
    
    calc_xoff = newtlbxoff
    
    ; set the offsets
    widget_control, tlb, xoffset = calc_xoff + in_xoff + tlb_xpad, $
                         yoffset = calc_yoff + in_yoff + tlb_ypad

end
