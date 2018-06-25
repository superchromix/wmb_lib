;+
; NAME:
;    HIST_ND_WEIGHT
;
; PURPOSE:
;    Wrapper to the dfanning HIST_ND function that calculates a
;    weighted multi-dimensional histogram.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = HIST_ND_WEIGHT(V, Bin)
;
; INPUTS:
;    V:   Values whose histogram is to be taken. V should be an NxP
;         array for P points in N dimensions.
;
;    Bin: Bin size. May either be a scalar, or an N-dimensional vector.
;
; KEYWORD PARAMETERS:
;    WEIGHT:       A vector of the same dimensions as V with the weights
;                  for each data value.
;
;    UNWEIGHTED:       Outputs the unweighted histogram.
;
;    REVERSE_INDICES:  Outputs the reverse index array.
;
;    _EXTRA:   All extra keywords are passed through to HIST_ND.
;
; OUTPUTS:
;    The function returns a multi-dimensional histogram where each data value
;    has been weighted by its WEIGHT value. The return type is the same type
;    as WEIGHT.
;
; EXAMPLE:
;    IDL> q = TRANSPOSE( [ [0.1*FINDGEN(40)], [0.2*FINDGEN(40)] ] )
;    IDL> PRINT, HIST_ND_WEIGHT(q, 1, WEIGHT=q, UNWEIGHTED=plainhist)
;         0.500000      0.00000      0.00000      0.00000
;          2.50000      0.00000      0.00000      0.00000
;          0.00000      4.00000      0.00000      0.00000
;          0.00000      6.50000      0.00000      0.00000
;          0.00000      0.00000      7.50000      0.00000
;          0.00000      0.00000      10.5000      0.00000
;          0.00000      0.00000      0.00000      11.0000
;          0.00000      0.00000      0.00000      14.5000
;    IDL> PRINT, plainhist
;               5           0           0           0
;               5           0           0           0
;               0           5           0           0
;               0           5           0           0
;               0           0           5           0
;               0           0           5           0
;               0           0           0           5
;               0           0           0           5
; 
; MODIFICATION HISTORY:
;    Written by:     Jeremy Bailin
;    12 June 2008    Public release in JBIU
;    17 June 2011    Bug fix for bins with no entries.
;-
function hist_nd_weight, V, BIN, $
  weight=weight, reverse_indices=ri, unweighted=prehist, _extra=histkeywords

prehist = hist_nd(V, BIN, _strict_extra=histkeywords, reverse_indices=ri)

histsize=size(prehist,/dimen)

outhist = replicate(weight[0],histsize)

for i=0l,n_elements(prehist)-1 do if prehist[i] gt 0 then begin
  q = ri[ri[i]:ri[i+1]-1]
  outhist[i] = total(weight[q])
endif else outhist[i]=0.

return, outhist

end

