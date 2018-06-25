;+
; NAME:
;    EXTRACT_ROWS
;
; PURPOSE:
;    This function extracts rows from a CSV structure (as read
;    using READ_CSV) and returns a new CSV structure.
;
; CATEGORY:
;    I/O
;
; CALLING SEQUENCE:
;    Result = EXTRACT_ROWS(A, V)
;
; INPUTS:
;    A:   A CSV structure, of the format read in using READ_CSV.
;
;    V:   A vector of indices of the rows to extract.
;
; OUTPUTS:
;    A structure of the same form as the one returned by READ_CSV
;    containing only the rows listed in V.
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    11 June 2008  Public release in JBIU
;-
function extract_rows, a, v

if (max(v) ge a.nrows) or (min(v) lt 0) then message, $
  'Elements of V must be between 0 and A.NROWS-1'
if n_tags(a) ne a.ncols+2 then message, $
  'A.NCOLS is not consistent with structure of A'
newrows = n_elements(v)

header_vars = tag_names(a)

outstruct = create_struct(header_vars[0], a.(0)[v])
for i=1,a.ncols-1 do $
  outstruct = create_struct(outstruct, header_vars[i], a.(i)[v])

outstruct = create_struct(outstruct, 'nrows', newrows, 'ncols', a.ncols)

return, outstruct

end

