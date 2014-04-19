;+
; NAME:
;   WMB_CLIPBOARD_PASTE
;
; PURPOSE:
;   This function is used to copy the contents of the Windows system
;   clipboard to an IDL variable
;
; CATEGORY:
;   Utility.
;
; CALLING SEQUENCE:
;   Result = WMB_CLIPBOARD_PASTE(Outdata)
;
; INPUTS:
;   None.
;       
; OUTPUTS:
;   This function returns 1 if the copy was successful, or 0 if an error 
;   occurred.
; 
;   Outdata: Destination variable for the clipboard data.  This function 
;   returns the data stored in the clipboard as a scalar string, an array of 
;   strings, a scalar numeric value, or an array of numeric values.  Arrays 
;   may be 1D or 2D.  Numeric values may be long interger or double precision
;   data type, depending on the clipboard contents.
;   
; RESTRICTIONS:
;   This routine depends on an externally compiled library: wmb_clipboard.dll.
;   It does not handle complex numeric data types.
;
; PROCEDURE:
;   WMB_CLIPBOARD_PASTE copies the content of the clipboard to a variable and 
;   creates a string, a string array, a numeric variable (long or double), 
;   or a numeric array.
;   
;   The program will try to create an array. For this to succeed, the
;   material that is passed from the clipboard must be a tab delimited array,
;   such as produced by Excel's copy command. If the content does not have
;   this structure, the program simply returns a string. If the content is an
;   array, x will be a numerical array if all its components qualify as
;   numerical. 
;
; EXAMPLE:
; 
;   1) If the clipboard contains 'George's job is to chop wood.', then
;      rv = WMB_CLIPBOARD_PASTE(x) produces x = 'George's job is to chop wood.'
;  
;   2) If the content of the clipboard is a simple text with multiple lines
;      (copied from Notepad or Word or similar), then rv=WMB_CLIPBOARD_PASTE(x)
;      produces a string array with one entry per line of the input so each
;      line of text will be separated. 
;
;   3) If the clipboard contains an array of numbers, e.g.
;           1 -> 2 -> 3
;           4 -> 5 -> 6
;      for instance by copying these six cells from an Excel spreadsheet,
;      then rv = WMB_CLIPBOARD_PASTE(x) makes a 2x3 array of integers 
;      (or doubles, depending on the clipboard data) with the same content.  
;      The same is true if there are NaN values. So if the clipboard data was
;           1 ->  2  -> 3
;           4 -> NaN -> 6
;      then x =
;           1     2     3
;           4    NaN    6
;
;
; MODIFICATION HISTORY:
; 
;   Written by: Mark Bates, 2 September 2013. 
;   
;   Note: This program was inspired by the COPYPASTE library on the Mathworks 
;   file exchange, see http://www.mathworks.com/matlabcentral/fileexchange/28016
;-


function wmb_clipboard_paste_findlib, libpath

    ; Returns 1 if the external library is found, or 0 if not
  
    libpath = ''
  
    Help, Calls=callStack
  
    callingRoutine = (StrSplit(StrCompress(callStack[0])," ", /Extract))[0]

    thisRoutine = Routine_Info(callingRoutine, /Functions, /Source)
    
    sourcePath = thisroutine.Path
    
    root = StrMid(sourcePath, 0, $
                  StrPos(sourcePath, Path_Sep(), /Reverse_Search) + 1)
    
    myarch = !version.arch
    myos = !version.os
    
    if myos ne 'Win32' then begin
    
        msgtxt = 'Error: Only Microscoft Windows OS is supported'
        result = DIALOG_MESSAGE(msgtxt, /ERROR)
        return, 0
    
    endif
    
    case myarch of
    
        'x86_64': fname = 'wmb_clipboard_Win_x86_64.dll'
        'x86_32': fname = 'wmb_clipboard_Win_x86_32.dll'
        
        else: begin
        
            libpath = ''
            msgtxt = 'Error: Unsupported architecture'
            result = DIALOG_MESSAGE(msgtxt, /ERROR)
            return, 0
        
        end
        
    endcase
    
    libpath = root + fname
    
    if ~file_test(libpath) then begin
    
        msgtxt = 'Error: ' + fname + ' not found'
        result = DIALOG_MESSAGE(msgtxt, /ERROR)
        return, 0
        
    endif

    return, 1

end


