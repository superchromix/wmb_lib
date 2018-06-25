;+
; NAME:
;    JBMAJORITYFILTER
;
; USAGE:
;    Result = JBMAJORITYFILTER(Data)
;
; INPUTS:
;    Data:   2D array to be filtered
;
; OUTPUTS:
;    Result will be the input Data with values replaced if at least half of the
;    surrounding 8 pixels (fewer for edges and corners) have a common value.
;    If the neighbours are exactly split between 4-and-4, then the choice of
;    which to use is arbitrary.
;
; MODIFICATION HISTORY:
;   Written by: Jeremy Bailin
;   7 March 2013
;
;-
function jbmajorityfilter, data

datadimen = size(data,/dimen)
newdata = data   ; this will get its values replaced

valuehist = histogram(data, omin=om, reverse_indices=ri)
nvalues = n_elements(valuehist)

; loop through the values and deal with each one independently
for vi=0l,nvalues-1 do if valuehist[vi] gt 0 then begin
  val = vi+om   ; the actual value for this histogram bin - add the minimum back in
  
  ; build a list of all neighbours-of-neighbours of each pixel. in other words, for the
  ; "up" version, it's a list of all the pixels that this one will be compared with
  ; to determine whether to replace the "up" pixel
  pix_with_this_val = ri[ri[vi]:ri[vi+1]-1]
  xy_with_this_val = array_indices(data, pix_with_this_val)  ; turn into x,y pairs

  ; look at the entire 3x3 array centered on the "up" pixel minus it itself.
  ; these will be valuehist[vi] x 7 arrays of the x and y pixels of all
  ; neighbours-of-top-neighbours (8 neighbours, but one is the current pixel).
  up_nofn_x = [xy_with_this_val[0,*]-1, xy_with_this_val[0,*], xy_with_this_val[0,*]+1, $
    xy_with_this_val[0,*]-1, xy_with_this_val[0,*]+1, $
    xy_with_this_val[0,*]-1, xy_with_this_val[0,*]+1]
  up_nofn_y = [xy_with_this_val[1,*]-2, xy_with_this_val[1,*]-2, xy_with_this_val[1,*]-2, $
    xy_with_this_val[1,*]-1, xy_with_this_val[1,*]-1, $
    xy_with_this_val[1,*], xy_with_this_val[1,*]]
  ; also figure out what the coordinates of the up neighbour are
  up_n_x = xy_with_this_val[0,*]
  up_n_y = xy_with_this_val[1,*]-1

  ; to replace the up pixel there need to be 4 neighbour pixels that are the same, ie.
  ; 3 plus the current one that have the current value.
  ; so we add up how many of up's other neighbours have the current value.
  up_majority = where(total(/int, data[up_nofn_x, up_nofn_y] eq val, 1) ge 3, nreplace)
  ; and replace the actual up pixel for those where this was true
  if nreplace gt 0 then newdata[up_n_x[up_majority], up_n_y[up_majority]] = val

  ; do the same for the "down" pixel
  down_nofn_x = [xy_with_this_val[0,*]-1, xy_with_this_val[0,*], xy_with_this_val[0,*]+1, $
    xy_with_this_val[0,*]-1, xy_with_this_val[0,*]+1, $
    xy_with_this_val[0,*]-1, xy_with_this_val[0,*]+1]
  down_nofn_y = [xy_with_this_val[1,*]+2, xy_with_this_val[1,*]+2, xy_with_this_val[1,*]+2, $
    xy_with_this_val[1,*]+1, xy_with_this_val[1,*]+1, $
    xy_with_this_val[1,*], xy_with_this_val[1,*]]
  down_n_x = xy_with_this_val[0,*]
  down_n_y = xy_with_this_val[1,*]+1
  down_majority = where(total(/int, data[down_nofn_x, down_nofn_y] eq val, 1) ge 3, nreplace)
  if nreplace gt 0 then newdata[down_n_x[down_majority], down_n_y[down_majority]] = val

  ; do the same for the "left" pixel
  left_nofn_x = [xy_with_this_val[0,*]-2, xy_with_this_val[0,*]-2, xy_with_this_val[0,*]-2, $
    xy_with_this_val[0,*]-1, xy_with_this_val[0,*]-1, $
    xy_with_this_val[0,*], xy_with_this_val[0,*]]
  left_nofn_y = [xy_with_this_val[1,*]-1, xy_with_this_val[1,*], xy_with_this_val[1,*]+1, $
    xy_with_this_val[1,*]-1, xy_with_this_val[1,*]+1, $
    xy_with_this_val[1,*]-1, xy_with_this_val[1,*]+1]
  left_n_x = xy_with_this_val[0,*]-1
  left_n_y = xy_with_this_val[1,*]
  left_majority = where(total(/int, data[left_nofn_x, left_nofn_y] eq val, 1) ge 3, nreplace)
  if nreplace gt 0 then newdata[left_n_x[left_majority], left_n_y[left_majority]] = val


  ; do the same for the "right" pixel
  right_nofn_x = [xy_with_this_val[0,*]+2, xy_with_this_val[0,*]+2, xy_with_this_val[0,*]+2, $
    xy_with_this_val[0,*]+1, xy_with_this_val[0,*]+1, $
    xy_with_this_val[0,*], xy_with_this_val[0,*]]
  right_nofn_y = [xy_with_this_val[1,*]-1, xy_with_this_val[1,*], xy_with_this_val[1,*]+1, $
    xy_with_this_val[1,*]-1, xy_with_this_val[1,*]+1, $
    xy_with_this_val[1,*]-1, xy_with_this_val[1,*]+1]
  right_n_x = xy_with_this_val[0,*]+1
  right_n_y = xy_with_this_val[1,*]
  right_majority = where(total(/int, data[right_nofn_x, right_nofn_y] eq val, 1) ge 3, nreplace)
  if nreplace gt 0 then newdata[right_n_x[right_majority], right_n_y[right_majority]] = val

