; docformat = 'rst'

;+
;
; :Hidden:
;-
pro calculate_matrix, info
  ; build up the linear matrix for the slopes
  comps_good = where(info.comps2use, ncomps_good)
  comps_good_ai = array_indices(info.comps2use, comps_good)
  slope_amatrix = fltarr(info.nimages, ncomps_good+1)
  slope_bmatrix = fltarr(ncomps_good+1)
  ; set a_0=1
  slope_amatrix[*,0] = [1, replicate(0, info.nimages-1)]
  slope_bmatrix[0] = 1.
  ; remaining
  ; i2 = slope i_1
  ; =>  -slope i_1 + i_2 = 0
  ; so in the matrix, i1 should be set to minus the slope, and i2 should be set to 1
  ; i1 is comps_good_ai[0,*] and i2 is comps_good_ai[1,*]
  slope_amatrix[(comps_good_ai[0,*])[*],lindgen(ncomps_good)+1] = -info.slope_comparisons[comps_good]
  slope_amatrix[(comps_good_ai[1,*])[*],lindgen(ncomps_good)+1] = 1.
  ; solve slope matrix via SVD
  svdc, slope_amatrix, w, u, v
  inverse_scale = svsol(u, w, v, slope_bmatrix)
  ; rescale so that inverse_scale[0] is identically 1.
  inverse_scale /= inverse_scale[0]

  if info.zero then begin
    ; build up the linear matrix for the zero points
    zp_amatrix = fltarr(info.nimages, ncomps_good+1)
    zp_bmatrix = fltarr(ncomps_good+1)
    ; set a_0 = 0
    zp_amatrix[*,0] = [1, replicate(0, info.nimages-1)]
    ; remaining
    ; a_1 x_1 + b_1 = a_2 x_2 + b_2
    ; x_2 = a_1/a_2 x_1 + (b_1 - b_2) / a_2
    ; Fit to x_2 = m_12 x_1 + b_12
    ; Once we know a_2: b_1 - b_2 = b_12 a_2
    ; so in the matrix, i1 should be set to 1, i2 should be set to -1
    zp_amatrix[(comps_good_ai[0,*])[*],lindgen(ncomps_good)+1] = 1.
    zp_amatrix[(comps_good_ai[1,*])[*],lindgen(ncomps_good)+1] = -1.
    zp_bmatrix[1:*] = info.zero_comparisons[comps_good] * inverse_scale[(comps_good_ai[1,*])[*]]
    ; solve zero matrix via SVD
    svdc, zp_amatrix, w, u, v
    info.msczero = svsol(u, w, v, zp_bmatrix)
  endif else info.msczero = replicate(0., info.nimages)

  ; mscscale is the inverse of inverse_scale
  info.mscscale = 1. / inverse_scale

  astrolib
  print, 'Image              MSCSCALE   MSCZERO'
  forprint, info.data.imagename[info.imri[info.imri[0:info.nimages-1]]], $
    string(info.mscscale,format='(F10.5)'), string(info.msczero,format='(F10.5)'), /nocomment
end
  


;+
;
; :Hidden:
;-
pro jbimatch_gui_cleanup, tlb
; clean up pointers
  widget_control, tlb, get_uvalue=info, /no_copy
  if n_elements(info) eq 0 then return
  ptr_free, info.in1good
  ptr_free, info.in2good
end

;+
;
; :Hidden:
;-
pro jbimatch_display_plot, info
  ; compare images i1 and i2
  in1 = info.imri[info.imri[info.i1]:info.imri[info.i1+1]-1]
  in2 = info.imri[info.imri[info.i2]:info.imri[info.i2+1]-1]

  ; find communal regions
  regmap = value_locate(info.data.region[in1], info.data.region[in2])
  regmap_good = where(info.data.region[in1[regmap]] eq info.data.region[in2])

  ; store matching values in info
  *info.in1good = in1[regmap[regmap_good]]
  *info.in2good = in2[regmap_good]

  ; title line telling how many we're at
  totnumplots = info.nimages*(info.nimages-1)/2
  title = string(info.compplotnum, totnumplots, format='(%"%0d / %0d")')

  ; plot them
  wset, info.plot_drawwidget_wid
  cgplot, xtitle=info.data.imagename[in1[0]], ytitle=info.data.imagename[in2[0]], $
    info.data.data2[*info.in1good], info.data.data2[*info.in2good], psym=1, title=title

  ; make sure button activations are right. we must be in stage 0, so only skip is active
  widget_control, info.eye_button_id, sensitive=0
  widget_control, info.computed_button_id, sensitive=0
  widget_control, info.redo_button_id, sensitive=0
  widget_control, info.skip_button_id, sensitive=1
  widget_control, info.next_button_id, sensitive=0
