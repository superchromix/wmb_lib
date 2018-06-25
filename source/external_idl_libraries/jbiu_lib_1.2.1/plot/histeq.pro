;+
; NAME:
;    HISTEQ
;
; PURPOSE:
;    Performs histogram equalization scaling of a 2D image.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = HISTEQ(Image)
;
; INPUTS:
;    Image:      Input image (for example, as generated with HIST_2D) containing
;                integer or byte values.
;
; KEYWORD PARAMETERS:
;    ZEROEQ:     Set this keyword to perform equalization using all pixels,
;                even those with a value of zero. Default is to ignore pixels
;                with a zero value.
;
;    MAPPING:    Optional output keyword containing a 256-element array with the
;                original values corresponding to each output value.
;
; OUTPUTS:
;    Result contains a byte-scaled image where the distribution of pixel values
;    is roughly uniform.
;
; EXAMPLE:
;    xpts = randomn(seed, 100000)
;    ypts = randomn(seed, 100000)
;    im1 = hist_2d(xpts,ypts,min1=-2,max1=2,bin1=0.05,min2=-2,max2=2,bin2=0.05)
;    im2 = histeq(im1)
;    im1 = bytscl(im1)
;    !p.multi = [0,2,2]
;    tvim, im1, xrange=[-2,2], yrange=[-2,2], title='Normal'
;    plothist, im1, title='Pixel values', bin=10
;    tvim, im2, xrange=[-2,2], yrange=[-2,2], title='Histogram-equalized'
;    plothist, im2, title='Pixel values', bin=10
;    !p.multi = 0
;
; MODIFICATION HISTORY:
;    Writen by:   Jeremy Bailin, 9 Dec 2008
;    Modified 12 Dec 2008    JB: Do not include zero values when performing
;                            eq unless /ZEROEQ is set.
;    Modified 26 Sept 2010   Adding MAPPING keyword.
;    17 June 2011        Efficiency improvement when input values
;                        are much greater than 1.
;
;-
function histeq, image, zeroeq=zeroeq, mapping=mapping

zerosp = min(image) eq 0
min_nonzero = minfinite(image)
if keyword_set(zeroeq) and zerosp then minpixval=0 else minpixval=min_nonzero

h = histogram(image, min=minpixval, omax=maximage)
s = [0,total(h, /cumulative, /integer)]
outimage = bytscl(interpol(s, findgen(maximage+2-minpixval), image))

mapping = interpol(findgen(maximage+2-minpixval), bytscl(s), bindgen(256))

return, outimage
end

