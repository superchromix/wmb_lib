;+
; NAME:
;    IS_SORTED
;
; PURPOSE:
;    Checks whether an array is already sorted.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    Result = IS_SORTED(Array)
;
; INPUTS:
;    Array:   An array to check.
;
; EXAMPLE:
;    IDL> print, is_sorted([0,10,15,25])        
;       1
;    IDL> print, is_sorted([0,15,10,25])        
;       0
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    20 May 2011   Initial writing
function is_sorted, array

return, total(abs(sort(array) - lindgen(n_elements(array))),/int) eq 0

end

