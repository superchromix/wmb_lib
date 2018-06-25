;+
; NAME:
;    SAVE_PLOTSYSVARS
;
; PURPOSE:
;    Save important plotting system variables so that they can be
;    restored later using RESTORE_PLOTSYSVARS.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    SAVE_PLOTSYSVARS
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    27 Nov 2008   Released in JBIU.
;
;-
pro save_plotsysvars

common plotsysvars, charsize, charthick, xthick, ythick, thick

charsize=!p.charsize
charthick=!p.charthick
xthick=!x.thick
ythick=!y.thick
thick=!p.thick

end

