;+
; NAME:
;   WMB_CLIPBOARD_COPY
;
; PURPOSE:
;   This function is used to copy an IDL variable to the Windows system
;   clipboard.
;
; CATEGORY:
;   Utility.
;
; CALLING SEQUENCE:
;   Result = WMB_CLIPBOARD_COPY(Inputdata)
;
; INPUTS:
;   Inputdata:  Data to be copied to the clipboard.  Valid datatypes for 
;   are listed below.
;       
;       Scalar string
;       
;       Scalar numeric variable
;       
;       Scalar structure containing only scalar strings and numeric variables
;       
;       Array of strings (1D or 2D)
;       
;       Array of numeric variables (1D or 2D)
;
;       Array of structures containing only scalar strings and numeric
;       variables (1D only)
;       
; OUTPUTS:
;   This function returns 1 if the copy was successful, or 0 if an error 
;   occurred.
;   
; RESTRICTIONS:
;   If using IDL 8.2 or earlier, then this routine depends on an externally 
;   compiled library: wmb_clipboard.dll.  
;   
;   This routine does not handle complex numeric data types.
;
; PROCEDURE:
;   All data is converted to string type before being copied to the clipboard.
;   When copying 1D or 2D arrays of data or structures, neighboring elements in 
;   an array or structure are separated by TAB characters.  Successive rows are 
;   separated by CR/LF characters.  Arrays of higher dimension may not be 
;   copied.
;
; EXAMPLE:
;
;       Copy an array of numeric data to the system clipboard, in a 
;       format which could later be pasted into Microsoft Excel, for example.
;
;       mydata = [1,2,3,4,5]
;       WMB_CLIPBOARD_COPY, mydata
;
;       This pushes '1 -> 2 -> 3 -> 4 -> 5' to the clipboard 
;       (where -> indicates a TAB character).
;
; MODIFICATION HISTORY:
; 
;   Written by: Mark Bates, 15 August 2013. 
;   
;   Updated to use the Clipboard.Set() and Clipboard.Get() routines
;   introduced in IDL 8.3.  MB, 5 August 2014.
;-


function wmb_clipboard_copy_findlib, libpath

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


function wmb_clipboard_copy_getformatcode, x

    chktype = size(x,/TYPE)
    
    outstr = 'A'
    
    case chktype of
    
        0: 
        1: outstr = 'I0'
        2: outstr = 'I0'
        3: outstr = 'I0'
        
        4: outstr = 'G0'

        5: outstr = 'G0'
        6: 
        7: outstr = 'A'
        8: 
        9: 
        10: 
        11: 
        12: outstr = 'I0'
        13: outstr = 'I0'
        14: outstr = 'I0'
        15: outstr = 'I0'

    end

    return, outstr
    
end


function wmb_clipboard_copy, indata, force_dll = force_dll

    if N_elements(force_dll) eq 0 then force_dll = 0


    ; what version of IDL is running?
    
    ver = float(!version.release)
    
    if ver lt 8.3 or force_dll eq 1 then begin

        ; we will use the external DLL to perform the copy
    
        use_dlm = 1
        if ~wmb_clipboard_copy_findlib(shlib) then return, 0
        
    endif else begin
        
        ; we will use IDL's internal clipboard routine
        
        use_dlm = 0
        
    endelse


    crlf_char = string([13b,10b])
    sep_char = string(9B)

    ; check that the data is there
    
    if N_elements(indata) eq 0 then return, 0
    
    ; determine the datatype

    chktype = size(indata,/TYPE)
    
    chk_struct = chktype eq 8
    chk_arr = N_elements(indata) gt 1
    
    data_ndim = size(indata,/N_dimensions)
    data_dims = size(indata,/dimensions)
        
    ; a 1D array of structs is allowed, otherwise a 1D or 2D array is allowed
    
    if chk_struct then if data_ndim gt 1 then return, 0 $
                  else if data_ndim gt 2 then return, 0
        
        
    if chk_struct then begin
    
        n_struct_tags = n_tags(indata[0])
        n_rows = n_elements(indata)
    
        ; build a format code for conversion to string type
        
        fmtcode = '(' + string(n_rows,format='(I0)') + '('
        firstrow = indata[0]
        
        for i = 0, n_struct_tags-1 do begin
        
            tmpdat = firstrow.(i)
            
            ; verify that the structure member is a scalar
            tmpdat_ndim = size(tmpdat,/N_dimensions)
            if tmpdat_ndim ne 0 then return, 0
            
            tmpfc = wmb_clipboard_copy_getformatcode(tmpdat)
            
            if i ne n_struct_tags-1 then begin
            
                fmtcode = fmtcode + tmpfc + ',"'+sep_char+'",'
                
            endif else begin
            
                fmtcode = fmtcode + tmpfc + ',:,"'+crlf_char+'"))'
            
            endelse
            
        endfor

    endif else begin
    
        if chk_arr then begin
        
            case data_ndim of
            
                1: begin
                
                    n_col = data_dims[0]
                    n_rows = 1
                
                end
                
                2: begin
            
                    n_col = data_dims[0]
                    n_rows = data_dims[1]
 
                end
                
            endcase
        
        endif else begin

            n_col = 1
            n_rows = 1

        endelse

        tmpdat = indata[0]
        tmpfc = wmb_clipboard_copy_getformatcode(tmpdat)
    
        ; build a format code for conversion to string type
    
        fmtcode = '(' + string(n_rows,format='(I0)') + '('
    
        if n_col ge 2 then begin

            fmtcode = fmtcode + string(n_col-1,format='(I0)') + '(' + $
                                tmpfc + ',:,"' + sep_char + '"),'
            
        endif

        fmtcode = fmtcode + '1(' + tmpfc + '),:,"'+crlf_char+'"))' 
    
    endelse
    
    ; convert the data to a string
    
    tmptxt = string(indata, format=fmtcode, /PRINT)
    
    
    if use_dlm then begin
    
        ; convert the string to a byte array 
        
        byttxt = bytarr(strlen(tmptxt)+1,/nozero)
        
        byttxt[0] = byte(tmptxt)
        
        ; the string must be null terminated
        
        byttxt[strlen(tmptxt)] = 0b
        
        nbytes = size(byttxt,/dimensions)
        
        if call_external(shlib, $
                         'wmb_copy_to_clipboard', $
                         temporary(byttxt), $
                         nbytes) then return, 0
        
    endif else begin
        
        Clipboard.Set, tmptxt

    endelse

    return, 1
    
end



pro wmb_clipboard_test

    testdata = lindgen(10,10000)
    
    test_time = tic('Clipboard test, internal IDL routines')
    result = wmb_clipboard_copy(testdata)
    toc, test_time
    
    test_time2 = tic('Clipboard test, external routine')
    result = wmb_clipboard_copy(testdata, /force_dll)
    toc, test_time2
    
    print, result

end
