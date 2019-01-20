;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       RHTGRPSOLID__DEFINE
;
; PURPOSE:
;
;       The RHTgrPSolid class implements the 5 platonic solids in
;       IDL object graphics.  These simple graphics objects are
;       useful in testing as placeholders for more complicated objects.
;
; AUTHOR:
;       Rick Towler
;       School of Aquatic and Fishery Sciences
;       University of Washington
;       Box 355020
;       Seattle, WA 98195-5020
;       rtowler@u.washington.edu
;
;
; CATEGORY: Object Graphics
;
;
; CALLING SEQUENCE:
;
;   oModel = OBJ_NEW('RHTgrPsolid' [,/TETRAHEDRON] [,/HEXAHEDRON] $
;               [,/OCTAHEDRON] [,/ICOSAHEDRON] [,/DODECAHEDRON] $
;               [,POSITION={x,y,z}] [,RADIUS=float])
;
;
; KEYWORDS:
;           The RHTgrPSolid object accepts the keywords of it's parent
;           IDLgrModel and the IDLgrPolygon class as well as the following
;           keywords:
;
;       dodecahedron:   Set this keyword to create the 12 faced polygon
;                       object known as the dodecahedron.
;
;;        hexahedron:   Set this keyword to create the 6 faced polygon
;                       object known as the hexahedron.
;
;        icosohedron:   Set this keyword to create the 20 faced polygon
;                       object known as the icosohedron.
;
;         octahedron:   Set this keyword to create the 8 faced polygon
;                       object known as the dodecahedron.
;
;        tetrahedron:   Set this keyword to create the 4 faced polygon
;                       object known as the dodecahedron.
;
;
; METHODS:
;
;       GetProperty:
;
;       SetProperty:
;
;
; DEPENDENCIES: None.
;
;
; EXAMPLE:
;
;       oTetra = OBJ_NEW('RHTgrPSolid', /TETRAHEDRON, COLOR=[255,0,0], $
;           STYLE=1, RADIUS=3, POSITION=[0,0,10])
;
;
; LIMITATIONS:
;
;       Manipulating this object's transformation matrix outside of the
;       POSITION and RADIUS keywords can yield undesireable results.
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 27 October 2002.
;
;
; LICENSE
;
;   RHTGRPSOLID__DEFINE.PRO Copyright (C) 2002  Rick Towler
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
;   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;   02111-1307, USA.
;
;   A full copy of the GNU General Public License can be found on
;   line at http://www.gnu.org/copyleft/gpl.html#SEC1
;
;-


;   RHTgrPSolid::Init {{{
function RHTgrPSolid::Init, tetrahedron=tetra, $
                            hexahedron=hexa, $
                            octahedron=octa, $
                            dodecahedron=dodeca, $
                            icosahedron=icosa, $
                            radius=radius, $
                            position=position, $
                            _extra=extra

    case 1 of
        (KEYWORD_SET(tetra)):nfaces=4
        (KEYWORD_SET(hexa)):nfaces=6
        (KEYWORD_SET(octa)):nfaces=8
        (KEYWORD_SET(dodeca)):nfaces=12
        (KEYWORD_SET(icosa)):nfaces=20
        else:nfaces=4
    endcase

    self.position = (N_ELEMENTS(position) ne 3) ? [0.,0.,0.] : position
    self.radius = (N_ELEMENTS(radius) ne 1) ? 1.0 : radius

    ok = self->IDLgrModel::Init(/SELECT_TARGET, _Extra=extra)
    if (not ok) then RETURN, 0

    self.oPolygon = OBJ_NEW('IDLgrPolygon', _EXTRA=extra)
    self -> Add, self.oPolygon

    self -> MeshSolid, nfaces
    self -> Scale, self.radius, self.radius, self.radius
    self -> Translate, self.position[0], self.position[1], $
        self.position[2]

    RETURN, 1

end
;   }}}


