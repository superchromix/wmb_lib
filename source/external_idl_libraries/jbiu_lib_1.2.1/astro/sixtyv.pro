;+
; NAME:
;    SIXTYV
;
; PURPOSE:
;    Converts a vector of decimal numbers to sexigesimal (vector version of
;    SIXTY in the astronomy library).
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = SIXTY(X)
;
; INPUTS:
;    X:    One or more decimal values, in degrees or hours.
;
; OUTPUTS:
;    If X is a scalar, then Result is a 3-element vector of degrees, minutes and seconds.
;    If X is an array of length N, then result is a 3xN array.
;
; EXAMPLE:
;    IDL> print, sixtyv([90., -45.5])
;          90.0000      0.00000      0.00000
;         -45.0000      30.0000      0.00000
;
; MODIFICATION HISTORY:
;    Written by Jeremy Bailin   20 April 2011
;    Based on SIXTY in the Astronomy Users Library
;
;-
function sixtyv, x

nx = n_elements(x)

ss = abs(3600d * x)
mm = abs(60d * x)
dd = abs(x)

if size(x, /tname) eq 'DOUBLE' then result = dblarr(3,nx) else result=fltarr(3,nx)

result[0,*] = fix(dd)
result[1,*] = fix(mm - 60. * result[0,*])
result[2,*] = ss - 3600d*result[0,*] - 60d*result[1,*]

xneg = where(x lt 0., nxneg)
if nxneg gt 0 then result[0,xneg] = -result[0,xneg]

return, result

end

