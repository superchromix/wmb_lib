;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_PlotWindow object class
;
;   This file defines the wmb_PlotWindow object class.
;
;   The wmb_PlotWindow object class will define a graphical user
;   interface which enables the user to interact with a table of data.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_PlotWindow top level event handler
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_PlotWindow_events, event

    compile_opt idl2, strictarrsubs

;   This is the main event hander for the wmb_PlotWindow object. Its purpose
;   is to dispatch events to the appropriate event handler methods by parsing 
;   the user value of the widget causing the event.

;   Get the instructions from the widget causing the event and
;   act on them.
    
    Widget_Control, event.id, Get_UValue = instructions

    if obj_valid(instructions.object) then begin
    
        tmp_method = 'Event_Handler'
        tmp_object = instructions.object
        call_method, tmp_method, tmp_object, event
        
    endif

end 


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_PlotWindow cleanup procedure
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow_cleanup, tlb_id

    compile_opt idl2, strictarrsubs

    ; obtain the object reference of the wmb_PlotWindow from the uvalue
    ; of the top level base

    Widget_Control, tlb_id, Get_UValue = tlb_uvalue
    
    oTableWindow = tlb_uvalue.object

    ; destroy the wmb_PlotWindow object
    
    OBJ_DESTROY, oTableWindow

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Note: All object methods that may be called from an external source - such
;         as from another object method, are given the "Ext_" prefix.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Event_Handler method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Event_Handler, event

    compile_opt idl2, strictarrsubs


    ; get the instructions from the widget causing the event and act on them
    
    Widget_Control, event.id, Get_UValue = instructions

    if instructions.method ne 'NULL' then begin
    
        call_method, instructions.method, instructions.object, event
        
        ; print, instructions.method, event
        
    endif

    
    ; handle any view window requests in the request list
    
    self -> Handle_Requests


    ; handle redraw requests
    if self.flag_redraw_request then begin
       
        self -> Redraw
       
    endif
    

    ; timer events are used to run periodic housekeeping
    
    if (tag_names(event, /structure_name) eq 'WIDGET_TIMER') then begin
    
        self -> Housekeeping
        widget_control, event.id, timer=1
    
    endif


;    print, 'Event type:' + tag_names(event, /structure_name)
;    print, 'Tag names:', tag_names(event)
;    print, event

    ; quit the program
    if self.flag_quit then widget_control, event.top, /destroy

end 


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Handle_Requests method
;
;   Handles requests from the display objects to the view window.  All
;   requests in the request list are handled in a batch.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Handle_Requests

    compile_opt idl2, strictarrsubs

    ; get the object reference to the request list
    orequestlist = self.request_list
    
    foreach val, orequestlist do begin
    
        reqtype = strlowcase(val['type'])
        
        case reqtype of
        
            'window_redraw': begin
            
                self.flag_redraw_request = 1
            
            end
            
        

        endcase

    endforeach

    ; all requests have now been handled 
    if N_elements(orequestlist) gt 0 then orequestlist -> Remove, /ALL

end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Housekeeping method
;
;   This method runs periodically, triggered by timer events.  Use this to 
;   manage widget sensitivity, etc.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Housekeeping

    compile_opt idl2, strictarrsubs



end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetWID method
;
;   Knowing the uname of the desired widget, find the widget ID of any
;   widget contained within the wmb_PlotWindow top level base
;
;   This essentially gives control of any widget contained in the view window
;   to external code.  Use with caution.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_PlotWindow::GetWID, wid_uname

    compile_opt idl2, strictarrsubs
    
    tlb = self.wid_tlb

    id = widget_info(tlb, FIND_BY_UNAME=wid_uname)

    return, id
    
