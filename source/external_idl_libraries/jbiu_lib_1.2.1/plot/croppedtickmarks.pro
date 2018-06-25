;+
; NAME:
;    CROPPEDTICKMARKS
;
; PURPOSE:
;    This function is used as a plug-in to YTICKFORMAT that
;    crops a number to the appropriate number of digits. For example,
;    logarithmic axes might have labels 0.001, 0.01, 0.1, 1, 10.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    PLOT, X, Y, /YLOG, YTICKFORMAT='CROPPEDTICKMARKS'
;
; EXAMPLE:
;    x = [1,2,3,4]
;    y = [0.02,0.2,2,20]
;    PLOT, x, y, /YLOG, YTICKFORMAT='CROPPEDTICKMARKS'
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin, based on Paul van Delst's logticks_exp.
;    12 June 2008   Public release in JBIU
;-
FUNCTION croppedtickmarks, axis, index, value
  ; number of decimal digits:
  ndecdig = ceil(-(alog10(value))) > 0
  ; string version
  ndigitstr = string(ndecdig, format='(I0)')
  ; reformat value with the desired number of decimal places. use integers for 0
  if ndecdig eq 0 then tickmark = string(value, format='(I0)') $
    else tickmark = string(value, format='(F0.'+ndigitstr+')')

  return, tickmark
END 
