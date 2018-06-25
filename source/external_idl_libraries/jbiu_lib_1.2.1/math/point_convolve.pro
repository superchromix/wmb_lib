;+
; NAME:
;    POINT_CONVOLVE
;
; PURPOSE:
;    Convolves a list of N-dimensional points with a Gaussian kernel.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = POINT_CONVOLVE()
;
; KEYWORD PARAMETERS:
;    POINTS:    Array of MxN points for M dimensions and N particles (required).
;
;    BINSIZE:   Bin sizes for final output grid. Either a scalar or an
;               array of length M. (required)
;
;    RANGE:     Array of Mx2, containing the extent of output grid
;               in each dimension. (required)
;
;    SIGMA:     Width of Gaussian kernel. May either be a scalar that is
;               applied to all dimensions, an array of length M for
;               different widths in each dimension, OR an MxN array
;               containing a separate width for each particle and
;               dimension (this option uses manual summation as if
;               /NOCONVOL were set, and is therefore much slower).
;               (required)
;
;    WEIGHT: An array of length N containing the weight to assign to
;            each point. A weight of 1 (default) corresponds to a Gaussian
;            normalized such that its integral over the entire M-dimensional
;            space is unity.
;    
;    CUTOFF: Assume that the kernel may be safely truncated after this many
;            SIGMAs. Default: 8 (corresponding to a dynmical range of 7.9e13).
;
;    NOCONVOL:  If /NOCONVOL is set than use manual summation rather than an FFT.
;
;    NOFFT:     If /NOFFT is set then use the built-in CONVOL routine rather
;               than an FFT.
;
; OUTPUTS:
;    An grid containing the output density field. Each dimension i in the output
;    grid has length (RANGE[i,1]-RANGE[i,0])/BINSIZE[i]. Returns -1 on error.
;
; PROCEDURE:
;    By default, this function uses an FFT and the convolution theorem.
;    If /NOFFT is set, then it uses the built-in CONVOL function. If
;    either /NOCONVOL is set or SIGMA is an MxN array, then it uses
;    manual summation.
;
; EXAMPLE:
;    xpos = 10.*RANDOMU(seed,100)
;    ypos = 20.*RANDOMU(seed,100)
;    density = POINT_CONVOLVE(POINTS=TRANSPOSE([[xpos],[ypos]]),
;      BINSIZE=1., RANGE=[[0.,0.], [10.,20.]], SIGMA=[2.,4.])
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    12 June 2008  Public release in JBIU
;    15 Apr 2008   Fixed off-by-one bug and improved memory usage
;    27 March 2013 Speed improvements
;-
function point_convolve, points=points, binsize=inbinsize, range=inrange, $
	sigma=insigma, weight=weight, cutoff=cutoff, noconvol=noconvol, $
        nofft=nofft


if (n_elements(points) eq 0) or (n_elements(inbinsize) eq 0) or $
  (n_elements(inrange) eq 0) or (n_elements(insigma) eq 0) then begin
  message, 'Result = point_convolve(POINTS=points, BINSIZE=binsize, RANGE=range, SIGMA=sigma, WEIGHT=weight, CUTOFF=cutoff)'
endif

szpt = size(points, /dimen)
ndimen = szpt[0]
npt = szpt[1]
if (size(inbinsize, /n_dimen) eq 0) then begin
  binsize = replicate(inbinsize, ndimen)
endif else binsize = inbinsize

if (size(inrange, /n_dimen) eq 1) then begin
  if size(inrange, /dimen) ne 2 then begin
    message, 'RANGE must be an M x 2 or 2 element array'
  endif

  low = inrange[0] & high = inrange[1]
  range = fltarr(ndimen, 2)
  range[*,0] = low
  range[*,1] = high
endif else begin
  if (size(inrange, /n_dimen) ne 2) or ( (size(inrange, /dimen))[0] ne ndimen)$
      or ( (size(inrange, /dimen))[1] ne 2) then begin
    message, 'RANGE must be an M x 2 array'
  endif else range = inrange
endelse

numbins = lonarr(ndimen)
for a=0,ndimen-1 do numbins[a] = (range[a,1] - range[a,0]) / binsize[a]

uniquesigmas=0
if (size(insigma, /n_dimen) eq 0) then begin
  sigma = replicate(insigma, ndimen)
endif else if (size(insigma, /n_dimen) eq 1) then begin
  sigma = insigma
endif else begin
  if (size(insigma, /n_dimen) gt 2) then message, 'SIGMA must be MxN, M, or a scalar'
  uniquesigmas=1
  sigma = insigma