function wmb_clipboard_paste_convert, convtype, $
                                      indata, $
                                      outdata, $
                                      n_lf, $
                                      lf_index, $
                                      line_limits, $
                                      tabpos_arr_pointers, $
                                      ncol, $
                                      nrow
    
    ; converts the data in the input byte array (string) to a 1D or 2D array
    ; of strings, doubles, or longs
    ;
    ; return value: 1 if the data conversion was successful, otherwise 0
    ;
    ; convtype = 0 : convert to a 1D array of strings (line by line)
    ;            1 : convert to a 2D array of strings (field by field)
    ;            2 : convert to a 2D array of double floating point
    ;            3 : convert to a 2D array of long integers
    ;
    ; indata is a byte array - note that for convtype 2 and 3 the linefeed
    ; characters in indata will be replaced by spaces after the function
    ; returns
    ;
    ; outdata contains the output data - this variable will be valid only 
    ; if the conversion is successful

    case convtype of 
    
        0: begin    ; convert the data to a 1D array of strings,
                    ; divided line by line
        
            tmp_out = strarr(n_lf)
        
            for i = 0L, n_lf-1 do begin
            
                spos = line_limits[0,i]
                epos = line_limits[1,i]
                
                if spos le epos then tmp_out[i] = string(indata[spos:epos]) $
                                else tmp_out[i] = ''
    
            endfor
        
            ; if there is only one element in the array, then output a 
            ; scalar string
            
            if n_lf eq 1 then tmp_out = tmp_out[0]
            outdata = temporary(tmp_out)
            return, 1
        
        end
        
        1: begin    ; convert the data to a 2D string array
            
            strdata = string(indata)
            tmp_out = strarr(ncol,nrow)
            
            ; create an index to the start position and length of 
            ; each data entry

            for i = 0L, n_lf-1 do begin
            
                spos = line_limits[0,i]
                epos = line_limits[1,i]
                
                if spos le epos then begin
                
                    if ncol eq 1 then begin
                        
                        tmp_out[0,i] = strmid(strdata,spos,epos-spos+1)
                        
                    endif else begin
                    
                        tabpos = *(tabpos_arr_pointers[i])
                        
                        dpos = [spos,tabpos+1]
                        dlen = [tabpos,epos+1] - [spos,tabpos+1]
                        
                        ; read from the string into the string array
                        
                        tmp_out[0,i] = strmid(strdata,dpos,dlen)

                    endelse
                    
                endif else begin
                
                    ; empty line
                    tmp_out[0,i] = ''
                
                endelse
            
            endfor
        
            if ncol eq 1 and nrow eq 1 then tmp_out = tmp_out[0,0]
        
            outdata = temporary(tmp_out)
        
            return, 1
        
        end
        
        2: begin    ; convert the data to double precision floating point

            tmp_fmtstr = '(' + strtrim(string(nrow*ncol),2) + 'G0, Q)'
            tmp_out = dblarr(ncol, nrow, /NOZERO)

            ; for the conversion to work, replace linefeed characters 
            ; with spaces (otherwise the READS procedure will skip entries 
            ; after the linefeeds)
        
            indata[lf_index] = 32b
            strdata = string(indata)
            
            ; if the data is not numeric, the reads statement will fail
            
            on_ioerror, num_conv_err_1
        
            read_success = 0
            chars_remaining = 0L
            
            reads, strdata, tmp_out, chars_remaining, FORMAT=tmp_fmtstr

            read_success = 1

            ; is there still data in the input stream?  if so there is a 
            ; problem with the format specification
            
            if chars_remaining gt 1 then read_success = 0
            
            num_conv_err_1: on_ioerror, NULL
        
            if ncol eq 1 and nrow eq 1 then tmp_out = tmp_out[0,0]
        
            if read_success then outdata = temporary(tmp_out)
            
            return, read_success
        
        end
        
        3: begin    ; convert the data to long integer

            tmp_fmtstr = '(' + strtrim(string(nrow*ncol),2) + 'I0, Q)'
            tmp_out = lonarr(ncol, nrow, /NOZERO)

            ; for the conversion to work, replace linefeed characters 
            ; with spaces (otherwise the READS procedure will throw an error)
        
            indata[lf_index] = 32b
            strdata = string(indata)
            
            ; if the data is not numeric, the reads statement will fail
            
            on_ioerror, num_conv_err_2
        
            read_success = 0
            chars_remaining = 0L
        
            reads, strdata, tmp_out, chars_remaining, FORMAT=tmp_fmtstr
        
            read_success = 1
            
            ; is there still data in the input stream?  if so there is a 
            ; problem with the format specification
            
            if chars_remaining gt 1 then read_success = 0
            
            num_conv_err_2: on_ioerror, NULL
        
            if ncol eq 1 and nrow eq 1 then tmp_out = tmp_out[0,0]
        
            if read_success then outdata = temporary(tmp_out)
            
            return, read_success
        
        end
    endcase
