
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the wmb_ConvertToString function
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

function wmb_ConvertToString, invalue, error=errchk

    compile_opt idl2, strictarrsubs
    
    outstr = ''
    errchk = 0

    valinfo = size(invalue, /STRUCTURE)
    
    tname = valinfo.type_name
    dtype = valinfo.type
    ndim = valinfo.n_dimensions
    dim = valinfo.n_elements
    
    if ndim gt 1 then begin
        message, 'Only scalar value or 1D arrays are allowed'
        errchk = 1
    endif
    
    case dtype of
    
        0: str_invalue = 'UNDEFINED'
        
        1: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        

        2: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        3: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        4: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        5: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        6: begin
        
            if ndim eq 0 then begin
                str_invalue = strtrim(string(REAL_PART(invalue)),2) + $
                              '+i' + $
                              strtrim(string(IMAGINARY(invalue)),2)
            endif else begin
            
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(REAL_PART(val)),2) + $
                                  '+i' + $
                                  strtrim(string(IMAGINARY(val)),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            
            endelse

        end
        
        7: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        8: begin
        
            str_invalue = ''
        
            keynames = TAG_NAMES(invalue)
            nkeys = N_TAGS(invalue)
            
            if dim gt 1 then begin
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
                                  wmb_ConvertToString(sub_invalue)
                    if i ne (nkeys-1) then str_invalue = str_invalue + ','
                
                endfor
            
                str_invalue = str_invalue + '}'
            
            endif
        end
        
        9: begin
        
            if ndim eq 0 then begin
                str_invalue = strtrim(string(REAL_PART(invalue)),2) + $
                              '+i' + $
                              strtrim(string(IMAGINARY(invalue)),2)
            endif else begin
            
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(REAL_PART(val)),2) + $
                                  '+i' + $
                                  strtrim(string(IMAGINARY(val)),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            
            endelse

        end
    
        10: str_invalue = 'POINTER'
        
        11: begin
        
            ; what kind of object is it?
            ; (note that this will fail if invalue is an array)
            
            sname = TYPENAME(invalue)
            
            case sname of
            
                'HASH': begin
                    
                    ; convert the hash to a structure
                    hstruct = invalue.ToStruct()
                    str_invalue = wmb_ConvertToString(sub_invalue)
                
                end
                
                'LIST': begin
                
                    ; convert the list to an array
                    larray = invalue.ToArray()
                    str_invalue = wmb_ConvertToString(larray)
                
                end
        
                else:
                
            endcase
        end
    
        12: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
    
        13: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        14: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
        
        15: begin
        
            if ndim eq 0 then str_invalue = string(invalue) $
            else begin
                str_invalue = '['
                for i = 0, dim-1 do begin
                    val = invalue[i]
                    str_invalue = str_invalue + $
                                  strtrim(string(val),2)
                    if i ne dim-1 then str_invalue = str_invalue + ','
                endfor
                str_invalue = str_invalue + ']'
            endelse
        
        end
    
    endcase

    str_invalue = strtrim(str_invalue,2)

    return, str_invalue

end
