;+
; NAME:
;    SIGN
;
; PURPOSE:
;    Returns the sign of the argument.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = SIGN(X)
;
; INPUTS:
;    X:  Numerical argument (may be an array).
;
; OUTPUTS:
;    Returns 1 where X is positive, 0 where X is zero, and -1 where
;    X is negative.
;
; EXAMPLE:
;    IDL> PRINT, SIGN([-10,0,25])
;          -1       0       1
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;    13 June 2008  Re-written to omit FOR loop (thanks to Brian
;                  Larsen for the suggestion).
;-
function sign, x

result = make_array(n_elements(x), /int, value=1)
zero = where(x eq 0,nzero)
neg = where(x lt 0,nneg)
if nzero gt 0 then result[zero]=0
if nneg gt 0 then result[neg]=-1

return, result

end

