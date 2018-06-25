;+
; NAME:
;    PLOTCUMUL
;
; PURPOSE:
;    Plots the cumulative distribution of a set of data.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    PLOTCUMUL, Data
;
; INPUTS:
;    Data:   Data values.
;
; KEYWORD PARAMETERS:
;    OVERPLOT:    If /OVERPLOT is set then overplot the cumulative
;                 distribution over top of the existing plot coordinates.
;
;    ABSOLUTE:    If /ABSOLUTE is set then plot the true cumulative number
;                 distribution instead of the fractional cumulative
;                 distribution.
;
;    WINDOW:      Sets the /WINDOW keyword in Coyote Graphics.
;
;    ADDCMD:      Sets the /ADDCMD keyword in Coyote Graphics.
;
;    _Extra: All extra keywords are passed through to CGPLOT.
;
; OUTPUTS:
;    Plots or overplots the cumulative distribution of Data.
;
; EXAMPLE:
;    x = findgen(20)^2
;    PLOTCUMUL, x, YRANGE='Cumulative Fraction'
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;    11 March 2011  Switched to Coyote Graphics.
;-
pro plotcumul, data, overplot=oplotp, absolute=absnumberp, $
  window=window, addcmd=addcmd, _extra=extrakeywords

flatdata = data[*]
ndata = n_elements(flatdata)

xsort = sort(flatdata)
xax = flatdata[(transpose(rebin(xsort,ndata,2)))[*]]
yax = ((transpose(rebin(findgen(ndata+1),ndata+1,2)))[*])[1:ndata*2]
if ~keyword_set(absnumberp) then yax /= ndata

cgplot, xax, yax, overplot=oplotp, window=window, addcmd=addcmd, $
  _extra=extrakeywords

end


