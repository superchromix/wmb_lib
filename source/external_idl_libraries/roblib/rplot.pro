PRO RPLOT,X,Y,CUT=NUMSIG, _EXTRA=TOPPINGS 
;+
; NAME:
;	RPLOT
; PURPOSE:  
;	Autoscaled plot of glitchy data. Short horizontal bars on the left of 
;	the plot denote the allowed Y range.
;
; CALLING SEQUENCE:
;	RPLOT, X, Y, [ CUT= , _EXTRA= ] 
;			or
;	RPLOT, Y, [ CUT = , _EXTRA = ]
;
; INPUT ARGUMENTS:
;	X   = the independent variable [OPTIONAL]
;	Y   = the dependent variable
;
; OPTIONAL INPUT KEYWORDS:
;	CUT = the number of sigmas from the mean at which the data are to be 
;	clipped.  (Actually uses median and interquartile range.) Default = 3.0
;
;	RPLOT will accept any keyword accepted by the PLOT command.
; NOTES:  
;	The interquartile range is used to estimate the dispersion of the data
;       Points out of range are given the value of the ceiling or floor. If
;       there is a trend in the data that is large compared to the noise, the
;       ends may be cut off.
;
; EXAMPLES:
;	RPLOT,X,Y,CUT=4.0, PSYM=1,SYMSIZ=.5
;		or
;	RPLOT,Y,CUT=2.5, PSYM=1,SYMSIZ=.5
;
; REVISION HISTORY:
;	H.T. Freudenreich, HSTX, 3/91. _EXTRA added 2/94
;-

on_error,1

if not keyword_set(numsig) then sigcut=3.0 else sigcut=numsig

if n_params() eq 1 then z=x else z=y

n = n_elements(z)
s = sort(z)
a = z(s)
ymed = a(n/2)
ymin = ymed - sigcut*1.481*(ymed-a(n/4))
ymax = ymed + sigcut*1.481*(a(3*n/4)-ymed)
q=where(z gt ymax,n) & if n gt 0 then z(q)=ymax
q=where(z lt ymin,n) & if n gt 0 then z(q)=ymin

y1=[ymax,ymax]
y2=[ymin,ymin]
if n_params() eq 1 then begin
   plot,z,_extra=toppings 
;  Now mark the limits:
   x1=[!x.crange(0),!x.crange(0)+(!x.crange(1)-!x.crange(0))/20.]
   oplot,x1, y1,line=0
   oplot,x1, y2,line=0
endif else begin
   plot,x,z,_extra=toppings 
;  Now mark the limits:
   x1=[!x.crange(0),!x.crange(0)+(!x.crange(1)-!x.crange(0))/20.]
   oplot,x1, y1,line=0
   oplot,x1, y2,line=0
endelse

return
end

