;+
; NAME:
;    RESTORE_PLOTSYSVARS
;
; PURPOSE:
;    Restore important plotting system variables that were saved
;    using SAVE_PLOTSYSVARS.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    RESTORE_PLOTSYSVARS
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    27 Nov 2008   Released in JBIU.
;
;-
pro restore_plotsysvars

common plotsysvars, charsize, charthick, xthick, ythick, thick

!p.charsize=charsize
!p.charthick=charthick
!x.thick=xthick
!y.thick=ythick
!p.thick=thick

end

