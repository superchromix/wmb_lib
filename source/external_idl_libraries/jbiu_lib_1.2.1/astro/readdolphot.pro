;+
; NAME:
;        READDOLPHOT
;
; PURPOSE:
;        Read the output of the DOLPHOT photometry package into easier-to-
;        use data structures.
;
; CATEGORY:
;        Astro
;
; CALLING SEQUENCE:
;        Result = READDOLPHOT(Filename, Nimg)
;
; INPUTS:
;        Filename:      Name of DOLPHOT output file
;
;        Nimg:          Number of images
;
; KEYWORD PARAMETERS:
;        NHSTFILTERS:   If this is set to a number greater than 0, the output
;                       is assumed to have been generated using DOLPHOT/ACS
;                       or DOLPHOT/WFC3, and to have NHSTFILTERS photometry
;                       blocks at the beginning that give the combined results
;                       of each filter. The output is also assumed to both
;                       have instrumental and transformed magnitudes.
;
;        V2:            If /V2 set, then read in DOLPHOT 2 output (slightly changed
;                       from version 1)
;
; OUTPUTS:
;        This function outputs an array of structures, one for each star.
;        The structure has the following fields:
;           extension, chip, xpos, ypos, chi, sn, sharpness, roundness,
;           majoraxis, crowding, objtype, counts[N], background[N],
;           magnitude[N], magerr[N], imgchi[N], imgsn[N], imgsharpness[N],
;           imgroundness[N], imgcrowding[N], fwhm[N], ellipticity[N],
;           PSFa[N], PSFb[N], PSFc[N], errflag[N].
;         If NHSTFILTERS gt 0 then magnitude[N] is replaced by instmag[N]
;         and transfmag[N].
;         If /V2 is set, then fwhm[N], ellipticity[N], PSFa[N],
;         PSFb[N] and PSFc[N] are replaced with ctcorr[N] and dctcorr[N].
;         N is Nimg plus NHSTFILTERS. The HST filter information comes
;         first.
;
; MODIFICATION HISTORY:
;         Written by:     Jeremy Bailin
;         13 May 2010     Initial writing
;         18 June 2011    Updated to allow DOLPHOT2 output
;
;-
function readdolphot, filename, nimg, nhstfilters=nhstfilters, v2=v2output

if n_elements(nhstfilters) eq 0 then nhstfilters=0
if nhstfilters lt 0 then message, 'NHSTFILTERS must be greater than or equal to 0.'

hstphot = nhstfilters gt 0   ; 1 if in HST mode, 0 otherwise
nctcorr = keyword_set(v2output) * 2   ; number of ctcorr columns: 2 if /V2, 0 otherwise
nfepsf = 5 * (1-keyword_set(v2output))  ; number of fwhm/ellip/psf columns: 0 if /V2, 5 otherwise

nhead = 11
nphot = 15 + hstphot  ; there's one extra field if in HST mode
if keyword_set(v2output) then nphot -= 3   ; 5 fields gone, 2 new fields
nblock = Nimg + nhstfilters

; set up structure
outstruct = {extension:0, chip:0, xpos:0., ypos:0., chi:0., sn:0., $
  sharpness:0., roundness:0., majoraxis:0, crowding:0., objtype:0, $
  counts:replicate(0.,nblock), background:replicate(0.,nblock), $
  magerr:replicate(0.,nblock), imgchi:replicate(0.,nblock), $
  imgsn:replicate(0.,nblock), imgsharpness:replicate(0.,nblock), $
  imgroundness:replicate(0.,nblock), imgcrowding:replicate(0.,nblock), $
  errflag:replicate(0,nblock)}
if hstphot then $
  outstruct = create_struct(outstruct, 'instmag',replicate(0.,nblock), $
    'transfmag',replicate(0.,nblock)) $
else $
  outstruct = create_struct(outstruct, 'magnitude',replicate(0.,nblock))
if keyword_set(v2output) then $
  outstruct = create_struct(outstruct, 'ctcorr',replicate(0.,nblock), $
    'dctcorr',replicate(0.,nblock)) $
else $
  outstruct = create_struct(outstruct, 'fwhm',replicate(0.,nblock), $
    'ellipticity',replicate(0.,nblock), 'PSFa',replicate(0.,nblock), $
    'PSFb',replicate(0.,nblock), 'PSFc',replicate(0.,nblock))

ncolumn = nhead + nblock * nphot
nrow = file_lines(filename)

; generate final structure and a matrix to readf into
struct = replicate(outstruct, nrow)
inmatrix = fltarr(ncolumn,nrow)

; open file and read into matrix
openr,lun,filename, /get_lun
readf,lun,inmatrix
close,lun
free_lun, lun

; put elements into structure
struct.extension = reform(inmatrix[0,*],nrow)
struct.chip = reform(inmatrix[1,*],nrow)
struct.xpos = reform(inmatrix[2,*],nrow)
struct.ypos = reform(inmatrix[3,*],nrow)
struct.chi = reform(inmatrix[4,*],nrow)
struct.sn = reform(inmatrix[5,*],nrow)
struct.sharpness = reform(inmatrix[6,*],nrow)
struct.roundness = reform(inmatrix[7,*],nrow)
struct.majoraxis = reform(inmatrix[8,*],nrow)
struct.crowding = reform(inmatrix[9,*],nrow)
struct.objtype = reform(inmatrix[10,*],nrow)
; get an array of indices to the beginning of each photometry block
blockpts = lindgen(nblock)*nphot + nhead
struct.counts = inmatrix[blockpts,*]
struct.background = inmatrix[blockpts+1,*]
if keyword_set(v2output) then begin
  struct.ctcorr = inmatrix[blockpts+2,*]
  struct.dctcorr = inmatrix[blockpts+3,*]
endif
if hstphot then begin
  struct.instmag = inmatrix[blockpts+2+nctcorr,*]
  struct.transfmag = inmatrix[blockpts+3+nctcorr,*]
endif else struct.magnitude = inmatrix[blockpts+2+nctcorr,*]
struct.magerr = inmatrix[blockpts+3+nctcorr+hstphot,*]
struct.imgchi = inmatrix[blockpts+4+nctcorr+hstphot,*]
struct.imgsn = inmatrix[blockpts+5+nctcorr+hstphot,*]
struct.imgsharpness = inmatrix[blockpts+6+nctcorr+hstphot,*]
struct.imgroundness = inmatrix[blockpts+7+nctcorr+hstphot,*]
struct.imgcrowding = inmatrix[blockpts+8+nctcorr+hstphot,*]
if not keyword_set(v2output) then begin
  struct.fwhm = inmatrix[blockpts+9+nctcorr+hstphot,*]
  struct.ellipticity = inmatrix[blockpts+10+nctcorr+hstphot,*]
  struct.PSFa = inmatrix[blockpts+11+nctcorr+hstphot,*]
  struct.PSFb = inmatrix[blockpts+12+nctcorr+hstphot,*]
  struct.PSFc = inmatrix[blockpts+13+nctcorr+hstphot,*]
endif
struct.errflag = inmatrix[blockpts+9+nctcorr+hstphot+nfepsf,*]

return, struct

end