end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Resize_TLB method
;
;   This method adjusts the size of the top level base, by adjusting the
;   size of its contents
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Resize_TLB, deltax, deltay

    compile_opt idl2, strictarrsubs

    ; calculate a new size for the top level base, taking into account
    ; the minimum and maximum size limits

    oldx = self.stat_tlb_xsize
    oldy = self.stat_tlb_ysize
    
    newx = self.con_tlb_minxsize > (oldx+deltax) < self.con_tlb_maxxsize
    newy = self.con_tlb_minysize > (oldy+deltay) < self.con_tlb_maxysize 
    
    ; determine how much the tlb size needs to be changed
    
    adj_deltax = newx - self.stat_tlb_xsize
    adj_deltay = newy - self.stat_tlb_ysize

    self -> Update_Widget_Geo, tlb_deltax = adj_deltax, $
                               tlb_deltay = adj_deltay

    ; redraw the window

    self.flag_redraw_request = 1
        
end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Update_Widget_Geo method
;   
;   This method does not resize the TLB directly.  It changes the size and
;   position of the resizable widgets within the TLB.  
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Update_Widget_Geo, tlb_deltax = deltax, $
                                       tlb_deltay = deltay

    compile_opt idl2, strictarrsubs


    if N_elements(deltax) eq 0 then deltax = 0
    if N_elements(deltay) eq 0 then deltay = 0


    ; get the widget IDs of the relevant widgets

    ; the window widget
    win_wid = self.wid_window
    
    stored_win_xsize = self.stat_win_xsize
    stored_win_ysize = self.stat_win_ysize
    

    ; determine the new size for the window
    
    new_win_xsz = stored_win_xsize + deltax
    new_win_ysz = stored_win_ysize + deltay
    
    
    ; disable refresh for the window
    
    win_obj = self.orf_window
    
    win_obj.Refresh, /DISABLE
    
    ; change the window size
    
    widget_control, win_wid, draw_xsize = new_win_xsz, $
                             scr_xsize  = new_win_xsz, $
                             draw_ysize = new_win_ysz, $
                             scr_ysize  = new_win_ysz
                               
                               
    ; store the new window size
    
    self.stat_win_xsize = new_win_xsz
    self.stat_win_ysize = new_win_ysz
                               
    ; update the tlb base size 
    
    widget_control, self.wid_tlb, tlb_get_size=base_size
    self.stat_tlb_xsize = base_size[0]
    self.stat_tlb_ysize = base_size[1]
    
    ; re-enable refresh
    
    win_obj.Refresh

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Redraw method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Redraw

    compile_opt idl2, strictarrsubs


    self.flag_redraw_request = 0

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Note: All event handlers are given the "Evt_" prefix.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_Context method
;
;   This method handles context events from the table widget
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Evt_Context, event

    compile_opt idl2, strictarrsubs

    Widget_Control, event.id, Get_UValue = instructions

    src = instructions.source
    
    case src of
        
        'sample': begin

            ; sample context event handler

        end
        
    endcase
  
end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_TLB method
;
;   This method handles window resize events generated by the top level base
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Evt_TLB, event

    compile_opt idl2, strictarrsubs

  
    if tag_names(event, /STRUCTURE_NAME) eq 'WIDGET_BASE' then begin
        
        widget_control, self.wid_tlb, tlb_get_size=bsize
    
        newx = bsize[0]
        newy = bsize[1]

        ; determine how much the tlb size needs to be changed
        
        deltax = newx - self.stat_tlb_xsize
        deltay = newy - self.stat_tlb_ysize
    

        self -> Resize_TLB, deltax, deltay
    
        
    endif

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_Window method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Evt_Window, event

    compile_opt idl2, strictarrsubs
    @dv_pro_err_handler


    ; handle right click events which will display the context menu
    if event.type eq 0 and event.press eq 4 then begin
        self.context_last_x = event.x
        self.context_last_y = event.y
    endif
   
    
    if event.type eq 1 and event.release eq 4 then begin
        
        lastx = self.context_last_x
        lasty = self.context_last_y
        
        if event.x eq lastx and event.y eq lasty then begin
            
            win_wid = self.wid_window
            cmenu = self.wid_context_menu
            
            orig_ysize = self.con_win_orig_ysize
            cur_ysize = self.stat_win_ysize
            
            ; correct for a bug that causes the context menu to display
            ; at the wrong y position
            
            deltay = cur_ysize - orig_ysize
            
            if self.flag_context_menu_enabled eq 1 then begin
                widget_displaycontextmenu, win_wid, lastx, lasty-deltay, cmenu
            endif
            
        endif

    endif
    
