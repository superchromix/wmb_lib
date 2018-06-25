;+
; NAME:
;    ATANH
;
; PURPOSE:
;    Numerically calculate the inverse of the TANH function for real
;    values.
;
; CATEGORY:
;    Math:
;
; CALLING SEQUENCE:
;    Result = ATANH(X)
;
; INPUTS:
;    X:    Argument to atanh. May be an array.
;
; OUTPUTS:
;    The arctanh of the argument. Note that because of the numerical inversion
;    method, the results will be inaccurate for input values very near 1.
;
; EXAMPLE:
;    IDL> PRINT, ATANH(TANH([0,1,2]))
;          0.00000      1.00000      2.00000
;
; MODIFICATION HISTORY:
;    Written by: Jeremy Bailin
;    27 Nov 2008 Released in JBIU
;
;-
function atanh, x

bigchi = [findgen(10000)/1000.]
tanhlookup = [tanh(bigchi)]
return, interpol(bigchi, tanhlookup, x)

end


