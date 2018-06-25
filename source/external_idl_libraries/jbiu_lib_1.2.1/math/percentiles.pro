;+
; NAME:
;    PERCENTILES
;
; PURPOSE:
;    Determines what range of a distribution lies within a percentile range.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = PERCENTILES(Values)
;
; INPUTS:
;   Values:  Array containing the distribution.
;
; KEYWORD PARAMETERS:
;   CONFLIMIT:  The fraction of the distribution encompassed. Default: 0.68
;
; OUTPUTS:
;   A 2-element vector of values that encompass a fraction CONFLIMIT 
;   of the distribution. For example, if CONFLIMIT=0.68 then Result gives
;   the 16th and 85th percentiles.
;
; EXAMPLE:
;    IDL> a = 0.01*FINDGEN(101)
;    IDL> PRINT, PERCENTILES(a, CONFLIMIT=0.8)
;        0.1000000     0.900000
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;-
function percentiles, values, conflimit=conflimit

n = n_elements(values)
if n_elements(conflimit) eq 0 then conflimit=0.68

lowindex = long(((1.0-conflimit)/2)*n)
highindex = n-lowindex-1
sortvalues = values[sort(values)]

return, [sortvalues[lowindex],sortvalues[highindex]]

end