endelse

; if NOCONVOL is set, treat it as if it had uniquesigmas
if (not uniquesigmas) and keyword_set(noconvol) then begin
  uniquesigmas=1
  sigma = rebin(sigma,ndimen,npt,/sample)
endif

if ( (n_elements(weight) ne npt) and (n_elements(weight) ne 0)) then begin
  message, 'WEIGHT must have N elements'
endif
if (n_elements(weight) eq 0) then begin
  weight = replicate(1.0,npt)
endif

if n_elements(cutoff) gt 0 then sigcutoff=float(cutoff) else sigcutoff = 8.0



numcells = product(numbins,/int)
; hist_nd doesn't deal with particles outside the region properly,
; so we need to specifically exclude them
inregion = lindgen(npt)
for d=0L,ndimen-1 do begin
  newregion = where( (points[d,inregion] ge range[d,0]) and $
    (points[d,inregion] le range[d,1]), ninregion)
  if ninregion gt 0 then inregion=inregion[newregion]
endfor


; give a blank result if no particles in region
if ninregion eq 0 then return, fltarr(numbins)


if uniquesigmas then begin
  linearindex = lindgen(numcells)
  result = fltarr(numbins)
  fullindex = array_indices(result, temporary(linearindex))
  undefine, result
  ipos = float(temporary(fullindex))
  for i=0,ndimen-1 do begin
    ipos[i,*] *= binsize[i]
    ipos[i,*] += range[i,0]
  endfor
  ; due to memory constraints, we need to loop through either the points
  ; or the output elements, depending which there are fewer of
  result = fltarr(numbins)
  if numcells gt ninregion then begin
    for i=0L,ninregion-1 do begin
      ; we can do a little better by only including cells within sigcutoff
      ; of the particle
      maxlength = binsize*ceil(sigcutoff*sigma[*,inregion[i]]/binsize)
      closecells = lindgen(numcells)
      for d=0L,ndimen-1 do begin
        closecells = closecells[where( abs( $
          ipos[d,closecells] - points[d,inregion[i]]) le maxlength[d])]
      endfor
      nclosecells = n_elements(closecells)

      r2sig2 = total( ( (ipos[*,closecells]- $
        rebin(points[*,inregion[i]],ndimen,nclosecells,/sample)) / $
        rebin(sigma[*,inregion[i]],ndimen,nclosecells,/sample) )^2, 1)
      normalizefactor = product(sigma[*,inregion[i]]*sqrt(2.0*!dpi) / $
        binsize)
      result[closecells] += weight[inregion[i]]*exp(-0.5*r2sig2)/normalizefactor
    endfor
  endif else begin
    ; only include particles within their sigcutoff of the cell
    maxlength = binsize*ceil(replicate(sigcutoff,ndimen,ninregion)*sigma[*,inregion] / $
        rebin(binsize,ndimen,ninregion,/sample))
    for i=0L,numcells-1 do begin
      closepts = lindgen(ninregion)
      for d=0L,ndimen-1 do begin
	closei = where( abs( $
          ipos[d,i] - points[d,inregion[closepts]]) le $
          maxlength[d,inregion[closepts]], nclosepts)
	if nclosepts gt 0 then closepts=closepts[closei] $
	  else break
      endfor
      if nclosepts le 0 then continue

      r2sig2 = total( ((rebin(ipos[*,i],ndimen,nclosepts,/sample)-points[*,inregion[closepts]]) /$
        sigma[*,inregion[closepts]])^2, 1)
      normalizefactor = product(sigma[*,inregion[closepts]]*sqrt(2.0*!dpi) / $
        rebin(binsize,ndimen,nclosepts,/sample), 1)
      result[i] += total(weight[inregion[closepts]]*exp(-0.5*r2sig2)/normalizefactor)
    endfor
  endelse
endif else begin
  bs=binsize
  h = hist_nd(reform(points[*,inregion],ndimen,ninregion), bs, $
    min=range[*,0], max=range[*,1], reverse_indices=ri)

  ; weight histogram
  h = double(h)
  for j=0L,n_elements(h)-1 do begin
    if h[j] gt 0 then h[j] = total( weight[inregion[ri[ri[j]:ri[j+1]-1]]] )
  endfor
  undefine, ri
  undefine, inregion

  ; generate kernel
  maxlength = ceil(sigcutoff*sigma/binsize)
  krange = 0.5*total(range,2) - maxlength*binsize
  numkernelbins = 2*maxlength
  numkernelcells = product(numkernelbins,/int)
  kernel = fltarr(numkernelbins)
  fullindex = array_indices(kernel, lindgen(numkernelcells))
  ipos = (temporary(fullindex)-rebin(maxlength,ndimen,numkernelcells,/sample)) * $
    rebin(binsize,ndimen,numkernelcells,/sample)
  r2sig2 = total( (temporary(ipos)/rebin(sigma,ndimen,numkernelcells,/sample))^2, 1)
  kernel = exp(-0.5*r2sig2)
  kernel = reform(kernel,numkernelbins, /overwrite)
  ; normalize kernel
  kernel /= product(sigma*sqrt(2.0*!dpi)/binsize)

  ; clear out some memory
  undefine, r2sig2