end


function wmb_clipboard_paste, outdata

    crlf_char = string([13b,10b])
    sep_char = string(9B)
    lf_char = string(10b)


    ; check for the presence of the external library

    if ~wmb_clipboard_paste_findlib(shlib) then return, 0


    ; get the data from the clipboard (a string)
    
    nb = call_external(shlib, 'wmb_test_clipboard_text')
    
    if (nb le 1L) then begin
    
        ; no CF_TEXT object found
        outdata = ''
        return, 1
        
    endif  
    
    tmpdata = bytarr(nb) 
    tmplen = nb
    
    tmp_rslt = call_external(shlib,'wmb_paste_from_clipboard',tmpdata,tmplen) 
    
    if tmp_rslt then begin
    
        outdata = ''
        return, 1
    
    endif
    
    
    ; check the length and trim the byte array if necessary
    
    if tmplen lt nb then tmpdata = temporary(tmpdata[0:tmplen-1])
    
    
    ; append final cr/lf if missing (two cases for when the data is 
    ; null terminated or not)
    
    if tmpdata[tmplen-1] eq 0b then begin
    
        if tmpdata[tmplen-3] ne 13b or tmpdata[tmplen-2] ne 10b then begin
        
            tmpdata = [temporary(tmpdata[0:tmplen-2]), 13b, 10b, 0b]
            tmplen = N_elements(tmpdata)
        
        endif
        
    endif else begin
    
        if tmpdata[tmplen-2] ne 13b or tmpdata[tmplen-1] ne 10b then begin
        
            tmpdata = [temporary(tmpdata), 13b, 10b, 0b]
            tmplen = N_elements(tmpdata)
        
        endif
    
    endelse

    
    ; find linefeeds and tabs
    
    lf_index = where(tmpdata eq 10b, n_lf)
    tab_index = where(tmpdata eq 9b, n_tab_total)
    
    
    ; find the start and end positions of each line, also counting the 
    ; number of tabs per line and the tab positions
    
    line_limits = lonarr(2,n_lf)
    tabpos_arr_pointers = ptrarr(n_lf)
    n_tab_arr = lonarr(n_lf)

    spos = 0L
    s_tab_subset = 0L
    
    for i = 0L, n_lf-1L do begin
    
        epos = lf_index[i] - 2L
        
        line_limits[0,i] = spos
        line_limits[1,i] = epos
        
        ; does the line contain tabs?  how many and what are their positions?
        
        if n_tab_total gt 0 then begin
        
            ; choose a subset of the tab_index array that contains the 
            ; tabs for this line
            
            e_tab_subset = value_locate(tab_index, epos)
            
            if s_tab_subset le e_tab_subset then begin
            
                n_tab_arr[i] = e_tab_subset - s_tab_subset + 1L
                tmp_tabpos = tab_index[s_tab_subset:e_tab_subset]
                tabpos_arr_pointers[i] = ptr_new(tmp_tabpos, /NO_COPY)
                
                ; set the new start position for the tab subset
                s_tab_subset = e_tab_subset + 1L
            
            endif else begin
            
                n_tab_arr[i] = 0L
            
            endelse
            
        endif else begin
        
            ; no tabs in clipboard data
            n_tab_arr[i] = 0L
        
        endelse
        
        ; set the next start position (account for the CR/LF)
        spos = epos + 3L
    
    endfor
    

    ; if the number of tabs on each line is equal, then the clipboard data
    ; can be treated as a rectangular array

    arr_test = n_tab_arr eq n_tab_arr[0]
    chk_one_row = n_lf eq 1
    
    if chk_one_row then chk_isarray = 1 $
                   else chk_isarray = array_equal(arr_test, 1) 
    
    if chk_isarray then begin

        ; we are treating the clipboard data as an array with the form:
        ;
        ; (data)(separator)(data)(separator)(data)
        ; (data)(separator)(data)(separator)(data)
        ; ...

        num_tabs = n_tab_arr[0]
        nrow = long(n_lf)
        ncol = num_tabs + 1
        
        ;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
        ;
        ; determine the data type and convert from string
        ;
        ; we will start by analyzing the first line of the data - test to 
        ; see if this can be converted to numeric type (double or integer)
        ; 
        ; 1. If the first line can be converted to numeric type, try to 
        ;    convert the entire array.
        ;
        ;   1a. If conversion of the entire array fails, then convert to 
        ;       a 2D string array.
        ;         
        ; 2. If the first line cannot be converted to numeric type, then 
        ;    convert the data to a 2D string array.
        ;    
        ;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
        
        ; get the first line of the data
        
        fs = line_limits[0,0]
        fe = line_limits[1,0]
        
        if fs le fe then tmp_firstrow = string(tmpdata[fs:fe]) $
                    else tmp_firstrow = ''
                    
        ; test for conversion to double
        
        testfmt = '(' + strtrim(string(ncol),2) + 'G0)'
        tmp_numdata = dblarr(ncol, /NOZERO)
        
        ; if the data is not numeric, the reads statement will fail

        on_ioerror, num_conv_err_1
        read_success = 0
        reads, tmp_firstrow, tmp_numdata, FORMAT=testfmt
        read_success = 1
        num_conv_err_1: on_ioerror, NULL
        
        firstrow_numeric = read_success
        
        ; now we know if the first row is numeric
        
        if firstrow_numeric then begin
        
            ; test for integer compatibility of the first row and
            ; for the entire array
    
            ; integer compatibility tests:
            ; 
            ; 1. is there a decimal character in the data? ('.' = 46b)
            ; 2. is there an 'e' character in the data? ('e' = 101b)
            ; 3. is there an 'E' character in the data? ('E' = 69b)
            
            tmpind = where(tmp_firstrow eq 46b or $
                           tmp_firstrow eq 101b or $
                           tmp_firstrow eq 69b, tmpcnt)
        
            firstrow_integer = tmpcnt eq 0
        
            if firstrow_integer then begin
            
                ; is the whole dataset integer compatible?
            
                tmpind = where(tmpdata eq 46b or $
                               tmpdata eq 101b or $
                               tmpdata eq 69b, tmpcnt)
            
                all_data_integer = tmpcnt eq 0
                
            endif else begin
            
                all_data_integer = 0
            
            endelse
                 
            ; attempt to convert the entire array to numeric type
            
            if all_data_integer then begin
            
                ; convert to long integer
            
                convtype = 3
            
                conv_success = wmb_clipboard_paste_convert(convtype, $
                                                           tmpdata, $
                                                           outdata, $
                                                           n_lf, $
                                                           lf_index, $
                                                           line_limits, $
                                                           tabpos_arr_pointers,$
                                                           ncol, $
                                                           nrow)

            endif else begin
            
                ; convert to double floating point
            
                convtype = 2
            
                conv_success = wmb_clipboard_paste_convert(convtype, $
                                                           tmpdata, $
                                                           outdata, $
                                                           n_lf, $
                                                           lf_index, $
                                                           line_limits, $
                                                           tabpos_arr_pointers,$
                                                           ncol, $
                                                           nrow)

            endelse
            

            ; if the array conversion failed, convert the data to a 
            ; 2D array of strings
            
            if ~conv_success then begin

                ; convert the data to a 2D string array
                
                convtype = 1
            
                conv_success = wmb_clipboard_paste_convert(convtype, $
                                                           tmpdata, $
                                                           outdata, $
                                                           n_lf, $
                                                           lf_index, $
                                                           line_limits, $
                                                           tabpos_arr_pointers,$
                                                           ncol, $
                                                           nrow)

            endif
            
        endif else begin
        
            ; the clipboard data has an array format (an equal number of 
            ; field separators on each row)
            ; 
            ; the first row of data could not be converted to numeric type
            
            ; convert to a 2D string array
                
            convtype = 1
        
            conv_success = wmb_clipboard_paste_convert(convtype, $
                                                       tmpdata, $
                                                       outdata, $
                                                       n_lf, $
                                                       lf_index, $
                                                       line_limits, $
                                                       tabpos_arr_pointers,$
                                                       ncol, $
                                                       nrow)

        endelse
        
    endif else begin
    
        ; the clipboard data cannot be treated as a 2D array (the number of 
        ; field separators on each line is not equal)

        ; return the clipboard data as a 1D array of strings, divided 
        ; line by line 

        convtype = 0
    
        conv_success = wmb_clipboard_paste_convert(convtype, $
                                                   tmpdata, $
                                                   outdata, $
                                                   n_lf, $
                                                   lf_index, $
                                                   line_limits, $
                                                   tabpos_arr_pointers,$
                                                   ncol, $
                                                   nrow)
    
    endelse

    return, conv_success
    
end


