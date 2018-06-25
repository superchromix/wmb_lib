;+
; NAME:
;    JB_RGBPNG
;
; PURPOSE:
;    Turn individual image frames into an RGB PNG image file.
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    JB_RGBPNG, Filename, RImage, GImage, BImage
;
; INPUTS:
;    Filename:     Name of output .PNG file.
;
;    RImage:       2D image array to put in red channel. Assumed to be already scaled from 0-255.
;
;    GImage:       2D image array to put in green channel. Assumed to be already scaled from 0-255.
;
;    BImage:       2D image array to put in blue channel. Assumed to be already scaled from 0-255.
;
; KEYWORD PARAMETERS:
;    SCALE:        3-element array of relative scaling for R, G, and B images respectively.
;                  Default: [1,1,1]
;
;    NONLINEARITY  Scalar value of non-linearity parameter. Default: 3.
;
; OUTPUTS:
;    A .PNG file will be written with the colour image.
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin, based somewhat on DJS_RGB_MAKE.
;-
pro jb_rgbpng, filename, rimage, gimage, bimage, scale=scale, nonlinearity=nonlinearity

; check that images are 2D arrays with the same dimensions
rsize = size(rimage, /dimen)
if n_elements(rsize) ne 2 then message, 'RImage must be a 2D array.'
nx = rsize[0]
ny = rsize[1]
gsize = size(gimage, /dimen)
if n_elements(gsize) ne 2 then message, 'GImage must be a 2D array.'
if (gsize[0] ne nx) or (gsize[1] ne ny) then message, 'GImage and RImage have different sizes.'
bsize = size(bimage, /dimen)
if n_elements(bsize) ne 2 then message, 'BImage must be a 2D array.'
if (bsize[0] ne nx) or (bsize[1] ne ny) then message, 'BImage and RImage have different sizes.'

setdefaultvalue, nonlinearity, 3
setdefaultvalue, scale, [1,1,1]

; following taken from djs_rgb_make:
radius = (long(rimage) + long(gimage) + long(bimage))/(3*255.)
radius = nonlinearity * radius
radius = radius + (radius LE 0)
nonlinfac = asinh(radius) / radius

rscaled = scale[0] * rimage * nonlinfac
gscaled = scale[1] * gimage * nonlinfac
bscaled = scale[2] * bimage * nonlinfac

trueimage = bytarr(3,nx,ny)
trueimage[0,*,*] = rscaled
trueimage[1,*,*] = gscaled
trueimage[2,*,*] = bscaled
write_png, filename, trueimage

end


