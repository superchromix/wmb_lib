
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the wmb_ConvertToString function
;
;   The FORMATCODE keyword allows the user to specify a particular format string
;
;   NOTE: For arrays, only 1D arrays of simple types are allowed.
;
;   NOTE: For structures, lists, and hashes - these may only contain simple
;   data types and may NOT contain arrays, structures, lists, or hashes.
;   
;   NOTE: Lists may only contain elements of a single data type.
;   
;   NOTE: For lists, these will be returned with the same formatting as for
;   an array.
;   
;   NOTE: For hashes, these will be returned with the same formatting as
;   for a structure.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_ConvertToString, invalue, formatcode=formatcode, error=errchk

    compile_opt idl2, strictarrsubs
    
    chk_user_specified_format = 0
    
    if N_elements(formatcode) ne 0 then chk_user_specified_format = 1
    
    outstr = ''
    errchk = 0

    valinfo = size(invalue, /STRUCTURE)
    
    tname = valinfo.type_name
    dtype = valinfo.type
    ndim = valinfo.n_dimensions
    dimsz = valinfo.n_elements
    
    if ndim gt 1 then begin
        message, 'Only scalar values or 1D arrays are supported'
        errchk = 1
    endif
    
    if ndim eq 0 then begin
        
        ; scalar case - note that structures, hashes, etc will never 
        ; reach this section, since they report a value of 1 for n_dimensions
        
        if chk_user_specified_format eq 0 then begin
            
            formatstr = wmb_get_formatcode(invalue)

        endif else begin
            
            formatstr = formatcode
            
        endelse
        
        case dtype of
            
            0: str_invalue = 'UNDEFINED'
            8: str_invalue = 'STRUCT'
            10: str_invalue = 'POINTER'
            11: str_invalue = 'OBJREF'
            else: str_invalue = string(invalue, FORMAT=formatstr)
            
        endcase
        
    endif else begin
        
        ; this is the array case - also structures, hashes, etc will be
        ; processed in this section
        
        switch dtype of
            
            1:
            2:
            3:
            4:
            5:
            6:
            7:
            9:
            10:
            12:
            13:
            14:
            15: begin
                
                str_invalue = '['
                
                for i = 0, dimsz-1 do begin
                    
                    val = invalue[i]

                    str_invalue = str_invalue + wmb_converttostring(val, $
                                                    formatcode = formatcode)
                                  
                    if i ne dimsz-1 then str_invalue = str_invalue + ', '
                    
                endfor
                
                str_invalue = str_invalue + ']'

                break    
            end
            
            8: begin
                
                str_invalue = ''
            
                keynames = TAG_NAMES(invalue)
                nkeys = N_TAGS(invalue)
                
                if dimsz gt 1 then begin
                    message, 'Arrays of structures are not supported'
                    errchk = 1
                endif
                
                if nkeys gt 0 then begin
                
                    str_invalue = '{'
                    
                    for i = 0, nkeys-1 do begin
                    
                        sub_invalue = invalue.(i)
                        
                        str_invalue = str_invalue + strtrim(keynames[i],2)
                        str_invalue = str_invalue + ':'
                        str_invalue = str_invalue + $
                                      wmb_ConvertToString(sub_invalue, $
                                          formatcode = formatcode)
                                          
                        if i ne (nkeys-1) then str_invalue = str_invalue + ', '
                    
                    endfor
                
                    str_invalue = str_invalue + '}'
                
                endif
                
                break 
            end
            
            11: begin
                
                ; what kind of object is it?
                ; (note that this will fail if invalue is an array)
                
                sname = TYPENAME(invalue)
                
                case sname of
                
                    'HASH': begin
                        
                        ; convert the hash to a structure
                        hstruct = invalue.ToStruct()
                        str_invalue = wmb_ConvertToString(hstruct, $
                                                formatcode = formatcode)
                    
                    end
                    
                    'ORDEREDHASH': begin
                        
                        ; convert the orderedhash to a structure
                        hstruct = invalue.ToStruct()
                        str_invalue = wmb_ConvertToString(hstruct, $
                                                formatcode = formatcode)
                    
                    end
                    
                    'DICTIONARY': begin
                        
                        ; convert the dictionary to a structure
                        hstruct = invalue.ToStruct()
                        str_invalue = wmb_ConvertToString(hstruct, $
                                                formatcode = formatcode)
                    
                    end
                    
                    'LIST': begin
                    
                        ; convert the list to an array
                        larray = invalue.ToArray()
                        str_invalue = wmb_ConvertToString(larray, $
                                                formatcode = formatcode)
                    
                    end
            
                    else: str_invalue = 'OBJREF'
                    
                endcase

                break 
            end

        endswitch
        
    endelse

    str_invalue = strtrim(str_invalue,2)

    return, str_invalue

end
