;+
; NAME:
;      INERTIATENS
;
; PURPOSE:
;      Calculates the 2nd moment tensor (sometimes incorrectly referred to
;      as the moment of inertia tensor) of a mass distribution specified by
;      a list of particle positions.
;
; CATEGORY:
;      Astro
;
; CALLING SEQUENCE:
;      Result = INERTIATENS(Pos)
;
; INPUTS:
;      Pos:  An Nx3 array specifying the 3d positions of the N particles
;            that make up the mass distribution.
;
; KEYWORD PARAMETERS:
;      MASSES:  An N-element vector of the mass of each point. If not
;               specified, all masses are assumed to be unity.
;
;      R2WEIGHT:  If /R2WEIGHT is specified then particles are downweighted
;                 by a factor of 1/r^2 so that all particles have equal
;                 effect regardless of radius.
;
; OUTPUTS:
;      The function returns a 3x3 symmetric array containing the 2nd moment
;      of the mass distribution tensor, i.e. Result[i,j] is the sum over each
;      particle k of MASSES[k] * Pos[k,i] * Pos[k,j].
;
; EXAMPLE:
;      Calculate the inertia tensor of 6 equal-mass points distributed on
;      the vertices of a cube:
;
;      xmasspos = [-1,-1,-1,-1,1,1,1,1]
;      ymasspos = [-1,-1,1,1,-1,-1,1,1]
;      zmasspos = [-1,1,-1,1,-1,1,-1,1]
;      itens = INERTIATENS([[xmasspos],[ymasspos],[zmasspos]])
;
; MODIFICATION HISTORY:
;      Written by:    Jeremy Bailin
;      10 June 2008   Public release in JBIU
;      22 July 2011   Bug fix for /R2WEIGHT to actually do something useful
;-
function inertiatens, pos, masses=masses, r2weight=r2weight

Itens = dblarr(3,3)

npts = (size(pos,/dimen))[0]
weights = replicate(1.0,npts)
if keyword_set(r2weight) then begin
  posnot0 = where(total(pos^2,2) ne 0., nposnot0)
  if nposnot0 gt 0 then weights[posnot0] /= total(pos^2, 2)
endif
if n_elements(masses) ne 0 then weights *= masses

for i=0,2 do begin
  for j=i,2 do begin
    Itens[i,j] = total( weights * pos[*,i] * pos[*,j] )
    Itens[j,i] = Itens[i,j]
  endfor
endfor

return, Itens

end

