;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       RHTGRQUATERNION__DEFINE
;
; PURPOSE:
;       The purpose of this routine is to provide an easy mechanism
;       to store and manipulate model orientations for keyframe based
;       animations.  Quaternions do not suffer from the limitations
;       of the eular angle system such as Gimbal lock and they are
;       easy to interpolate.
;
;
; AUTHOR:
;       Rick Towler
;       NOAA National Marine Fisheries Service
;       Alaska Fisheries Science Center
;       Midwater Assesment/Conservation Engineering Group
;       7600 Sand Point Way NE
;       Seattle, WA  98115
;       rick.towler@noaa.gov
;       www.acoustics.washington.edu\~towler
;
;
; CATEGORY:
;       Object Graphics
;
;
; CALLING SEQUENCE:
;       oQuaternion = OBJ_NEW("RHTgrQuaternion" [, PITCH{Get, Set}=value{0 to 360}]
;               [, YAW{Get, Set}=value{0 to 360}] [, ROLL{Get, Set}=value{0 to 360}])
;
;
; KEYWORD PARAMETERS:
;
;   pitch:          A scalar defining the initial quaternion orientation about the
;                   X axis in degrees.
;
;                   Default: 0.
;
;   yaw:            A scalar defining the initial quaternion orientation about the
;                   Y axis in degrees.
;
;                   Default: 0.
;
;   roll:           A scalar defining the initial quaternion orientation about the
;                   Z axis in degrees.
;
;                   Default: 0.
;
;
; OBJECT METHODS:
;
;   GetCTM:         This function method returns a 4x4 transformation matrix
;                   representing the quaternion orientation.
;
;                   matrix = FLTARR(4,4)
;                   matrix = oQuaternion -> GetCTM()
;
;
;   GetDirectionVector: This function method returns a unit vector representing
;                       the object's current orientation as a 3 element float
;                       [X,Y,Z]
;
;                       vector = FLTARR(3)
;                       vector = oQuaternion -> GetDirectionVector()
;
;
;   GetPYR:         This function method returns the object's current orientation
;                   as a 3 element vector [pitch,yaw,roll] (as defined in the
;                   keywords section above).
;
;                   pyr = FLTARR(3)
;                   pyr = oQuaternion -> GetPYR()
;
;
;   GetQuat:        This function method returns the object's value
;                   as a 4 element float.  The values returned are in the form
;                   [w,x,y,z]
;
;                   q = DBLARR(4)
;                   q = oQuaternion -> GetQuat()
;
;
;   Interpolate:    This function method returns a quaternion in the form
;                   [w,x,y,z] which represents a spherically interpolated
;                   orientation based on the object's value, a "to" value,
;                   and a blend value ranging from 0.0 to 1.0.  A blend of
;                   0.0 will return this object's value and a blend of 1.0
;                   will return the "to" value.
;
;                   quat_one = OBJ_NEW('RHTgrQuaternion', pitch=0., yaw=0.)
;                   quat_two = OBJ_NEW('RHTgrQuaternion', pitch=50., yaw=270.)
;
;                   ;  get a quaternion with orientation halfway between
;                   ;  quat_one and quat_two
;                   q = DBLARR(4)
;                   q = quat_one -> Interpolate, quat_two -> GetQuat(), 0.5
;
;
;   Reset:          Reset the quaternion to the initial orientation.
;
;                   oQuaternion -> Reset
;
;
;   Set:            This procedure method will set the current orientation to the
;                   provided pitch, yaw, and roll values.
;
;                   oQuaternion -> Set, 15., 90., 0.
;
;
;   SetQuat:        This procedure method sets the object's value to the
;                   given value.  The value must be in the form:
;                   [w,x,y,z]
;
;                   quat_one = OBJ_NEW('RHTgrQuaternion')
;                   quat_two = OBJ_NEW('RHTgrQuaternion')
;
;                   <do something to quat_one>
;
;                   ;set quat_two equal to quat_one
;                   quat_two -> SetQuat, quat_one -> GetQuat()
;
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 01 November 2000.
;              RHT: 29 March 2002 - Added getPYR procedure.
;               DJ: Changed !RADEG to 180D / !DPI.
;
;
; LICENSE
;
;   QUATERNION__DEFINE.PRO Copyright (C) 2000-2003  Rick Towler
;
;   This program is free software; you can redistribute it and/or
;   modify it under the terms of the GNU General Public License
;   as published by the Free Software Foundation; either version 2
;   of the License, or (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the Free Software
;   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;
;   A full copy of the GNU General Public License can be found on line at
;   http://www.gnu.org/copyleft/gpl.html#SEC1
;
;-


;   RHTgrQuaternion::init {{{
function RHTgrQuaternion::init, eyespace=eyespace, $
                                pitch=pitch, $
                                yaw=yaw, $
                                roll=roll

    COMPILE_OPT idl2

    self.eyespace = KEYWORD_SET(eyespace)

    if (N_ELEMENTS(pitch) eq 0) then pitch = 0.
    if (N_ELEMENTS(yaw) eq 0) then yaw = 0.
    if (N_ELEMENTS(roll) eq 0) then roll = 0.

    self.dRadeg = 180D / !DPI

    self -> Set,  pitch, yaw, roll

    self.initial = self -> GetQuat()

    RETURN, 1

end
;   }}}


;   RHTgrQuaternion::Set {{{
pro RHTgrQuaternion::Set, x, y, z
    ;  Set the rotation angles (in degrees) around the x, y and z axes

    compile_opt idl2

    if (N_ELEMENTS(x) eq 1) and (N_ELEMENTS(y) eq 1) and $
            (N_ELEMENTS(z) eq 1) then begin

        if (self.eyespace) then begin
            xQ = self -> AxisAngle2Quat (-x, 1.0, 0.0, 0.0)
            yQ = self -> AxisAngle2Quat (-y, 0.0, 1.0, 0.0)
        endif else begin
            xQ = self -> AxisAngle2Quat (x, 1.0, 0.0, 0.0)
            yQ = self -> AxisAngle2Quat (y, 0.0, 1.0, 0.0)
        endelse
        zQ = self -> AxisAngle2Quat (z, 0.0, 0.0, 1.0)

        self.q = yQ

        self -> PostMult, xQ
        self -> PostMult, zQ

        self -> Normalize
    endif

end
;   }}}


;   RHTgrQuaternion::GetPYR {{{
function RHTgrQuaternion::GetPYR
    ;  return a 3 element vector [p,y,r] representing the quat's orientation.

    compile_opt idl2

    transform = self -> getCTM()

    yaw = ASIN(transform[2])
    if (self.eyespace) then yaw = -yaw
    c =  COS(yaw)
    yaw = yaw * self.dRadeg

    if (ABS(yaw) > 0.005D) then begin

        trx =  transform[10] / c
        try = -transform[6]  / c

        pitch  = ATAN(try,trx) * self.dRadeg
        if (self.eyespace) then pitch = -pitch

        trx = transform[0] / c
        try = -transform[1] / c

        roll = ATAN(try,trx) * self.dRadeg

    endif else begin

      pitch = 0D

      trx = transform[5]
      try = transform[4]

      roll = ATAN(try,trx) * self.dRadeg

    endelse

    if (pitch lt 0D) then pitch = pitch + 360D
    if (yaw lt 0D) then yaw = yaw + 360D
    if (roll lt 0D) then roll = roll + 360D

    RETURN, [pitch,yaw,roll]

end
;   }}}


;   RHTgrQuaternion::GetCTM {{{
Function RHTgrQuaternion::GetCTM
    ;  return a 4x4 transform matrix representing the quaternion's orientation.

    compile_opt idl2

    matrix = DBLARR(4,4)

    w = self.q[0]
    x = self.q[1]
    y = self.q[2]
    z = self.q[3]

    x2 = x + x
    y2 = y + y
    z2 = z + z
    xx = x * x2
    xy = x * y2
    xz = x * z2
    yy = y * y2
    yz = y * z2
    zz = z * z2
    wx = w * x2
    wy = w * y2
    wz = w * z2

    matrix[0,0] = 1.0D - (yy + zz)
    matrix[1,0] = xy - wz
    matrix[2,0] = xz + wy

    matrix[0,1] = xy + wz
    matrix[1,1] = 1.0D - (xx + zz)
    matrix[2,1] = yz - wx

    matrix[0,2] = xz - wy
    matrix[1,2] = yz + wx
    matrix[2,2] = 1.0D - (xx + yy)

    matrix[3,3] = 1.0D

    RETURN, matrix

end
;   }}}


;   RHTgrQuaternion::GetDirectionVector {{{
function RHTgrQuaternion::GetDirectionVector
    ;  Return a unit vector representing the current orientation.

    compile_opt idl2

    w = self.q[0]
    x = self.q[1]
    y = self.q[2]
    z = self.q[3]

    if (self.eyespace) then begin
        dirX = -2.0 * (x * z - w * y)
        dirY = -2.0 * (y * z + w * x)
    endif else begin
        dirX = 2.0 * (x * z - w * y)
        dirY = 2.0 * (y * z + w * x)
    endelse
    dirZ = -1.0 + 2.0 * (x * x + y * y)

    RETURN, [dirX, dirY, dirZ]

end
;   }}}


;   RHTgrQuaternion::GetQuat {{{
function RHTgrQuaternion::GetQuat
    ;  return the 4 element quaternion.

    compile_opt idl2

    RETURN, self.q
end
;   }}}


;   RHTgrQuaternion::Reset {{{
pro RHTgrQuaternion::Reset
    ;  reset to the initial orientation.

    compile_opt idl2

    self.q = self.initial
end
;   }}}


;   RHTgrQuaternion::SetQuat {{{
pro RHTgrQuaternion::SetQuat, q
    ;  set the 4 element quaternion.

    compile_opt idl2

    if (N_ELEMENTS(q) eq 4) then begin
        self.q = q
        self -> Normalize
    endif

end
;   }}}


;   RHTgrQuaternion::Quat2AxisAngle {{{
function RHTgrQuaternion::Quat2AxisAngle
    ;  return the 4 element axis/angle values of the current orientation.

    compile_opt idl2

    axisangle = DBLARR(4)

    tw = ACOS(self.q[0]) * 2.0
    scale = SIN(tw / 2.0)

    axisangle = self.q / scale

    axisangle[0] = (tw * 180.0) / !PI

    RETURN, axisangle

end
;   }}}


;   RHTgrQuaternion::Interpolate {{{
function RHTgrQuaternion::Interpolate, qTo, blend
    ;interpolate from the object's current orientation (self.q) to
    ;a new orientation, qTo, using spherical linear interpolation.
    ;Adapted from: Watt and Watt, Advanced Animation p. 364

    compile_opt idl2

    if (N_ELEMENTS(qTo) eq 4) and (N_ELEMENTS(blend) eq 1) then begin

        blend = 0D > blend < 1D
        delta = 0.001D
        qResult = DBLARR(4)

        cosom = TOTAL(self.q * qTo)

        if (cosom lt 0) then begin
            cosom = -cosom
            self.q = -self.q
        endif

        if ((1D - cosom) gt delta) then begin
            omega = ACOS(cosom)
            sinom = SIN(omega)
            scale0 = SIN((1D - blend) * omega) / sinom
            scale1 = SIN(blend * omega) / sinom
        endif else begin
            scale0 = 1D - blend
            scale1 = blend
        endelse

        qResult = (scale0 * self.q) + (scale1 * qTo)

        RETURN, qResult
    endif

end
;   }}}


;   RHTgrQuaternion::AxisAngle2Quat {{{
function RHTgrQuaternion::AxisAngle2Quat, angle, x, y, z

    compile_opt idl2

    q = DBLARR(4)
    rangle = angle * !DTOR

    scale = SQRT(x^2 + y^2 + z^2)
    x = x / scale
    y = y / scale
    z = z / scale

    q[0] = COS(rangle / 2.0D)
    sinHalfAngle = SIN(rangle / 2.0D)
    q[1] = x * sinHalfAngle
    q[2] = y * sinHalfAngle
    q[3] = z * sinHalfAngle

    RETURN, q

end
;   }}}


;   RHTgrQuaternion::PostMult {{{
pro RHTgrQuaternion::PostMult, quat

    compile_opt idl2

    if (N_ELEMENTS(quat) eq 4) then self -> MultAndSet, self.q, quat

end
;   }}}


;   RHTgrQuaternion::MultAndSet {{{
pro RHTgrQuaternion::MultAndSet, quat1, quat2

    compile_opt idl2

    self.q[0] = quat2[0] * quat1[0] - $
                quat2[1] * quat1[1] - $
                quat2[2] * quat1[2] - $
                quat2[3] * quat1[3]

    self.q[1] = quat2[0] * quat1[1] + $
                quat2[1] * quat1[0] + $
                quat2[2] * quat1[3] - $
                quat2[3] * quat1[2]

    self.q[2] = quat2[0] * quat1[2] - $
                quat2[1] * quat1[3] + $
                quat2[2] * quat1[0] + $
                quat2[3] * quat1[1]

    self.q[3] = quat2[0] * quat1[3] + $
                quat2[1] * quat1[2] - $
                quat2[2] * quat1[1] + $
                quat2[3] * quat1[0]

    self -> Normalize

end
;   }}}


;   RHTgrQuaternion::Normalize {{{
pro RHTgrQuaternion::Normalize

    compile_opt idl2

    scale = SQRT(TOTAL(self.q^2))
    self.q = self.q / scale

end
;   }}}


;   RHTgrQuaternion::cleanup {{{
pro RHTgrQuaternion::cleanup

    compile_opt idl2

end
;   }}}


;   RHTgrQuaternion__define {{{
pro RHTgrQuaternion__define

    struct = {RHTgrQuaternion, $
              dRadeg:0D, $
              eyespace:0B, $
              q:DBLARR(4), $
              initial:DBLARR(4) $
             }

end
;   }}}

