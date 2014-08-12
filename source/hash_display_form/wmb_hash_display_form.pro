;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_hash_display_form.pro
;
;   Form widget to get a single numeric value from the user.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Event handler
;
;   Note that events generated by widgets other than the OK or Cancel buttons
;   are being ignored due to the case statement.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_hash_display_form_event, event

    compile_opt idl2, strictarrsubs

    formclose = 0

    ; get state information
    widget_control, event.top, get_uvalue=locinfoptr
    locinfo = *locinfoptr

    ; identify widget which caused the event
    widget_uname = widget_info(event.id, /UNAME)

    ; identify the event type
    event_type = tag_names(event, /STRUCTURE_NAME)

    ; get the table widget id
    table_id = locinfo.table_wid

    case widget_uname of

        'wmb_hd_table': begin
            
            ; the event originated from the table widget
            
            case event_type of
                
                'WIDGET_TABLE_CELL_SEL': begin
                    
                    ; this is a table cell select event - reset the table so
                    ; that no cells are selected
                    
                    widget_control, table_id, set_table_select = [-1,-1,-1,-1]
                    
                end
                
                else:
                
            endcase

        end

        'ok': begin

            formclose = 1

        end

        else: 

    endcase

    ; save state information
    *locinfoptr = locinfo

    ; destroy the widget hierarchy
    if formclose then widget_control, event.top, /destroy

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Cleanup procedure
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_hash_display_form_cleanup, id

    compile_opt idl2, strictarrsubs
    
    ; get state information

    widget_control, id, get_uvalue=locinfoptr
    locinfo = *locinfoptr


end




;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_hash_display_form.pro
;
;   Main procedure
;
;   Note that a modal form widget is blocking (the No_block keyword is not 
;   specified to Xmanager) and "modal", meaning it is always on top, by 
;   specifying the modal keyword at the top level base.  A modal form widget
;   MUST have a group leader specified.
;
;   This procedure creates a table widget to display the contents of a hash.
;   The hash contents are not editable.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_hash_display_form, grpleader, $
                           data_hash, $
                           wintitle = wtitle, $
                           desc_label = desc_label, $
                           col_label = col_label, $
                           labelfont = labelfont, $
                           fieldfont = fieldfont, $
                           max_ysize = max_ysize, $
                           bg_stripes = bg_stripes
                           


    compile_opt idl2, strictarrsubs

    if N_elements(wtitle) eq 0 then wtitle = 'Data'
    if N_elements(desc_label) eq 0 then desc_label = ''
    if N_elements(col_label) eq 0 then col_label = 'Value'
    if N_elements(labelfont) eq 0 then labelfont = ''
    if N_elements(fieldfont) eq 0 then fieldfont = ''
    if N_elements(bg_stripes) eq 0 then bg_stripes = 0
    if N_elements(max_ysize) eq 0 then max_ysize = 0

    if N_elements(grpleader) eq 0 then $
            message, 'Group leader must be specified'
            
    if N_elements(data_hash) eq 0 then $
            message, 'Data hash must be specified'


    ; CONVERT DATA HASH TO STRINGS AND EXTRACT KEY NAMES
    
    nrows = data_hash.Count()
    
    if nrows eq 0 then message, 'Empty data hash'
    
    datakeys = (data_hash.Keys()).ToArray()
    
    ; convert the data hash to a structure
    ; (all data will first be converted to string type)
    
    data_struct = {}
    
    for i = 0, nrows-1 do begin
    
        tmp_field = 'field' + strtrim(string(i),2)
        str_data = wmb_converttostring(data_hash[datakeys[i]])
        data_struct = create_struct(data_struct, tmp_field, str_data)
    
    endfor
    

    ; CREATE TLB

    tlb = widget_base(column=1, title=wtitle, space=5, $
                      uname='wmb_hd_tlb', xpad=5, ypad=5, $
                      /modal, /floating, GROUP_LEADER=grpleader, $
                      /base_align_center,  $
                      tlb_frame_attr = 1)


    ; CREATE DESCRIPTION LABEL

    if desc_label ne '' then begin

        desc_label_base = widget_base(tlb, row=1, /base_align_center)
                               
        labelwid = widget_label(desc_label_base, $
                                value=desc_label, $
                                font=labelfont)
        
    endif


    ; CREATE CENTER BASE AND TABLE WIDGET

    centerbase = widget_base(tlb, $
                             column=1, $
                             /base_align_center, $
                             xpad=5, $
                             uname='wmb_hd_centerbase')

    
    table_id = widget_table(centerbase, $  
                            value=data_struct, $
                            font=fieldfont, $
                            column_labels = [col_label], $
                            row_labels = datakeys, $
                            scroll = 0, $
                            ALIGNMENT = 1, $
                            /COLUMN_MAJOR, $
                            /ALL_EVENTS, $
                            uname='wmb_hd_table')


    ; CREATE THE BUTTON BASE AND THE OK BUTTON

    bxsize = 60
    bysize = bxsize / 2.3
    bbase     = widget_base(tlb, row=1, space=5, /align_center, $
                            uname='wmb_hd_buttonbase')
                            
    b_ok      = widget_button(bbase, value='OK', uname='ok', $
                              xsize=bxsize, ysize=bysize, $
                              ACCELERATOR='Return', font=fieldfont)                          


    ; SET THE TABLE TO HAVE NO CELLS SELECTED

    widget_control, table_id, set_table_select = [-1,-1,-1,-1]


    ; CENTER THE TLB ON IT'S PARENT

    wmb_center_tlb_on_parent, tlb, grpleader


    ; REALIZE THE WIDGET HIERARCHY

    Widget_Control, tlb, /Realize


    ; ADJUST THE COLUMN WIDTH AND TABLE XSIZE TO FIT THE DATA STRINGS

    cur_col_width = (widget_info(table_id, /COLUMN_WIDTHS))[0]

    pad_xpix = 10

    col_header_width = (widget_info(table_id, string_size=col_label))[0] $
                       + pad_xpix
        
    new_width = col_header_width
    
    for i = 0, nrows-1 do begin

        tmp_data = data_struct.(i)
        
        tmp_strsize = (widget_info(table_id, string_size=tmp_data))[0] $
                      + pad_xpix
        
        new_width = new_width > tmp_strsize
            
    endfor
        
    deltax = new_width - cur_col_width
        
    ; increase the size of the widget to accomodate the larger columns
    
    table_geo = widget_info(table_id, /geometry)
    cur_table_xpix = table_geo.scr_xsize
    cur_table_ypix = table_geo.scr_ysize

    new_xpix = cur_table_xpix + deltax
    
    ; on Windows systems, the table Y size is one pixel too large - 
    ; adjust this when resizing the table
    
    if !version.os eq 'Win32' then begin
    
        widget_control, table_id, scr_xsize = new_xpix, $
                                  column_widths = [new_width], $
                                  scr_ysize = cur_table_ypix-1
                                  
    endif else begin
        
        widget_control, table_id, scr_xsize = new_xpix, $
                                  column_widths = [new_width]
                                  
    endelse


    ; CREATE THE TABLE BACKGROUND STRIPES

    if bg_stripes eq 1 then begin
        
        white_bg = [255B,255B,255B]
        grey_bg = [230B,230B,230B]
        n_cols = 1
        
        tmp_bg_arr1 = bytarr(3,n_cols)
        for i = 0, n_cols-1 do tmp_bg_arr1[0,i] = white_bg
        
        tmp_bg_arr2 = bytarr(3,n_cols)
        for i = 0, n_cols-1 do tmp_bg_arr2[0,i] = grey_bg
        
        tmp_pattern = [[tmp_bg_arr1], [tmp_bg_arr2]]
        
        widget_control, table_id, BACKGROUND_COLOR=tmp_pattern
        
    endif


    ; RESIZE THE TABLE SO THAT THE TLB DOES NOT EXCEED THE MAXIMUM 
    ; SIZE SPECIFIED BY THE USER
    
    device, get_screen_size=screen_size

    yscreen = screen_size[1]
    
    if max_ysize eq 0 then max_ysize = yscreen
    
    widget_control, tlb, tlb_get_size = base_size
    table_geo = widget_info(table_id, /geometry)

    cur_tlb_ypix = base_size[1]    
    cur_table_ypix = table_geo.scr_ysize
    
    extra_y = cur_tlb_ypix - cur_table_ypix

    max_table_ypix = max_ysize - extra_y

    if cur_table_ypix gt max_table_ypix then begin
        
        ; resize the table so that the tlb will have the correct size

        widget_control, table_id, scr_ysize = cur_table_ypix < max_table_ypix
        
    endif
   
    
    ; CREATE AND STORE THE STATE INFORMATION

    local_info_struct = {table_wid: table_id}    
    locinfoptr = ptr_new(local_info_struct)

    widget_control, tlb, set_uvalue=locinfoptr


    ; MANAGE EVENTS

    xmanager, 'wmb_hash_display_form', tlb, $
              cleanup='wmb_hash_display_form_cleanup', $
              event_handler='wmb_hash_display_form_event'



    ; The form has now been closed.  Return results to the calling program.

    result = *locinfoptr
    ptr_free, locinfoptr

