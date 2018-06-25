;+
; NAME:
;    PLOT_BINNEDDATA
;
; PURPOSE:
;    Takes a set of X,Y data and plots the mean y value for points
;    binned by their x coordinate.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    PLOT_BINNEDDATA, X, Data, Bin
;
; INPUTS:
;    X:     Array containing x coordinates of data points.
;
;    Data:  Array containing y coordinates of data points.
;
;    Bin:   Bin width, in x coordinates (if positive) or in
;           data points per bin (if negative).
;
; KEYWORD PARAMETERS:
;    MIN:       Minimum value for bins. Default: minimum value of X.
;
;    MAX:       Maximum value for bins. Default: maximum value of X.
;
;    OX:        Optional output of x coordinates of bins.
;
;    ODATA:     Optional output of plotted y values.
;
;    OERR:      Optional output 2xNbin array containg the ends of the
;               error bars.
;
;    DX:        Shifts the x coordinates of the plot locations (only on
;               the plot, not in OX).
;
;    ERRORBAR:  If /ERRORBAR is set, then error bars are plotted in the y
;               direction. The size of the error bar is the statistical
;               error in the mean (or, if /MEDIAN is set, the range
;               containing the fraction CONFLIMIT of the data).
;
;    CONFLIMIT: Fraction of the data to enclose in the error bar if
;               /MEDIAN is set. For example, use CONFLIMIT=0.9 to
;               plot the 5th to 95th percentile range.
;
;    MEDIAN:    If /MEDIAN is set then plot the median Y value instead
;               of the mean.
;
;    ROBUST:    If /ROBUST is set then use ROBUST_MEAN to calculate the
;               mean Y value. Not compatible with /MEDIAN.
;
;    HORIZONTALBAR:   If /HORIZONTALBAR is set then the routine plots a
;                     horizontal line that spans each bin.
;
;    OVERPLOT:  If /OVERPLOT is set then overplot binned data points on
;               an existing plot.
;
;    NOPLOT:    If /NOPLOT is set then do not create a plot. Useful if
;               you just want to extract the values using the O...
;               keywords.
;
;   COLOR:      Color of plotted points and error bars.
;
;   HISTOGRAM:  Outputs the histogram of number of Data values that
;               contributed to each bin. Not compatible with negative
;               values for Bin.
;
;   REVERSE_INDICES:  Outputs the reverse indices of the histogram.
;                     Not compatible with negative values for Bin.
;
;   WINDOW:     Sets the /WINDOW keyword in Coyote Graphics.
;
;   ADDCMD:     Sets the /ADDCMD keyword in Coyote Graphics.
;
;   _Extra: Extra keywords are passed through to CGPLOT.
;
; EXAMPLE:
;    x = 0.1*FINDGEN(20)
;    y = 10. * x^2 + RANDOMN(seed, 20)
;    PLOT, PSYM=3, x, y
;    PLOT_BINNEDDATA, x, y, -4, /OVERPLOT, /ERRORBAR
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;    3 May 2009     When BIN<0, make all bins have approximately the
;                   same number of elements instead of sticking any
;                   excess elements in the final bin.
;    12 July 2010   Added /ROBUST keyword.
;    31 July 2010   Added HISTOGRAM and REVERSE_INDICES keywords.
;    11 March 2011  Switched to Coyote Graphics.
;-
pro plot_binneddata, X, DATA, BIN, MIN=minval, MAX=maxval, $
 ERRORBAR=errorbarp, OVERPLOT=overplotp, NOPLOT=noplotp, $
 OX=ox, ODATA=odata, OERR=oerr, COLOR=color, DX=dx, MEDIAN=medianp, $
 HORIZONTALBAR=horizontalbarp, CONFLIMIT=conflimit, ROBUST=robustp, $
 HISTOGRAM=Xhist, REVERSE_INDICES=xri, _EXTRA=keywords, $
 WINDOW=window, ADDCMD=addcmd

if keyword_set(medianp) and keyword_set(errorbarp) and $
  n_elements(conflimit) eq 0 then $ 
  message, 'If /MEDIAN and /ERRORBAR are both set, then CONFLIMIT must also be set.'
if keyword_set(medianp) and keyword_set(robustp) then $
  message, '/MEDIAN and /ROBUST cannot both be set.'

if n_elements(minval) eq 0 then minval = min(X)
if n_elements(maxval) eq 0 then maxval = max(X)
if n_elements(color) ne 0 then $
  augment_inherited_keyword, keywords, 'COLOR', color

n = n_elements(X)
if n ne n_elements(data) then message, 'X and DATA do not have the same number of elements.'

if bin gt 0 then begin
  Xhist = histogram(X, min=minval, max=maxval, bin=bin, reverse=xri, location=xloc)
  ox = xloc + 0.5*bin
  nbin = ceil( (float(maxval)-minval)/bin )
endif else begin
  xsort = sort(X)
  nbin = ceil(float(n) / (-bin))
  ox = fltarr(nbin)
endelse

odata = fltarr(nbin)
oerr = fltarr(2,nbin)
xbar = fltarr(2,nbin)
for i=0l,nbin-1 do begin
  if bin gt 0 then begin
    if Xhist[i] eq 0 then begin
      odata[i] = !values.f_nan
      oerr[i] = !values.f_nan
      continue
    endif
    xuse = xri[xri[i]:xri[i+1]-1]
    xbar[0,i] = xloc[i]
    xbar[1,i] = xloc[i]+bin
  endif else begin
    xuse = xsort[floor(i*n/float(nbin)) : floor((i+1)*n/float(nbin))-1]
    ox[i] = median(X[xuse])
    xbar[*,i] = minmax(X[xuse])
  endelse

  if keyword_set(medianp) then begin
    odata[i] = median(DATA[xuse])
    oerr[*,i] = percentiles(DATA[xuse], conflimit=conflimit)
  endif else begin
    if keyword_set(robustp) then begin
      resistant_mean, DATA[xuse], 3., rmean
      odata[i] = rmean
    endif else odata[i] = mean(DATA[xuse])
    if Xhist[i] gt 1 then errsize = stddev(DATA[xuse]) / sqrt(n_elements(xuse))$
      else errsize = 0.
    oerr[0,i] = odata[i]-errsize
    oerr[1,i] = odata[i]+errsize
  endelse
endfor

xplot = ox
if n_elements(dx) gt 0 then xplot += dx

if ~keyword_set(noplotp) then begin
  if ~keyword_set(horizontalbarp) then begin
    cgplot, xplot, odata, overplot=overplotp, window=window, addcmd=addcmd, _extra=keywords
    if keyword_set(window) then begin
      ; switch to addcmd
      window=0
      addcmd=1
    endif
  endif else begin
    if ~keyword_set(overplotp) then begin
      cgplot, [0],[0],/nodata, xrange=minmax(xbar), yrange=minmax(odata), $
	window=window, addcmd=addcmd, _extra=keywords
      if keyword_set(window) then begin
        ; switch to addcmd
        window=0
        addcmd=1
      endif
    endif
   
    if keyword_set(addcmd) then cgcontrol, execute=0 
    for i=0l,nbin-1 do cgplot, /over, xbar[*,i], odata[i]*[1,1], window=window, addcmd=addcmd, _extra=keywords
  endelse

  if keyword_set(errorbarp) then begin
    if keyword_set(addcmd) then cgcontrol, execute=0 
    for i=0l,nbin-1 do cgplot, /over, xplot[i]*[1,1], oerr[*,i], window=window, $
      addcmd=addcmd, _extra=keywords
  endif
endif

if keyword_set(addcmd) then cgcontrol, execute=1

end

