;+
; NAME:
;    GETPTS
;
; PURPOSE:
;    Find the locations of a number of points on an existing plot using CURSOR.
;    Use right mouse button to mark final point.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    GETPTS, X, Y
;
; OPTIONAL OUTPUTS:
;    X:     Array of x coordinates.
;
;    Y:     Array of y coordinates.
;
; KEYWORD PARAMETERS:
;    VERBOSE:  Print out each data point as it is selected.
;
;    DATA:     Use data coordinates (default).
;
;    DEVICE:   Use device coordinates.
;
;    NORMAL:   Use normalized coordinates.
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin, 3 December 2010
;
;-
pro getpts, x, y, device=sysdevice, normal=sysnormal, data=sysdata, verbose=verbose, $
  _extra=extra

; ensure only one coordinate system is selected
nsys=0l
if keyword_set(sysdevice) then nsys++
if keyword_set(sysnormal) then nsys++
if keyword_set(sysdata) then nsys++
if nsys gt 1 then message, 'Only one of /DATA, /DEVICE and /NORMAL can be set.'
; default is /DATA
if nsys eq 0 then sysdata=1

undefine, x
undefine, y

repeat begin
  cursor, xpt, ypt, /up, data=sysdata, device=sysdevice, norm=sysnormal
  if keyword_set(verbose) then print, xpt, ypt
  push, x, xpt
  push, y, ypt
endrep until (!mouse.button and 4) gt 0  ; 4 is right mouse button

end
  