end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_File method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Evt_File, event

    compile_opt idl2, strictarrsubs

    widget_control, event.id, get_uvalue = wid_uvalue
    
    evt_source = wid_uvalue.source

    case evt_source of
        
        'save': begin
            
            ; get a save file name
            
            cur_path = self.stat_current_path
            wtitle = self.stat_wtitle
            
            default_fn = wtitle+'.png'
            
            fn = dialog_pickfile(DEFAULT_EXTENSION='*.png', $
                                 DIALOG_PARENT=event.top, $
                                 GET_PATH=out_path, $
                                 FILE=default_fn, $
                                 PATH=cur_path, $
                                 /OVERWRITE_PROMPT, $
                                 /WRITE)
                                 
            if fn ne '' then begin
            
                plot_obj = self.orf_plot
                
                plot_obj.Save, fn

                self.stat_currentpath = out_path
                
            endif
            
        end
        
        
        
        'close': begin

            self.flag_quit = 1

        end
        
    endcase

end





;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Context_menu_init method
;
;   Creates the context menu
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_PlotWindow::Context_menu_init

    compile_opt idl2, strictarrsubs

    win_wid = self.wid_window

    cmenu = widget_base(win_wid, /context_menu)
    
    button = widget_button(cmenu, value='Sample menu item', $
              uvalue={Object:self, Method:'Evt_Context', $
                      Source:'sample'}, uname='cont_menu_sample', $
                      /checked_menu)  

    self.wid_context_menu = cmenu
   
end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Start_TimerEvents method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::Start_TimerEvents
 
    compile_opt idl2, strictarrsubs
 
    tlb = self.wid_tlb

    widget_control, tlb, timer=1

end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the PlotSetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::PlotSetProperty, title = title, $
                                     _Extra=extra

    compile_opt idl2, strictarrsubs

    plot_obj = self.orf_plot


    ; override the setting of the title property in order to 
    ; correct for a bug that result in the plot title having the 
    ; wrong font and font color.

    if N_elements(title) ne 0 then begin
        
        ; this is only valid if it is the first time we are setting
        ; the title property
        
        if ~obj_valid(plot_obj.title) then begin
            
            fname = plot_obj.font_name
            fcolor = plot_obj.font_color
            
            plot_obj.title = title
            titleobj = plot_obj.title

            plot_obj.font_name = fname
            plot_obj.font_color = fcolor

            titleobj.font_name = fname
            titleobj.font_color = fcolor
            
        endif
        
    endif


    ; Set properties of the plot object

    plot_obj -> SetProperty, _Extra=extra

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the PlotGetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::PlotGetProperty, _Ref_Extra = extra
                                
    compile_opt idl2, strictarrsubs


    ; Get properties from the plot object
    
    plot_obj = self.orf_plot
    
    plot_obj -> GetProperty, _Extra=extra
    
end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::SetProperty, tlb_xoffset = tlb_xoffset, $
                                 tlb_yoffset = tlb_yoffset

    compile_opt idl2, strictarrsubs

    if N_elements(tlb_xoffset) ne 0 and N_elements(tlb_yoffset) ne 0 then begin
        
        tlb = self.wid_tlb
        
        widget_control, tlb, tlb_set_xoffset = tlb_xoffset, $
                             tlb_set_yoffset = tlb_yoffset
        
    endif else begin

        if N_elements(tlb_xoffset) ne 0 then begin
            
            tlb = self.wid_tlb
            widget_control, tlb, tlb_set_xoffset = tlb_xoffset
            
        endif
    
        if N_elements(tlb_yoffset) ne 0 then begin
            
            tlb = self.wid_tlb
            widget_control, tlb, tlb_set_yoffset = tlb_yoffset
            
        endif
        
    endelse
