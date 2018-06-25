;+
; NAME:
;    MATRIX2QUATERNION
;
; PURPOSE:
;    Transforms a rotation matrix into a quaternion.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = MATRIX2QUATERNION(Rotmatrix)
;
; INPUTS:
;    Rotmatrix:   A 3x3 rotation matrix.
;
; OUTPUTS:
;    The function returns the quaternion corresponding to the rotation
;    specified by the rotation matrix.
;
; EXAMPLE:
;    IDL> theta=!PI/3.
;    IDL> rm = [[COS(theta),0,-SIN(theta)],[0,1,0],[SIN(theta),0,COS(theta)]]
;    IDL> quat = MATRIX2QUATERNION(rm)
;    IDL> PRINT, quat
;          0.00000    -0.50000      0.00000     0.866025
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    27 Nov 2008   Released in JBIU
;
;-
function matrix2quaternion, rotmatrix

tr = trace(rotmatrix)

if tr gt 0 then begin
  qs = 0.5/sqrt(tr+1.)
  qw = 0.25/qs
  qx = (rotmatrix[1,2] - rotmatrix[2,1]) * qs
  qy = (rotmatrix[2,0] - rotmatrix[0,2]) * qs
  qz = (rotmatrix[0,1] - rotmatrix[1,0]) * qs
endif else begin
  bigval = max(rotmatrix[indgen(3),indgen(3)], coli)
  colj = (coli + 1) mod 3
  colk = (coli + 2) mod 3
  qs = 0.5 / sqrt(rotmatrix[coli,coli] - (rotmatrix[colj,colj] + $
    rotmatrix[colk,colk]) + 1.)
  if not finite(qs) then qs=0.
  qarr = fltarr(4)
  qarr[coli] = 0.25/qs
  qarr[3] = (rotmatrix[colj,colk] - rotmatrix[colk,colj]) * qs
  qarr[colj] = (rotmatrix[coli,colj] + rotmatrix[colj,coli]) * qs
  qarr[colk] = (rotmatrix[coli,colk] + rotmatrix[colk,coli]) * qs
  qx = qarr[0]
  qy = qarr[1]
  qz = qarr[2]
  qw = qarr[3]
endelse

return, [qx,qy,qz,qw]

end

  

