;+
; NAME:
;      SHAPE_ITERATIVE
;
; PURPOSE:
;      Given a 3-dimensional distribution of points, determines the best
;      ellipsoidal shape using particles in an interatively-defined ellipsoid
;      (or ellipsoidal shell) of the same shape.
;
; CATEGORY:
;      Astro
;
; CALLING SEQUENCE:
;      Result = SHAPE_ITERATIVE(Pos, Radius)
;
; INPUTS:
;      Pos:       An Nx3 array specifying the 3d positions of the N particles
;                 that make up the mass distribution.
;
;      Radius:    Radius at which to compute the shape. For a filled ellipsoid,
;                 this is the geometric mean radius of the principal axes that
;                 define the outer limits of the ellipsoid; for an ellipsoidal shell,
;                 this is the geometric mean radius at the center of the shell.
;
; KEYWORD PARAMETERS:
;      SHELL:   Use an ellipsoidal shell rather than a filled ellipsoid. The
;               value is the width of the shell.
;
;      AXES:    An output 3x3 array containing the principal axes.
;               AXES[*,i] is the direction of the i-th principal axis.
;
;      MASSES:  An N-element vector of the mass of each point. If not
;               specified, all masses are assumed to be unity.
;
;      R2WEIGHT:  If /R2WEIGHT is specified then particles are downweighted
;                 by a factor of 1/r^2 so that all particles have equal
;                 effect regardless of radius.
;
;      FVAL:      Iterate until the axis ratios and directions of the axes
;                 vary by less than FVAL. Default is 0.001.
;
;      MAXIT:     Maximum number of iterations to allow. Default is 20.
;
;      VERBOSE:   Print information about each iteration.
;
; OUTPUTS:
;      The function returns a 3-element array containing the lengths of the
;      principal axes of the ellipse.
;
; EXAMPLE:
;      Set up a 1/r^2 ellipsoidal density distribution and find its shape.
;
;      np = 100000
;      r = 200 * randomu(seed, np)
;      ph = 2. * !pi * randomu(seed, np)
;      th = acos(randomu(seed, np))
;      x = 2. * r * cos(ph) * sin(th)
;      y = r * sin(ph) * sin(th)
;      z = 3. * r * cos(th)
;      print, shape_iterative([[x],[y],[z]], 100., axes=axes)
;      print, axes
;
; MODIFICATION HISTORY:
;      Written by:    Jeremy Bailin
;      22 July 2011   Initial release
;-
function shape_iterative, pos, radius, masses=masses, r2weight=r2weight, shell=dshell, $
  axes=evec, fval=fval, maxit=maxit, verbose=verbose

ndimen=3  ; might try to generalize to arbitrary dimensions later
np = (size(pos,/dimen))[0]

setdefaultvalue, fval, 1e-3
setdefaultvalue, maxit, 20

; for first iteration, use a sphere
evec = identity(ndimen)
axrat = replicate(1., ndimen)

; precompute some squares
if keyword_set(dshell) then begin
  inner_r2 = (radius-0.5*dshell)^2
  outer_r2 = (radius+0.5*dshell)^2
endif else outer_r2 = radius^2

; iteration 0 info statement
if keyword_set(verbose) then print, string(0, axrat, format='(%"Iteration %0d   Axis ratios: %0.3f %0.3f %0.3f")')

for itnum=1,maxit do begin
  ; save values for convergence check
  oldaxrat = axrat
  oldevec = evec    

  ; define particles that are in the current ellipsoid(al shell)
  ; first project along principal axes
  projpos = pos # evec
  ; scale axis ratios so the volume is equal to 1 and make into Nx3 array
  axscale = rebin(reform(axrat / product(axrat)^(1./ndimen), 1, ndimen), np, ndimen, /sample)
  if keyword_set(dshell) then begin
    ; use ellipsoidal shell
    use = where(between(inner_r2, total( (projpos/axscale)^2, 2), outer_r2), nuse)
  endif else begin
    ; use ellipsoidal volume
    use = where(total( (projpos/axscale)^2, 2) le outer_r2, nuse)
  endelse
  if nuse eq 0 then message, 'No usable points.'

  ; calculate the second moment tensor
  itens = inertiatens(pos[use,*], masses=masses, r2weight=r2weight)
  ; calculate eigenvalues and eigenvectors
  eval = eigenql(itens, eigenvec=evec)
  ; turn into axis ratios
  axrat = sqrt(eval/eval[0])
  
  ; info statement 
  if keyword_set(verbose) then print, string(itnum, axrat, format='(%"Iteration %0d   Axis ratios: %0.3f %0.3f %0.3f")')

  ; check for convergence
  if max(abs(axrat-oldaxrat)) lt fval and max(abs(evec-oldevec)) lt fval then break
endfor

; return axis ratios
return, axrat

end

