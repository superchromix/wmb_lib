;+
; NAME:
;    YLADDER
;
; PURPOSE:
;    Creates vertically-stacked ladder plots.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = YLADDER(NY)
;
; INPUTS:
;    NY:   Number of plots.
;
; KEYWORD PARAMETERS:
;    XRANGE:   The x-range of the plots in normalized units. Default: [0.1,0.9]
;
;    YRANGE:   The y-range of the plots in normalized units. Default: [0.1,0.9]
;
; OUTPUTS:
;    A 4xNY array containing the normalized position coordinates for each
;    plot. Result[*,N] are the normalized coordinates for plot N (going
;    from bottom to top).
;
; EXAMPLE:
;    ladderpos = YLADDER(2)
;    PLOT, x1, y1, POS=ladderpos[*,0]
;    PLOT, x2, y2, /NOERASE, YTICKFORMAT='(A1)', POS=ladderpos[*,1]
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;    13 June 2011   Changed to be a wrapper to XYLADDER
;    24 June 2011   Bug fix related to above change.
;-
function yladder, ny, xrange=xr, yrange=yr, _extra=extra

ladder = xyladder(1, ny, xrange=xr, yrange=yr, _extra=extra)

; reform to get rid of middle "x" ladder dimension
ladderdimen = size(ladder, /dimen)
ladder = reform(ladder, ladderdimen[0], ladderdimen[2])

return, ladder

end

