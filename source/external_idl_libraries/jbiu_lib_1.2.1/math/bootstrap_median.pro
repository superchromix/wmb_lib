;+
; NAME:
;    BOOTSTRAP_MEDIAN
;
; PURPOSE:
;    Calculates the median and a confidence limit on the median based on
;    bootstrap resampling.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = BOOTSTRAP_MEDIAN(Values)
;
; INPUTS:
;    Values:  A vector of values whose median and error is to be calculated.
;
; KEYWORD PARAMETERS:
;    NBOOT:      Number of bootstrap resamplings. Default: 1000.
;
;    CONFLIMIT:  Confidence limit. Default: 0.68 (equivalent to 1sigma
;                for a normal distribution).
;
;    UNIQLIST:   If independent points are associated with more than one
;                element of Values, then they should all be included or
;                excluded together in the bootstrap resampling. In this
;                case, set UNIQLIST to the result of running UNIQ on
;                a list with the same length as Values containing the
;                unique identifier associated with each. Note that for
;                this to work, Values must be sorted in order of the
;                identifier.
;
; OUTPUTS:
;    Returns a 3-element vector containing the lower limit, median, and
;    upper limit.
;
; EXAMPLE:
;    Calculates the error in the median of 5000 values distributed normally:
;
;    IDL> vals = 2.5*RANDOMN(seed,5000)
;    IDL> PRINT, BOOTSTRAP_MEDIAN(vals) 
;         -0.25968859     -0.15505694     0.095240064
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;-
function bootstrap_median, values, nboot=nboot, conflimit=conflimit, $
  uniqlist=uniqlist

if n_elements(nboot) eq 0 then nboot=1000
if n_elements(conflimit) eq 0 then conflimit=0.68

if n_elements(uniqlist) eq 0 then begin
  n = n_elements(values)
  uniqlist = lindgen(n)
endif else begin
  n = n_elements(uniqlist)
endelse
nperuniq = uniqlist - [-1,uniqlist]

mix = long(randomu(seed,nboot,n)*n)
bootvalues = dblarr(nboot)
for i=0L,nboot-1 do begin
  undefine, allmix
  for j=0L,n-1 do begin
    if mix[i,j] gt 0 then begin
      push, allmix, lindgen(nperuniq[mix[i,j]])+total(nperuniq[0:mix[i,j]-1])
    endif else push, allmix, lindgen(nperuniq[mix[i,j]])
  endfor
  bootvalues[i] = median(values[allmix])
endfor

lowindex = long(((1.0-conflimit)/2)*nboot)
highindex = nboot-lowindex-1
bootvalues = bootvalues[sort(bootvalues)]

return, [bootvalues[lowindex],median(values),bootvalues[highindex]]

end