end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::GetProperty, wid_tlb = wid_tlb, $
                                 plot_obj = plot_obj, $
                                 pw_request_list = pw_request_list
                                
    compile_opt idl2, strictarrsubs

    if Arg_present(wid_tlb) ne 0 then wid_tlb = self.wid_tlb
    
    if Arg_present(plot_obj) ne 0 then plot_obj = self.orf_plot
    
    if Arg_present(pw_request_list) ne 0 then $
                                    pw_request_list = self.request_list
    
end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GUI_Init method
;
;   Creates the widgets and starts xmanager
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow::GUI_Init, xdata, $
                              ydata, $
                              tlb_xoffset, $
                              tlb_yoffset, $
                              _Extra=extra
 
    compile_opt idl2, strictarrsubs
 
    xsize = self.con_win_default_xsize
    ysize = self.con_win_default_ysize
    
    chk_center_tlb = 0
    
    if min([tlb_xoffset,tlb_yoffset]) lt 0 then begin
        
        ; if tlb_offset is initialized to a value of [-1,-1] then 
        ; we will simply center the base on the screen        
        
        chk_center_tlb = 1
        tlb_offset = long([0,0])
        
    endif

    ; We will store self.name in the uname of the widget_base of the
    ; TLB.  This means that the WID of the TLB will not be returned by 
    ; the GetWID procedure.  This information is stored in self.wid_tlb, 
    ; however, as well as event.top.

    tlb = widget_base(mbar=mbar, $
                      title=self.stat_wtitle, $
                      xoffset=tlb_xoffset, $
                      yoffset=tlb_yoffset, $
                      uname=self.name, $
                      uvalue={Object:self, Method:'evt_tlb', Source:'tlb'}, $
                      MAP=0, $
                      xpad = 0, $
                      ypad = 0, $
                      /COLUMN, $
                      /TLB_SIZE_EVENTS, $
                      /KBRD_FOCUS_EVENTS)

    ; note that the children of the tlb will be automatically resized
    ; when the tlb is resized
    
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Menu bar
;

