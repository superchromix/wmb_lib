;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       RHTGRAABB__DEFINE
;
; PURPOSE:
;
;       This program implements an axially aligned bounding box class
;       for use in spatial partitioning, collision detection,
;       view setup, or whatever else your creative mind can come up
;       with.  The bounding box is represented in position-extent form.
;
;       RHTgrAABB is a child of IDLgrModel but allows only IDLgrModel
;       objects to be added to itself.
;
;       Empty models return a bounding box with a position of
;       [0,0,0] and extents of [0,0,0] and are ignored when
;       calculating a bounding box that contains geometry.
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
; CATEGORY: Object Graphics
;
;
; CALLING SEQUENCE:
;
;   oAABB = OBJ_NEW('RHTgrAABB', [oModel], [, COLOR=index or RGB vector]
;                   [, DOUBLE{Get, Set}={0 | 1}], [, /SHOWBOUNDS {Get, Set}])
;
;
; KEYWORDS:
;
;       Color:          Set this keyword to a 3 element vector specifying the
;                       color of the bounding box
;
;                       DEFAULT: [128,128,128]
;
;       Double:         Set this keyword to store and return the bounding box
;                       position and extents in double precision.
;
;                       DEFAULT: 0
;
;       ShowBounds:     Set this keyword to make the bounds of the bounding box
;                       visible when drawn.
;
;                       DEFAULT: 0
;
;
; METHODS:
;
;       Add:            This procedure method adds a model (or models) to the
;                       bounding box.  You can only add IDLgrModels or children
;                       of IDLgrModel.  You cannot add children of IDLgrGraphic
;                       a.k.a. graphics "atoms".  Care should be taken when
;                       constructing the object hierarchy being added to the
;                       bounding box.  Extraneous instances of IDLgrModel in the
;                       object hierarchy will slow the calculation of the bounding
;                       box.  After adding the new model(s) the bounding box
;                       updates it's position and extents properties.
;
;                       EXAMPLE: oAABB -> Add, [oModelA, oModelB]
;
;
;       Bisect:         This function method bisects the bounding box about the
;                       specified axis and location and returns two structures [left,
;                       right] containing information about the objects in the
;                       bisected halves.  If an object spans the bisecting axis it will
;                       appear in both the left and right structures.  The returned
;                       data structures have the following form:
;
;                       left = {position:[0.,0.,0.], extents:[0.,0.,0.],
;                       models:OBJARR(), nmodels:0L}
;                       right = {position:[0.,0.,0.], extents:[0.,0.,0.],
;                       models:OBJARR(), nmodels:0L}
;
;                       where position is the position (center) of the left or right
;                       bounding box created by the bisection, extents is the
;                       extents of this bounding box, and models contains an array
;                       of object references specifying the models contained within
;                       the box.  Nmodels contains a long representing the number
;                       of models contained within the bounding box.
;
;                       Set the AXIS argument to 0,1, or 2 to specify bisection
;                       along the X, Y, or Z axis respectively.  Set the LOCATION
;                       argument to specify where on the axis to cut the bounding
;                       box.
;
;                       Set the DUPLICATES keyword to return a 2xn array containing
;                       the index values of left.models and right.models respectivly
;                       that span the bisecting axis.
;
;                       This method is under construction.
;
;
;       GetAABB:        This procedure method updates the position and extents
;                       properties and optionally returns this data to the caller.
;                       This procedure method must be called if any of the objects
;                       contained in the bounding box have changed (models have
;                       been manipulated, vertices changed, coordinate
;                       conversions altered).  Set the ALL keyword to return
;                       positions and extents for all models that have been added to
;                       the bounding box.
;
;
;       Intersects:     This function method tests the intersection between this
;                       bounding box and another.  The other bounding box can be
;                       either a valid reference to another instance of RHTgrAABB
;                       or it can be provided via the POSITION and EXTENTS
;                       keywords.  You must provide either a reference to a second
;                       RHTgrAABB object or both the POSITION and
;                       EXTENTS keywords.  The function returns TRUE (1) if
;                       the two bounding boxes intersect and FALSE (0) if they do
;                       not.
;
;
;       Remove:         This procedure method removes a model from the
;                       bounding box.  Set the ALL keyword to remove all models
;                       contained within the bounding box.  After removing the
;                       model(s) the bounding box updates it's position and extents
;                       properties.
;
;
; DEPENDENCIES:         RHTgrAABB.dlm
;
;
; EXAMPLE:
;
;
; LIMITATIONS:      This object acts as a container for IDLgrModel objects only.
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 27 October 2002.
;
;
; LICENSE
;
;   RHTgrAABB__DEFINE.PRO Copyright (C) 2002-2003  Rick Towler
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


