
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_PlotWindow_MouseEvt_MouseEvt object class
;
;   This file defines the wmb_PlotWindow_MouseEvt object class.
;
;   The wmb_PlotWindow_MouseEvt object class will define an event handler
;   for mouse events in the wmb_plotwindow.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the MouseDown method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_PlotWindow_MouseEvt::MouseDown, oWin, $
                                             evtx, $
                                             evty, $
                                             iButton, $
                                             KeyMods, $
                                             nClicks

    compile_opt idl2, strictarrsubs

    ; construct a conventional mouse event structure and send it to the widget
    
    tmp_evt = {WIDGET_DRAW, $
               ID:0L, TOP:0L, HANDLER:0L, $
               TYPE: 0, $
               X: long(evtx), $
               Y: long(evty), $
               PRESS: byte(iButton), $
               RELEASE: 0B, $
               CLICKS: long(nClicks), $
               MODIFIERS: long(KeyMods), $
               CH:0B, $
               KEY:0L }
    
    win_wid = owin.uvalue.widget_window_id
    
    widget_control, win_wid, send_event = tmp_evt

    ; skip default event handling

    return, 0

end

 
 ;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the MouseUp method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_PlotWindow_MouseEvt::MouseUp, oWin, $
                                           evtx, $
                                           evty, $
                                           iButton


    compile_opt idl2, strictarrsubs

    ; construct a conventional mouse event structure and send it to the widget
    
    tmp_evt = {WIDGET_DRAW, $
               ID:0L, TOP:0L, HANDLER:0L, $
               TYPE: 1, $
               X: long(evtx), $
               Y: long(evty), $
               PRESS: 0B, $
               RELEASE: byte(iButton), $
               CLICKS: 0L, $
               MODIFIERS: 0L, $
               CH: 0B, $
               KEY: 0L }
    
    win_wid = owin.uvalue.widget_window_id
    
    widget_control, win_wid, send_event = tmp_evt

    ; skip default event handling

    return, 0

end
 
 
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   The Init method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_PlotWindow_MouseEvt::Init

    compile_opt idl2, strictarrsubs


    if ~ self->GraphicsEventAdapter::Init() then begin
        message, 'Error initializing GraphicsEventAdapter object'
        return, 0
    endif
    
    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_PlotWindow_MouseEvt__define.pro
;
;   This is the object class definition
;
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_PlotWindow_MouseEvt__define

    compile_opt idl2, strictarrsubs

    struct = {       wmb_PlotWindow_MouseEvt,                  $
                     INHERITS GraphicsEventAdapter,            $
                                                               $
                     X0                         : 0,           $
                     Y0                         : 0,           $
                     BUTTONDOWN                 : 0            }

end


