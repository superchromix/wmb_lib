
forward_function ml_nnl, hessian, derivee2xy, ml_distfit

function ML_NNL, P
common ML_DISTFIT_CB, DATA, FN, CONSTRAINTP, CONSTRAINTFUNC
  bignum=1e10
  ; if we're in a constrained part of parameter space, get the hell out!
  if constraintp then if ~call_function(constraintfunc,p) then return, bignum

  f = call_function(fn,data,p)
  ; if there are any negative values, get out of there.
  if total(f lt 0.) gt 0 then return, bignum

  ; don't include zeros
  nonzero = where(f ne 0.0,nok)
  if nok gt 0 then nnl=-total(alog(f[nonzero])) else nnl=bignum

  return, nnl
end


; uses derivee2xy to calculate partial derivatives, then inverts
; (based on MLEfit.pro)
pro hessian, name, param, correl
; compute the matrix elements
	Ndim=N_elements(param)
	temp=dblarr(Ndim,Ndim)
	for i=0,Ndim-1 do begin
		for j=i,Ndim-1 do begin
			temp[i,j]=derivee2xy(name,param,i,j)
			temp[j,i]=temp[i,j]
		endfor
	endfor
	correl=invert(temp)
end


; calculate partial derivatives
; (based on MLEfit.pro, but with the brackets fixed up so it's readable)
function derivee2xy, name, xparam, nx, ny
common ML_DISTFIT_CB, DATA, FN, CONSTRAINTP, CONSTRAINTFUNC

	temp=xparam
;
	if (nx EQ ny) then begin
;
; 2nd derivative with respect to the same nx-ieme
; variable
;
		h=abs(xparam[nx]*0.001d0)
		if (h LT 0.01) then begin
			h=0.01d0
		endif
;
		f00=call_function(name,temp)
;
		temp[nx]=xparam[nx]+h
		fp10=call_function(name,temp)
;
		temp[nx]=xparam[nx]-h
		fm10=call_function(name,temp)
;
		return,(fp10+fm10-2.d0*f00)/h^2

	endif else begin

;
; 2nd partial derivative with respect to the different
; variables

		hx=abs(xparam[nx]*0.001d0)
		hy=abs(xparam[ny]*0.001d0)
		if (hx LT 0.01) then begin
			hx=0.01d0
		endif
		if (hy LT 0.01) then begin
			hy=0.01d0
		endif
;
		temp[nx]=xparam[nx]+hx
		temp[ny]=xparam[ny]+hy
		fp1p1=call_function(name,temp)
;
		temp[nx]=xparam[nx]+hx
		temp[ny]=xparam[ny]-hy
		fp1m1=call_function(name,temp)
;
		temp[nx]=xparam[nx]-hx
		temp[ny]=xparam[ny]+hy
		fm1p1=call_function(name,temp)
;
		temp[nx]=xparam[nx]-hx
		temp[ny]=xparam[ny]-hy
		fm1m1=call_function(name,temp)

		return,(fp1p1+fm1m1-fp1m1-fm1p1)/4.d0/hx/hy
	endelse

end



;+
;
; NAME:
;    ML_DISTFIT
;
; PURPOSE:
;    Performs maximum likelihood fitting of a distribution.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    ML_DISTFIT, X, Parm, Function_Name, ConfRegion
;
; INPUTS:
;    X:              Array of input data values. This is passed straight to the
;                    user-supplied function, so complicated data structures that
;                    encompass multi-dimensional information for each data
;                    point can be used.
;
;    Parm:           Variable containing initial guesses for parameters on input
;                    and best fit values on output.
;
;    Function_Name:  Name of user-supplied function defining the distribution.
;                    The function must accept 2 arguments, X and Parm, and
;                    return a vector containing the likelihood values for
;                    each data point in X for the point in parameter space
;                    given by Parm. The likelihood must be normalized so
;                    that its total integral over all possible values of X
;                    is a constant, regardless of Parm (it makes the most
;                    sense to normalize this integral to unity, but that
;                    is not strictly required).
;
; OPTIONAL OUTPUTS:
;    ConfRegion:     Lower and upper error estimates of each parameter,
;                    marginalized over the other parameters.
;                    I.e. ConfRegion[*,0] returns [low0,high0]
;                    where low0 <= parm[0] <= high0
;
; KEYWORD PARAMETERS:
;    FITA:           Vector of which parameters should be fit (1 for each
;                    parameter to be fit, 0 for each parameter to be held
;                    constant).
;                    THERE IS A BUG IN THE IMPLEMENTATION. DO NOT USE.
;
;    CONSTRAINT:     Name of a user-supplied function that takes a parameter
;                    vector as input and returns 1 if the point in parameter
;                    space is permitted and 0 if it is not permitted.
;
;    LIKELIHOOD:     Outputs an M-dimensional array with the likelihood
;                    values over the range of parameter space probed. M is
;                    the number of parameters that are fitted, which can be
;                    less than the length of Parm if FITA is used.
;
;    LIKERANGE:      2xM dimensional array containing the bounds of the
;                    LIKELIHOOD array.
;
; EXAMPLE:
;    Fit the width and offset of a zero-centered Gaussian plus constant
;    distribution.
;
;    First, define the distribution function:
;    FUNCTION gauss_plus_const, X, Parm
;      ; Parm[0]=constant offset, Parm[1]=width sigma
;      vmax = 2000.
;      normalization = Parm[1]*SQRT(!pi/2.)*ERF(vmax/(SQRT(2.)*Parm[1])) $
;        + vmax*Parm[0]
;      distribution = EXP(-X^2/(2.*Parm[1]^2)) + Parm[0]
;      RETURN, distribution/normalization
;    END
;
;    Then generate some data that should adhere to this distribution,
;    with a width of 250 and a constant term containing 10% of the points.
;    IDL> data = [250*RANDOMN(seed, 900), 4000*(RANDOMU(seed, 100) - 0.5)]
;
;    And finally fit the distribution:
;    IDL> parm = [0., 100.]
;    IDL> ML_DISTFIT, data, parm, 'gauss_plus_const', parmconf
;    IDL> PRINT, parm
;         0.0625345         223.94577
;    IDL> PRINT, parmconf
;        0.057511609  0.0973332
;          207.087      243.841
;
; MODIFICATION HISTORY:
;     Written by: Jeremy Bailin. Thanks to the writers of MLEfit.pro, which
;                 furnished the Hessian routines, Peder Norberg for useful
;                 discussions, and Nicolas Petitclerc for additional testing.
;     27 Nov 2008 Release in JBIU.
;
;-
pro ML_DISTFIT, X, Parm, Function_Name, ConfRegion, FITA=FITA, $
   LIKELIHOOD=LIKELIHOOD, LIKERANGE=LIKERANGE, CONSTRAINT=CONSTRAINT
common ML_DISTFIT_CB, DATA, FN, CONSTRAINTP, CONSTRAINTFUNC


ftol=1e-8
minfracerr=0.01
maxit=20
nptsperparmside=30

data=x
fn=function_name
nparm = (size(parm,/dimen))[0]

if n_elements(constraintfunc) eq 0 then constraintp=0 else begin
  constraintp=1
  constraintfunc=constraint
endelse

if n_elements(fita) gt 0 then begin
  if n_elements(fita) ne nparm then message, 'FITA and PARM must have the same number of elements'
endif else begin
  fita=replicate(1.0,nparm)
endelse
whichfitparms = where(fita ne 0, complement=whichconstparms, nfitparms, $
  ncomp=nconstparms)
if nfitparms gt 0 then begin   ; don't bother if we're not fitting anything

identmatrix=identity(nparm,/double)
; note that if nparm=1, this doesn't appear square to Powell
powell, parm, reform(identmatrix,nparm,nparm), ftol, fmin, 'ML_NNL', /DOUBLE
min_likelihood = ml_nnl(parm)

; initial estimate of confidence limits using covariance matrix
hessian, 'ML_NNL', parm, covar
sigma = sqrt(covar[indgen(nparm),indgen(nparm)])

; now do it for real using the full likelihood
; only do it for parameters that we're actually fitting
nsigslow = replicate(3.0,nfitparms)
nsigshigh = replicate(3.0,nfitparms)
likelihood=dblarr(replicate(2*nptsperparmside+1,nfitparms))
; if there are any that are ridiculously small sigmas, set them to minfracerr
lowsig = where((sigma lt minfracerr*parm) or (sigma ne sigma), ntoolow)
if ntoolow gt 0 then sigma[lowsig] = (minfracerr*parm)[lowsig]
incrementslow = replicate(1B,nfitparms) & ninclow=nfitparms
incrementshigh = replicate(1B,nfitparms) & ninchigh=nfitparms
for sigi=1,maxit do begin
  lowrange = parm[whichfitparms] - sigma[whichfitparms]*nsigslow
  highrange = parm[whichfitparms] + sigma[whichfitparms]*nsigshigh
  deltaparmlow = nsigslow*sigma[whichfitparms]/nptsperparmside
  deltaparmhigh = nsigshigh*sigma[whichfitparms]/nptsperparmside
  indexmap = dblarr(nfitparms,2*nptsperparmside+1)
  indexmap[*,0:nptsperparmside]=rebin(lowrange,nfitparms,nptsperparmside+1) + $
    deltaparmlow#findgen(nptsperparmside+1)
  indexmap[*,nptsperparmside:*]=rebin(parm[whichfitparms],nfitparms,nptsperparmside+1) $
    + deltaparmhigh#findgen(nptsperparmside+1)
  likerange = [[lowrange],[highrange]]
  for i=0L,n_elements(likelihood)-1 do begin
    likind = array_indices(likelihood,i)
    ; don't bother recalculating sections of the likelihood array
    ; that haven't changed
    skipcalc=1
    if (ninclow gt 0) then begin
      if total((likind le nptsperparmside)[incrementslow]) ne 0 then skipcalc=0
    endif
    if (ninchigh gt 0) then begin
      if total((likind ge nptsperparmside)[incrementshigh]) ne 0 then skipcalc=0
    endif
    if skipcalc then continue
    ptest = parm
    ptest[whichfitparms] = indexmap[lindgen(nfitparms),likind]
    likelihood[i] = ml_nnl(ptest)
  endfor

  xi21 = where(likelihood le min_likelihood+1.0)
  xi21_ind = reform(array_indices(likelihood,xi21),nfitparms,n_elements(xi21))

  confregion = fltarr(2,nparm)
  minmaxinds = minmax(xi21_ind, dimen=2)
  confregion[0,whichfitparms] = transpose(indexmap[lindgen(nfitparms),minmaxinds[0,*]])
  confregion[1,whichfitparms] = transpose(indexmap[lindgen(nfitparms),minmaxinds[1,*]])

  ; if we haven't reached the edge of the confidence region in a given
  ; parameter, expand the range we're looking at
  incrementslow = where(confregion[0,whichfitparms] le indexmap[*,0], ninclow, $
    complement=noinclow)
  if ninclow gt 0 then nsigslow[incrementslow] *= 3.0
  incrementshigh = where(confregion[1,whichfitparms] ge indexmap[*,2*nptsperparmside], $
     ninchigh, complement=noinchigh)
  if ninchigh gt 0 then nsigshigh[incrementshigh] *= 3.0
  if ninclow+ninchigh eq 0 then break
endfor

if sigi ge maxit then print, 'ML_DISTFIT: Maximum number of iterations reached. Errors are probably underestimated.' 

end ;if there are fit parameters

; the confidence region of a constant parameter is just the value given
if nconstparms gt 0 then $
  confregion[*,whichconstparms] = rebin(transpose(parm[whichconstparms]), $
  2,nconstparms)

end


