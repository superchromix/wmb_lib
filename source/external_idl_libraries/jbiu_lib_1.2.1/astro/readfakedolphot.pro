;+
; NAME:
;        READFAKEDOLPHOT
;
; PURPOSE:
;        Read the output of the DOLPHOT photometry package when run in
;        artificial star mode into easier-to-use data structures.
;
; CATEGORY:
;        Astro
;
; CALLING SEQUENCE:
;        Result = READFAKEDOLPHOT(Filename, FakeStarList, Nimg)
;
; INPUTS:
;        Filename:      Name of DOLPHOT output file
;
;        FakeStarList:  Name of file containing list of fake stars
;
;        Nimg:          Number of images
;
; KEYWORD PARAMETERS:
;        NHSTFILTERS:   If this is set to a number greater than 0, the output
;                       is assumed to have been generated using DOLPHOT/ACS
;                       or DOLPHOT/WFC3, and to have NHSTFILTERS photometry
;                       blocks at the beginning that give the combined results
;                       of each filter (unless Nimg is 1). The output is also
;                       assumed to both have instrumental and transformed magnitudes.
;                       I don't know what DOLPHOT does with artificial stars
;                       when there are more than 2 filters, so I'm just going to
;                       assume that there are never more than 2 filters.
;
; OUTPUTS:
;        This function outputs an array of structures, one for each star.
;        The structure has the following fields:
;           extension, chip, xpos, ypos, chi, sn, sharpness, roundness,
;           majoraxis, crowding, objtype, counts[N], background[N],
;           magnitude[N], magerr[N], imgchi[N], imgsn[N], imgsharpness[N],
;           imgroundness[N], imgcrowding[N], fwhm[N], ellipticity[N],
;           PSFa[N], PSFb[N], PSFc[N], errflag[N],
;           input_extension, input_chip, input_xpos, input_ypos, input_counts[N],
;           input_magnitude[N].
;         If NHSTFILTERS gt 0 then magnitude[N] is replaced by instmag[N]
;         and transfmag[N].
;         N is Nimg plus NHSTFILTERS. The HST filter information comes
;         first.
;
; MODIFICATION HISTORY:
;         Written by:     Jeremy Bailin
;         13 May 2010     Initial writing
;         13 Jan 2011     Bug fixes for NHSTFILTERS ne 0
;
;-
function readfakedolphot, filename, fakestarlist, nimg, nhstfilters=nhstfilters

if n_elements(nhstfilters) eq 0 then nhstfilters=0
if nhstfilters lt 0 then message, 'NHSTFILTERS must be greater than or equal to 0.'
if nhstfilters gt 2 then message, 'NHSTFILTERS must be less than or equal to 2.'

hstphot = nhstfilters gt 0   ; 1 if in HST mode, 0 otherwise
nhstfilterblocks = (nimg eq 1)? 0 : nhstfilters

ninithead = 4
ninmagcols = 2 * Nimg
nparthead = ninithead + ninmagcols
nhead = 11 + nparthead
nphot = 15 + hstphot  ; there's one extra field if in HST mode
nblock = Nimg + nhstfilterblocks

; set up structure
outstruct = {extension:0, chip:0, xpos:0., ypos:0., chi:0., sn:0., $
  sharpness:0., roundness:0., majoraxis:0, crowding:0., objtype:0, $
  counts:replicate(0.,nblock), background:replicate(0.,nblock), $
  magerr:replicate(0.,nblock), imgchi:replicate(0.,nblock), $
  imgsn:replicate(0.,nblock), imgsharpness:replicate(0.,nblock), $
  imgroundness:replicate(0.,nblock), imgcrowding:replicate(0.,nblock), $
  fwhm:replicate(0.,nblock), ellipticity:replicate(0.,nblock), $
  PSFa:replicate(0.,nblock), PSFb:replicate(0.,nblock), $
  PSFc:replicate(0.,nblock), errflag:replicate(0,nblock), $
  input_extension:0, input_chip:0, input_xpos:0., input_ypos:0., $
  input_counts:replicate(0.,nblock), input_magnitude:replicate(0.,nblock) }
