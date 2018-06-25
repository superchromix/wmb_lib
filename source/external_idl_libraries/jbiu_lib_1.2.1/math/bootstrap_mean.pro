;+
; NAME:
;    BOOTSTRAP_MEAN
;
; PURPOSE:
;    Calculates the mean and a confidence limit on the mean based on
;    bootstrap resampling.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = BOOTSTRAP_MEAN(Values)
;
; INPUTS:
;    Values:  A vector of values whose mean and error is to be calculated.
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
; EXAMPLE:
;    Compares the expected error in the mean of normally-distributed values
;    to the bootstrap-determined error:
;
;    IDL> vals = RANDOMN(seed, 100)
;    IDL> vals = 2.5*RANDOMN(seed, 100)
;    IDL> PRINT, BOOTSTRAP_MEAN(vals)
;         -0.26419502    -0.014198994      0.22447498
;    IDL> PRINT, 2.5/SQRT(100)
;         0.250000
;
; OUTPUTS:
;    Returns a 3-element vector containing the lower limit, mean, and
;    upper limit.
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;-
function bootstrap_mean, values, nboot=nboot, conflimit=conflimit, $
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

nperuniq_cumul = [0,total(nperuniq, /cumulative, /int)]

mix = long(randomu(seed,nboot,n)*n)
bootvalues = dblarr(nboot)
for i=0L,nboot-1 do begin
  boottot = 0d
  bootnum = 0l
  mixhist = histogram(mix[i,*], omin=om, reverse_indices=mixri)
  for j=0,n_elements(mixhist)-1 do if mixhist[j] gt 0 then begin
    boottot += total(values[nperuniq_cumul[j+om] + lindgen(nperuniq[j+om])])
    bootnum += nperuniq[j+om]
  endif
  bootvalues[i] = boottot/bootnum
endfor

bootlimits = percentiles(bootvalues, conflimit=conflimit)

return, [bootlimits[0], mean(values), bootlimits[1]]

end


