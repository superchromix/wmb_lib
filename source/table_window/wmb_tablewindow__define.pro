;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_TableWindow object class
;
;   This file defines the wmb_TableWindow object class.
;
;   The wmb_TableWindow object class will define a graphical user
;   interface which enables the user to interact with a table of data.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_TableWindow top level event handler
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_TableWindow_events, event

    compile_opt idl2, strictarrsubs

;   This is the main event hander for the wmb_TableWindow object. Its purpose
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
;   wmb_TableWindow cleanup procedure
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow_cleanup, tlb_id

    compile_opt idl2, strictarrsubs

    ; obtain the object reference of the wmb_TableWindow from the uvalue
    ; of the top level base

    Widget_Control, tlb_id, Get_UValue = tlb_uvalue
    
    oTableWindow = tlb_uvalue.object

    ; destroy the wmb_TableWindow object
    
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

pro wmb_TableWindow::Event_Handler, event

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

pro wmb_TableWindow::Handle_Requests

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

pro wmb_TableWindow::Housekeeping

    compile_opt idl2, strictarrsubs



end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetWID method
;
;   Knowing the uname of the desired widget, find the widget ID of any
;   widget contained within the wmb_TableWindow top level base
;
;   This essentially gives control of any widget contained in the view window
;   to external code.  Use with caution.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_TableWindow::GetWID, wid_uname

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

pro wmb_TableWindow::Resize_TLB, deltax, deltay

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

pro wmb_TableWindow::Update_Widget_Geo, tlb_deltax = deltax, $
                                       tlb_deltay = deltay

    compile_opt idl2, strictarrsubs


    if N_elements(deltax) eq 0 then deltax = 0
    if N_elements(deltay) eq 0 then deltay = 0


    ; get the widget IDs of the relevant widgets

    ; the table widget
    wid_table = self.wid_table
    
    
    ; get the current sizes of the table and table viewport
    
    cur_table_ncols = self.stat_table_ncols
    cur_table_nrows = self.stat_table_nrows

    
    ; get the current and stored geometry information

    table_geo = widget_info(wid_table, /GEOMETRY)
    table_col_widths = widget_info(wid_table, /COLUMN_WIDTHS)
    table_row_heights = widget_info(wid_table, /ROW_HEIGHTS)
    
    
    stored_table_xsize = self.stat_table_scr_xsize
    stored_table_ysize = self.stat_table_scr_ysize
    

    ; determine the new size for the table
    
    new_table_xsz = stored_table_xsize + deltax
    new_table_ysz = stored_table_ysize + deltay
    
    ; change the table size
    widget_control, wid_table, scr_xsize = new_table_xsz, $
                               scr_ysize = new_table_ysz
                               
    ; store the new table size
    
    self.stat_table_scr_xsize = new_table_xsz
    self.stat_table_scr_ysize = new_table_ysz
                               
    ; update the tlb base size 
    
    widget_control, self.wid_tlb, tlb_get_size=base_size
    self.stat_tlb_xsize = base_size[0]
    self.stat_tlb_ysize = base_size[1]

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Redraw method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::Redraw

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
;   This is the Evt_TLB method
;
;   This method handles window resize events generated by the top level base
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::Evt_TLB, event

    compile_opt idl2, strictarrsubs

  
    if tag_names(event, /STRUCTURE_NAME) eq 'WIDGET_BASE' then begin
        
        widget_control, self.wid_tlb, tlb_get_size=bsize
    
        newx = bsize[0]
        newy = bsize[1]

        ; determine how much the tlb size needs to be changed
        
        deltax = newx - self.stat_tlb_xsize
        deltay = newy - self.stat_tlb_ysize
    
        ; note the way in which TLB resize events work:
        ;
        ; when the user resizes the tlb with the mouse, the tlb size changes,
        ; and the resize is reported by an event.  at this point, if the tlb
        ; is queried with widget_control, tlb, tlb_get_size=size, this will
        ; report the new size of the window.  however, the tlb size is truly
        ; set by the size of the widgets it contains.  the first time the size
        ; of one of the contained widgets is updated, the tlb boundaries will 
        ; "snap back" to the size defined by the contained widgets.
        ;
        ; therefore, in order to resize the tlb, the contained widgets must be 
        ; resized.  widget_control must not be used to resize the tlb directly, 
        ; since this results in unexpected behaviour.  if the user manually 
        ; resizes the tlb, the new size of the tlb can be checked, but in order
        ; to make the size change permanent the contained widget sizes must
        ; be updated accordingly.
    
        ; update the widget geometries (this adjusts the size and position 
        ; of widgets within the center base, and also updates the display 
        ; geometries)
        
        
        self -> Resize_TLB, deltax, deltay
    
        
    endif

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_Table method
;
;   This method handles window resize events generated by the table widget
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::Evt_Table, event

    compile_opt idl2, strictarrsubs

    evt_type = tag_names(event,/STRUCTURE_NAME)

    case evt_type of
        
        'WIDGET_TABLE_COL_WIDTH': begin
            
            ; the width of one of the columns was changed
            
            old_col_widths = *self.stat_table_col_widths
            
            col_index = event.col
            old_width = old_col_widths[col_index]
            
            col_deltax = event.width - old_width
            
            ; adjust the maximum x size of the tlb
            
            self.con_tlb_maxxsize = self.con_tlb_maxxsize + col_deltax
           
            new_col_widths = old_col_widths
            new_col_widths[col_index] = event.width
            *self.stat_table_col_widths = new_col_widths
            
            ; adjust the TLB size
            
            self -> Resize_TLB, col_deltax, 0
            
        end
        
        else:

    endcase

