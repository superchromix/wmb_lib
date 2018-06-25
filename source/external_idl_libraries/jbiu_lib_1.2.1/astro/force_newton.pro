;+
; NAME:
;       FORCE_NEWTON
;
; PURPOSE:
;       Calculates the gravitational force from a particle distribution
;       at a list of positions.
;
; CATEGORY:
;       Astro
;
; CALLING SEQUENCE:
;       Result = FORCE_NEWTON(X, Y, Z, Xpart, Ypart, Zpart, Mass)
;
; INPUTS:
;       X:     X coordinates at which to calculate forces.
;
;       Y:     Y coordinates at which to calculate forces.
;
;       Z:     Z coordinates at which to calculate forces.
;
;       Xpart: X coordinates of particle positions defining the mass
;              distribution.
;
;       Ypart: Y coordinates of particle positions defining the mass
;              distribution.
;
;       Zpart: Z coordinates of particle positions defining the mass
;              distribution.
;
;       Mass:  Mass of each particle.
;
; KEYWORD PARAMETERS:
;       LENGTHUNIT: Length unit, in cm (or kpc if /ASTRO is set). Default: 1kpc.
;
;       MASSUNIT:   Mass unit, in grams (or solar masses if /ASTRO is
;                   set). Default: 1 solar mass.
;
;       SOFTENING:  Plummer softening length. Default: 0 (no softening).
;
;       ASTRO:      If /ASTRO is set then LENGTHUNIT and MASSUNIT are given
;                   in kpc and solar masses respectively, otherwise they are
;                   in CGS (Lengthunit in cm, Massunit in grams).
;
; OUTPUTS:
;       This function returns the gravitational force at each X,Y,Z position.
;       If there are NPOS positions, Result is an NPOSx3 matrix.
;
; EXAMPLE:
;       Calculate the gravitational force on a line along the x-axis from
;       6 point masses placed at the vertices of a cube:
;
;       xmasspos = [-1,-1,-1,-1,1,1,1,1]
;       ymasspos = [-1,-1,1,1,-1,-1,1,1]
;       zmasspos = [-1,1,-1,1,-1,1,-1,1]
;       masses = REPLICATE(1.,8)
;       xlinepos = 0.1*FINDGEN(20)
;       ylinepos = REPLICATE(0.,20)
;       zlinepos = REPLICATE(0.,20)
;       forces = FORCE_NEWTON(xlinepos, ylinepos, zlinepos, xmasspos, ymasspos,
;         zmasspos, masses)
;
; MODIFICATION HISTORY:
;       Written by:    Jeremy Bailin
;       10 June 2008   Public release in JBIU
;
;-
function force_newton, x, y, z, xpart, ypart, zpart, mass, $
  lengthunit=lengthunit, massunit=massunit, astro=astro_units, softening=given_eps

; copied from astroconst.idl to reduce dependencies:
A_pc = 3.08567758d18
A_msun = 1.9889d33
A_G = 6.673d-8


npart = n_elements(xpart)
npos = n_elements(x)

if n_elements(y) ne npos then message, 'X, Y, and Z must have the same number of elements.'
if n_elements(z) ne npos then message, 'X, Y, and Z must have the same number of elements.'
if n_elements(ypart) ne npart then message, 'XPART, YPART, and ZPART must have the same number of elements.'
if n_elements(zpart) ne npart then message, 'XPART, YPART, and ZPART must have the same number of elements.'
if n_elements(mass) ne npart then message, 'MASS must have the same number of elements as XPART.'



if n_elements(lengthunit) eq 0 then lengthunit=1e3*A_pc else begin
  if keyword_set(astro) then lengthunit*=1e3*A_pc
endelse
if n_elements(massunit) eq 0 then massunit=A_msun else begin
  if keyword_set(astro) then massunit*=A_msun
endelse


if n_elements(given_eps) eq 0 then eps=0. else eps=double(given_eps)
eps *= lengthunit


xdiff = double(rebin(reform(x*lengthunit,npos,1),npos,npart) - $
  rebin(reform(xpart*lengthunit,1,npart),npos,npart))
ydiff = double(rebin(reform(y*lengthunit,npos,1),npos,npart) - $
  rebin(reform(ypart*lengthunit,1,npart),npos,npart))
zdiff = double(rebin(reform(z*lengthunit,npos,1),npos,npart) - $
  rebin(reform(zpart*lengthunit,1,npart),npos,npart))
rdiff = sqrt(xdiff^2 + ydiff^2 + zdiff^2)
notitself = where(rdiff ne 0.)
xdiff[notitself] /= rdiff[notitself]
ydiff[notitself] /= rdiff[notitself]
zdiff[notitself] /= rdiff[notitself]
rdiff2 = reform(temporary(rdiff^2) + eps^2,npos,npart)

forcex = - A_G * total(reform(xdiff,npos,npart) * reform(rebin(reform(mass*massunit,1,npart),npos,npart),npos,npart) / rdiff2, 2)
forcey = - A_G * total(reform(ydiff,npos,npart) * reform(rebin(reform(mass*massunit,1,npart),npos,npart),npos,npart) / rdiff2, 2)
forcez = - A_G * total(reform(zdiff,npos,npart) * reform(rebin(reform(mass*massunit,1,npart),npos,npart),npos,npart) / rdiff2, 2)

return, [[forcex],[forcey],[forcez]]

end

