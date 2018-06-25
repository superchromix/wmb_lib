;+
; NAME:
;    SKY2XY
;
; PURPOSE:
;    Converts between sky coordinates and pixel coordinates of a FITS image
;    using the WCSTOOLS sky2xy routine. Useful for images with WCS keywords
;    that are not implemented in the astronomy library (such as the TNX
;    convention for distortions).
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = SKY2XY(FITSFile, Ra, Dec)
;
; INPUTS:
;    FITSFile:   Name of FITS file that contains the WCS to use.
;
;    Ra:   Vector of right ascensions. Assumed to be in decimal degrees unless
;          /STRING is set.
;
;    Dec:  Vector of declinations. Assumed to be in decimal degrees unless
;          /STRING is set.
;
; KEYWORD PARAMETERS:
;    STRING:   If set, Ra and Dec are strings in HH:MM:SS, DD:MM:SS format.
;
;    WCSTOOLSDIR:  Path to the location of the binary sky2xy files in wcstools.
;
; OUTPUTS:
;    The function returns a structure with fields .X and .Y which are arrays
;    containing the x and y pixel values.
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
function sky2xy, fitsfile, ra, dec, string=stringp, wcstoolsdir=wcstoolsdir

if n_elements(wcstoolsdir) ne 0 then begin
  if strmid(wcstoolsdir, strlen(wcstoolsdir)-1, 1) ne '/' then wcstoolsdir += '/'
endif else wcstoolsdir=''

astrolib
skyfile=tmpfile('tmp','dat',4)
xyfile=tmpfile('tmp','dat',4)
if ~keyword_set(stringp) then begin
  radec, ra, dec, rahr, ramn, rasc, dede, demn, desc
  forprint, rahr, ramn, rasc, dede, demn, desc, format='(%"%02d:%02d:%06.3f %+3d:%02d:%06.3f")', $
    textout=skyfile, /nocomment
endif else begin
  forprint, ra, dec, textout=skyfile, format='(%"%s %s")', /nocomment
endelse

spawn, wcstoolsdir+'sky2xy '+fitsfile+' @'+skyfile+' > '+xyfile
readcol, xyfile, x, y, format='x,x,x,x,f,f'
file_delete, skyfile, xyfile

return, {x:x, y:y}

end

