;+
; NAME:
;    TRUEIFY
;
; PURPOSE:
;    Turn an indexed image into an RGB-decomposed image based on the
;    current colour table.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = TRUEIFY(Image)
;
; INPUTS:
;    Image:  A 2d byte array image.
;
; OUTPUTS:
;    An RGB-decomposed version of Image based on the current colour
;    table. If Image is MxN, Result is 3xMxN.
;
; EXAMPLE:
;    image = TVRD()
;    decompimage = TRUEIFY(image)
;    WRITE_PNG, 'image.png', decompimage
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;-
function trueify, image

tvlct, rct, gct, bct, /get
imager = rct[image]
imageg = gct[image]
imageb = bct[image]

trueimage = bytarr([3,size(image,/dimen)])
trueimage[0,*,*] = imager
trueimage[1,*,*] = imageg
trueimage[2,*,*] = imageb


return, trueimage

end

