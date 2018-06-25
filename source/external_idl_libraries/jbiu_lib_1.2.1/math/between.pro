;+
; NAME:
;    BETWEEN
;
; PURPOSE:
;    Determines if the argument lies between the bounds.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = BETWEEN(Lowerbound, Argument, Upperbound)
;
; INPUTS:
;    Lowerbound: Scalar or array of lower bounds.
;
;    Argument:   Scalar or array of numerical argument.
;
;    Upperbound: Scalar or array of upper bounds.
;
; KEYWORD PARAMETERS:
;    GTSTRICT:  Argument must be strictly greater than Lowerbound,
;                rather than greater or equal to.
;
;    LTSTRICT:  Argument must be strictly less than Upperbound,
;                rather than less or equal to.
;
; OUTPUTS:
;    Outputs 1 for any element where Argument is between Lowerbound and
;    Upperbound, and 0 for all other elements. Values equal to Lowerbound
;    and Upperbound return 1 unless overridden by /GTSTRICT and/or /LTSTRICT.
;    Each of the inputs may be either a scalar or an array, but if more than
;    one are arrays then they must have the same numbers of elements.
;
; EXAMPLE:
;    IDL> print, between(2.5, [0,1,2,3,4], 7.)
;       0   0   0   1   1
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    18 July 2009   Public release in JBIU
;-
function between, lowerbound, argument, upperbound, gtstrict=gtp, ltstrict=ltp

narg = n_elements(argument)
nlower = n_elements(lowerbound)
nupper = n_elements(upperbound)

; each of narg, nlower and nupper must either be 1, or equal to any other
; that aren't 1.
allnum = [narg,nlower,nupper]
allnum = allnum[sort(allnum)]
uniqn = uniq(allnum)
if n_elements(uniqn) gt 2 or allnum[0] eq 0 then $
  message, 'Each of Argument, Lowerbound and Upperbound must either be a scalar or have the same number of elements as any others that are not scalars.'

if ~keyword_set(gtp) and ~keyword_set(ltp) then $
  return, argument ge lowerbound and argument le upperbound
if ~keyword_set(gtp) and keyword_set(ltp) then $
  return, argument ge lowerbound and argument lt upperbound
if keyword_set(gtp) and ~keyword_set(ltp) then $
  return, argument gt lowerbound and argument le upperbound
if keyword_set(gtp) and keyword_set(ltp) then $
  return, argument gt lowerbound and argument lt upperbound

end

