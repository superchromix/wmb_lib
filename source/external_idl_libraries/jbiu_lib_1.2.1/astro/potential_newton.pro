;+
; NAME:
;       POTENTIAL_NEWTON
;
; PURPOSE:
;       Calculates the gravitational potential from a particle distribution
;       at a list of positions.
;
; CATEGORY:
;       Astro
;
; CALLING SEQUENCE:
;       Result = POTENTIAL_NEWTON(X, Y, Z, Xpart, Ypart, Zpart, Mass)
;
; INPUTS:
;       X:     X coordinates at which to calculate potential.
;
;       Y:     Y coordinates at which to calculate potential.
;
;       Z:     Z coordinates at which to calculate potential.
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
;       LOMEM:      If /LOMEM is set then sacrifice efficiency for
;                   lower memory usage
;
; OUTPUTS:
;       This function returns the gravitational potential at each X,Y,Z position.
;       If there are NPOS positions, Result is a vector of length NPOS.
;
; EXAMPLE:
;       Calculate the gravitational potential on a line along the x-axis from
;       6 point masses placed at the vertices of a cube:
;
;       xmasspos = [-1,-1,-1,-1,1,1,1,1]
;       ymasspos = [-1,-1,1,1,-1,-1,1,1]
;       zmasspos = [-1,1,-1,1,-1,1,-1,1]
;       masses = REPLICATE(1.,8)
;       xlinepos = 0.1*FINDGEN(20)
;       ylinepos = REPLICATE(0.,20)
;       zlinepos = REPLICATE(0.,20)
;       potentials = POTENTIAL_NEWTON(xlinepos, ylinepos, zlinepos, xmasspos, ymasspos,
;         zmasspos, masses)
;
; MODIFICATION HISTORY:
;       Written by:    Jeremy Bailin
;       10 June 2008   Public release in JBIU
;
;-
function potential_newton, x, y, z, xpart, ypart, zpart, mass, $
  lengthunit=lengthunit, massunit=massunit, astro=astro_units, softening=eps, $
  lomem=lomemp

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
lengthunit=double(lengthunit)
massunit=double(massunit)


if n_elements(eps) eq 0 then eps=0
eps *= lengthunit


if keyword_set(lomemp) then begin
  potential = dblarr(npos)
  ; loop over whichever has fewer elements: positions or particles
  if npos lt npart then begin
    for i=0L,npos-1 do begin
      xdiff = double(x[i]*lengthunit - xpart*lengthunit)
      ydiff = double(y[i]*lengthunit - ypart*lengthunit)
      zdiff = double(z[i]*lengthunit - zpart*lengthunit)
      rdiff = sqrt(xdiff^2 + ydiff^2 + zdiff^2)+eps

      potential[i] = -A_G * total(mass*massunit / rdiff)
   endfor
  endif else begin
    for i=0L,npart-1 do begin
      xdiff = double(x*lengthunit - xpart[i]*lengthunit)
      ydiff = double(y*lengthunit - ypart[i]*lengthunit)
      zdiff = double(z*lengthunit - zpart[i]*lengthunit)
      rdiff = sqrt(xdiff^2 + ydiff^2 + zdiff^2)+eps

      potential += -A_G * mass[i]*massunit / rdiff
    endfor
  endelse

endif else begin  ; use as much memory as you want!
  xdiff = double(rebin(reform(x*lengthunit,npos,1),npos,npart) - $
    rebin(reform(xpart*lengthunit,1,npart),npos,npart))
  ydiff = double(rebin(reform(y*lengthunit,npos,1),npos,npart) - $
    rebin(reform(ypart*lengthunit,1,npart),npos,npart))
  zdiff = double(rebin(reform(z*lengthunit,npos,1),npos,npart) - $
    rebin(reform(zpart*lengthunit,1,npart),npos,npart))
  rdiff = sqrt(xdiff^2 + ydiff^2 + zdiff^2)+eps
  
  potential = -A_G * total(rebin(reform(mass*massunit,1,npart),npos,npart) / $
    rdiff, 2)
endelse

return, potential

end


