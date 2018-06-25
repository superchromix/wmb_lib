;+
; NAME:
;    RGBINDEX
;
; PURPOSE:
;    Translates RGB triplets into colour indices for 24-bit decomposed mode.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = RGBINDEX(R, G, B)
;
; INPUTS:
;    R:   A byte or array of bytes of red values.
;
;    G:   A byte or array of bytes of green values.
;
;    B:   A byte or array of bytes of blue values.
;
; OUTPUTS:
;    Returns the colour index or indices for 24-bit decomposed mode
;    (DEVICE, DECOMPOSED=1) corresponding to the R,G,B triplets.
;
; EXAMPLE:
;    r = [0,128,255]
;    g = [128,128,128]
;    b = [255,128,0]
;    colourarray = RGBINDEX(r, g, b)
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;-
function rgbindex, r, g, b
return, r+256L*(g+256L*b)
end

