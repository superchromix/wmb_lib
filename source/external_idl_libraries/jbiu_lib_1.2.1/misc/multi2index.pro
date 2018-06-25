;+
; NAME:
;    MULTI2INDEX
;
; PURPOSE:
;    Translates multidimensional indices into flat indices (the inverse
;    of ARRAY_INDICES).
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    Result = MULTI2INDEX(Subscripts, Dimensions)
;
; INPUTS:
;    Subscripts:   Multidimensional indices. If Dimensions has D
;                  elements, then Subscripts is a DxQ dimensional
;                  array to translate Q sets of indices. Q may be
;                  1 (or, equivalently, missing).
;
;    Dimensions:   An array containing the length of each dimension in
;                  the multidimensional array.
;
; OUTPUTS:
;    Flat indices into an array with the given dimensions.
;
; EXAMPLE:
;    If a is an LxMxN array, the following expressions are equivalent:
;
;    a[sub1, sub2, sub3]
;    a[ multi2index([sub1, sub2, sub3], [L, M, N]) ]
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;    26 May  2010   Added /INTEGER keyword to PRODUCT and TOTAL calls.
;-
function multi2index, subscripts, dimensions

multidim = (size(subscripts, /n_dimen) eq 2)

ndimen = (size(subscripts, /dimen))[0]
if ndimen ne (size(dimensions, /dimen))[0] then message, 'Array dimensions do not match.'
if multidim then nq = (size(subscripts, /dimen))[1] else nq=1L

dvals = [1L, (product(dimensions, /cumulative, /integer))[0:ndimen-2]]
; depending on memory constraints:
if ndimen*nq ge 10000000L then begin
  flatindex = lonarr(nq)
  for d=0L,ndimen-1 do flatindex += subscripts[d,*]*dvals[d]
endif else flatindex = total( subscripts*rebin(dvals,ndimen,nq), 1, /integer)

return, long(flatindex)

end
  


