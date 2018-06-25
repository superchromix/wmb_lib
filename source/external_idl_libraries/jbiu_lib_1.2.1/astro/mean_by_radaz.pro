;+
; NAME:
;    MEAN_BY_RADAZ
;
; PURPOSE:
;    Calculates the mean value of an image in bins of both radius and
;    pie slices of azimuthal angle.
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = MEAN_BY_RADAZ(Image)
;
; INPUTS:
;    Image:  2D image array.
;
; KEYWORD PARAMETERS:
;    RBIN:        Size of radial bins (in pixels). Default: 1.
;    NTHETA:      Number of azimuthal bins. Default: 8.
;    CENTER:      Pixel co-ordinate to consider the center. May be
;                 non-integer, or even off the image (as long as
;                 /CROPCIRCLE is not set). Default: Image center.
;    ROTATION:    Start the first azimuthal bin at an angle ROTATION
;                 (in radians) from the x-axis. Default: 0.
;    CROPCIRCLE:  Set this keyword to crop out the corners of
;                 the image, i.e. use only those pixels within the largest
;                 circle that is fully enclosed in the image.
;    NAN:         Set this keyword to check for NaN or Infinity when
;                 calculating the means. Any such elements are treated
;                 as missing data.
;
; OUTPUTS:
;    This function returns a structure containing the inner radii of each
;    radial bin (tagged 'RADIAL_AXIS'), the image mean within each radial
;    bin (tagged 'RADIAL_MEAN'), the starting azimuth of each azimuthal
;    bin (tagged 'AZIMUTHAL_AXIS'), and the image mean within each azimuthal
;    pie slice (tagged 'AZIMUTHAL_MEAN'). Note that azimuthal angle is
;    calculated counterclockwise starting at the x-axis (unless ROTATION
;    is specified).
;
; EXAMPLE:
;    Calculate the radial and azimuthal means of some image data, cutting
;    out the "corners" that aren't fully sampled to the same radii. Use
;    radial bins 2 pixels wide and azimuthal bins 30 degrees wide.
;
;    imagedata = dist(25,25)
;    imagemeans = MEAN_BY_RADAZ(imagedata, RBIN=2, NTHETA=12, /CROPCIRCLE)
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin, in response to a question by Andy Bohn.
;    17 June 2008   Public release in JBIU
;    18 June 2008   Fixed typo in documentation
;
;-
function mean_by_radaz, image, rbin=rbin, ntheta=ntheta, center=xy0, $
  cropcircle=cropcirclep, rotation=rotation, nan=check_for_nan

; set defaults
if n_elements(rbin) eq 0 then rbin=1.
if n_elements(ntheta) eq 0 then ntheta=8
if n_elements(rotation) eq 0 then rotation=0.

imagesize = size(image,/dimen)
if n_elements(xy0) eq 0 then xy0 = 0.5*(imagesize-1)

undefine, mean_keywords
if keyword_set(check_for_nan) then $
  augment_inherited_keywords, mean_keywords, 'NAN', 1

indeximage = array_indices(image, lindgen(n_elements(image)))
pixelradii = sqrt( (indeximage[0,*]-xy0[0])^2 + (indeximage[1,*]-xy0[1])^2 )
pixelazimuth = atan(indeximage[1,*]-xy0[1], indeximage[0,*]-xy0[0]) - rotation
; fold pixelazimuth into range 0-2pi
cirrange, pixelazimuth, /radians

; get nearest edge of image, in bin numbers
maxrad = min( [xy0+1, imagesize-xy0] ) / rbin
; calculate radial histogram
radhist = histogram(pixelradii, min=0, bin=rbin, location=radial_axis, $
  reverse_indices=radri)
; use only those within maxrad if /cropcircle is set
if keyword_set(cropcirclep) then goodpix=radri[radri[0]:radri[maxrad]-1] $
  else goodpix=lindgen(n_elements(image))
; calculate azimuthal histogram
azhist = histogram(pixelazimuth[goodpix], min=0, bin=2.*!pi/ntheta, $
  max=2.*!pi, location=azimuthal_axis, reverse_indices=azri)
azimuthal_axis += rotation
cirrange, azimuthal_axis, /radians

; create new arrays to hold the means
if keyword_set(cropcirclep) then nrad=maxrad else nrad=n_elements(radhist)-1
naz=ntheta
radial_mean = fltarr(nrad)
azimuthal_mean = fltarr(naz)

; calculate the means using the reverse indices of the histograms
; note that azimuthal one needs to be dereferenced through goodpix
for i=0l,nrad-1 do if radhist[i] gt 0 then $
  radial_mean[i] = mean(image[radri[radri[i]:radri[i+1]-1]], _extra=mean_keywords)
for i=0l,naz-1 do if azhist[i] gt 0 then $
  azimuthal_mean[i] = mean(image[goodpix[azri[azri[i]:azri[i+1]-1]]], $
  _extra=mean_keywords)

return, {radial_axis:radial_axis[0:nrad-1], radial_mean:radial_mean, $
  azimuthal_axis:azimuthal_axis[0:naz-1], azimuthal_mean:azimuthal_mean}

end


