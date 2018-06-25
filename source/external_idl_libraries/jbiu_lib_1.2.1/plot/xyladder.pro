;+
; NAME:
;    XYLADDER
;
; PURPOSE:
;    Creates horizontally- and vertically-stacked ladder plots.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    Result = XYLADDER(NX,NY)
;
; INPUTS:
;    NX:   Number of plots in the horizontal direction.
;
;    NY:   Number of plots in the vertical direction.
;
; KEYWORD PARAMETERS:
;    XRANGE:   The x-range of the plots in normalized units. Default: [0.1,0.9]
;
;    YRANGE:   The y-range of the plots in normalized units. Default: [0.1,0.9]
;
;    ISOTROPIC: If set, each panel is a square.
;
; OUTPUTS:
;    A 4xNXxNY array containing the normalized position coordinates for each
;    plot. Result[*,IX,IY] are the normalized coordinates for horizontal
;    plot IX (from left to right) and vertical plot IY (from bottom to top).
;
; EXAMPLE:
;    ladderpos = XYLADDER(2,2)
;    PLOT, x1, y1, POS=ladderpos[*,0,0]
;    PLOT, x2, y2, /NOERASE, YTICKFORMAT='(A1)', POS=ladderpos[*,1,0]
;    PLOT, x3, y3, /NOERASE, XTICKFORMAT='(A1)', POS=ladderpos[*,0,1]
;    PLOT, x4, y4, /NOERASE, XTICKFORMAT='(A1)', YTICKFORMAT='(A1)',
;       POS=ladderpos[*,1,1]
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;    13 June 2011   Added /ISTROPIC keyword
;-
function xyladder, nx, ny, xrange=xr, yrange=yr, isotropic=isotropic

if keyword_set(isotropic) then begin
  if n_elements(xr) eq 0 then xmargin = 0.1 else xmargin = max([xr[0],1.-xr[1]])
  if n_elements(yr) eq 0 then ymargin = 0.1 else ymargin = max([yr[0],1.-yr[1]])
  margin = max([xmargin,ymargin])

  position = aspect(float(ny)/float(nx), margin=min([xmargin, ymargin]))

  if n_elements(xr) gt 0 then begin
    if xr[0] gt position[0] then begin
      xshift = xr[0]-position[0]
      position[[0,2]] += xshift
    endif
    if xr[1] lt position[2] then begin
      xshift = position[2]-xr[1]
      position[[0,2]] -= xshift
    endif
  endif
  if n_elements(yr) gt 0 then begin
    if yr[0] gt position[1] then begin
      yshift = yr[0]-position[1]
      position[[1,3]] += yshift
    endif
    if yr[1] lt position[3] then begin
      yshift = position[3]-yr[1]
      position[[1,3]] -= yshift
    endif
  endif
  
endif else begin
  setdefaultvalue, xr, [0.1,0.9]
  setdefaultvalue, yr, [0.1,0.9]

  position = [xr[0], yr[0], xr[1], yr[1]]
endelse

xbot = position[0]
ybot = position[1]
xtop = position[2]
ytop = position[3]

lpos = fltarr(4,nx,ny)
for i=0,nx-1 do for j=0,ny-1 do $
  lpos[*,i,j] = [xbot + i*(xtop-xbot)/nx, ybot + j*(ytop-ybot)/ny, $
    xbot + (i+1)*(xtop-xbot)/nx, ybot + (j+1)*(ytop-ybot)/ny]

return, lpos

end