endif

; post-processing: fix the edges going pixel-by-pixel
; top edges: use a 2D histogram to find the most popular neighbours of each top pixel
; x and y coordinates of each top pixel. note that we need to do the corners
; separately, so we purposely omit them here.
top_xcoordlist = lindgen(datadimen[0]-2)+1
top_ycoordlist = replicate(0l, datadimen[0]-2)
; list of x and y coordinates respectively of the 5 neighbours of each top pixel
; these are a Nx5 arrays
top_n_x = [[top_xcoordlist-1], [top_xcoordlist-1], [top_xcoordlist], $
  [top_xcoordlist+1], [top_xcoordlist+1]]
top_n_y = [[top_ycoordlist], [top_ycoordlist+1], [top_ycoordlist+1], $
  [top_ycoordlist+1], [top_ycoordlist]]
;  dimen1: data values
;  dimen2: column along the edge
top_n_vhist = hist_2d(data[top_n_x, top_n_y]-om, min1=0, $
  rebin(top_xcoordlist, datadimen[0]-2, 5, /sample))
; there need to be 3 neighbour pixels the same
top_wheremajority = where(top_n_vhist ge 3, nreplace)
if nreplace gt 0 then begin
  ; separate the where, which is a 1D index into the 2D histogram,
  ; into a separate column number and data value
  top_majority_valbycolumn = array_indices(top_n_vhist, top_wheremajority)
  newdata[top_majority_valbycolumn[1,*], 0] = top_majority_valbycolumn[0,*]+om
endif

; as above, but for the bottom row
bot_xcoordlist = top_xcoordlist
bot_ycoordlist = replicate(datadimen[1]-1, datadimen[0]-2)
bot_n_x = [[bot_xcoordlist-1], [bot_xcoordlist-1], [bot_xcoordlist], $
  [bot_xcoordlist+1], [bot_xcoordlist+1]]
