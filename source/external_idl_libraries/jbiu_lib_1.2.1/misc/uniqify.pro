;+
; NAME:
;    UNIQIFY
;
; PURPOSE:
;    Returns the unique elements of an array.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    Result = UNIQIFY(Array)
;
; INPUTS:
;    Array:  An array whose elements are to be uniqued.
;
; MODIFICATION HISTORY:
;    Written by:  Jeremy Bailin
;    9 March 2011   Initial writing
;
;-
function uniqify, array

sortlist = sort(array)
return, array[sortlist[uniq(array[sortlist])]]

end