;   File pulldown menu

    fmenu = widget_button(mbar, value='File', uname='menu_file_top')

    button = widget_button(fmenu, value='Save...', $
                 uvalue={Object:self, Method:'evt_file', Source:'save'}, $
                 uname='menu_file_save')
                                             
    button = widget_button(fmenu, value='Close', /separator, $
                 uvalue={Object:self, Method:'evt_file', Source:'close'}, $
                 uname='menu_file_close')

    mouse_evt_handler = obj_new('wmb_plotwindow_mouseevt')
    
    
    win_wid = widget_window(tlb, $
                            xsize=xsize, $
                            ysize=ysize, $
                            renderer=0, $
                            uname='pw_window', $
                            uvalue={Object:self, $
                                    Method:'evt_window', $
                                    Source:'window'}, $
                            event_handler=mouse_evt_handler)


    widget_control, tlb, /realize
    
    ; retrieve the newly-created Window object
    
    WIDGET_CONTROL, win_wid, GET_VALUE=win_obj
    
    ; store the widget id of the widget_window in the uvalue of the 
    ; window object
    
    win_obj.uvalue = {widget_window_id:win_wid}
    
    ; change the background color
    
    win_obj.background_color = [0,0,0]
    
    ; make the new window object current
    
    win_obj.SetCurrent
    
    ; note that all of the default keyword value specified below may be 
    ; overridden by the _Extra keyword.
    
    def_font = 'Courier'
    def_color = [255,255,255]
    
    plot_obj = plot(xdata, $
                    ydata, $
                    /CURRENT, $
                    antialias=1, $
                    window_title = self.stat_wtitle, $
                    color = def_color, $
                    xcolor = def_color, $
                    ycolor = def_color, $
                    font_color = def_color, $
                    sym_color = def_color, $
                    sym_fill_color = def_color, $
                    font_name = def_font, $
                    _Extra=extra)


    ; handle the plot font title bug
    
    titleobj = plot_obj.title
    if obj_valid(titleobj) then begin

        ; the plot title was specified during plot creation
        
        fname = plot_obj.font_name
        fcolor = plot_obj.font_color
        titleobj.font_name = fname
        titleobj.font_color = fcolor
        
    endif
    



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


    ; find the current tlb size and window size
    
    widget_control, tlb, tlb_get_size = base_size
    
    cur_tlb_xpix = base_size[0]
    cur_tlb_ypix = base_size[1]    
    
    win_geo = widget_info(win_wid, /GEOMETRY)
    
    cur_win_xpix = win_geo.xsize
    cur_win_ypix = win_geo.ysize
    

    ; center the tlb on the screen 
    
    if chk_center_tlb then cgCentertlb, tlb, 0.25, 0.35


    ; show the plot 
    
    widget_control, tlb, MAP=1


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Start event manager

    xmanager, self.name, tlb, event_handler='wmb_PlotWindow_events', $
              cleanup='wmb_PlotWindow_cleanup', /no_block


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Update object data
;

    self.wid_tlb = tlb
    self.wid_window = win_wid
    self.orf_window = win_obj
    self.orf_plot = plot_obj
    
    self.con_win_orig_ysize = cur_win_ypix
    
    self.stat_tlb_xsize = cur_tlb_xpix
    self.stat_tlb_ysize = cur_tlb_ypix
    self.stat_win_xsize = cur_win_xpix
    self.stat_win_ysize = cur_win_ypix


end





;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the INIT method
;
;   NOTE THAT EXTRA KEYWORDS ARE PASSED TO THE PLOT OBJECT WHEN 
;   IT IS CREATED
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_PlotWindow::Init, name, $
                               data1, $
                               data2, $
                               xsize=xsize, $
                               ysize=ysize, $
                               window_title = window_title, $
                               current_path = current_path, $
                               tlb_xoffset = tlb_xoffset, $
                               tlb_yoffset = tlb_yoffset, $
                               _Extra=extra

                               
    compile_opt idl2, strictarrsubs

;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Check that the positional and keyword parameters are present
;

    if N_elements(name) eq 0 then begin
        message, 'Error: a unique object name must be specified when ' + $
                 'initializing a wmb_PlotWindow object.'
        return, 0
    endif else begin
        name = 'wmb_PlotWindow_' + name
    endelse


    ; each instance of wmb_PlotWindow must have a unique name

    if XRegistered(name) gt 0 then begin
        message, 'Error: a unique object name must be specified when ' + $
                 'initializing a wmb_PlotWindow object.'
        return, 0
    endif


    ; check for the x and y data
    
    chk_data1 = N_elements(data1) ne 0
    chk_data2 = N_elements(data2) ne 0
    
    if chk_data1 and chk_data2 then begin
        
        ; both x and y data provided
        
        if N_elements(data1) ne N_elements(data2) then begin
            message, 'Error: the number of elements in the X and Y ' + $
                     'data arrays must be equal.'
            return, 0
        endif
        
        xdata = data1
        ydata = data2
        
    endif else begin
        
        if chk_data1 then begin
            
            ; only y data provided
            
            xdata = indgen(N_elements(data1))
            ydata = data1
          
        endif else begin
            
            ; no data provided
            
            if N_elements(data1) ne N_elements(data2) then begin
                message, 'Error: missing plot data'
                return, 0
            endif
            
        endelse
        
    endelse


    ; set the default font, and the default size of the table
    
    if N_elements(xsize) eq 0 then xsize = 525
    if N_elements(ysize) eq 0 then ysize = 280
    if N_elements(window_title) eq 0 then window_title = 'Plot window'
    if N_elements(current_path) eq 0 then current_path = ''
    if N_elements(tlb_xoffset) eq 0 then tlb_xoffset = -1
    if N_elements(tlb_yoffset) eq 0 then tlb_yoffset = -1


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Initialize variables and set constants
;