end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_File method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::Evt_File, event

    compile_opt idl2, strictarrsubs

    widget_control, event.id, get_uvalue = wid_uvalue
    
    wid_table = self.wid_table
    evt_source = wid_uvalue.source

    case evt_source of
        
        'save': begin
            
            ; get a save file name
            
            cur_path = self.stat_currentpath
            wtitle = self.stat_wtitle
            
            default_fn = wtitle+'.txt'
            
            fn = dialog_pickfile(DEFAULT_EXTENSION='*.txt', $
                                 DIALOG_PARENT=event.top, $
                                 GET_PATH=out_path, $
                                 FILE=default_fn, $
                                 PATH=cur_path, $
                                 /OVERWRITE_PROMPT, $
                                 /WRITE)
                                 
            if fn ne '' then begin
            
                get_lun, tmplun
                openw, tmplun, fn, ERROR=errorstatus
                
                if errorstatus ne 0 then begin
                    message, 'Error opening file
                endif
                
                ; convert the data to text for writing
                indata = *self.dataptr
            
                n_struct_tags = n_tags(indata[0])
                n_rows = n_elements(indata)
            
                ; build a format code for conversion to string type
                
                crlf_char = string([13b,10b])
                sep_char = string(9B)
    
                fmtcode = '(' + string(n_rows,format='(I0)') + '('
                firstrow = indata[0]
                
                for i = 0, n_struct_tags-1 do begin
                
                    tmpdat = firstrow.(i)
                    
                    ; verify that the structure member is a scalar
                    tmpdat_ndim = size(tmpdat,/N_dimensions)
                    
                    if tmpdat_ndim ne 0 then begin
                        
                        message, 'Invalid structure member
                        
                    endif
                    
                    tmpfc = wmb_get_formatcode(tmpdat)
                    
                    if i ne n_struct_tags-1 then begin
                    
                        fmtcode = fmtcode + tmpfc + ',"'+sep_char+'",'
                        
                    endif else begin
                    
                        fmtcode = fmtcode + tmpfc + ',"'+crlf_char+'"))'                
                    
                    endelse
                    
                endfor
            
                printf, tmplun, indata, FORMAT=fmtcode
            
                close, tmplun
                free_lun, tmplun
            
                self.stat_currentpath = out_path
                
            endif
            
        end
        
        'rename': begin
            
            existing_name = self.stat_wtitle
            
            wintitle = 'Edit table name'
            
            def_str1 = hash()
            def_str1['type'] = 'string'
            def_str1['xsize'] = 30
            def_str1['label'] = 'Table name'
            def_str1['postfixlabel'] = ''

            pg1_layout = {wmb_input_form_layout}
            pg1_wid_key_list = list('str1')
            pg1_layout.widget_key_list = pg1_wid_key_list
            
            wid_def = hash('str1', def_str1)
            input_dat = hash('str1', existing_name)
            layout_list = list(pg1_layout)
            
            wmb_input_form, event.top, $
                            wid_def, $
                            layout_list, $
                            input_dat, $
                            formcancel, $
                            wintitle = wintitle, $
                            frame=0
            
            if ~formcancel and input_dat['str1'] ne '' then begin
                
                widget_control, self.wid_tlb, TLB_SET_TITLE=input_dat['str1']
                self.stat_wtitle = input_dat['str1']
                
            endif
        end
        
        'close': begin

            self.flag_quit = 1

        end
        
    endcase

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Evt_Edit method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::Evt_Edit, event

    compile_opt idl2, strictarrsubs

    widget_control, event.id, get_uvalue = wid_uvalue
    
    wid_table = self.wid_table
    evt_source = wid_uvalue.source

    case evt_source of
        
        'selectall': begin
            
            n_cols = self.stat_table_ncols
            n_rows = self.stat_table_nrows
            
            tmp_sel = [0,0,n_cols-1,n_rows-1]
            
            widget_control, wid_table, set_table_select=tmp_sel
            
        end
        
        'copy': begin
            
            tmp_sel = widget_info(wid_table, /table_select)
            
            leftsel =  tmp_sel[0]
            topsel = tmp_sel[1]
            rightsel = tmp_sel[2]
            bottomsel = tmp_sel[3]

            selrows = bottomsel - topsel + 1
            selcols = rightsel - leftsel + 1
            
            widget_control, wid_table, $
                            get_value = tmpdat, $
                            use_table_select = tmp_sel
            
            tmpndims = size(tmpdat,/n_dimensions)
            tmptype = size(tmpdat,/type)
            
            if tmptype ne 8 and tmpndims eq 1 then begin
                
                ; check if the data array should be transposed
                
                if selrows gt 1 then begin
                    
                    tmpdat = reform(tmpdat,selcols,selrows,/overwrite)
                    
                endif
            endif
            
            if ~wmb_clipboard_copy(tmpdat) then message, 'Copy failed'
            
        end
        
    endcase