;   RHTgrPSolid::MeshSolid {{{
pro RHTgrPSolid::MeshSolid, nfaces

    compile_opt idl2

    case nfaces of
        4:begin
            a = SQRT(2.)/3.
            b = SQRT(6.)/3.
            c = 1./3.
            vertices = [[0.,0.,1.], $
                        [2*a,0.,-c], $
                        [-a, b,-c], $
                        [-a, -b,-c]]

            polygons = [3,0,1,2, $
                        3,0,2,3, $
                        3,0,3,1, $
                        3,1,3,2]
        end

        6:begin
            vertices = [[-1.,-1.,-1.], $
                        [1.,-1.,-1.], $
                        [1.,1.,-1.], $
                        [-1.,1.,-1.], $
                        [-1.,-1.,1], $
                        [1.,-1.,1.], $
                        [1.,1.,1.], $
                        [-1.,1.,1.]]
            vertices = TEMPORARY(vertices) / SQRT(3.0)

            polygons = [3,0,3,2, $
                        3,0,2,1, $
                        3,0,1,5, $
                        3,0,5,4, $
                        3,0,4,7, $
                        3,0,7,3, $
                        3,6,5,1, $
                        3,6,1,2, $
                        3,6,2,3, $
                        3,6,3,7, $
                        3,6,7,4, $
                        3,6,4,5]
        end

        8:begin
            vertices = [[1.,0.,0.], $
                        [-1.,0.,0.], $
                        [0.,1.,0.], $
                        [0.,-1.,0.], $
                        [0.,0.,1.], $
                        [0.,0.,-1.]]

            polygons = [3,4,0,2, $
                        3,4,2,1, $
                        3,4,1,3, $
                        3,4,3,0, $
                        3,5,2,0, $
                        3,5,1,2, $
                        3,5,3,1, $
                        3,5,0,3]
        end

        12:begin
            a = 1. / SQRT(3.)
            b = SQRT((3. - SQRT(5.))/6.)
            c = SQRT((3. + SQRT(5.))/6.)

            vertices = [[a,a,a], $
                        [a,a,-a], $
                        [a,-a,a], $
                        [a,-a,-a], $
                        [-a,a,a], $
                        [-a,a,-a], $
                        [-a,-a,a], $
                        [-a,-a,-a], $
                        [b,c,0.], $
                        [-b,c,0.], $
                        [b,-c,0.], $
                        [-b,-c,0.], $
                        [c,0.,b], $
                        [c,0.,-b], $
                        [-c,0.,b], $
                        [-c,0.,-b], $
                        [0.,b,c], $
                        [0.,-b,c], $
                        [0.,b,-c], $
                        [0.,-b,-c]]

            polygons = [3,0,8,9, $
                        3,0,9,4, $
                        3,0,4,16, $
                        3,0,12,13, $
                        3,0,13,1, $
                        3,0,1,8, $
                        3,0,16,17, $
                        3,0,17,2, $
                        3,0,2,12, $
                        3,8,1,18, $
                        3,8,18,5, $
                        3,8,5,9, $
                        3,12,2,10, $
                        3,12,10,3, $
                        3,12,3,13, $
                        3,16,4,14, $
                        3,16,14,6, $
                        3,16,6,17, $
                        3,9,5,15, $
                        3,9,15,14, $
                        3,9,14,4, $
                        3,6,11,10, $
                        3,6,10,2, $
                        3,6,2,17, $
                        3,3,19,18, $
                        3,3,18,1, $
                        3,3,1,13, $
                        3,7,15,5, $
                        3,7,5,18, $
                        3,7,18,19, $
                        3,7,11,6, $
                        3,7,6,14, $
                        3,7,14,15, $
                        3,7,19,3, $
                        3,7,3,10, $
                        3,7,10,11]

        end
        20:begin

            a = 1. + SQRT(5.)

            vertices = [[a,1.,0.], $
                        [-a,1.,0.], $
                        [a,-1.,0.], $
                        [-a,-1.,0.], $
                        [1.,0.,a], $
                        [1.,0.,-a], $
                        [-1.,0.,a], $
                        [-1.,0.,-a], $
                        [0.,a,1.], $
                        [0.,-a,1.], $
                        [0.,a,-1.], $
                        [0.,-a,-1.]]

            vertices = TEMPORARY(vertices) / SQRT(1. + a^2)

            polygons = [3,0,8,4, $
                        3,0,5,10, $
                        3,2,4,9, $
                        3,2,11,5, $
                        3,1,6,8, $
                        3,1,10,7, $
                        3,3,9,6, $
                        3,3,7,11, $
                        3,0,10,8, $
                        3,1,8,10, $
                        3,2,9,11, $
                        3,3,11,9, $
                        3,4,2,0, $
                        3,5,0,2, $
                        3,6,1,3, $
                        3,7,3,1, $
                        3,8,6,4, $
                        3,9,4,6, $
                        3,10,5,7, $
                        3,11,7,5]
        end
    endcase

    self.oPolygon -> SetProperty, DATA=vertices, POLYGONS=polygons

end
;   }}}


;   RHTgrPSolid::SetProperty {{{
pro RHTgrPSolid::SetProperty,   tetrahedron=tetra, $
                                hexahedron=hexa, $
                                octahedron=octa, $
                                dodecahedron=dodeca, $
                                icosahedron=icosa, $
                                radius=radius, $
                                position=position, $
                                _extra=extra

    compile_opt idl2

    update = 0B

    self -> IDLgrModel::SetProperty, _EXTRA=extra
    self.oPolygon -> SetProperty, _EXTRA=extra

    if (KEYWORD_SET(tetra)) then self -> MeshSolid, 4
    if (KEYWORD_SET(hexa)) then self -> MeshSolid, 6
    if (KEYWORD_SET(octa)) then self -> MeshSolid, 8
    if (KEYWORD_SET(dodeca)) then self -> MeshSolid, 12
    if (KEYWORD_SET(icosa)) then self -> MeshSolid, 20

    if (N_ELEMENTS(position) eq 3) then begin
        update = 1B
        self.position = position
    endif

    if (N_ELEMENTS(radius) eq 1) then begin
        update = 1B
        self.radius = radius
    endif

    if (update) then begin
        self -> Reset
        self -> Scale, self.radius, self.radius, self.radius
        self -> Translate, self.position[0], self.position[1], $
            self.position[2]
    endif

end
;   }}}


;   RHTgrPSolid::GetProperty {{{
pro RHTgrPSolid::GetProperty,   object=object, $
                                _ref_extra=extra


    compile_opt idl2

    object = self.oPolygon

    self -> IDLgrModel::GetProperty, _EXTRA=extra
    self.oPolygon -> GetProperty, _EXTRA=extra

end
;   }}}


;   RHTgrPSolid::Cleanup {{{
pro RHTgrPSolid::Cleanup

    compile_opt idl2

    OBJ_DESTROY, self.oPolygon

    self->IDLgrModel::Cleanup

end
;   }}}


;   RHTgrPSolid__Define {{{
pro RHTgrPSolid__Define

    struct={RHTgrPSolid, $
            Inherits IDLgrModel, $
            oPolygon:OBJ_NEW(), $
            radius:0., $
            position:FLTARR(3) $
           }

end
;   }}}



