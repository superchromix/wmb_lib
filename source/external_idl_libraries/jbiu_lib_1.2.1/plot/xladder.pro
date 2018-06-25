;+
; NAME:
;    XLADDER
;
; PURPOSE:
;    Creates horizontally-stacked ladder plots.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = XLADDER(NX)
;
; INPUTS:
;    NX:   Number of plots.
;
; KEYWORD PARAMETERS:
;    XRANGE:   The x-range of the plots in normalized units. Default: [0.1,0.9]
;
;    YRANGE:   The y-range of the plots in normalized units. Default: [0.1,0.9]
;
; OUTPUTS:
;    A 4xNX array containing the normalized position coordinates for each
;    plot. Result[*,N] are the normalized coordinates for plot N (going
;    from left to right).
;
; EXAMPLE:
;    ladderpos = XLADDER(2)
;    PLOT, x1, y1, POS=ladderpos[*,0]
;    PLOT, x2, y2, /NOERASE, YTICKFORMAT='(A1)', POS=ladderpos[*,1]
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;    13 June 2011   Changed to be a wrapper to XYLADDER.
;-
function xladder, nx, xrange=xr, yrange=yr, _extra=extra

return, xyladder(nx, 1, xrange=xr, yrange=yr, _extra=extra)

end
