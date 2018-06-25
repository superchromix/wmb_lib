;+
; NAME:
;    HISTOGRAM_WEIGHT
;
; PURPOSE:
;    Wrapper to the built-in HISTOGRAM function that calculates a
;    weighted histogram.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = HISTOGRAM_WEIGHT(Data)
;
; INPUTS:
;    Data:   Values whose histogram is to be taken.
;
; KEYWORD PARAMETERS:
;    WEIGHT:       A vector of the same length as Data with the weights
;                  for each data value.
;
;    BIN:          Bin width. Passed through to HISTOGRAM.
;
;    UNWEIGHTED:       Outputs the unweighted histogram.
;
;    REVERSE_INDICES:  Outputs the reverse index array.
;
;    _REF_EXTRA:   All extra keywords are passed through to HISTOGRAM.
;
; OUTPUTS:
;    The function returns a histogram where each Data value has been
;    weighted by its WEIGHT value. The return type is the same type
;    as WEIGHT.
;
; EXAMPLE:
;    IDL> values = 0.1*FINDGEN(40)
;    IDL> PRINT, HISTOGRAM_WEIGHT(values, WEIGHT=VALUES, UNWEIGHTED=plainhist)
;          4.50000      14.5000      24.5000      34.5000
;    IDL> PRINT, plainhist
;              10          10          10          10
; 
; MODIFICATION HISTORY:
;    Written by:     Jeremy Bailin
;    12 June 2008    Public release in JBIU
;    11 April 2009   Bug fix
;    8 November 2009 Bug fux for bins with no entries
;-
function histogram_weight, DATA, bin=bin, weight=weight, $
   reverse_indices=ri, unweighted=prehist, _ref_extra=histkeywords

prehist = histogram(DATA, bin=bin, _strict_extra=histkeywords, reverse_indices=ri)

histsize=size(prehist,/dimen)

outhist = replicate(weight[0],histsize)

for i=0l,n_elements(prehist)-1 do if prehist[i] gt 0 then begin
  q = ri[ri[i]:ri[i+1]-1]
  outhist[i] = total(weight[q])
endif else outhist[i]=0.

return, outhist

end

