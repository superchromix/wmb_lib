;+
; NAME:
;    REDSHIFT_AXIS
;
; PURPOSE:
;    For a plotting coordinate system that is set up in terms of
;    cosmic time in Gyr, adds a redshift axis.
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    REDSHIFT_AXIS, Z
;
; INPUTS:
;    Z:       Array of redshifts at which to label axis.
;
; KEYWORD PARAMETERS:
;    XAXIS:        XAXIS=0 for a lower x-axis, XAXIS=1 for an upper x-axis.
;                  Default: XAXIS=1
;
;    YAXIS:        YAXIS=0 for a left y-axis, YAXIS=1, for a right y-axis.
;                  Default: no y axis.
;
;    H100:         Hubble parameter in units of 100 km/s/Mpc. Required.
;
;    OMEGAM:       Total matter density at z=0. Required.
;
;    OMEGALAMBDA:  Total vacuum energy density at z=0. Required.
;
;    LOOKBACK:     Time is in lookback time (default is time since Big Bang).
;
;    _EXTRA:       Extra keywords are passed to AXIS procedure.
;
; OUTPUTS:
;    Displays an axis showing redshift.
;
; EXAMPLE:
;    FIXME
;
; MODIFICATION HISTORY:
;    Written by Jeremy Bailin   29 May 2013
;
;-
pro redshift_axis, z, xaxis=xaxis, yaxis=yaxis, h100=h100, $
  omegam=omegam, omegalambda=omegalambda, lookback=lookbackp, _extra=extra

compile_opt idl2

red, h100=h100, omega0=omegam, omega_lambda=omegalambda, /silent
timelabels = getage(z, /gyr)

if keyword_set(lookbackp) then begin
  timelabels = getage(1e4, /gyr) - timelabels
endif

nlabels = n_elements(z)

if keyword_set(xaxis) then begin
  if keyword_set(yaxis) then message, 'Only one of XAXIS and YAXIS must be given.'
  axis, xaxis=xaxis, xticks=nlabels-1, xtickv=timelabels, _extra=extra
endif else begin
  if ~keyword_set(yaxis) then message, 'One of XAXIS and YAXIS must be given.'
  axis, yaxis=yaxis, yticks=nlabels-1, ytickv=timelabels, _extra=extra
endelse


end