if keyword_set(nofft) then begin
    ; expand the histogram array to include a sufficient number of zeros at the edge
    expanded_h = dblarr(numbins+2*numkernelbins)
  ; I hate to have such dimension-specific code here, but it is MUCH more efficient!
  ; maximum of 8 dimensions
    lowelement = lonarr(8)
    highelement = lonarr(8)
    lowelement[0:ndimen-1] = numkernelbins
    highelement[0:ndimen-1] = lowelement+numbins-1
    expanded_h[lowelement[0]:highelement[0], lowelement[1]:highelement[1], $
      lowelement[2]:highelement[2], lowelement[3]:highelement[3], $
      lowelement[4]:highelement[4], lowelement[5]:highelement[5], $
      lowelement[6]:highelement[6], lowelement[7]:highelement[7]] = temporary(h)

    ; convolve
    expanded_result = convol(temporary(expanded_h), kernel, /center)

    ; get the central region back out
    result = temporary(expanded_result[lowelement[0]:highelement[0], $
     lowelement[1]:highelement[1], lowelement[2]:highelement[2], $
     lowelement[3]:highelement[3], lowelement[4]:highelement[4], $
     lowelement[5]:highelement[5], lowelement[6]:highelement[6], $
     lowelement[7]:highelement[7]])

endif else begin
    ; use FFT
    numexpandedbins = max([[numbins],[numkernelbins]], dimen=2)
    numexpandedcells = product(numexpandedbins)
    lowh = lonarr(8) & highh = lonarr(8)
    lowk = lonarr(8) & highk = lonarr(8)
    hbigger = where(numbins eq numexpandedbins, nhb, complement=kbigger)
    nkb = ndimen-nhb
    if nhb gt 0 then begin
      lowh[hbigger]=0 & highh[hbigger]=numbins[hbigger]-1
      lowk[hbigger]=(numexpandedbins[hbigger]-numkernelbins[hbigger])/2
      highk[hbigger]=(numexpandedbins[hbigger]+numkernelbins[hbigger])/2 - 1
    endif
    if nkb gt 0 then begin
      lowh[kbigger]=(numexpandedbins[kbigger]-numbins[kbigger])/2
      highh[kbigger]=(numexpandedbins[kbigger]+numbins[kbigger])/2 - 1
      lowk[kbigger]=0 & highk[kbigger]=numkernelbins[kbigger]-1
    endif
stop
    expanded_h = fltarr(numexpandedbins)
    expanded_h[lowh[0],lowh[1],lowh[2],lowh[3],lowh[4],lowh[5],lowh[6], $
      lowh[7]] = h[lowh[0]:highh[0], lowh[1]:highh[1], $
      lowh[2]:highh[2], lowh[3]:highh[3], lowh[4]:highh[4], lowh[5]:highh[5], $
      lowh[6]:highh[6], lowh[7]:highh[7]]
    undefine, h
    expanded_kernel = fltarr(numexpandedbins)
    expanded_kernel[lowk[0]:highk[0], lowk[1]:highk[1], lowk[2]:highk[2], $
      lowk[3]:highk[3], lowk[4]:highk[4], lowk[5]:highk[5], $
      lowk[6]:highk[6], lowk[7]:highk[7]] = temporary(kernel)
    expanded_result = numexpandedcells * fft( fft(temporary(expanded_h),/over)*$
      fft(temporary(expanded_kernel),/over), /inverse,/over)
    ; fix the wraparound
    expanded_result = real_part(temporary(expanded_result))
    expanded_result=shift(temporary(expanded_result),numexpandedbins/2)
    exapnded_result = expanded_result[lowh[0]:highh[0], $
      lowh[1]:highh[1], lowh[2]:highh[2], lowh[3]:highh[3], lowh[4]:highh[4], $
      lowh[5]:highh[5], lowh[6]:highh[6], lowh[7]:highh[7]]
    result = temporary(expanded_result)
  endelse

endelse

return, result

end

