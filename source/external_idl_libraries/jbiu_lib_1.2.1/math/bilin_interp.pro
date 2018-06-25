;+
; NAME:
;    BILIN_INTERP
;
; PURPOSE:
;    Performs bilinear interpolation for a function defined on a 2D grid.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = BILINC_INTERP(Z, X, Y, Xout, Yout)
;
; INPUTS:
;    Z:     2D array containing the values of the function defined at each
;           X,Y grid point. The first dimension of Z must have the same length
;           as X and the second dimension must have the same length as Y.
;
;    X:     Vector containing the x-locations of the grid points at which
;           the function is defined.
;
;    Y:     Vector containing the y-locations of the grid points at which
;           the function is defined.
;
;    Xout:  A vector of x-locations at which the function is to be interpolated.
;
;    Yout:  A vector of y-locations at which the function is to be interpolated.
;
; OUTPUTS:
;    A vector containing the value of the function bilinearly
;    interpreted at each Xout,Yout pair. The output will have the
;    same number of elements as Xout and Yout.
;
; EXAMPLE:
;    IDL> xgrid = [1.,2.]
;    IDL> ygrid = [2.,5.]
;    IDL> zvals = [ [10.,2.], [25.,15.] ]
;    IDL> PRINT, BILIN_INTERP(zvals, xgrid, ygrid, [1.3], [3.])
;          12.4000
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    11 June 2008  Public release in JBIU
;-
function bilin_interp, z, x, y, xout, yout

if size(z,/n_dimen) ne 2 then message, 'Z must be a 2D array'
if size(x,/n_dimen) ne 1 then message, 'X must be a vector'
if size(y,/n_dimen) ne 1 then message, 'Y must be a vector'

zdim = size(z,/dimen)
xdim = size(x,/dimen)
ydim = size(y,/dimen)

if zdim[0] ne xdim[0] then message, 'Dimensions of Z and X do not match'
if zdim[1] ne ydim[0] then message, 'Dimensions of Z and Y do not match'
if n_elements(xout) ne n_elements(yout) then message, 'Dimension of XOUT and YOUT do not match'
nout = n_elements(xout)

xsorti = sort(x)
ysorti = sort(y)

xloc = bsearch(x, xout, /missing_ignore)
yloc = bsearch(y, yout, /missing_ignore)

t = (xout-x[xloc])/(x[xloc+1]-x[xloc])
u = (yout-y[yloc])/(y[yloc+1]-y[yloc])

zout = (1.0-t)*(1.0-u)*z[xloc,yloc] + t*(1.0-u)*z[xloc+1,yloc] + $
    (1.0-t)*u*z[xloc,yloc+1] + t*u*z[xloc+1,yloc+1]

return, zout

end

  
  

