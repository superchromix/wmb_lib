;+
; NAME:
;    XY2SKY
;
; PURPOSE:
;    Converts between pixel coordinates of a FITS image and sky coordinates
;    using the WCSTOOLS xy2sky routine. Useful for images with WCS keywords
;    that are not implemented in the astronomy library (such as the TNX
;    convention for distortions).
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = XY2SKY(FITSFile, X, Y)
;
; INPUTS:
;    FITSFile:   Name of FITS file that contains the WCS to use.
;
;    X:          Vector of x coordinates.
;
;    Y:          Vector of y coordinates.
;
; KEYWORD PARAMETERS:
;    STRING:    Output strings of HH:MM:SS and DD:MM:SS format.
;
;    WCSTOOLSDIR:   Path to the location of the binary xy2sky in wcstools.
;
; OUTPUTS:
;    The function returns a structure with fields .RA and .DEC which are arrays
;    containing the RA and Dec values in decimal degrees (or in strings,
;    if /STRING is set).
;
; NOTES:
;    Requires WCSTOOLS to be installed, along with the UWashington TMPFILE
;    and DIR_EXIST routines.
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    20 August 2010   Initial release
;    10 Feb 2011    Made WCSTOOLSDIR a keyword parameter.
;
;-
function xy2sky, fitsfile, x, y, string=stringp, wcstoolsdir=wcstoolsdir

if n_elements(wcstoolsdir) ne 0 then begin
  if strmid(wcstoolsdir, strlen(wcstoolsdir)-1, 1) ne '/' then wcstoolsdir += '/'
endif else wcstoolsdir=''

astrolib
skyfile=tmpfile('tmp','dat',4)
xyfile=tmpfile('tmp','dat',4)

forprint, x, y, textout=xyfile, /nocomment
spawn, wcstoolsdir+'/xy2sky -n 4 '+fitsfile+' @'+xyfile+' > '+skyfile
readcol, skyfile, ra, dec, format='a,a,x,x,x'
file_delete, xyfile, skyfile

if ~keyword_set(stringp) then begin
  ra = 15. * tenv(ra)
  dec = tenv(dec)
endif

return, {ra:ra, dec:dec}

end

