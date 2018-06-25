;+
; NAME:
;    RMS
;
; PURPOSE:
;    Calculates the root-mean-square of a set of values. Extra parameters such
;    as DIMENSION are passed through to MEAN.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = RMS(X)
;
; INPUTS:
;    X:  Array of values.
;
; OUTPUTS:
;    Calculates the square root of the mean of the squares of X.
;
; EXAMPLE:
;    x = 4. * RANDOMN(seed, 10000)
;    rmsx = RMS(x)
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;    27 May 2015   Added _EXTRA to mean call
;-
function rms, X, _extra=ex

return, sqrt(mean(X^2, _strict_extra=ex))

end

