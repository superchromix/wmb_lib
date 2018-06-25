;+
; NAME:
;    JBBILATERALFILTER
;
; PURPOSE:
;    Implements the bilateral filter on an image.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;   Result = JBBILATERALFILTER(Image, Sigma_Space, Sigma_Range)
;
; INPUTS:
;   Image:        2D array to be filtered.
;
;   Sigma_Space:  Gaussian width in the spatial dimensions.
;
;   Sigma_Range:  Gaussian width in the intensity dimension.
;
; PROCEDURE:
;   Uses the Paris & Durand (2006) algorithm. Note that there is heavy
;   memory optimization because the application it was written for runs
;   it on extremely large images.
;
; MODIFICATION HISTORY:
;   Original release by Jeremy Bailin, 3 Dec 2012
;   Bug fixes (floating point locations for
;     trilinear interpolation, /edge_zero
;     instead of /edge_truncate) and improved documentation 4 Dec 2012
;   Added lots of TEMPORARY and SHRINKINTTYPE calls to improve memory usage   6 Dec 2012
;
;- 
function jbbilateralfilter, image, sigma_space, sigma_range

; Number of sigmas at which to truncate Gaussian. Should be an integer
; so that the number of elements in the kernel is an integer!
truncate = 2

; dimensions of original image and of downsampled image
originalimagedimen = size(image, /dimen)
downimagedimen = ceil(originalimagedimen / float(sigma_space))

; range of intensity values
intensityrange = minmax(image)

; "down" variables refer to downsampled versions
downintensityrange = ceil( (intensityrange-intensityrange[0])/sigma_range )
intensitydimen=(downintensityrange[1]-downintensityrange[0])+1

; dimensions of downsampled 3d arrays
dimen3d = [downimagedimen,intensitydimen]
ndownimage = product(/int, downimagedimen)

; calculated downsampled intensity, both the real value and a rounded integer
; to determine where in the 3D grid it goes
downintensity = round( (image-intensityrange[0])/float(sigma_range) )
shrinkinttype, downintensity
; calculated downsampled xy positions, both the real value and rounded integers
; to determine where in the 3D grid it goes
downxy_float = array_indices(originalimagedimen, lindgen(originalimagedimen), /dimen) / $
  float(sigma_space)
downx = reform(round(downxy_float[0,*]))
shrinkinttype, downx
downy = reform(round(downxy_float[1,*]))
shrinkinttype, downy
; construct a 1D index into the downsampled 3D array using the rounded integers
indices3d = temporary(downx) + temporary(downy)*downimagedimen[0] + $
  temporary(downintensity)*ndownimage
shrinkinttype, indices3d

; Note that the use of the "homogeneous vector" (wi,w) is not very well
; explained in the Paris & Durand papers. The easiest way to think about it
; is that the weights tell you how many full-resolution pixels get placed into
; each low-resolution grid spacing. This is initially an integer, but
; becomes a real floating point weight after convolution.
downwi = fltarr(dimen3d)
downw = fltarr(dimen3d)
; accumulate all of the wi's and w's in the downsampled 3D grid using the standard
; double histogram technique. see the drizzling/chunking page.
h1 = histogram(indices3d, reverse_indices=ri1, omin=om)
shrinkinttype, ri1  ; not likely to help, but can't hurt
h2 = histogram(h1, reverse_indices=ri2, min=1)
; cases without duplication
if h2[0] gt 0 then begin
  vec_inds = ri2[ri2[0]:ri2[1]-1]
  downw[om+vec_inds] = 1.
  downwi[om+vec_inds] = image[ri1[ri1[vec_inds]]]
endif
; cases duplicated j+1 times (+1 because min=1 in the definition of h2)
for j=1,n_elements(h2)-1 do if h2[j] gt 0 then begin
  vec_inds = ri2[ri2[j]:ri2[j+1]-1]  ; indices into h1
  vinds = om + vec_inds
  shrinkinttype, vinds
  ; originals plus the following j values because we add lindgen(j+1)
  vec_inds = rebin(ri1[vec_inds], h2[j], j+1, /sample) + $
    rebin(transpose(lindgen(j+1)), h2[j], j+1, /sample)
  shrinkinttype, vec_inds
  ; the weight by definition is j+1 because these indices were repeated j+1 times
  downw[vinds] = j+1
  downwi[vinds] += total(image[ri1[vec_inds]], 2)
endif


; convolve with the 3D Gaussian using CONVOL. Because the
; kernel is separable, we can do 3 separate 1D convolutions,
; which is much faster than via FFT because of the
; compactness of the kernel (when truncated).
nkernel = 2*truncate+1
kernelaxis = findgen(nkernel)-truncate
kernel1d = exp(-0.5*kernelaxis^2.) / sqrt(2.*!pi)
; convolve in each dimension in turn. The reforms turn the 1D kernel
; along each dimension.
downwiconvol_1 = convol(temporary(downwi), reform(kernel1d,nkernel,1,1), /center, /edge_zero)
downwconvol_1 = convol(temporary(downw), reform(kernel1d,nkernel,1,1), /center, /edge_zero)
downwiconvol_2 = convol(temporary(downwiconvol_1), reform(kernel1d,1,nkernel,1), /center, /edge_zero)
downwconvol_2 = convol(temporary(downwconvol_1), reform(kernel1d,1,nkernel,1), /center, /edge_zero)
downwiconvol = convol(temporary(downwiconvol_2), reform(kernel1d,1,1,nkernel), /center, /edge_zero)
downwconvol = convol(temporary(downwconvol_2), reform(kernel1d,1,1,nkernel), /center, /edge_zero)


; trilinearly interpolate downsampled functions
downintensity_float = (image-intensityrange[0]) / float(sigma_range)
wi = interpolate(temporary(downwiconvol), downxy_float[0,*], downxy_float[1,*], downintensity_float)
w = interpolate(temporary(downwconvol), downxy_float[0,*], downxy_float[1,*], downintensity_float)

; normalize result and restore image dimensions
filteredintensity = reform(temporary(wi)/temporary(w), originalimagedimen)

return, filteredintensity
end