if hstphot then $
  outstruct = create_struct(outstruct, 'instmag',replicate(0.,nblock), $
    'transfmag',replicate(0.,nblock)) $
else $
  outstruct = create_struct(outstruct, 'magnitude',replicate(0.,nblock))

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
struct.input_extension = reform(inmatrix[0,*],nrow)
struct.input_chip = reform(inmatrix[1,*],nrow)
struct.input_xpos = reform(inmatrix[2,*],nrow)
struct.input_ypos = reform(inmatrix[3,*],nrow)
; get an array of indices to the beginning of each input counts/mag set
incountmagpts = lindgen(Nimg)*2 + ninithead
struct.input_counts[nhstfilters:*] = inmatrix[incountmagpts,*]
struct.input_magnitude[nhstfilters:*] = inmatrix[incountmagpts+1,*]
struct.extension = reform(inmatrix[nparthead,*],nrow)
struct.chip = reform(inmatrix[nparthead+1,*],nrow)
struct.xpos = reform(inmatrix[nparthead+2,*],nrow)
struct.ypos = reform(inmatrix[nparthead+3,*],nrow)
struct.chi = reform(inmatrix[nparthead+4,*],nrow)
struct.sn = reform(inmatrix[nparthead+5,*],nrow)
struct.sharpness = reform(inmatrix[nparthead+6,*],nrow)
struct.roundness = reform(inmatrix[nparthead+7,*],nrow)
struct.majoraxis = reform(inmatrix[nparthead+8,*],nrow)
struct.crowding = reform(inmatrix[nparthead+9,*],nrow)
struct.objtype = reform(inmatrix[nparthead+10,*],nrow)
; get an array of indices to the beginning of each photometry block
blockpts = lindgen(nblock)*nphot + nhead
struct.counts = inmatrix[blockpts,*]
struct.background = inmatrix[blockpts+1,*]
if hstphot then begin
  struct.instmag = inmatrix[blockpts+2,*]
  struct.transfmag = inmatrix[blockpts+3,*]
endif else struct.magnitude = inmatrix[blockpts+2,*]
struct.magerr = inmatrix[blockpts+3+hstphot,*]
struct.imgchi = inmatrix[blockpts+4+hstphot,*]
struct.imgsn = inmatrix[blockpts+5+hstphot,*]
struct.imgsharpness = inmatrix[blockpts+6+hstphot,*]
struct.imgroundness = inmatrix[blockpts+7+hstphot,*]
struct.imgcrowding = inmatrix[blockpts+8+hstphot,*]
struct.fwhm = inmatrix[blockpts+9+hstphot,*]
struct.ellipticity = inmatrix[blockpts+10+hstphot,*]
struct.PSFa = inmatrix[blockpts+11+hstphot,*]
struct.PSFb = inmatrix[blockpts+12+hstphot,*]
struct.PSFc = inmatrix[blockpts+13+hstphot,*]
struct.errflag = inmatrix[blockpts+14+hstphot,*]


; if this is HST photometry, need to use the fake star list to
; determine the actual inputs for the filter(s).
if hstphot then begin
  ; we can just use the first line
  openr,fakelistlun,fakestarlist,/get_lun
  fakestarline = fltarr(6)
  readf,fakelistlun,fakestarline
  free_lun,fakelistlun

  ; figure out which set of counts/mags correspond to the first filter
  ; in the fake star list
  filternum = lonarr(nhstfilters)
  filtermatchedp = bytarr(nhstfilters)
  for fi=0l,nhstfilters-1 do begin
    filternum[fi] = (where(struct[0].input_magnitude eq fakestarline[4+fi], nfilter))[0]
    filtermatchedp[fi] = nfilter gt 0
  endfor

  ; make sure that we have the right number of matches
  if (total(filtermatchedp,/int) ne nhstfilters) then $
    message, 'Wrong number of matched filters.'

  ; put the correct number of counts and magnitudes into the first
  ; elements of input_counts and input_magnitudes
  for fi=0l,nhstfilters-1 do begin
    struct[*].input_counts[fi] = struct[*].input_counts[filternum[fi]]
    struct[*].input_magnitude[fi] = struct[*].input_magnitude[filternum[fi]]
  endfor
endif


return, struct

end

