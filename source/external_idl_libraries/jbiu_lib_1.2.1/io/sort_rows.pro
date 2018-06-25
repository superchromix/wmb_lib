;+
; NAME:
;    SORT_ROWS
;
; PURPOSE:
;    This function re-sorts the rows in a CSV structure (as read
;    using READ_CSV).
;
; CATEGORY:
;    I/O
;
; CALLING SEQUENCE:
;    SORT_ROWS, A, ORDER=V
;
; INPUTS:
;    A:   A CSV structure, of the format read in using READ_CSV.
;
; KEYWORD PARAMETERS:
;
;    ORDER:   A vector of indices of the new sorted order. Must have the
;            same elements as there are rows in A.
;
; OUTPUTS:
;    A is returned in the new sort order.
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    5 Feb 2010:  Public release in JBIU
;-
pro sort_rows, a, order=v

if (max(v) ge a.nrows) or (min(v) lt 0) then message, $
  'Elements of V must be between 0 and A.NROWS-1'
if n_tags(a) ne a.ncols+2 then message, $
  'A.NCOLS is not consistent with structure of A'
if n_elements(v) ne a.nrows then message, $
  'V must have the same number of elements as there are rows in A.'

header_vars = tag_names(a)
for i=0l,n_tags(a)-1 do begin
  if header_vars[i] eq 'nrows' then continue
  if header_vars[i] eq 'ncols' then continue
  a.(i) = a.(i)[v]
endfor

end

