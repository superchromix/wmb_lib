;+
; NAME:
;    MM_DIST
;
; PURPOSE:
;    Converts between distance modulus m-M and distance in parsecs.
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = MM_DIST()
;
; KEYWORD PARAMETERS:
;    MM:   Input distance modulus m-M.
;
;    DIST: Input distance in parsecs.
;
; OUTPUTS:
;    If mM is specified, then Result is the distance in parsecs. If DIST
;    is specified, then Result is the distance modulus m-M.
;
; EXAMPLE:
;    Calculate distance of an object with distance modulus m-M=16.8:
;
;    distance = mM_DIST(mM=16.8)
;
;    Calculate the distance modulus of an object at 350pc:
;
;    distmod = mM_DIST(DIST=350.)
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    10 June 2008  Public release in JBIU
;-
function mM_dist, mM=mM, dist=dist

nspec=0
if keyword_set(mM) then nspec++
if keyword_set(dist) then nspec++
if nspec gt 1 then message, 'Only one of mM and DIST may be specified.'
if nspec eq 0 then message, 'Please give either mM or DIST.'

if keyword_set(mM) then begin
  return, 10^(0.2*(mM+5))  
endif else begin ; keyword_set(dist) must be true
  return, 5.*alog10(dist)-5.
endelse

end