;   RHTgrAABB::Init {{{
function RHTgrAABB::Init,   oModel, $
                            color=color, $
                            double=double, $
                            showBounds=showBounds, $
                            _extra=extra

    self.double = KEYWORD_SET(double)
    self.showBounds = (N_ELEMENTS(showBounds) ne 1) ? 0B : $
        KEYWORD_SET(showBounds)
    self.pPositions = PTR_NEW(-1)
    self.pExtents = PTR_NEW(-1)
    color = (N_ELEMENTS(color) ne 3) ? [180,180,180] : color

    ok = self -> IDLgrModel::Init(_EXTRA=extra)
    if (not ok) then RETURN, 0B

    polygons = [4,0,3,2,1, $
                4,3,7,6,2, $
                4,7,4,5,6, $
                4,4,0,1,5]

    self.oPolyObj = OBJ_NEW('IDLgrPolygon', COLOR=color, $
        HIDE=1 xor self.showBounds, POLYGONS=polygons, STYLE=1, $
        _EXTRA=extra)
    self -> IDLgrModel::Add, self.oPolyObj

    if (N_ELEMENTS(oModel) gt 0) then begin
        self ->Add, oModel, OK=ok, _EXTRA=extra
        if (not ok) then RETURN, 0B
    endif

    RETURN, 1B

end
;   }}}


;   RHTgrAABB::Add {{{
pro RHTgrAABB::Add,     oModel, $
                        ok=ok, $
                        _extra=extra

    ;  Add a model to the bounding box.

    compile_opt IDL2

    CATCH, error
    if (error ne 0) then begin
        CATCH, /CANCEL
        MESSAGE, 'Object reference type required', /CONTINUE
        RETURN
    endif

    ok = 0B
    nObjects = N_ELEMENTS(oModel)
    nValid = TOTAL(OBJ_VALID(oModel))

    if (nValid eq nObjects) then begin

        models = OBJ_ISA(oModel, 'IDLgrModel')

        if (TOTAL(models) eq nObjects) then begin

            self -> IDLgrModel::Add, oModel, _EXTRA=extra
            null = self -> Get(/ALL, COUNT=nObjs, ISA='IDLgrModel')

            *self.pPositions = MAKE_ARRAY(3, nObjs + 1, DOUBLE=self.double)
            *self.pExtents = MAKE_ARRAY(3, nObjs + 1, DOUBLE=self.double)

            self -> GetAABB

            ok = 1B

        endif else begin

            MESSAGE, 'Object(s) must be, or be subclasses of, ' + $
                'IDLgrModel', /CONTINUE

        endelse

    endif

end
;   }}}


;   RHTgrAABB::Remove {{{
pro RHTgrAABB::Remove,  oModel, $
                        all=all

    ;  Remove a model from the Bounding Box

    compile_opt IDL2

    all = KEYWORD_SET(all)

    if (all) then begin

        self -> IDLgrModel::Remove, /ALL
        self -> IDLgrModel::Add, self.oPolyObj

        *self.pPositions = -1
        *self.pExtents =  -1

        vertices = FLTARR(3,8)
        self.oPolyObj -> SetProperty, DATA=vertices

    endif else begin

        nObjects = N_ELEMENTS(oModel)
        nValid = TOTAL(OBJ_VALID(oModel))

        if (nValid eq nObjects) then begin

            models = OBJ_ISA(oModel, 'IDLgrModel')

            if (TOTAL(models) eq nObjects) then begin

                self -> IDLgrModel::Remove, oModel
                null = self -> Get(/ALL, COUNT=nObjs, ISA='IDLgrModel')

                *self.pPositions = MAKE_ARRAY(3, nObjs + 1, DOUBLE=self.double)
                *self.pExtents = MAKE_ARRAY(3, nObjs + 1, DOUBLE=self.double)

                self -> GetAABB

            endif

        endif

    endelse

end
;   }}}