end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GUI_Init method
;
;   Creates the widgets and starts xmanager
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::GUI_Init
 
    compile_opt idl2, strictarrsubs
 

    indata = *self.dataptr
 
    n_cols = self.stat_table_ncols
    n_rows = self.stat_table_nrows
 
    font = self.con_tablefont
 
    has_col_headers = self.has_col_headers
    has_row_headers = self.has_row_headers
    has_col_labels = self.has_col_labels
    has_row_labels = self.has_row_labels
    
    if has_col_labels eq 1 then col_labels = *self.col_labels
    if has_row_labels eq 1 then row_labels = *self.row_labels
 
    row_major = self.con_table_row_major
    col_major = self.con_table_col_major
 
;   Create widgets

;   Get the screen size and define the position of the window
;   This places the window roughly in the middle of the user's screen

    device, get_screen_size=screen_size

    xscreen = screen_size[0]
    yscreen = screen_size[1]

    xcen = xscreen / 2
    ycen = yscreen / 2

    xcorner = xcen - 50
    ycorner = ycen - 50

    ; We will store self.name in the uname of the widget_base of the
    ; TLB.  This means that the WID of the TLB will not be returned by 
    ; the GetWID procedure.  This information is stored in self.wid_tlb, 
    ; however, as well as event.top.

    tlb = widget_base(mbar=mbar, $
                      title=self.stat_wtitle, $
                      xoffset=xcorner, $
                      yoffset=ycorner, $
                      uname=self.name, $
                      uvalue={Object:self, Method:'evt_tlb', Source:'tlb'}, $
                      MAP=0, $
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
                 
    button = widget_button(fmenu, value='Rename...', $
               uvalue={Object:self, Method:'evt_file', Source:'rename'}, $
               uname='menu_file_rename')       
               
;    button = widget_button(fmenu, value='Duplicate...', $
;                 uvalue={Object:self, Method:'evt_file', Source:'duplicate'}, $
;                 uname='menu_file_duplicate')
                                             
    button = widget_button(fmenu, value='Close', /separator, $
                 uvalue={Object:self, Method:'evt_file', Source:'close'}, $
                 uname='menu_file_close')



;   Edit pulldown menu

    emenu = widget_button(mbar, value='Edit', uname='menu_edit_top')

;    button = widget_button(emenu, value='Cut', $
;                 uvalue={Object:self, Method:'evt_edit', Source:'cut'}, $       
;                 uname='menu_edit_cut', $
;                 accelerator='ctrl+x')
  
;    button = widget_button(emenu, value='Clear', $
;                 uvalue={Object:self, Method:'evt_edit', Source:'clear'},$       
;                 uname='menu_edit_clear')

    button = widget_button(emenu, value='Select all', $
                 uvalue={Object:self, Method:'evt_edit', Source:'selectall'}, $
                 uname='menu_edit_selectall', $
                 accelerator='ctrl+a')
                 
    button = widget_button(emenu, value='Copy', $
                 uvalue={Object:self, Method:'evt_edit', Source:'copy'}, $       
                 uname='menu_edit_copy', $
                 accelerator='ctrl+c')

    
    table_id = widget_table(tlb, $  
                            value=indata, $
                            font=font, $
                            column_labels = col_labels, $
                            row_labels = row_labels, $
                            no_column_headers = ~has_col_headers, $
                            no_row_headers = ~has_row_headers, $
                 uvalue={Object:self, Method:'evt_table', Source:'table'}, $ 
                 ROW_MAJOR = row_major, $
                 COLUMN_MAJOR = col_major, $
                 /RESIZEABLE_COLUMNS, $
                 /ALL_EVENTS)


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


    widget_control, tlb, /realize


    ; resize the columns to fit the column labels, if necessary
    
    col_widths = widget_info(table_id, /COLUMN_WIDTHS)

    if has_col_headers eq 1 then begin
        
        new_col_widths = col_widths
        
        added_xpix = 0
        
        for i = 0, n_cols-1 do begin
    
            tmp_header = col_labels[i]
            tmp_strsize = widget_info(table_id, string_size=tmp_header) + 10
            
            if tmp_strsize[0] gt col_widths[i] then begin
                
                new_col_widths[i] = tmp_strsize[0]
                added_xpix = added_xpix + (tmp_strsize[0] - col_widths[i])
                
            endif
            
        endfor
        
        widget_control, table_id, column_widths = new_col_widths
        
        ; increase the size of the widget to accomodate the larger columns
        
        table_geo = widget_info(table_id, /geometry)
        cur_table_xpix = table_geo.scr_xsize

        new_xpix = cur_table_xpix + added_xpix
        
        widget_control, table_id, scr_xsize = new_xpix
        
        col_widths = new_col_widths
        
    endif


    
    ; initially, the table size is equal to the size needed to display
    ; all of the data
    
    widget_control, tlb, tlb_get_size = base_size
    table_geo = widget_info(table_id, /geometry)

    cur_tlb_xpix = base_size[0]
    cur_tlb_ypix = base_size[1]    
    cur_table_xpix = table_geo.scr_xsize
    cur_table_ypix = table_geo.scr_ysize
    
    ; adjust the maximum sizes - we will not allow the table to be made
    ; larger than it's contents
    
    new_max_tlb_xsize = cur_tlb_xpix < self.con_tlb_maxxsize
    new_max_tlb_ysize = cur_tlb_ypix < self.con_tlb_maxysize
    
    ; resize the table if necessary
    
    def_table_xpix = self.con_table_default_xpix
    def_table_ypix = self.con_table_default_ypix
    
    if cur_table_xpix gt def_table_xpix or $
       cur_table_ypix gt def_table_ypix then begin
        
        widget_control, table_id, scr_xsize = cur_table_xpix < def_table_xpix, $
                                  scr_ysize = cur_table_ypix < def_table_ypix
        
    endif
    
    
    ; make the zebra stripes

    if self.flag_bg_stripes eq 1 then begin
        
        white_bg = [255B,255B,255B]
        grey_bg = [230B,230B,230B]
        n_cols = self.stat_table_ncols
        
        tmp_bg_arr1 = bytarr(3,n_cols)
        for i = 0, n_cols-1 do tmp_bg_arr1[0,i] = white_bg
        
        tmp_bg_arr2 = bytarr(3,n_cols)
        for i = 0, n_cols-1 do tmp_bg_arr2[0,i] = grey_bg
        
        tmp_pattern = [[tmp_bg_arr1], [tmp_bg_arr2]]
        
        widget_control, table_id, BACKGROUND_COLOR=tmp_pattern
        
    endif

    ; center the table on the screen 
    
    cgCentertlb, tlb, 0.25, 0.35


    ; show the table 
    
    widget_control, tlb, MAP=1

;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Start event manager

    xmanager, self.name, tlb, event_handler='wmb_TableWindow_events', $
              cleanup='wmb_TableWindow_cleanup', /no_block


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Update object data
;

    widget_control, tlb, tlb_get_size = base_size
    
    table_geo = widget_info(table_id, /geometry)
    final_table_xpix = table_geo.scr_xsize
    final_table_ypix = table_geo.scr_ysize
    
    self.con_tlb_maxxsize = new_max_tlb_xsize
    self.con_tlb_maxysize = new_max_tlb_ysize
    self.stat_tlb_xsize = base_size[0]
    self.stat_tlb_ysize = base_size[1]
    self.stat_table_scr_xsize = final_table_xpix
    self.stat_table_scr_ysize = final_table_ypix
    self.stat_table_col_widths = ptr_new(col_widths)
    self.wid_tlb = tlb
    self.wid_table = table_id

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Start_TimerEvents method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::Start_TimerEvents
 
    compile_opt idl2, strictarrsubs
 

    tlb = self.wid_tlb

    widget_control, tlb, timer=1

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the SetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::SetProperty, currentpath = currentpath

    compile_opt idl2, strictarrsubs

    if N_elements(currentpath) ne 0 then self.stat_currentpath = currentpath


end



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow::GetProperty, table_ncols = table_ncols, $
                                 table_nrows = table_nrows, $
                                 wid_tlb = wid_tlb, $
                                 currentpath = currentpath, $
                                 tw_request_list = tw_request_list
                                
    compile_opt idl2, strictarrsubs

    if Arg_present(table_ncols) ne 0 then table_ncols = self.stat_table_ncols
    if Arg_present(table_nrows) ne 0 then table_nrows = self.stat_table_nrows
    
    if Arg_present(wid_tlb) ne 0 then wid_tlb = self.wid_tlb
    
    if Arg_present(currentpath) ne 0 then currentpath = self.stat_currentpath
    
    if Arg_present(tw_request_list) ne 0 then $
                                    tw_request_list = self.request_list
    
end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the INIT method
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_TableWindow::Init, name, $
                                indata, $
                                font=font, $
                                xsize=xsize, $
                                ysize=ysize, $
                                col_labels = col_labels, $
                                row_labels = row_labels, $
                                no_col_headers = no_col_headers, $
                                no_row_headers = no_row_headers, $
                                window_title = window_title, $
                                current_path = currentpath, $
                                bg_stripes = bg_stripes

                               
    compile_opt idl2, strictarrsubs

;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Check that the positional and keyword parameters are present
;

    if N_elements(name) eq 0 then begin
        message, 'Error: a unique object name must be specified when ' + $
                 'initializing a wmb_TableWindow object.'
        return, 0
    endif else begin
        name = 'wmb_TableWindow_' + name
    endelse


    ; each instance of wmb_TableWindow must have a unique name

    if XRegistered(name) gt 0 then begin
        message, 'Error: a unique object name must be specified when ' + $
                 'initializing a wmb_TableWindow object.'
        return, 0
    endif


    ; check that the input data is present

    if N_elements(indata) eq 0 then begin
        message, 'Input data must be provided at table initialization'
        return, 0
    endif
    
    if size(indata,/type) ne 8 then begin
        message, 'Input data must be a 1D array of structures'
        return, 0
    endif


    ; the table will be row-major
    
    row_major = 1
    col_major = 0


    ; determine the number of rows and columns
    
    nrecords = N_elements(indata)
    n_rows = nrecords
    n_cols = n_tags(indata[0])

    
    ; set the default font, and the default size of the table
    
    if N_elements(font) eq 0 then font = ''
    if N_elements(xsize) eq 0 then xsize = 750
    if N_elements(ysize) eq 0 then ysize = 400
    
    
    ; check whether there will be column or row headers
    
    if N_elements(no_col_headers) eq 0 then no_col_headers = 0
    if N_elements(no_row_headers) eq 0 then no_row_headers = 0
    
    has_col_headers = ~no_col_headers
    has_row_headers = ~no_row_headers
    
    ; check for column and row labels

    if N_elements(col_labels) eq n_cols then begin
        has_col_labels = 1
    endif else begin
        has_col_labels = 0
        col_labels = ''
    endelse
    
    if N_elements(row_labels) eq n_rows then begin
        has_row_labels = 1
    endif else begin
        has_row_labels = 0
        row_labels = ''
    endelse


    if N_elements(window_title) eq 0 then window_title = 'Data table'
    if N_elements(bg_stripes) eq 0 then bg_stripes = 0


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Set the default path
;

    if N_elements(currentpath) eq 0 then currentpath = ''

    

;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Initialize variables and set constants
;

;   Minimum window size
    tlb_minxsize = 200
    tlb_minysize = 100


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
    
    self.dataptr = ptr_new(indata, /no_copy)
    self.nrecords = nrecords
    self.has_col_headers = has_col_headers
    self.has_row_headers = has_row_headers
    self.has_col_labels = has_col_labels
    self.has_row_labels = has_row_labels
    self.col_labels = ptr_new(col_labels, /no_copy)
    self.row_labels = ptr_new(row_labels, /no_copy)

    self.con_tlb_minxsize  = tlb_minxsize
    self.con_tlb_minysize  = tlb_minysize
    self.con_tlb_maxxsize = maxtlbxsz
    self.con_tlb_maxysize = maxtlbysz
    self.con_tablefont = font
    self.con_table_default_xpix = xsize
    self.con_table_default_ypix = ysize
    self.con_table_row_major = row_major
    self.con_table_col_major = col_major

    self.stat_table_ncols = n_cols
    self.stat_table_nrows = n_rows
    self.stat_wtitle  = window_title
    self.stat_currentpath = currentpath
    
    self.flag_bg_stripes = bg_stripes
    
    self.request_list = list()


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Initialize the GUI
;
    
    self -> GUI_Init

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
;   finished initializing wmb_TableWindow object
;

    return, 1

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_TableWindow::Cleanup

    compile_opt idl2, strictarrsubs

    ptr_free, self.dataptr
    ptr_free, self.col_labels
    ptr_free, self.row_labels
    ptr_free, self.stat_table_col_widths

    wmb_destroylist, self.request_list
    
end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_TableWindow__define.pro
;
;   This is the object class definition
;
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_TableWindow__define

    compile_opt idl2, strictarrsubs

    struct = {       wmb_TableWindow,                          $
                     INHERITS IDL_Object,                      $
                                                               $
                     name                        : '',         $
                                                               $
                     wid_tlb                     : long(0),    $
                     wid_table                   : long(0),    $
                                                               $
                     dataptr                     : ptr_new(),  $
                     nrecords                    : 0ULL,       $
                     has_col_labels              : 0,          $
                     has_row_labels              : 0,          $
                     has_col_headers             : 0,          $
                     has_row_headers             : 0,          $
                     col_labels                  : ptr_new(),  $
                     row_labels                  : ptr_new(),  $
                                                               $
                     con_tlb_minxsize            : 0,          $
                     con_tlb_minysize            : 0,          $
                     con_tlb_maxxsize            : 0,          $
                     con_tlb_maxysize            : 0,          $
                     con_tablefont               : '',         $
                     con_table_default_xpix      : 0,          $
                     con_table_default_ypix      : 0,          $
                     con_table_row_major         : 0,          $
                     con_table_col_major         : 0,          $
                                                               $
                     stat_wtitle                 : '',         $
                     stat_tlb_xsize              : 0,          $
                     stat_tlb_ysize              : 0,          $
                     stat_table_scr_xsize        : 0,          $
                     stat_table_scr_ysize        : 0,          $
                     stat_table_ncols            : 0,          $
                     stat_table_nrows            : 0,          $
                     stat_table_col_widths       : ptr_new(),  $
                     stat_currentpath            : '',         $
                                                               $
                     flag_redraw_request         : 0,          $
                     flag_bg_stripes             : 0,          $
                     flag_quit                   : 0,          $
                                                               $
                     request_list                : list()      }

end

pro testtable

    inputdat = {name:'',age:1L,sex:''}
    
    inputdat = replicate(inputdat, 10)
    
    col_labels = ['Name','Age long long long header','Testing very long column headers']
    
    tmp_names = ['peter','paul','mark','luke','john', $
                 'mary','kevin','james','harold','tim']
                          
    tmp_ages = indgen(10) + 30
    
    for i = 0, 9 do begin
    
        inputdat[i].name = tmp_names[i]
        inputdat[i].age = tmp_ages[i]
        inputdat[i].sex = 'M'
        if i eq 5 then inputdat[i].sex = 'F'
    
    endfor

    new_inputdat = []
    
    for i = 0, 9 do new_inputdat = [new_inputdat, inputdat]

    clabels = ['X Pixels','Y Pixels', 'Photons per pixel']
    dat = [{xpix:0,ypix:0,opeperadu:0.0}]
    dat[0].xpix = 512
    dat[0].ypix = 512
    dat[0].opeperadu = 12.3

    otable = obj_new('wmb_TableWindow','mark2', $
                     new_inputdat, $
                     col_labels = col_labels, $
                     window_title='Employees', $
                     bg_stripes = 1)

end