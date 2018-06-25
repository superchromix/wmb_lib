;+
; NAME:
;    JBLINFIT
;
; PURPOSE:
;    Performs least squares fitting to a straight line, but can perform it over
;    one particular dimension for a multi-dimensional data set. Acts like the
;    built-in function LINFIT if DIMENSION is not set.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = JBLINFIT(X, Y)
;
; INPUTS:
;    X:         Array containing the independent variable values.
;
;    Y:         Array containing the dependent variable values.
;
; KEYWORD PARAMETERS:
;    DIMENSION: If X and Y are multi-dimensional arrays, perform the fitting
;               accross this dimension.
;
;    CHISQR:    Output variable containing the chi squared values.
;
;    COVAR:     Output variable containing the covariance matrix.
;
;    MEASURE_ERRORS:  Array containing the measurement errors in Y.
;
;    PROB:      Output variable containing the probability of obtaining a fit
;               with at least this chi squared value.
;
;    SIGMA:     Output variable containing uncertainties in fit parameters.
;
;    YFIT:      Output variable containing the values of the dependent variable at
;               the X locations, according to the fit.
;
; OUTPUTS:
;    Returns the parameters of the linear fit. If X has dimensions [D1, D2, D3... DM],
;    and DIMENSION=N, then Result has dimensions [2, D1...DN-1, DN+1...DM].
;    Result[0,....] contains the constant term and Result[1,...] contains the slope.
;
; EXAMPLE:
;    seed = 43l
;    n = 10000L
;    x = 1e-3 * findgen(n)
;    y1 = x + randomn(seed, n)
;    y2 = 10. - 2 * x + 0.5 * randomn(seed, n)
;    x = [[x],[x]]
;    y = [[y1],[y2]]
;    
;    result = jblinfit(x, y, sigma=sigma, yfit=yfit, dimension=1)
;    
;    xax = [0,10]
;    cgplot, psym=3, x, y1, yrange=minmax(y), color='red'
;    cgplot, /overplot, psym=3, x, y2, color='blue'
;    cgplot, /overplot, xax, result[0,0] + result[1,0]*xax, color='red'
;    cgplot, /overplot, xax, result[0,1] + result[1,1]*xax, color='blue'
;    
;    cgtext, x[9000], yfit[9000,0] + 2, color='red', align=1, $
;      string(result[0,0], sigma[0,0], result[1,0], sigma[1,0], $
;      format='(%"y = (%0.2f +/- %0.2f) + (%0.3f +/- %0.3f) x")'), $
;      charsize=1.5
;    cgtext, x[9000], yfit[9000,1] - 3, color='blue', align=1, $
;      string(result[0,1], sigma[0,1], result[1,1], sigma[1,1], $
;      format='(%"y = (%0.2f +/- %0.2f) + (%0.3f +/- %0.3f) x")'), $
;      charsize=1.5
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    28 March 2011   Initial writing.
;
;-
function jblinfit, x, y, dimension=dimension, chisqr=chisqr, covar=covar, $
  measure_errors=measure_errors, prob=prob, sigma=sigma, yfit=yfit

; if not using dimension, just pass to LINFIT
if ~keyword_set(dimension) then return, linfit(x, y, chisqr=chisqr, covar=covar, $
  measure_errors=measure_errors, prob=prob, sigma=sigma, yfit=yfit)

; check dimensions of inputs
insize_x = size(x, /dimen)
insize_y = size(y, /dimen)
insize_err = size(measure_errors, /dimen)
if n_elements(insize_x) ne n_elements(insize_y) or $
  total(/int, insize_x ne insize_y) gt 0 then message, 'X and Y must have same dimensions.'
if n_elements(measure_errors) gt 0 then $
  if n_elements(insize_x) ne n_elements(insize_err) or $
    total(/int, insize_x ne insize_err) gt 0 then message, 'MEASURE_ERRORS must have same dimensions as X and Y.'

ndata = insize_x[dimension-1]

; use measure_errors=1 if not specified
if n_elements(measure_errors) eq 0 then measure_errors = replicate(1., insize_y)
; define 1 / sigma^2
inverse_errsq = 1. / measure_errors^2

; based on NR "Fitting Data to a Straight Line" section (15.2 in 2nd edition)
S = total(inverse_errsq, dimension)
Sx = total(x * inverse_errsq, dimension)
Sy = total(y * inverse_errsq, dimension)
formsize = insize_x
formsize[dimension-1] = 1
tval = (x - rebin(reform(Sx/S, formsize), insize_x, /samp)) / measure_errors
Stt = total(tval^2, dimension)

fit_slope = total(tval * y / measure_errors, dimension) / Stt
fit_const = (Sy - Sx * fit_slope) / S
err_slope = sqrt(1. / Stt)
err_const = sqrt((1. + Sx^2 / (S * Stt)) / S)

outsize = size(fit_const, /dimen)
noutsize = product(outsize, /int)

result = [reform(fit_const,[1,outsize]), reform(fit_slope,[1,outsize])]
sigma = [reform(err_const,[1,outsize]), reform(err_slope,[1,outsize])]
; apparently you can only nest 3 levels of [[[]]] and I would need 4 to
; do this elegantly:
covab = - Sx / (S * Stt)
covar = fltarr(2,2, noutsize)
covar[0,0,*] = reform(err_const^2, 1, 1, noutsize)
covar[0,1,*] = reform(covab, 1, 1, noutsize)
covar[1,0,*] = reform(covab, 1, 1, noutsize)
covar[1,1,*] = reform(err_slope^2, 1, 1, noutsize)
covar = reform(covar, [2, 2, outsize])

yfit = rebin(reform(fit_const,formsize), insize_x, /samp) + $
  rebin(reform(fit_slope, formsize), insize_x, /samp) * x
chisqr = total( (y - yfit)^2 * inverse_errsq, dimension )
prob = 1. - igamma(0.5 * (ndata - 2), 0.5 * chisqr)

return, result

end