;   RHTgrAABB::GetAABB {{{
pro RHTgrAABB::GetAABB,     all=all, $
                            extents=extents, $
                            position=position

    compile_opt IDL2

    all = KEYWORD_SET(all)

    if (N_ELEMENTS(*self.pPositions) lt 3) then begin
        MESSAGE, 'Bounding box is empty.', /CONTINUE
        position = *self.pPositions
        extents = *self.pExtents
        RETURN
    endif

    bBox = self -> CalcBB(self, /TOP)

    if (ARG_PRESENT(position)) then $
        if (all) then position = (*self.pPositions)[*,1:*] $
            else position = (*self.pPositions)[*,0]
    if (ARG_PRESENT(extents)) then $
        if (all) then extents = (*self.pExtents)[*,1:*] $
            else extents = (*self.pExtents)[*,0]

    if (self.showBounds) then begin
        position = (*self.pPositions)[*,0]
        extents = (*self.pExtents)[*,0]
        vertices = [[position + (extents * [-1,1,1])], $
                    [position + (extents * [1,1,1])], $
                    [position + (extents * [1,-1,1])], $
                    [position + (extents * [-1,-1,1])], $
                    [position + (extents * [-1,1,-1])], $
                    [position + (extents * [1,1,-1])], $
                    [position + (extents * [1,-1,-1])], $
                    [position + (extents * [-1,-1,-1])]]
        self.oPolyObj -> SetProperty, DATA=vertices
    endif
end
;   }}}


;   RHTgrAABB::Intersects {{{
function RHTgrAABB::Intersects, oAABB, $
                                extents=extents, $
                                position=position

    ;  Test intersection between this bounding box and another.

    compile_opt idl2

    error = 0B

    if (OBJ_VALID(oAABB)) then begin
        if (OBJ_ISA(oAABB, 'RHTgrAABB')) then $
            oAABB -> GetProperty, POSITION=position, EXTENTS=extents $
        else error = 1B
    endif else $
        if (not ((N_ELEMENTS(extents) eq 3) and $
            (N_ELEMENTS(position) eq 3))) then error = 1B

    if (error) then begin
        MESSAGE, 'You must pass either a valid reference to an AABB' + $
            ' object or supply both the extents and position vectors', /CONTINUE
        RETURN, 0B
    endif

    aTob = (*self.pPositions)[*,0] - position
    overlap = ABS(aTob) le ((*self.pExtents)[*,0] + extents)

    RETURN, (TOTAL(overlap) eq 3)

end
;   }}}


