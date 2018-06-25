;+
; NAME:
;    ZPHASE
;
; PURPOSE:
;    Calculates the phase angle of a complex number.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = ZPHASE(Z)
;
; INPUTS:
;    Z:    Complex number or array.
;
; OUTPUTS:
;    Result is the phase of the complex number(s) Z. Ie. if Z = A e(i phi)
;    then phi=ZPHASE(Z).
;
; EXAMPLE:
;    z = COMPLEX(1,1)
;    arg = ZPHASE(Z)
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;-
function zphase, z
 phase = atan(imaginary(z),real_part(z))
 return, phase
end