end 

;+
;
; :Hidden:
;-
pro jbimatch_display_approval, info
  ; compare images i1 and i2
  in1 = info.imri[info.imri[info.i1]:info.imri[info.i1+1]-1]
  in2 = info.imri[info.imri[info.i2]:info.imri[info.i2+1]-1]

  ; find communal regions
  regmap = value_locate(info.data.region[in1], info.data.region[in2])
  regmap_good = where(info.data.region[in1[regmap]] eq info.data.region[in2])

  ; store matching values in info
  *info.in1good = in1[regmap[regmap_good]]
  *info.in2good = in2[regmap_good]

  ; title line telling how many we're at
  totnumplots = info.nimages*(info.nimages-1)/2
  title = string(info.compplotnum, totnumplots, format='(%"%0d / %0d")')

  ; plot them
  fitline = [(info.msczero[info.i1]-info.msczero[info.i2])*info.mscscale[info.i2], $
    info.mscscale[info.i1]/info.mscscale[info.i2]]

  wset, info.plot_drawwidget_wid
  cgplot, xtitle=info.data.imagename[in1[0]], ytitle=info.data.imagename[in2[0]], $
    info.data.data2[*info.in1good], info.data.data2[*info.in2good], psym=1, title=title
  xax = !x.crange
  cgplot, /over, color='blue', xax, fitline[0]+fitline[1]*xax
  cgplot, /over, color='red', xax, info.zero_comparisons[info.i1,info.i2]+ $
    info.slope_comparisons[info.i1,info.i2]*xax

  al_legend, /top, /left, box=0, color=['blue','red'], ['Global fit','Selected fit'], lines=0
end 


;+
;
; :Hidden:
;-
pro drawwidget_events, event
  if event.type eq 1 then begin  ; button release
    Widget_Control, event.ID, Get_UValue=draw_info, /No_Copy
    widget_control, event.top, get_uvalue=info, /no_copy

    wset, info.plot_drawwidget_wid
    xy_data = convert_coord(event.x, event.y, /device, /to_data)

    case info.stage of
      0:begin
        draw_info.xcurs1 = xy_data[0]
        draw_info.ycurs1 = xy_data[1]
         
        wset, info.plot_drawwidget_wid
        cgplot, [draw_info.xcurs1], [draw_info.ycurs1], color='red', psym=5, /over

        info.stage = 1
        end
      1:begin
        draw_info.xcurs2 = xy_data[0]
        draw_info.ycurs2 = xy_data[1]

        wset, info.plot_drawwidget_wid
        cgplot, [draw_info.xcurs2], [draw_info.ycurs2], color='red', psym=5, /over

        ; overplot selected line.
        info.cursline = linfit([draw_info.xcurs1,draw_info.xcurs2], [draw_info.ycurs1,draw_info.ycurs2])
        xax = !x.crange
        cgplot, /over, lines=2, color='red', xax, info.cursline[0]+info.cursline[1]*xax
  
        ; select only points within 3sigma of this line for optimal fit
        maxsig = 3.
        deviation = info.data.data2[*info.in2good] - (info.cursline[0]+info.cursline[1]*info.data.data2[*info.in1good])
        sigma = stddev(deviation)
        within_maxsig = where(abs(deviation) le maxsig*sigma, nwithin_maxsig)
       
        info.computeline = robust_linefit(info.data.data2[(*info.in1good)[within_maxsig]], $
          info.data.data2[(*info.in2good)[within_maxsig]], /bisect)

        ; overplot computed fit
        cgplot, /over, color='blue', xax, info.computeline[0]+info.computeline[1]*xax
        al_legend, color=['red','blue'], lines=[2,0], ['Eye fit','Computed fit'], /top, /left, box=0

        ; advance stage and activate buttons
        info.stage = 2
        widget_control, info.eye_button_id, sensitive=1
        widget_control, info.computed_button_id, sensitive=1
        widget_control, info.redo_button_id, sensitive=1
        widget_control, info.skip_button_id, sensitive=1
        end
      else:
    endcase

    ; return info structures
    Widget_Control, event.ID, set_UValue=draw_info, /No_Copy
    widget_control, event.top, set_uvalue=info, /no_copy
  endif