;   RHTgrAABB::Bisect {{{
function RHTgrAABB::Bisect, axis, $
                            location, $
                            duplicates=duplicates

    ;  Bisect bounding box - return left and right pos, ext, and contents.
    ;
    ;       axis = 0 split X axis
    ;       axis = 1 split Y axis
    ;       axis = 2 split Z axis

    compile_opt idl2

    duplicates = [[-1],[-1]]

    ;  Clamp the bisecting axis.
    axis = 0 > axis < 2

    ;  Calculate the bounding box range [min,max]
    range = [[(*self.pPositions)[*,0] - (*self.pExtents)[*,0]], $
             [(*self.pPositions)[*,0] + (*self.pExtents)[*,0]]]

    ;  Get the contents of the bounding box.
    oContained =  self -> Get(/ALL, COUNT=nContained, $
        ISA='IDLgrModel')

    case 1 of

        (location le range[axis,0]):begin

            ;  Bisection to the left of the bounding box.
            right = {position:(*self.pPositions)[*,0], $
                extents:(*self.pExtents)[*,0], models:oContained, $
                nModels:nContained}
            left = {position:[0.,0.,0.], extents:[0.,0.,0.], $
                models:OBJ_NEW(), nModels:0L}

        end
        (location ge range[axis,1]):begin

            ;  Bisection to the right of the bounding box.
            left = {position:(*self.pPositions)[*,0], $
                extents:(*self.pExtents)[*,0], models:oContained, $
                nModels:nContained}
            right = {position:[0.,0.,0.], extents:[0.,0.,0.], $
                models:OBJ_NEW(), nModels:0L}

        end
        else:begin

            ;  Bisection thru bounding box.
            nLeft = 0L
            nRight = 0L
            lModels = OBJ_NEW()
            rModels = OBJ_NEW()

            ;  Calculate left position and extents.
            lPosition = (*self.pPositions)[*,0]
            lExtents = (*self.pExtents)[*,0]
            lPosition[axis] = (location + range[axis,0]) / 2.
            lExtents[axis] = location - lPosition[axis]

            ;  Calculate right position and extents.
            rPosition = (*self.pPositions)[*,0]
            rExtents = (*self.pExtents)[*,0]
            rPosition[axis] = location + ((range[axis,1] - location) / 2.)
            rExtents[axis] = rPosition[axis] - location

            for n=0, nContained-1 do begin

                ;  Determine left contents.
                intersectL = TOTAL(ABS(lPosition - (*self.pPositions)[*,n+1]) le $
                    (lExtents + (*self.pExtents)[*,n+1])) eq 3
                if (intersectL) then begin
                    if (nLeft eq 0) then lModels=oContained[n] else $
                        lModels = [lModels, oContained[n]]
                    nLeft = nLeft + 1L
                endif

                ;  Determine right contents.
                intersectR = TOTAL(ABS(rPosition - (*self.pPositions)[*,n+1]) le $
                    (rExtents + (*self.pExtents)[*,n+1])) eq 3
                if (intersectR) then begin
                    if (nRight eq 0) then rModels=oContained[n] else $
                        rModels = [rModels, oContained[n]]
                    nRight = nRight + 1L
                endif

                if (intersectL and intersectR) then duplicates = $
                    [duplicates,[[nLeft-1],[nRight-1]]]

            endfor

            if ((SIZE(duplicates))[1] gt 1) then duplicates = duplicates[1:*,*]

            left = {position:lPosition, extents:lExtents, $
                models:lModels, nModels:nLeft}
            right = {position:rPosition, extents:rExtents, $
                models:rModels, nModels:nRight}
        end

    endcase

    RETURN, {left:left, right:right}

end
;   }}}


;   RHTgrAABB::GetProperty {{{
pro RHTgrAABB::GetProperty, all=all, $
                            double=double, $
                            extents=extents, $
                            position=position, $
                            range=range, $
                            showBounds=showBounds, $
                            _ref_extra=extra

    compile_opt idl2

    all = KEYWORD_SET(all)

    double = self.double
    if (all) then begin
        extents = *self.pExtents
        position = *self.pPositions
    endif else begin
        extents = (*self.pExtents)[*,0]
        position = (*self.pPositions)[*,0]
    endelse
    range = [[position - extents], $
             [position + extents]]
    showBounds = self.showBounds

    self -> IDLgrMODEL::GetProperty, _Extra=extra
    self.oPolyObj -> GetProperty, _Extra=extra

end
;   }}}


;   RHTgrAABB::SetProperty {{{
pro RHTgrAABB::SetProperty, double=double, $
                            extents=extents, $
                            position=position, $
                            showBounds=showBounds, $
                            _extra=extra

    compile_opt idl2

    if (N_ELEMENTS(double) eq 1) then self.double = KEYWORD_SET(double)
    if (N_ELEMENTS(extents) eq 3) then $
        *self.pExtents = (self.double) ? DOUBLE(extents) : FLOAT(extents)
    if (N_ELEMENTS(position) eq 3) then $
        *self.pPositions = (self.double) ? DOUBLE(position) : FLOAT(position)
    if (N_ELEMENTS(showBounds) eq 1) then self.showBounds = KEYWORD_SET(showBounds)

    self -> IDLgrModel::SetProperty, _EXTRA=extra

    if (self.showBounds) then begin
        position = (*self.pPositions)[*,0]
        extents = (*self.pExtents)[*,0]
        vertices = [[position + (extents * [-1,1,1])], $
                    [position + (extents * [1,1,1])], $
                    [position + (extents * [1,-1,1])], $
                    [position + (extents * [-1,-1,1])], $
                    [position + (extents * [-1,1,-1])], $
                    [position + (extents * [1,1,-1])], $
                    [position + (extents * [1,-1,-1])], $
                    [position + (extents * [-1,-1,-1])]]
        self.oPolyObj -> SetProperty, DATA=vertices, HIDE=0
    endif else self.oPolyObj -> SetProperty, /HIDE
end
;   }}}


