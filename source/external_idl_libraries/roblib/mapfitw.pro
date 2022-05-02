function mapfitw,map,ndeg,w,xxx,  single=precision
;+
; NAME:
;	MAPFITW
;
; PURPOSE:
;	Fit a 2D surface to a map through call to REGRESS. Each pixel in the map
;	may be given a weight. (If pixels have equal weight, SURFACE_FIT 
;	suffices.)
;
; CALLING SEQUENCE:
;	surface = MAPFITW( map,ndeg,w )
;
; INPUT:
;	map = array to fit, floating-point
; ndeg= degree in X and Y of polynomials to be fitted
;       Maximum degree = 7 (35 terms)
; W   = array of same size and type as map containing the pixel weights.
;
;RETURNS:
; The calculated fitted surface at each pixel: an array like the input array.
;
;KEYWORDS:
; SINGLE  if set, single precision is used. This should be done only if there
;         is not enough memory for the default double-precision calculations.
;
;SUBROUTINES NEEDED:
; REGRESS (in USERLIB)
;
;NOTE:
; This routine merely convert the pixel coordinates into a form REGRESS can 
; digest.
;
;AUTHOR: H.T. Freudenreich, HSTX, 3/16/94
;-

on_error,2

if keyword_set(precision) then singlep=1    else singlep=0

nterms=[1,3,5,9,14,20,27,35]
maxdeg = n_elements(nterms)

if ndeg gt maxdeg then begin
   PRINT,'MAPFITW: Maximum degree = 7!'
   return,map   
endif

; Get the needed dimensions:

syz=size(map)
nx=syz(1)   &   ny=syz(2)
ntot=nx*ny

if ntot lt nterms(ndeg) then begin
   print,'MAPFITW: Too few points!'
   return,0.
endif

z=reform(map,ntot)
wt=reform(w,ntot)

; Obtain (X,Y) coordinates of the pixels, if not already available:
get_coords=1
if n_elements(old_nx) ne 0 then begin
   if (old_nx eq nx) and (old_ny eq ny) then get_coords=0
endif 
old_nx = nx  & old_ny = ny

if n_elements(xxx) eq 0 then get_coords=1 else get_coords=0

if get_coords eq 1 then begin      
   u=findgen(nx)     &  v=findgen(ny)
   xx=fltarr(nx,ny)  &  yy=fltarr(nx,ny)
   for i=0,ny-1 do xx(*,i)=u  &  u=0
   for i=0,nx-1 do yy(i,*)=v  &  v=0
   x=reform(xx,ntot) & xx=0
   y=reform(yy,ntot) & yy=0 

   if (singlep eq 0) then begin
      x=double(x)  &  y=double(y)  
      xxx=dblarr(nterms(ndeg),ntot)
   endif else begin
      xxx=fltarr(nterms(ndeg),ntot)
   endelse

   xxx(0,*)=x     & xxx(1,*)=y

   if ndeg gt 1 then begin
      x2 = x*x       & y2 = y*y
      xxx(2,*)=x2    & xxx(3,*)=y2
      xxx(4,*)=x*y  

      if ndeg gt 2 then begin
         xxx(5,*)=x2*x   & xxx(6,*)=y2*y
         xxx(7,*)=x2*y   & xxx(8,*)=y2*x

         if ndeg gt 3 then begin
            xxx(9,*) =x2*x2    & xxx(10,*)=y2*y2
            xxx(11,*)=x2*x*y   & xxx(12,*)=y2*y*x
            xxx(13,*)=x2*y2
      
            if ndeg gt 4 then begin
               xxx(14,*)=x^5      & xxx(15,*)=y^5
               xxx(16,*)=x2*x2*y  & xxx(17,*)=y2*y2*x
               xxx(18,*)=x^3*y2   & xxx(19,*)=y^3*x2

               if ndeg gt 5 then begin
                  xxx(20,*)=x^6      & xxx(21,*)=y^6
                  xxx(22,*)=x^5*y    & xxx(23,*)=y^5*x
                  xxx(24,*)=x^4*y2   & xxx(25,*)=y^4*x2
                  xxx(26,*)=x^3*y^3  

                  if ndeg gt 6 then begin
                     xxx(27,*)=x^7      & xxx(28,*)=y^7
                     xxx(29,*)=x^6*y    & xxx(30,*)=y^6*x
                     xxx(31,*)=x^5*y2   & xxx(32,*)=y^5*x2
                     xxx(33,*)=x^4*y^3  & xxx(34,*)=y^4*x^3
                  endif
               endif
            endif
         endif
      endif
   endif
endif

if singlep eq 0 then begin 
   wt=double(wt)
   z=double(z)
endif
cc=regress(xxx,z,wt,zfit)

if ndeg gt 1 then zfit=float(zfit)

; Convert back to 2D:
pap=reform(zfit,nx,ny)

return,pap
end