;   Minimum window size
    tlb_minxsize = 250
    tlb_minysize = 250


;   Maximum window size
    device, get_screen_size=screen_size
    xscreen = screen_size[0]
    yscreen = screen_size[1]
    
    maxtlbxsz = xscreen
    maxtlbysz = yscreen

    
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Update the object data
;
    

    self.name = name
    self.stat_wtitle = window_title
    self.stat_current_path = current_path
    self.con_win_default_xsize = xsize
    self.con_win_default_ysize = ysize
    self.con_tlb_minxsize  = tlb_minxsize
    self.con_tlb_minysize  = tlb_minysize
    self.con_tlb_maxxsize = maxtlbxsz
    self.con_tlb_maxysize = maxtlbysz
    
    self.flag_context_menu_enabled = 0
    self.request_list = list()


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Initialize the GUI
;
    
    ; by passing extra keywords to the GUI_init method, we can initialize
    ; additional plot parameters
    
    self -> GUI_Init, xdata, ydata, tlb_xoffset, tlb_yoffset, _Extra=extra

    self -> Context_menu_init

    self -> Start_TimerEvents

    

;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Initialize the IDL_Object
;

    if ~ self->IDL_Object::Init() then begin
        message, 'Error initializing IDL_Object.'
        return, 0
    endif


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   finished initializing wmb_PlotWindow object
;

    return, 1

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_PlotWindow::Cleanup

    compile_opt idl2, strictarrsubs

    widget_control, self.wid_tlb, /destroy
    
    wmb_destroylist, self.request_list
    
end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_PlotWindow__define.pro
;
;   This is the object class definition
;
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow__define

    compile_opt idl2, strictarrsubs

    struct = {       wmb_PlotWindow,                           $
                     INHERITS IDL_Object,                      $
                                                               $
                     name                        : '',         $
                                                               $
                     wid_tlb                     : long(0),    $
                     wid_window                  : long(0),    $
                     orf_window                  : obj_new(),  $
                     orf_plot                    : obj_new(),  $                                        
                                                               $
                     con_win_default_xsize       : 0,          $
                     con_win_default_ysize       : 0,          $
                     con_tlb_minxsize            : 0,          $
                     con_tlb_minysize            : 0,          $
                     con_tlb_maxxsize            : 0,          $
                     con_tlb_maxysize            : 0,          $
                     con_win_orig_ysize          : 0,          $           
                                                               $
                     stat_wtitle                 : '',         $
                     stat_current_path           : '',         $
                     stat_tlb_xsize              : 0,          $
                     stat_tlb_ysize              : 0,          $
                     stat_win_xsize              : 0,          $
                     stat_win_ysize              : 0,          $
                                                               $
                     wid_context_menu            : long(0),    $
                     context_last_x              : 0,          $
                     context_last_y              : 0,          $
                                                               $
                     flag_redraw_request         : 0,          $
                     flag_context_menu_enabled   : 0,          $
                     flag_quit                   : 0,          $
                                                               $
                     request_list                : list()      }

end



pro test_wmb_plotwin

    xdata = indgen(100)
    ydata = sin(xdata*!pi/20.0)

    bb=obj_new('wmb_plotwindow', $
               'testwin', $
                xdata, $
                ydata, $
                xsize=600, $
                ysize=300, $
                font_size=12, $
                font_style=0, $
                font_name='Courier')

end