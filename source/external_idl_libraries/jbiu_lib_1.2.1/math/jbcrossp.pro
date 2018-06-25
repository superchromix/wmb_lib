;+
; NAME:
;    JBCROSSP
;
; PURPOSE:
;    Calculate the cross products between two arrays of 3-vectors.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = JBCROSSP(V1, V2)
;
; INPUTS:
;    V1:   First 3xN array.
;
;    V2:   Second 3xN array.
;
; OUTPUTS:
;    A 3xN array, where each Result[*,i] 3-vector is equal to
;    CROSSP(V1[*,i], V2[*,i]).
;
; EXAMPLE:
;    IDL> a = [ [0.1, -1.0, 3.5], [-1.0, -1.0, 4.0] ]
;    IDL> b = [ [0.2, -2.0, 7.0], [2.5, -2.5, 1.0] ]
;    IDL> PRINT, JBCROSSP(a,b)
;          0.00000      0.00000      0.00000
;          9.00000      11.0000      5.00000
;
; MODIFICATION HISTORY:
;     Written by:    Jeremy Bailin
;     12 June 2008   Public release in JBIU
;-
function jbcrossp, v1, v2

x = v1[1,*]*v2[2,*] - v1[2,*]*v2[1,*]
y = v1[2,*]*v2[0,*] - v1[0,*]*v2[2,*]
z = v1[0,*]*v2[1,*] - v1[1,*]*v2[0,*]

return, [x,y,z]

end

; Q. What do you get when you cross an elephant with a farmer?
; A. Element farmer sin theta.
; Q. What do you get when you cross an elephant with a fisherman?
; A. Element fisherman sin theta.
; Q. What do you get when you cross an elephant with a mountain climber?
; A. You can't cross a vector with a scaler.