end


;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   test program
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro hashformtest_event, event

    compile_opt idl2, strictarrsubs

    wintitle = 'Hash contents'

    desclabel = 'These are the contents of the HASH'

    labelfont = 'Verdana*14*Bold'

    inputdat = orderedhash()

    inputdat['First property'] = 1
    inputdat['Second property'] = [1,2]
    inputdat['Third property'] = 'This is a string'
    inputdat['Fourth property'] = 14.335
    inputdat['Fifth property'] = 092834L
    inputdat['Sixth property'] = [2.3,53.2,45.2]
    inputdat['Seventh property'] = list(3,4,5)
    inputdat['Eighth property'] = {First:1,Second:2}

    
    wmb_hash_display_form, event.top, $
                           inputdat, $
                           wintitle = wtitle, $
                           desc_label = desclabel, $
                           labelfont = labelfont, $
                           max_ysize = 400, $
                           bg_stripes = 1
                           
    
end

pro hashformtest_cleanup, wid


end

pro hashformtest
   
    compile_opt idl2, strictarrsubs
    
    tlb = widget_base(col=1, space=10, xpad=50, ypad=50)

    bxsize = 60
    bysize = bxsize/2.3

    bbase     = widget_base(tlb, row=1, /align_center)
    b_ok      = widget_button(bbase, value='OK', uname='ok', $
                              xsize=bxsize, ysize=bysize, $
                              ACCELERATOR='Return')                          
          
    cgcentertlb, tlb   
    Widget_Control, tlb, /Realize
    XManager, 'hashformtest', tlb, /No_Block, CLEANUP = 'hashformtest_cleanup'
    
end





