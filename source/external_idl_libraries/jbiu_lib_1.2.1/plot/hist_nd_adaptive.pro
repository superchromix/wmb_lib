;+
; NAME:
;    HIST_ND_ADAPTIVE
;
; PURPOSE:
;    Given a list of particle positions (and optional particle weights), bin sizes, and ranges,
;    creates a density image where the regions with fewer particles are sampled at larger bin sizes.
;    This can be used as a drop-in for HIST_ND_WEIGHT, but it divides by the bin area (or ND-volume).
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = HIST_ND_ADAPTIVE(V, Bin)
;
; INPUTS:
;    V:        An NDxN element array of the ND-dimensional positions of the N particles.
;
;    Bin:      Size of highest-resolution pixels in output image.
;
; KEYWORD PARAMETERS:
;    MIN:      ND-element array of minimum positions in final map. If a scalar, used for all dimensions.
;              Default is the minimum particle position in each dimension.
;
;    MAX:      ND-element array of maximum positions in final map. If a scalar, used for all dimensions.
;              Default is the maximum particle position in each dimension.
;
;    WEIGHT:   Array of weights for each particle.
;
;    LEVELMAX: Maximum number of lower-density levels to use (0=no smoothing). Default: 4.
;
;    NTHRESHOLD:   Minimum number of particles within a pixel before going to the next level. Default: 3.
;
; OUTPUTS:
;    Result contains a density map of the points. The map has its highest effective
;    resolution in the regions with the most points, but degrades to factor-of-2 lower resolutions
;    when the number of particles per pixel drops below the threshold.
;
; EXAMPLE:
;    n = 100000
;    positions = 5*randomn(seed, 2, n)
;    image = hist_nd(positions, 0.5, min=-20, max=20) * 4
;    smthimage = hist_nd_adaptive(positions, 0.5, min=-20, max=20)
;    isurface, image, zrange=[0,3], title='Original'
;    isurface, smthimage, zrange=[0,3], title='Smooth'
;
; MODIFICATION HISTORY:
;    Written by: Jeremy Bailin   20 June 2011
;
;-
function hist_nd_adaptive, v, bin, min=minrange, max=maxrange, weight=weight, $
  levelmax=levelmax, nthreshold=nthreshold

ndimen = (size(v,/dimen))[0]

setdefaultvalue, minrange, min(v, dimen=2)
setdefaultvalue, maxrange, max(v, dimen=2)
if n_elements(minrange) eq 1 then minrange=replicate(minrange, ndimen)
if n_elements(maxrange) eq 1 then maxrange=replicate(maxrange, ndimen)

setdefaultvalue, weight, 1
setdefaultvalue, levelmax, 4
setdefaultvalue, nthreshold, 3

; highest resolution map
bin_hires = double(rebin([bin],ndimen))
pixarea_hires = product(bin_hires)
hiresmap = hist_nd_weight(v, bin_hires, min=minrange, max=maxrange, $
  weight=weight, unweighted=unweighted) / pixarea_hires

for li=1L,levelmax do begin
  toofew = where(unweighted lt nthreshold, ntoofew)
  if ntoofew eq 0 then break

  li2 = 2L^li
  ; create 2d histogram of toofew bins in low-res grid
  toofew_ai = array_indices(hiresmap, toofew)
  toofew_nd = hist_nd(toofew_ai/li2, 1, min=0, max=size(hiresmap,/dimen)/li2, $
    reverse_indices=tfri)
  
  ; loop through the low-res bins and take the mean value
  for hi=0L,n_elements(toofew_nd)-1 do if toofew_nd[hi] gt 0 then begin
    these_lowres = toofew[tfri[tfri[hi]:tfri[hi+1]-1]]
    hiresmap[these_lowres] = mean( hiresmap[these_lowres] )
    unweighted[these_lowres] = total(/int, unweighted[these_lowres])
  endif
endfor


; return the hiresmap
return, hiresmap

end


