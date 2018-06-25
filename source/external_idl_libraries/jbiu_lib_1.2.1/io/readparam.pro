;+
; NAME:
;    READPARAM
;
; PURPOSE:
;    Reads in a parameter file containing "key = value" pairs.
;
; CATEGORY:
;    I/O
;
; CALLING SEQUENCE:
;    Result = READPARAM(Filename)
;
; INPUTS:
;    Filename:    Name of parameter file.
;
; OUTPUTS:
;    Returns a structure that has one element for each line in the file. The first
;    character of the file specifies the type: a for string, b for boolean,
;    i or n for integer, and d for double. # is a comment character.
;
; EXAMPLE:
;    FIXME
;
; REQUIRES:
;    Craig Markwardt's hashtable object (http://www.physics.wisc.edu/~craigm/idl/down/hashtable__define.pro).
;
; MODIFICATION HISTORY:
;    Written by: Jeremy Bailin
;    Lost in history: Was once written and then lost?!
;    23 May 2011   Re-written
;    26 May 2011   Added OBJ_DESTROY.
;-
function readparam, filename

nlines = file_lines(filename)
lines = strarr(nlines)

openr,lun,filename,/get_lun
readf,lun,lines
free_lun,lun

; create a hash table (http://www.physics.wisc.edu/~craigm/idl/down/hashtable__define.pro)
; to contain the key/value pairs
ht = obj_new('hashtable')

for i=0l,nlines-1 do begin
  ; strip out comments
  hashpos = strpos(lines[i], '#')
  if hashpos gt -1 then lines[i]=strmid(lines[i],0,hashpos+1)

  ; use stregex to see if it matches a normal line and to find the key and value
  tab=string(9b)
  rematch = stregex(lines[i], '^[ '+tab+']*([a-zA-Z0-9]+)[ '+tab+']*=[ '+tab+']*([^ '+tab+']+)', /subexpr, /extract)
  if rematch[0] ne '' then begin
    ; it matched
    case strmid(rematch[1], 0, 1) of
      'a': val=rematch[2]
      'b': val=(rematch[2] ne 0)
      'i': val=long(rematch[2])
      'n': val=long(rematch[2])
      'd': val=double(rematch[2])
    endcase
    ; add to hashtable
    ht->add, rematch[1], val
  endif
endfor

; turn the hashtable into a structure
nht = ht->count()
if nht eq 0 then message, 'No key/value pairs found in file.'
outstruct = ht->struct()
obj_destroy, ht

return, outstruct
  
end


