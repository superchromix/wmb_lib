;+
; NAME:
;    BIHARMONIC_INTERP
;
; PURPOSE:
;    Performs biharmonic interpolation for a function defined on a 2D grid.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = BIHARMONIC_INTERP(Z, X, Y, Xout, Yout)
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
;    A vector containing the value of the function biharmonically
;    interpreted at each Xout,Yout pair. The output will have the
;    same number of elements as Xout and Yout.
;
; EXAMPLE:
;    IDL> xgrid = [1.,2.]
;    IDL> ygrid = [2.,5.]
;    IDL> zvals = [ [10.,2.], [25.,15.] ]
;    IDL> PRINT, BIHARMONIC_INTERP(zvals, xgrid, ygrid, [1.3], [3.])
;          13.2745
;
; PROCEDURE:
;    Biharmonic interplation of Z(X,Y) is equivalent to bilinear
;    interpolation on the grid Z( log(X), log(Y) ), which is in fact
;    how it is calculated.
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    11 June 2008  Public release in JBIU
;-
function biharmonic_interp, z, x, y, xout, yout

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

xloc = lonarr(nout)
yloc = lonarr(nout)
for i=0L,nout-1 do begin
  wherearr = where(x[xsorti] ge xout[i],ngr)
  if (ngr eq 0) or (ngr eq xdim[0]) then message, 'Value lies outside of grid bounds'
  xloc[i] = wherearr[0]
  wherearr = where(y[xsorti] ge yout[i],ngr)
  if (ngr eq 0) or (ngr eq ydim[0]) then message, 'Value lies outside of grid bounds'
  yloc[i] = wherearr[0]
endfor

t = (alog(xout)-alog(x[xloc-1]))/(alog(x[xloc])-alog(x[xloc-1]))
u = (alog(yout)-alog(y[yloc-1]))/(alog(y[yloc])-alog(y[yloc-1]))

zout = (1.0-t)*(1.0-u)*z[xloc-1,yloc-1] + t*(1.0-u)*z[xloc,yloc-1] + $
    (1.0-t)*u*z[xloc-1,yloc] + t*u*z[xloc,yloc]

return, zout

end

  
  

