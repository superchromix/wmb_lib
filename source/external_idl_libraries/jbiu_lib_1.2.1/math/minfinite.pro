;+
; NAME:
;    MINFINITE
;
; PURPOSE:
;    Calculate the minimum non-zero value of an array.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = MINFINITE(X, [Index])
;
; INPUTS:
;    X:    Array
;
; OPTIONAL OUTPUTS:
;    Index:  The index of the minimum value.
;
; OUTPUTS:
;    A scalar containing the minimum non-zero value of X. If there
;    are none, returns 0.
;
; EXAMPLE:
;    IDL> a = [1, 0, 2]
;    IDL> print, MINFINITE(a, i)
;           1
;    IDL> print, i
;               0
;
; MODIFICATION HISTORY:
;     Written by:    Jeremy Bailin
;     17 May 2011    Initial writing
;-
function minfinite, x, index

nonzero = where(x ne 0, nnonzero)

if nnonzero eq 0 then return, 0.
; implicit else:
minval = min(x[nonzero], minind)
index = nonzero[minind]
return, minval

end