bot_n_y = [[bot_ycoordlist], [bot_ycoordlist-1], [bot_ycoordlist-1], $
  [bot_ycoordlist-1], [bot_ycoordlist]]
bot_n_vhist = hist_2d(data[bot_n_x, bot_n_y]-om, min1=0, $
  rebin(bot_xcoordlist, datadimen[0]-2, 5, /sample))
bot_wheremajority = where(bot_n_vhist ge 3, nreplace)
if nreplace gt 0 then begin
  bot_majority_valbycolumn = array_indices(bot_n_vhist, bot_wheremajority)
  newdata[bot_majority_valbycolumn[1,*], datadimen[1]-1] = bot_majority_valbycolumn[0,*]+om
endif

; as above, but for the left column
left_xcoordlist = replicate(0l, datadimen[1]-2)
left_ycoordlist = lindgen(datadimen[1]-2)+1
left_n_x = [[left_xcoordlist], [left_xcoordlist+1], [left_xcoordlist+1], $
  [left_xcoordlist+1], [left_xcoordlist]]
left_n_y = [[left_ycoordlist-1], [left_ycoordlist-1], [left_ycoordlist], $
  [left_ycoordlist+1], [left_ycoordlist+1]]
left_n_vhist = hist_2d(data[left_n_x, left_n_y]-om, min1=0, $
  rebin(left_xcoordlist, datadimen[1]-2, 5, /sample))
left_wheremajority = where(left_n_vhist ge 3, nreplace)
if nreplace gt 0 then begin
  left_majority_valbyrow = array_indices(left_n_vhist, left_wheremajority)
  newdata[0, left_majority_valbyrow[1,*]] = left_majority_valbyrow[0,*]+om
endif

; as above, but for the right column
right_xcoordlist = replicate(datadimen[0]-1, datadimen[1]-2)
right_ycoordlist = left_ycoordlist
right_n_x = [[right_xcoordlist], [right_xcoordlist-1], [right_xcoordlist-1], $
  [right_xcoordlist-1], [right_xcoordlist]]
right_n_y = [[right_ycoordlist-1], [right_ycoordlist-1], [right_ycoordlist], $
  [right_ycoordlist+1], [right_ycoordlist+1]]
right_n_vhist = hist_2d(data[right_n_x, right_n_y]-om, min1=0, $
  rebin(right_xcoordlist, datadimen[1]-2, 5, /sample))
right_wheremajority = where(right_n_vhist ge 3, nreplace)
if nreplace gt 0 then begin
  right_majority_valbyrow = array_indices(right_n_vhist, right_wheremajority)
  newdata[datadimen[0]-1, right_majority_valbyrow[1,*]] = right_majority_valbyrow[0,*]+om
endif

; corners need 2 neighbours the same
tl_n_x = [0,1,1]
tl_n_y = [1,1,0]
tl_n_vhist = histogram(data[tl_n_x, tl_n_y]-om, min=0)
if max(tl_n_vhist, tl_n_maxval) ge 2 then newdata[0,0]=tl_n_maxval+om
tr_n_x = datadimen[0] - tl_n_x - 1
tr_n_y = tl_n_y
tr_n_vhist = histogram(data[tr_n_x, tr_n_y]-om, min=0)
if max(tr_n_vhist, tr_n_maxval) ge 2 then newdata[datadimen[0]-1,0]=tr_n_maxval+om
bl_n_x = tl_n_x
bl_n_y = datadimen[1] - tl_n_y - 1
bl_n_vhist = histogram(data[bl_n_x, bl_n_y]-om, min=0)
if max(bl_n_vhist, bl_n_maxval) ge 2 then newdata[0,datadimen[1]-1]=bl_n_maxval+om
br_n_x = tr_n_x
br_n_y = bl_n_y
br_n_vhist = histogram(data[br_n_x, br_n_y]-om, min=0)
if max(br_n_vhist, br_n_maxval) ge 2 then newdata[datadimen[0]-1,datadimen[1]-1]=br_n_maxval+om

return, newdata

end

