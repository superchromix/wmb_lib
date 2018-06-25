;+
; NAME:
;    SPLINEPLOT
;
; PURPOSE:
;    Plots a 2D spline curve using a set of given coordinates.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    SPLINEPLOT, XCoords, YCoords
;
; INPUTS:
;    XCoords:    Array of x coordinates of curve.
;
;    YCoords:    Array of y coordinates of curve.
;
; KEYWORD PARAMETERS:
;    NSPLINE:  Number of points to use to draw the curve. Default: 100.
;
;    OVERPLOT: Plots over existing plot.
;
;    WINDOW:   Uses the /WINDOW flag for Coyote Graphics.
;
;    ADDCMD:   Uses the /ADDCMD flag for Coyote Graphics.
;
; EXAMPLE:
;    This uses GETPTS to select a number of points, and then draws a smooth curve
;    connecting those points:
;
;    GETPTS, x, y
;    SPLINEPLOT, x, y, /OVERPLOT
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin, 3 Dec 2010
;    11 March 2011 Moved to SPLINEPLOT and allowing overplot as an option.
;                  Switched to Coyote Graphics.
;
;-
pro splineplot, xcoords, ycoords, nspline=nspline, overplot=overplot, $
  window=window, addcmd=addcmd, _extra=plotextra

setdefaultvalue, nspline, 100L

npt = n_elements(xcoords)
if npt ne n_elements(ycoords) then message, 'XCOORDS and YCOORDS must have the same number of elements.'

seglen = sqrt( (xcoords[1:*]-xcoords)^2 + (ycoords[1:*]-ycoords)^2 )
segx = [0,total(seglen, /cumulative)]
totallen = segx[npt-1]
t = totallen * findgen(nspline) / (nspline-1)

xvals = spline(segx, xcoords, t)
yvals = spline(segx, ycoords, t)

cgplot, xvals, yvals, overplot=overplot, window=window, addcmd=addcmd, _extra=plotextra

end

