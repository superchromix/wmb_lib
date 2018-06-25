;+
; NAME:
;    COMBIGEN
;
; PURPOSE:
;    Generates all possible combinations n-choose-k.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = COMBIGEN(N, K)
;
; INPUTS:
;    N:    Maximum number.
;
;    K:    Number of elements in each combination.
;
; OUTPUTS:
;    Returns a M x K array of all K-length combinations of numbers from 0 to N-1.
;
; EXAMPLE:
;    Generate all combinations 5-choose-3:
;
;    IDL> print, combigen(5,3)
;           0       0       0       0       0       0       1       1       1       2
;           1       1       1       2       2       3       2       2       3       3
;           2       3       4       3       4       4       3       4       4       4
;
; MODIFICATION HISTORY:
;    Written by Jeremy Bailin
;    1 April 2011   Initial writing.
;-
function combigen, n, k

if n lt 2 then message, 'N must be greater than 1.'
if k gt n then message, 'K must be less than or equal to N.'

possible_prev = indgen(n)
for vi=1l, k-1 do begin
  possible_next = indgen(n)
  ; only really possible when possible_next > possible_prev
  prevsize = size(possible_prev, /dimen)
  possible_prev = rebin(reform(possible_prev,1,prevsize), [n,prevsize], /sample)
  possible_next = rebin(possible_next, [n,prevsize], /sample)
  good = where(possible_next gt possible_prev, ngood)

  if vi eq 1 then begin
    ; set up array that answers get stored in
    result = [[possible_prev[good]],[possible_next[good]]]
  endif else begin
    ; add to result
    good_ai = array_indices(possible_prev, good)
    result = [[result[good_ai[1,*],*]], [possible_next[good]]]
  endelse

  possible_prev = possible_next[good]      
endfor

return, result

end