end

;+
;
; :Hidden:
;-
pro i1i2_increment, info, done
  ; equivalent to these for loops:
  ; for i1=0l,nimages-2 do if imhist[i1] gt 0 then begin
  ;   for i2=i1+1,nimages-1 do if imhist[i2] gt 0 then begin
  repeat begin
    info.i2++
    if info.i2 eq info.nimages then begin
      info.i1++
      if info.i1 eq info.nimages-1 then begin
        done=1
        return
      endif
      info.i2 = info.i1+1
    endif
  endrep until info.imhist[info.i1] gt 0 and info.imhist[info.i2] gt 0
  done=0
  info.compplotnum++
end



;+
;
; :Hidden:
;-
pro leftpanel_button_events, event
  widget_control, event.top, get_uvalue=info, /no_copy

  case event.id of
    info.eye_button_id:begin
                       ; use cursline as fit
                       info.slope_comparisons[info.i1,info.i2] = info.cursline[1]
                       if info.zero then info.zero_comparisons[info.i1,info.i2] = info.cursline[0]
                       info.comps2use[info.i1,info.i2]=1
                       ; increment i1 and i2 to the next valid comparison
                       i1i2_increment, info, done
                       if done then begin
                         info.stage=3
                         break
                       endif
                       jbimatch_display_plot, info
                       end
    info.computed_button_id:begin
                       ; use computeline as fit
                       info.slope_comparisons[info.i1,info.i2] = info.computeline[1]
                       if info.zero then info.zero_comparisons[info.i1,info.i2] = info.computeline[0]
                       info.comps2use[info.i1,info.i2]=1
                       ; increment i1 and i2 to the next valid comparison
                       i1i2_increment, info, done
                       if done then begin
                         info.stage=3
                         break
                       endif
                       jbimatch_display_plot, info
                            end
    info.redo_button_id:begin
                        ; just redisplay it
                        jbimatch_display_plot, info
                        end
    info.skip_button_id:begin
                        ; increment i1 and i2 to the next valid comparison
                        i1i2_increment, info, done
                        if done then begin
                          info.stage=3
                          break
                        endif
                        jbimatch_display_plot, info
                        end
  endcase

  ; now go to stage 0 (waiting for first point) unless we're done
  if info.stage lt 3 then info.stage = 0

  ; if we're done, update button sensitivities, calculate matrix and display first approval plot
  if info.stage eq 3 then begin
    widget_control, info.eye_button_id, sensitive=0
    widget_control, info.computed_button_id, sensitive=0
    widget_control, info.redo_button_id, sensitive=0
    widget_control, info.skip_button_id, sensitive=0
    widget_control, info.next_button_id, sensitive=1
    info.i1 = 0
    info.i2 = 1
    info.compplotnum=1
    calculate_matrix, info
    jbimatch_display_approval, info
  endif

  widget_control, event.top, set_uvalue=info, /no_copy
end


;+
;
; :Hidden:
;-
pro nextbutton_events, event
  widget_control, event.top, get_uvalue=info, /no_copy

  i1i2_increment, info, done
  if done then begin
    info.stage=4
    ; create dialog asking whether to update
    update_headers = dialog_message(dialog_parent=event.top, /question, $
      'Update FITS file headers?', /default_no)
    if strupcase(update_headers) eq 'YES' then begin
      for ii=0l,info.nimages-1 do begin
        head = headfits(info.data.imagename[info.imri[info.imri[ii]]])
        sxaddpar, head, 'MSCSCALE', info.mscscale[ii]
        sxaddpar, head, 'MSCZERO', info.msczero[ii]
        modfits, info.data.imagename[info.imri[info.imri[ii]]], 0, head
      endfor
    endif

    ; and destroy the tlb - we're done!
    widget_control, event.top, /destroy
  endif else begin
    jbimatch_display_approval, info
    widget_control, event.top, set_uvalue=info, /no_copy
  endelse
end



;+
;
; :Description:
; Determines the relative scaling of different images based on the measured
; output of the IRAF task MSCIMATCH.
;
; All scalings (and optionally zero points, if /ZERO is set) will be printed to
; the screen. If the user requests it via the dialog, the MSCSCALE and MSCZERO
; keywords of the FITS files will also be modified