;   RHTgrAABB::CalcBB {{{
function RHTgrAABB::CalcBB, oModel, $
                            top=top, $
                            transform=transform

    ;  Calculate the bounding box containing the provided model.

    compile_opt IDL2

    top = KEYWORD_SET(top)

    ;  Get all of the objects contained in the model.  Filter oPolyObj.
    if (top) then oContained =  oModel -> Get(/ALL, COUNT=nContained, $
        ISA='IDLgrModel') else oContained =  oModel -> Get(/ALL, $
        COUNT=nContained)

    ;  Get this model's transform matrix.
    oModel -> GetProperty, TRANSFORM=thisTransform

    ;  Compound transformations.
    if (N_ELEMENTS(transform) ne 16) then $
        transform = thisTransform else $
        transform = thisTransform # transform

    ;  Loop thru objects contained in this model.
    for n=0L, nContained-1 do begin
        if (OBJ_ISA(oContained[n], 'IDLgrModel')) then begin

            ;  Calculate the bounding box for this model.
            bBox = self -> CalcBB(oContained[n], TRANSFORM=transform[*,*])

        endif else begin

            ;  Get this atom's data range and "coordinate conversion".
            oContained[n] -> IDLgrGraphic::GetProperty, XRANGE=xRange, $
                YRANGE=yRange, ZRANGE=zRange, XCOORD_CONV=xCoordConv, $
                YCOORD_CONV=yCoordConv, ZCOORD_CONV=zCoordConv

            ;  Calculate this atom's bounding box.
            bBox = RHTgrAABB_CalcBB(xRange, yRange, zRange, xCoordConv, $
                yCoordConv, zCoordConv, transform)

        endelse

        ;  Grow box.
        if (N_ELEMENTS(minMax) ne 0) then begin
            if (bBox[0,2]) then begin
                minMax[*,0] = minMax[*,0] < bBox[*,0]
                minMax[*,1] = bBox[*,1] >  minMax[*,1]
            endif
        endif else minMax = bBox

    endfor

    ;  Calculate position and extents - handle empty models.
    if (N_ELEMENTS(minMax) eq 0) then begin
        minMax = REPLICATE(0., 3, 3)
        extents = [0., 0., 0.]
        position = [0., 0., 0.]
    endif else begin
        extents = (minMax[*,1] - minMax[*,0]) * 0.5
        position = minMax[*,0] + extents
    endelse

    ;  Store position and extents - if needed.
    if (top) then begin
        (*self.pExtents)[*,0] = extents
        (*self.pPositions)[*,0] = position
    endif else begin
        inTop = self -> IsContained(oModel, POSITION=pos)
        if (inTop) then begin
            (*self.pExtents)[*,pos] = extents
            (*self.pPositions)[*,pos] = position
        endif
    endelse

    ;  Return this model's extents in min/max form.
    RETURN, minMax

end
;   }}}


;   RHTgrAABB::Cleanup {{{
pro RHTgrAABB::Cleanup

    compile_opt idl2

    OBJ_DESTROY, self.oPolyObj

    PTR_FREE, [self.pExtents, self.pPositions]

    self -> IDLgrModel::Cleanup

end
;   }}}


;   RHTgrAABB__Define {{{
pro RHTgrAABB__Define

    struct={RHTgrAABB, $
            inherits IDLgrModel, $

            double:0B, $
            oPolyObj:OBJ_NEW(), $
            pExtents:PTR_NEW(), $
            pPositions:PTR_NEW(), $
            showBounds:0B $
           }

end
;   }}}


