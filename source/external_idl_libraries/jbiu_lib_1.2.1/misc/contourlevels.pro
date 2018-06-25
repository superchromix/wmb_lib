;+
; NAME:
;    CONTOURLEVELS
;
; PURPOSE:
;    Calculates the contour level that encloses a given fraction of the data
;    in a multi-dimensional histogram.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    Result = CONTOURLEVELS(Image, Enclosedfrac)
;
; INPUTS:
;    Image:         A histogram in arbitrary dimensions, e.g. as generated
;                   with HIST_2D or HIST_ND.
;
;    Enclosedfrac:  The fraction of data points
;    
; OUTPUTS:
;    Takes an IMAGE generated using something like HIST_2D, ie. which
;    contains the number of data points that fall within the bounds of
;    each pixel, and calculates the contour levels that enclose a given
;    fraction ENCLOSEDFRAC (which can be an array) of the data points.
;    The RESULT can be passed to CONTOUR as the LEVELS= argument.
;    IMAGE may have any dimensionality desired.
;
;    Note that this errs on the side of lower contour levels that enclose
;    a larger fraction of the data. I.e. if no contour level contains exactly
;    ENCLOSEDFRAC of the data points then RESULT will be the highest contour
;    level that contains no less than ENCLOSEDFRAC of the data.
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin  (lost in time..)
;-
function contourlevels, image, enclosedfrac

imlevelhist = histogram(image, min=0, omax=maxhist, loc=imlevelloc)
cumulativepixels = total(reverse(imlevelhist*imlevelloc), /cumulative)
reverseloc = reverse(imlevelloc)
fraccumulativepixels = cumulativepixels/cumulativepixels[maxhist]
result = reverseloc[value_locate(fraccumulativepixels, enclosedfrac)]
result = result[sort(result)]

return, result

end


