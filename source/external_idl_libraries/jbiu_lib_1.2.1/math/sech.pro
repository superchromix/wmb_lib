;+
; NAME:
;    SECH
;
; PURPOSE:
;    Calculates the hyperbolic inverse cosine function (sech).
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = SECH(X)
;
; INPUTS:
;    X:   Argument to sech (may be an array).
;
; OUTPUTS:
;    1 / cosh(X)
;
; EXAMPLE:
;    IDL> PRINT, SECH(1.)
;         0.648054
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;-
function sech, x

return, 1.0/cosh(x)

end

