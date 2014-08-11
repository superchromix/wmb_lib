
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the wmb_ConvertFromString function
;
;   The outputtype parameter specifies the data type that will be returned by
;   this function.  The "undefined" type may be used to automatically process
;   simple scalar types, but will not handle structures, arrays, hashes,  
;   or lists.
;
;   outputtype: undefined
;               string
;               int
;               long_int
;               float
;               double
;               complex_double
;               array
;               structure
;               hash
;               list
;            
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_ConvertFromString, invalue, outputtype, error=errchk

    compile_opt idl2, strictarrsubs
    
    outval = 0
    errchk = 0

    dtype = size(invalue, /type)
    if dtype ne 7 then message, 'Input value must be string type'
    
    instr = strtrim(invalue,2)
    
    case strlowcase(outputtype) of
    
        'undefined': begin
        
            ; test whether the string is not entirely numeric
            teststr = stregex( instr, '[^0-9.-]', /boolean )
            
            ; test whether there is a decimal point
            testdec = stregex( instr, '[.]', /boolean )
        
            if teststr then begin
            
                ; return a string
                outval = instr
            
            endif else begin
            
                if testdec then outval = double(instr) $
                           else outval = long(instr)
            
            endelse
        end
        
        'string': begin
        
            outval = instr
        
        end
        

        'int': begin    
        
            outval = fix(instr, TYPE = 2)
        
        end
        
        'long_int': begin
        
            outval = fix(instr, TYPE = 3)
        
        end
        
        'float': begin
        
            outval = fix(instr, TYPE = 4)
        
        end
        
        'double': begin
        
            outval = fix(instr, TYPE = 5)

        end
        
        'complex_double': begin
        
            ; first find the location of the '+i' in the input string
            pos = strpos(instr, '+i')
            if pos ne -1 then begin
            
                rstr = strmid(instr, 0, pos)
                istr = strmid(instr, pos+2)
                rpart = double(rstr)
                ipart = double(istr)
                outval = complex(rpart, ipart, /double)
            
            endif else begin
            
                rstr = instr
                rpart = double(rstr)
                outval = complex(rpart, /double)
            
            endelse
        end
        
        'array': begin
        
            ; check that the first and last characters of the string are [ and ]
        
            spos = strpos(instr,'[')
            epos = strpos(instr,']')
        
            if spos eq 0 and epos eq strlen(instr)-1 then begin
            
                substr = strmid(instr, 1, strlen(instr)-2)
                
                extstr = strsplit(substr, ',', /EXTRACT)
            
                dim = N_elements(extstr)
                
                outval = []
                
                for i = 0, dim-1 do begin
                
                    tmpstr = extstr[i]
                    tmpval = wmb_ConvertFromString(tmpstr,'undefined')
                    outval = [outval,tmpval]
                
                endfor
            
            endif else message, 'Misformed array string'
        
        end
        
        'structure': begin
        
            ; check that the first and last characters of the string are { and }
        
            spos = strpos(instr,'{')
            epos = strpos(instr,'}')
        
            if spos eq 0 and epos eq strlen(instr)-1 then begin
            
                substr = strmid(instr, 1, strlen(instr)-2)
                
                extstr = strsplit(substr, ',', /EXTRACT)
            
                dim = N_elements(extstr)
                
                tmp_labels = list()
                tmp_values = list()
                
                for i = 0, dim-1 do begin
                
                    tmpstr = strtrim(extstr[i],2)

                    tmpparts = strsplit(tmpstr, ':', /EXTRACT)
                    
                    tmpl = tmpparts[0]
                    tmpv = tmpparts[1]
                    
                    tmp_labels.Add, strtrim(tmpl,2)
                    tmp_values.Add, wmb_ConvertFromString(tmpv,'undefined')
                
                endfor
            
                outval = {}
                
                for i = dim-1, 0, -1 do begin
                
                    tlabel = tmp_labels[i]
                    tval = tmp_values[i]
                    
                    outval = create_struct(tlabel, tval, outval)

                endfor
            
            endif else message, 'Misformed structure string'
            
        end
        
        'hash': begin
        
            ; check that the first and last characters of the string are { and }
        
            spos = strpos(instr,'{')
            epos = strpos(instr,'}')
        
            if spos eq 0 and epos eq strlen(instr)-1 then begin
            
                substr = strmid(instr, 1, strlen(instr)-2)
                
                extstr = strsplit(substr, ',', /EXTRACT)
            
                dim = N_elements(extstr)
                
                tmp_labels = list()
                tmp_values = list()
                
                for i = 0, dim-1 do begin
                
                    tmpstr = strtrim(extstr[i],2)
                    
                    tmpparts = strsplit(tmpstr, ':', /EXTRACT)
                    
                    tmp_labels.Add, strtrim(tmpparts[0],2)
                    tmp_values.Add, wmb_ConvertFromString(tmpparts[1], $
                                                            'undefined')
                
                endfor
            
                outval = hash(tmp_labels, tmp_values)

            endif else message, 'Misformed structure string'
            
        end
    
        'list': begin
        
            ; check that the first and last characters of the string are [ and ]
        
            spos = strpos(instr,'[')
            epos = strpos(instr,']')
        
            if spos eq 0 and epos eq strlen(instr)-1 then begin
            
                substr = strmid(instr, 1, strlen(instr)-2)
                
                extstr = strsplit(substr, ',', /EXTRACT)
            
                dim = N_elements(extstr)
                
                outval = list()
                
                for i = 0, dim-1 do begin
                
                    tmpstr = extstr[i]
                    tmpval = wmb_ConvertFromString(tmpstr,'undefined')
                    outval.Add, tmpval
                
                endfor
            
            endif else message, 'Misformed list string'
        
        end
        
        else: message, 'Undefined output type'
        
    endcase

    return, outval

end
