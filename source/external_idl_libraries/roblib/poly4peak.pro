function poly4peak,coef

; Finds the maximum of a 4th degree polynomial c0+c1x+c2x^2+c3x^3+c4x^4
; Called by HALFAGAUSS
; INPUT: COEFFICIENTS OF POLYNOMIAL. RETURNS: THE LOCATION OF THE MAX.
;
help,coef
cc=[coef(1),2.*coef(2),3.*coef(3),4.*coef(4)]
roots=cuberoot(cc)
q=where(roots gt -1.0e29,count)
if count lt 1 then begin
   print,'POLY4PEAK: No Real Roots!'
   return,-1.0e30
endif
roots=roots(q)
y=coef(0)+coef(1)*roots+coef(2)*roots^2+coef(3)*roots^3+coef(4)*roots^4
q=where(y eq max(y),count)
if count gt 1 then begin
   print,'POLY4PEAK: More Than 1 Maximum!'
   return,-1.0e30
endif
peak_x = roots(q(0))
peak_y = max(y)
return,[peak_x,peak_y]
end
