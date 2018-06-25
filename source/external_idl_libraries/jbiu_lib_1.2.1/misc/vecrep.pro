;+
; NAME:
;    VECREP
;
; PURPOSE:
;    Replicates a vector a given number of times.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    Result = VECREP(Vec, N)
;
; INPUTS:
;    Vec:           1D vector to replicate
;
;    N:             Number of times to replicate
;
; EXAMPLE:
;    IDL> a = [10,11,12]
;    IDL> print, VECREP(a,2)
;          10      11      12      10      11      12
;
; MODIFICATION HISTORY:
;    Written by Jeremy Bailin, Nov 29 2010
;-
function vecrep, vec, n

vecsize = size(vec,/dimen)

if n_elements(vecsize) gt 1 then message, 'VECREP: Vec must be a 1D vector or a scalar.'

; scalar
if vecsize[0] eq 0 then return, replicate(vec,n)

norig=vecsize[0]
return, (rebin(vec,norig,n))[*]

end