; :Categories:
;    Astro
;
; :Params:
;   datfile: in, required, type=string
;      Name of the datfile generated using MSCIMATCH with the "measured" keyword.
;
; :Keywords:
;   zero: in, optional, type=boolean
;      Fit zero points if /ZERO is set. Otherwise, just fit slopes.
;
; :Author:
;    Jeremy Bailin
;  
; :History:
;    14 Oct 2011   First release
;    18 Oct 2011   Turned into widget program
;    20 Oct 2011   Comments re-written, put into JBIU
;
;-
pro jbimatch, datfile, zero=zero

Catch, theError 
IF theError NE 0 THEN BEGIN 
   Catch, /Cancel 
   ok = Error_Message(Traceback=1) 
   RETURN 
ENDIF 


; template for reading Datfile, as generated by ascii_template
imatch_template = {version:1., datastart:1L, delimiter:32b, missingvalue:!values.f_nan, $
  commentsymbol:'', fieldcount:10L, fieldtypes:long([3,3,7,7,7,3,3,4,4,4]), $
  fieldnames:['imagenum','region','imagename','ra','dec','xc','yc','sky','data1','data2'], $
  fieldlocations:long([1,4,8,27,38,50,57,60,64,73]), fieldgroups:lindgen(10)}
; read in data file
data = read_ascii(datfile, template=imatch_template)
; make imagenum start at 0
data.imagenum--

nimages = max(data.imagenum)+1

; figure out which lines correspond to which images
imhist = histogram(data.imagenum, min=0, max=nimages-1, bin=1, reverse=imri)

; arrays to store relative scalings and zero points from fits
slope_comparisons = fltarr(nimages,nimages)
zero_comparisons = fltarr(nimages,nimages)
comps2use = bytarr(nimages,nimages)   ; keep track of skipped ones
mscscale = fltarr(nimages)
msczero = fltarr(nimages)
i1=0L
i2=1L
stage=0  ;0=waiting for first point, 1=waiting for second point,
  ;2=waiting for button, 3=waiting for approval next, 4=waiting for whether to update files


; create widgets:
;  main window will have left section for buttons, right section for plots
tlb = Widget_Base(row=1, Title='JBIMATCH')
; left panel is a base widget for buttons
leftpanel_basewidget_id = widget_base(tlb, column=1, event_pro='leftpanel_button_events')
eye_button_id = widget_button(leftpanel_basewidget_id, sensitive=0, value='Eye Fit')
computed_button_id = widget_button(leftpanel_basewidget_id, sensitive=0, value='Computed Fit')
redo_button_id = widget_button(leftpanel_basewidget_id, sensitive=0, value='Redo Fit')
skip_button_id = widget_button(leftpanel_basewidget_id, sensitive=1, value='Skip')
next_button_id = widget_button(leftpanel_basewidget_id, sensitive=0, value='Next', event_pro='nextbutton_events')
; right panel is a draw widget
plot_drawwidget_id = widget_draw(tlb, /button_events, xsize=500, ysize=500, event_pro='drawwidget_events')

; tlb info structure for passing information
info = { zero:keyword_set(zero), data:data, nimages:nimages, imhist:imhist, imri:imri, $
  slope_comparisons:slope_comparisons, zero_comparisons:zero_comparisons, $
  comps2use:comps2use, stage:stage, plot_drawwidget_wid:-1L, $
  eye_button_id:eye_button_id, computed_button_id:computed_button_id, $
  redo_button_id:redo_button_id, skip_button_id:skip_button_id, $
  next_button_id:next_button_id, i1:i1, i2:i2, mscscale:mscscale, $
  msczero:msczero, in1good:ptr_new(in1good), in2good:ptr_new(in2good), $
  cursline:[0.,0.], computeline:[0.,0.], compplotnum:1L }

; draw widget info structure for storing button clicks
draw_info = { xcurs1:0., ycurs1:0., xcurs2:0., ycurs2:0.}

widget_control, plot_drawwidget_id, set_uvalue=draw_info, /no_copy
  
; display widgets
widget_control, tlb, /realize

; display the first plot
Widget_Control, plot_drawwidget_id, Get_Value=plot_drawwidget_wid
info.plot_drawwidget_wid=plot_drawwidget_wid
jbimatch_display_plot, info

Widget_Control, tlb, Set_UValue=info, /No_Copy 

; start event loop
xmanager, 'jbimatch', tlb, cleanup='jbimatch_gui_cleanup'

end


