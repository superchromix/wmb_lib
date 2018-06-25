;+
; NAME:
;    QUAT2ROTAXIS
;
; PURPOSE:
;    Returns the net axis and angle of the rotation specified by the
;    input quaternion.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = QUAT2ROTAXIS(Quat)
;
; INPUTS:
;    Quat:    A quaternion specifying a rotation.
;
; OUTPUTS:
;    The function returns a 4-element vector. The first 3 elements are
;    the axis of the rotation and the 4th element is the
;    magnitude of the rotation in radians.
;
; EXAMPLE:
;    IDL> theta=!PI/3.
;    IDL> rm = [[COS(theta),0,-SIN(theta)],[0,1,0],[SIN(theta),0,COS(theta)]]
;    IDL> quat = MATRIX2QUATERNION(rm)
;    IDL> rotation = QUAT2ROTAXIS(quat)
;    IDL> PRINT, rotation
;          0.00000    -1.000000      0.00000     1.04720
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    27 Nov 2008   Released in JBIU
;
;-
function quat2rotaxis, quat

halftheta = acos(quat[3])
sintheta = sin(halftheta)

return, [quat[0]/sintheta, quat[1]/sintheta, quat[2]/sintheta, 2.0*halftheta]

end

