;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       RHTGRCAMERA__DEFINE
;
; PURPOSE:
;       This routine implements a virtual-camera object class for use in
;       rendering scenes in IDL object graphics.
;
;       The camera object allows intuitive control of object graphics scene
;       composition. There are two basic methods for specifying the
;       camera's view, the axis-angle method and the look-at method.  The
;       axis-angle method defines the orientation as a series of rotations
;       about x, y, and z, axes.  The look-at method centers the view on the
;       defined look at point.
;
;       See the HTML docs for more information.
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
;     oCamera = Obj_New("RHTgrCamera", [, CAMERA_LOCATION{Get, Set}=[x,y,z]]
;               [, COLOR{Get, Set}=index or RGB vector] [, DEPTH_CUE{Get, Set}=[zbright, zdim]]
;               [, DIMENSIONS{Get, Set}=[width, height]] [, /DOUBLE {Get, Set}]
;               [, LOCATION{Get, Set}=[x, y]] [, /LOCK{Get, Set] [, FORCE_AR{Get, Set}={0 | 1}]
;               [, PITCH{Get, Set}=value{0 to 360}] [, EYE{Set}=value] [, FOV{Get, Set}=value]
;               [, ROLL{Get, Set}=value{0 to 360}] [,THIRD_PERSON{Get, Set}=value]
;               [, /TRACK{Get, Set}] [, /TRANSPARENT{Get, Set}] [, UNITS{Get, Set}={0 | 1 | 2 | 3}]
;               [, UVALUE{Get, Set}=value] [, VIEWPLANE_DIMS{Get, Set}=[width, height]]
;               [, YAW{Get, Set}=value{0 to 360}] [, ZERROR{Get, Set}=value] [, ZOOM{Get, Set}=value])
;
;
;
; KEYWORDS:
;
;   This object inherits keywords from it's superclass, IDLgrView.  Note that this object
;   denies SET access to the EYE, VIEWPLANE_RECT, ZCLIP, and PROJECTION properties.
;   Attempts to set these properties thru the Init and SetProperty methods will be ignored.
;   The RHTgrCamera object adds (or modifies) the following keywords:
;
;  CAMERA_LOCATION: Set this keyword to a 3 element vector [x,y,z] that defines
;                   the camera's position in world space.
;
;                   Default: [0.,0.,1.]
;
;
;        DEPTH_CUE: Set this keyword to a 2 element vector [zbright, zdim] specifying the
;                   the near and far Z planes between which depth cueing is in effect.
;                   Depth (Z) distance is measured in positive units away from the camera.
;                   For example, if the DEPTH_CUE property is set to [5,10] an object
;                   would start to fade into the background 5 units from the camera
;                   and would fade completely into the background 10 units from the camera.
;
;                   zbright < zdim, rendering darkens with depth
;                   zbringt > zdim, rendering lightens with depth
;                   zbright = zdim, no depth cueing
;
;                   Default: [0.0, 0.0]
;
;
;         FORCE_AR: Set this keyword to lock the pixel aspect ratio based on
;                   the camera's viewplane dimensions and the initial dimensions
;                   of the destination object.  Subsequent changes to the
;                   dimensions of the destination object will result in changes
;                   to the viewplane dimensions to preserve the initial pixel
;                   aspect ratio.  In other words, use this keyword to ensure that
;                   window resizing doesn't change your pixel aspect ratio.
;
;                   Default: 0
;
;
;              FOV: Set this keyword to a 2 element vector [width, height]
;                   specifying the camera's natural (unzoomed) field of view
;                   in degrees .  You can only set this property via the camera's
;                   SETPROPERTY method.  0 > FOV < 180
;
;                   Default: None.  Defined by frustum dims.
;
;
;     FRUSTUM_DIMS: Set this keyword to a 3 element vector [width, height, depth] that
;                   defines the camera's viewing volume.  Objects contained within the
;                   view volume are rendered, objects outside of the view volume are not.
;
;                   Default: [2.0, 2.0, 4.0]
;
;
;             LOCK: Set this keyword to lock the camera to prevent rolling when
;                   simultaneously changing the pitch and yaw while panning. This
;                   roll is a result of normal quaternion rotation but can be
;                   disorienting and by default is suppressed.  If you desire true
;                   quaternion rotation, set this keyword to 0.
;
;                   Default: 1
;
;
;            PITCH: Set this keyword to a scalar defining the pitch (rotation about the
;                   X axis) of the camera in degrees. 0 > pitch < 360
;
;                   Default: 0.0
;
;
;             ROLL: Set this keyword to a scalar defining the roll (rotation about the
;                   Z axis) of the camera in degrees. 0 > roll < 360
;
;                   Default: 0.0
;
;
;     THIRD_PERSON: Set this keyword to a scalar defining the number of units the
;                   camera will lag behind the defined camera position.  This creates
;                   a simple 3rd person effect. Setting this keyword equal to 0 will
;                   disable it.
;
;                   Default: 0.0
;
;
;              YAW: Set this keyword to a scalar defining the yaw (rotation about the
;                   Y axis) of the camera in degrees. 0 > yaw < 360
;
;                   Default: 0.0
;
;
;           ZERROR: Set this keyword to a scalar defining, in relative terms, the precision
;                   of the Z buffer.  Poor precision results in "flimmering" where objects
;                   close to one another randomly show thru each other, usually at distance.
;                   Note that increasing Z buffer precision by setting ZERROR to a small
;                   value will increase the distance between the eye and the near clipping
;                   plane which will limit how "close" you can get to objects before they
;                   are clipped.  Conversely, setting ZERROR to a large value will bring the
;                   eye right up to the near clipping plane allowing you to get very
;                   close to objects but at the same time reducing the precision of the Z
;                   buffer at distance.
;
;                   Default: 6.0
;
;
;             ZOOM: Set this keyword to a scalar defining the zoom factor of the
;                   camera.  Setting zoom < 0 will zoom the camera out (increasing
;                   field of view) while setting zoom > 0 will zoom it in (decreasing
;                   field of view).  The default field of view of the camera (zoom = 0)
;                   depends on the frustum dimensions (as set by either the FRUSTUM_DIMS
;                   or FOV keywords).
;
;                   Default: 0.0
;
;
; METHODS:
;
;   This object inherits methods from it's superclass, IDLgrView, and adds or modifies the
;   following methods:
;
;
;   Add:            This procedure method adds a model to the camera's view.
;                   Models added to the camera will be rendered if they fall within
;                   the viewing volume.
;
;                   Set the POSITION keyword to specify where the model should be
;                   added relative to the models currently contained within the
;                   camera.  The POSITION keyword will be ignored if the DYNAMIC and
;                   STATIC keywords are set.
;
;                   Set the DYNAMIC keyword to add the model(s) as dynamically
;                   culled content.  During transformation, the extent of dynamic
;                   models is determined and any models falling completly outside
;                   the viewing frustum will not be rendered.
;
;                   The performance of dynamic view frustum culling depends on
;                   many factors.  Follow the hints provided in the HTML
;                   documentation and experiment.
;
;                   Set the STATIC keyword to add the model(s) as statically
;                   culled content.  A binary tree is constructed to spatialy
;                   partition the static model space.  During transformation,
;                   this tree is traversed to determine which models fall within
;                   the view frustum.  Models outside the view frustum will not be
;                   rendered.  Static model geometry and transformations must not
;                   be modified after being added to the camera.
;
;                   Set the MOTHER keyword to add the model(s) as non-culled,
;                   NON-TRANSFORMED content.  These models will not be transformed
;                   when the camera is moved, nor will the camera's clipping planes
;                   be applied to them.  While not of any general interest, you can
;                   use the MOAM (motherOfAllModels) to do some special tricks.
;
;
;   GetDirectionVector: This function method returns a unit vector representing
;                       the current camera orientation.
;
;
;   Lookat:         This procedure method changes the camera's orientation by
;                   calculating a direction vector from the camera's position
;                   to a given point in space, a.k.a. the lookat point. The
;                   lookat point is in world units.
;
;                   Set the TRACK keyword to force the camera to follow your
;                   lookat point thru subsequent transformations.
;
;                   To point the camera at [5,10,20]:
;
;                   oCamera -> Lookat, [5,10,20]
;
;
;   Pan:            This procedure method changes the camera's orientation by
;                   changing it's pitch and yaw.  The values passed are the
;                   changes in pitch and yaw in degrees.
;
;                   To pan the camera 15 deg. to the right and 5 deg. down:
;
;                   oCamera -> Pan, 15.0, -5.0
;
;
;   Roll:           This procedure method roll's the camera about the z axis.
;                   The value passed is the change in roll in degrees. Positive
;                   values roll clockwise, negative values roll counterclockwise.
;
;                   To roll the camera 10 degrees about the Z axis:
;
;                   oCamera -> Roll, 10.0
;
;
;   SetClipPlanes:  This procedure method applies clipping planes to the scene
;                   using the CLIP_PLANES property of IDLgrModel.  You supply a
;                   4xN array [A,B,C,D] which defines the planes Ax+By+Cz+d=0.  See
;                   the documentation for IDLgrModel for more info.
;
;                   Many graphics accelerators do not have optimized rendering
;                   routines for OpenGL clipping planes.  Others do.  Using this
;                   feature can have dramatic affects on performance.  Good or bad.
;                   If rendering performance is key to your application you would
;                   benefit from comparing performance of the clipping planes vs
;                   the performance of the camera's culling system.
;
;                   Clipping plane coordinates are in *view space* not world space.
;
;
;                   To set 4 clipping places (right, left, top, and bottom) given
;                   8 vertices (fv) defining a box:
;
;                        ;  "right" plane
;                        u = fv[*,5] - fv[*,1]
;                        v = fv[*,6] - fv[*,1]
;                        n = crossp(v,u)
;                        n = n / SQRT(TOTAL(n^2))
;                        cpr = [n,total(n*(-fv[*,1]))]
;
;                        ;  "left" plane
;                        u = fv[*,4] - fv[*,0]
;                        v = fv[*,7] - fv[*,0]
;                        n = crossp(u,v)
;                        n = n / SQRT(TOTAL(n^2))
;                        cpl = [n,total(n*(-fv[*,1]))]
;
;                        ;  "top" plane
;                        u = fv[*,5] - fv[*,1]
;                        v = fv[*,4] - fv[*,1]
;                        n = crossp(u,v)
;                        n = n / SQRT(TOTAL(n^2))
;                        cpt = [n,total(n*(-fv[*,1]))]
;
;                        ;  "bottom" plane
;                        u = fv[*,6] - fv[*,3]
;                        v = fv[*,7] - fv[*,3]
;                        n = crossp(v,u)
;                        n = n / SQRT(TOTAL(n^2))
;                        cpb = [n,total(n*(-fv[*,1]))]
;
;                        ;  Set the camera's cutting planes
;                        camera -> SetClipPlanes, [[cpr],[cpl],[cpt],[cpb]]
;
;
;
;   Truck:          This procedure method 'moves' the camera along a defined axis
;                   relative to the current orientation.  You must define
;                   the axis to move along [x, y, z] and a distance to move the
;                   camera in world units.
;
;                   To move the camera forward 10 units:
;
;                   oCamera -> Truck, [0, 0, 1], 10.
;
;
;   Zoom:           This procedure method "zooms" the camera by specified zoom
;                   factor.  Setting ZOOM equal to 0 disables zooming.
;
;                   To zoom in the camera so that your subject is ~5 times it's size:
;
;                   oCamera -> Zoom, 5.
;
;
;
; DEPENDENCIES:     RHTgrCamera.dlm
;                   RHTgrAABB__define.pro
;                   RHTgrAABB.dlm
;                   RHTgrQuaternion__define.pro
;
;
; EXAMPLE:
;               Please see the example programs.
;
;
; LIMITATIONS:
;
;               The camera *always* uses a perspective based projection.
;
;               The ADD method ignores the POSITION keyword when the DYNAMIC or
;               STATIC keywords are set.
;
;
; LICENSE
;
;   RHTGRCAMERA__DEFINE.PRO Copyright (C) 2001-2005  Rick Towler
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


;   RHTgrCamera::Init {{{
function RHTgrCamera::Init,     camera_location=cameraLocation, $
                                eye=eye, $
                                force_AR=forceAR, $
                                frustum_dims=viewDims, $
                                lock=lock, $
                                lookat=lookat, $
                                pitch=pitch, $
                                projection=projection, $
                                roll=roll, $
                                third_person=thirdPerson, $
                                track=track, $
                                viewplane_rect=viewRect, $
                                yaw=yaw, $
                                zclip=zclip, $
                                zoom=zoom, $
                                zError=zError, $
                                _extra=extra

    ;  Process keywords.
    lookat = (N_ELEMENTS(lookat) ne 3) ? [0.,0.,0.] : lookat
    self.viewDims = (N_ELEMENTS(viewDims) ne 3) ? [2.,2.,4.] : viewDims
    self.cameraLocation = (N_ELEMENTS(cameraLocation) NE 3) ? [0.,0.,1.] : $
        cameraLocation
    self.lock = (N_ELEMENTS(lock) ne 1) ? 1B : KEYWORD_SET(lock)
    self.aspectRatio[0] = KEYWORD_SET(forceAR)
    self.pitch = (N_ELEMENTS(pitch) ne 1) ? 0. : pitch
    self.roll = (N_ELEMENTS(roll) ne 1) ? 0. : roll
    self.thirdPerson = (N_ELEMENTS(thirdPerson) ne 1) ? 0. : thirdPerson
    self.track =  KEYWORD_SET(track)
    self.yaw = (N_ELEMENTS(yaw) ne 1) ? 0. : yaw
    self.zoom = (N_ELEMENTS(zoom) ne 1) ? [0.,1.] : [zoom,1.]
    self.zError = (N_ELEMENTS(zError) ne 1) ? 8. : 0.0001 > zError < 1000.

    ;  Initialize objects.
    self.oQuatA = OBJ_NEW('RHTgrQuaternion', /EYESPACE)
    self.oQuatB = OBJ_NEW('RHTgrQuaternion', /EYESPACE)
    self.oOrientation = OBJ_NEW('RHTgrQuaternion', PITCH=pitch, YAW=yaw, $
        ROLL=roll, /EYESPACE)
    self.oDynamicModel = OBJ_NEW('RHTgrAABB', /DOUBLE)
    self.oStaticModel = OBJ_NEW('RHTgrAABB', /DOUBLE)
    self.oCamModel = OBJ_NEW('IDLgrModel')
    self.oMotherOfAllModels = OBJ_NEW('IDLgrModel')

    ;  Initialize pointers.
    self.pDynamicMask = PTR_NEW(-1)
    self.pDynamicModels = PTR_NEW(-1)
    self.pStaticMask = PTR_NEW(-1)
    self.pStaticModels = PTR_NEW(-1)
    self.pTempMask = PTR_NEW(-1)
    self.pRootNode = self -> GetRootNode(/NULL)

    ;  Set Double RADEG - D. Jackson
    self.dRadeg = 180D / !DPI

    ;  Calculate viewing rectangle based on view dimensions.
    self.viewRect = [(-self.viewDims[0] / 2.), (-self.viewDims[1] / 2.), $
        self.viewDims[0], self.viewDims[1]]

    ;  Initialize the superclass.
    ok = self -> IDLgrView::Init(VIEWPLANE_RECT=self.viewRect, PROJECTION=2, $
        _EXTRA=extra)
    if (not ok) then RETURN, 0B

    ;  Set z clipping planes.
    self.zclip = [self.viewDims[2] / 2D, -self.viewDims[2] / 2D]

    ;  Set eye.  Assume 16bit z buffer precision.
    self.eye[2] = self.zclip[0] + ((self.zclip[0]^2 + self.zError * $
        self.zclip[0]) / (65536. * self.zError))

    ;  Calculate the view Z offset.
    self.viewZ = self.eye[2] - self.thirdPerson

    ;  Adjust depth cueing.
    self.dcue = self.depth_cue
    self.depth_cue = self.dcue - self.viewZ

    ;  Calculate field of view.
    self.fov = [ATAN((self.view[2] / 2.) / self.eye[2]), $
        ATAN((self.view[3] / 2.) / self.eye[2])]

    ;  Calculate viewing frustum vertices.
    self.frustum = RHTgrCamera_ComputeFrustum(self.zclip, self.fov, $
        self.eye[2], PLANES=planes)
    self.frustPlanes = planes

    ;  Zoom.
    if (self.zoom[0] ne 0.) then self -> Zoom, self.zoom[0]

    ;  Add the base models to the view.
    self.oMotherOfAllModels -> Add, [self.oStaticModel, self.oDynamicModel, $
        self.oCamModel]
    self -> IDLgrView::Add, self.oMotherOfAllModels

    RETURN, 1B

end
;   }}}


;   RHTgrCamera::Add {{{
pro RHTgrCamera::Add,   oModel, $
                        binTreeStruct=binTreeStruct, $
                        dynamic=dynamic, $
                        mother=mother, $
                        static=static, $
                        position=position, $
                        _extra=extra

    ;  Add IDLgrModel objects to camera.

    compile_opt idl2

    CATCH, error
    if (error ne 0) then begin
       CATCH, /CANCEL
       MESSAGE, !Error_State.Msg, /CONTINUE
       RETURN
    endif

    dynamic = KEYWORD_SET(dynamic)
    mother = KEYWORD_SET(mother)
    static = KEYWORD_SET(static)
    nModels = N_ELEMENTS(oModel)

    ;  Check that we have been passed only models
    models = OBJ_ISA(oModel, 'IDLgrModel')
    if (TOTAL(models) ne nModels) then begin
        MESSAGE, 'Objects must be, or be subclasses of IDLgrModel', $
            /CONTINUE
        RETURN
    endif

    case 1 of

        ;  Add model as dynamicaly culled content.
        dynamic: begin

            ;  Reset the object's HIDE property.
            for n=0, nModels-1 do oModel[n] -> SetProperty, HIDE=0

            ;  Add model as dynamic content.
            self.oDynamicModel -> Add, oModel, _EXTRA=extra
            *self.pDynamicModels = self.oDynamicModel -> Get(/ALL, $
                COUNT=nDynamic, ISA='IDLgrModel')
            self.nDynamic = nDynamic

            ;  Set initial HIDE state and visibility mask
            transform = RHTgrCamera_Transform(self.oOrientation -> GetCTM(), $
                self.cameraLocation, self.viewZ)
            self.oDynamicModel -> SetProperty, TRANSFORM=transform
            self.oDynamicModel -> GetAABB, POSITION=pos, EXTENTS=ext, /ALL
            inview = RHTgrCamera_AABBIntersectFrustum(pos, ext, self.frustPlanes)
            *self.pDynamicMask = inView
            for n=0L, self.nDynamic-1 do $
                (*self.pDynamicModels)[n] -> SetProperty, $
                    HIDE=1 xor (*self.pDynamicMask)[n]

        end

        ;  Add model as statically culled content.
        static: begin

            ;  Reset the object's HIDE property.
            for n=0, nModels-1 do oModel[n] -> SetProperty, HIDE=0

            ;  Add model as static content.
            self.oStaticModel -> Reset
            self.oStaticModel -> Add, oModel, _EXTRA=extra
            *self.pStaticModels = self.oStaticModel -> Get(/ALL, $
                COUNT=nStatic, ISA='IDLgrModel')
            self.nStatic = nStatic
            *self.pTempMask = REPLICATE(1B, self.nStatic)

            ;  Construct binary tree.
            if (SIZE(binTreeStruct, /TYPE) eq 8) then begin
                ;  A binary tree struct has been passed. Assume proper structure.
                *self.pRootNode = binTreeStruct
            endif else begin
                ;  Free existing tree.
                self -> FreeBTree, self.pRootNode

                ;  Get the root node.
                self.pRootNode = self -> GetRootNode()

                ;  Build the new tree.
                self -> BuildBTree, self.pRootNode
            endelse

            ;  Set initial HIDE state and visibility mask
            transform = RHTgrCamera_Transform(self.oOrientation -> GetCTM(), $
                self.cameraLocation, self.viewZ)
            self -> CullStatic, self.pRootNode, transform, /ROOT
            *self.pStaticMask = *self.pTempMask
            for n=0L, self.nStatic-1 do $
                (*self.pStaticModels)[n] -> SetProperty, $
                    HIDE=1 xor (*self.pStaticMask)[n]

        end

        ;  Add model as non-culled content and *non-transformed* content
        mother:begin
            if (N_ELEMENTS(position) gt 0) then $
                self.oMotherOfAllModels -> Add, oModel, POSITION=position, $
                    _EXTRA=extra $
                else self.oMotherOfAllModels -> Add, oModel, _EXTRA=extra
        end


        ;  Add model as non-culled content.
        else: begin
            if (N_ELEMENTS(position) gt 0) then $
                self.oCamModel -> Add, oModel, POSITION=position, _EXTRA=extra $
                else self.oCamModel -> Add, oModel, _EXTRA=extra
        end

    endcase

    ;  Update model transforms and cull.
    self -> Transform

end
;   }}}


;   RHTgrCamera::Remove {{{
pro RHTgrCamera::Remove,    oModel, $
                            all=all

    ;  Remove an object from the camera.

    compile_opt IDL2

    all = KEYWORD_SET(all)

    ;  Reset HIDE property of culled models.
    if (all) then begin
        for n=0, self.nDynamic-1 do $
            (*self.pDynamicModels)[n] -> SetProperty, HIDE=0
        for n=0, self.nStatic-1 do $
            (*self.pStaticModels)[n] -> SetProperty, HIDE=0
    endif else begin
        camModels = self.oCamModel -> IsContained(oModel)
        incIDX = WHERE(camModels eq 0, nInc)
        if (nInc gt 0) then  oModel = oModel[incIDX]
        nModels = N_ELEMENTS(oModel)
        for n=0, nModels-1 do $
            oModel[n] -> SetProperty, HIDE=0
    endelse

    ;  Remove dynamic models.
    self.oDynamicModel -> Remove, oModel, ALL=all
    *self.pDynamicModels = self.oDynamicModel -> Get(/ALL, $
        COUNT=nDynamic, ISA='IDLgrModel')
    self.nDynamic = nDynamic

    ;  Remove static models.
    self.oStaticModel -> Remove, oModel, ALL=all
    *self.pStaticModels = self.oStaticModel -> Get(/ALL, $
        COUNT=nStatic, ISA='IDLgrModel')
    if (self.nStatic ne nStatic) then begin
        self -> FreeBTree, self.pRootNode
        self.pRootNode = self -> GetRootNode(/NULL)
        if (nStatic ne 0) then begin
            self.oStaticModel -> Remove, /ALL
            self -> Add, *self.pStaticModels, /STATIC
        endif
        self.nStatic = nStatic
    endif

    ;  Remove non-culled models.
    self.oCamModel -> Remove, oModel, ALL=all

    ;  Remove non-culled non-transformed models.
    self.oMotherOfAllModels -> Remove, oModel, ALL=all

end
;   }}}


;   RHTgrCamera::Get {{{
function RHTgrCamera::Get,  count=count, $
                            mother=mother, $
                            _extra=extra

    ;  Return an array of objects contained in the camera.

    compile_opt IDL2

    CATCH, error
    if (error ne 0) then begin
       CATCH, /CANCEL
       MESSAGE, !Error_State.Msg, /CONTINUE
       RETURN, -1
    endif

    count = 0L
    contents = OBJ_NEW()

    if (KEYWORD_SET(mother)) then begin
        ;  return a reference to the "mother of all models"

        count = 1L
        contents = self.oMotherOfAllModels

    endif else begin
        ;  return objects that have been added to the camera

        dynContents = self.oDynamicModel -> Get(_EXTRA=extra)
        if (OBJ_VALID(dynContents[0])) then begin
            count = N_ELEMENTS(dynContents)
            contents = dynContents
        endif

        staContents = self.oStaticModel -> Get(_EXTRA=extra)
        if (OBJ_VALID(staContents[0])) then begin
            count = count + N_ELEMENTS(staContents)
            if (OBJ_VALID(contents[0])) then contents = [contents, staContents] $
                else contents = staContents
        endif

        camContents = self.oCamModel -> Get(_EXTRA=extra)
        if (OBJ_VALID(camContents[0])) then begin
            count = count + N_ELEMENTS(camContents)
            if (OBJ_VALID(contents[0])) then contents = [contents, camContents] $
                else contents = camContents
        endif
    endelse

    RETURN, contents

end
;   }}}


;   RHTgrCamera::Lookat {{{
pro RHTgrCamera::Lookat,    lookat, $
                            no_transform=noTransform, $
                            track=track

    ;  Center the camera view at a specified "lookat" point.

    compile_opt idl2

    if (N_ELEMENTS(lookat) eq 3) then begin

        if (N_ELEMENTS(track) ne 0) then self.track = KEYWORD_SET(track)
        self.lookat = lookat

        lvector = lookat - self.cameraLocation
        if (TOTAL(lvector eq 0.) eq 3) then RETURN
        lvector = lvector / SQRT(TOTAL(lvector^2))

        self.yaw = 180. + ATAN(lvector[0],lvector[2]) * self.dRadeg
        self.pitch = ATAN(lvector[1], SQRT(lvector[2]^2 + lvector[0]^2)) * self.dRadeg
        self.oOrientation -> Set, self.pitch, self.yaw, self.roll

    endif

end
;   }}}


;   RHTgrCamera::Zoom {{{
pro RHTgrCamera::Zoom,  zoom, $
                        no_transform=noTransform

    ;  Zoom the camera view by the specified zoom factor.

    compile_opt idl2

    if (N_ELEMENTS(zoom) eq 1) then begin

        self.zoom[0] = zoom

        case 1 of
            (zoom ge 0) : self.zoom[1] = 1. + zoom
            (zoom lt 0) : self.zoom[1] = (1. / (1. - zoom))
        endcase

        self.view = self.viewRect / self.zoom[1]

        self.fov = [ATAN((self.view[2] / 2.) / self.eye[2]), $
            ATAN((self.view[3] / 2.) / self.eye[2])]

        self.frustum = RHTgrCamera_ComputeFrustum(self.zclip, self.fov, $
            self.eye[2], PLANES=planes)
        self.frustPlanes = planes

    endif

end
;   }}}


;   RHTgrCamera::Roll {{{
pro RHTgrCamera::Roll,  dRoll, $
                        no_transform=noTransform

    ;  Roll the camera about the Z axis.

    compile_opt idl2

    if (N_ELEMENTS(dRoll) eq 1) then begin

        self.roll = self.roll + dRoll

        if (self.roll ge 360.) then self.roll = self.roll - 360.
        if (self.roll lt 0.) then self.roll = self.roll + 360.

        self.oQuatA -> Set, 0., 0., dRoll

        self.oOrientation -> PostMult, self.oQuatA -> GetQuat()

    endif

end
;   }}}


;   RHTgrCamera::Pan {{{
pro RHTgrCamera::Pan,   dYaw, $
                        dPitch, $
                        no_transform=noTransform

    ;  Pan the camera, rotating about the X and Y axes.

    compile_opt idl2

    if (N_ELEMENTS(dYaw) eq 1) and (N_ELEMENTS(dPitch) eq 1) then begin

        self.pitch = self.pitch + dPitch
        self.yaw = self.yaw + dYaw

        if (self.pitch ge 360.) then self.pitch = self.pitch - 360.
        if (self.pitch lt 0.) then self.pitch = self.pitch + 360.

        if (self.yaw ge 360.) then self.yaw = self.yaw - 360.
        if (self.yaw lt 0.) then self.yaw = self.yaw + 360.

        if (self.lock) then begin
            self.oOrientation -> Set, self.pitch, self.yaw, self.roll
        endif else begin
            self.oQuatA -> Set, dPitch, dYaw, 0.0
            self.oOrientation -> PostMult, self.oQuatA -> GetQuat()
        endelse

    endif

end
;   }}}


;   RHTgrCamera::Truck {{{
pro RHTgrCamera::Truck,     truckAxis, $
                            distance, $
                            no_transform=noTransform

    ;  "Truck" (move) the camera relative to its current orientation.

    compile_opt idl2

    if (N_ELEMENTS(truckAxis) eq 3) and (N_ELEMENTS(distance) eq 1) then begin

        tAxisSq = truckAxis^2
        v = TOTAL(tAxisSq)
        if ( v eq 0.) then RETURN
        truckAxis = truckAxis / SQRT(v)

        yaw = -ATAN(truckAxis[0],truckAxis[2]) * self.dRadeg
        pitch = ATAN(truckAxis[1], SQRT(tAxisSq[2] + tAxisSq[0])) * self.dRadeg

        self.oQuatA -> Set, pitch, yaw, 0.0
        self.oQuatB -> SetQuat, self.oOrientation -> GetQuat()
        self.oQuatB -> PostMult, self.oQuatA -> GetQuat()
        dvect = self.oQuatB -> GetDirectionVector()
        self.cameraLocation = self.cameraLocation + (dvect * distance)

    endif

end
;   }}}


;   RHTgrCamera::GetDirectionVector {{{
function RHTgrCamera::GetDirectionVector

    ;  Return a 3 element vector [X,Y,Z] representing the orientation of
    ;  the camera.

    compile_opt IDL2

    RETURN, self.oOrientation -> GetDirectionVector()

end
;   }}}


;   RHTgrCamera::SetClipPlanes {{{
pro RHTgrCamera::SetClipPlanes, clip_planes

    ;  Applies user supplied clipping planes to a scene.  Note that the
    ;  planes are in *view space*
    ;
    ;  See the docs for IDLgrModel for more info.

    compile_opt IDL2

    if ((size(clip_planes, /DIMENSIONS))[0] ne 4) then begin
        MESSAGE, 'clip_planes argument must be a 4xN array ' + $
            '[A,B,C,D] defining the plane Ax+By+Cz+D=0', /CONTINUE
        RETURN
    endif

    self.oMotherOfAllModels -> SetProperty, CLIP_PLANES=clip_planes

end
;   }}}


;   RHTgrCamera::SetProperty {{{
pro RHTgrCamera::SetProperty,   camera_location=cameraLocation, $
                                depth_cue=depthCue, $
                                eye=eye, $
                                force_AR=forceAR, $
                                fov=fov, $
                                frustum_dims=viewDims, $
                                lock=lock, $
                                lookat=lookat, $
                                no_transform=noTransform, $
                                orientation=orientation, $
                                pitch=pitch, $
                                override=override, $
                                projection=projection, $
                                reset_AR=resetAR, $
                                roll=roll, $
                                third_person=thirdPerson, $
                                track=track, $
                                viewplane_rect=viewRect, $
                                yaw=yaw, $
                                zclip=zclip, $
                                zError=zError, $
                                _extra=extra

    compile_opt idl2

    updateView = 0B
    updateOrientation = 0B

    if (N_ELEMENTS(cameraLocation) eq 3) then $
        self.cameraLocation = cameraLocation

    if (N_ELEMENTS(depthCue) eq 2) then begin
        self.dcue = depthCue
        updateView = 1B
    endif

    if (N_ELEMENTS(eye) eq 1) then begin
        self.eye[2] = eye
        updateView = 1B
    end

    if (N_ELEMENTS(lock) eq 1) then self.lock = KEYWORD_SET(lock)

    if (N_ELEMENTS(lookat) eq 3) then self.lookat = lookat

    if (N_ELEMENTS(orientation) eq 4) then $
        self.oOrientation -> SetQuat, orientation

    if (N_ELEMENTS(projection) eq 1) && KEYWORD_SET(override) then $
        self -> IDLgrView::SetProperty, PROJECTION=projection

    if (N_ELEMENTS(pitch) eq 1) then begin
        self.pitch = pitch
        updateOrientation = 1B
    endif

    if (N_ELEMENTS(resetAR) eq 1) then $
        self.aspectRatio[1:2] = [0.,0.]

    if (N_ELEMENTS(roll) eq 1) then begin
        self.roll = roll
        updateOrientation = 1B
    endif

    if (N_ELEMENTS(thirdPerson) eq 1) then begin
        self.thirdPerson = thirdPerson
        updateView = 1B
    endif

    if (N_ELEMENTS(track) eq 1) then self.track = KEYWORD_SET(track)

    if (N_ELEMENTS(yaw) eq 1) then begin
        self.yaw = yaw
        updateOrientation = 1B
    endif

    if (N_ELEMENTS(zError) eq 1) then begin
        self.zError = 0.0001 > zError < 1000.
        self.eye[2] = self.zclip[0] + ((self.zclip[0]^2 + self.zError * $
            self.zclip[0]) / (65536. * self.zError))
        updateView = 1B
    end

    if (N_ELEMENTS(viewDims) eq 3) then begin
        self.viewDims = viewDims
        self.viewRect = [(-viewDims[0] / 2.), (-viewDims[1] / 2.), $
            viewDims[0], viewDims[1]]
        self.zclip = [viewDims[2] / 2D, -viewDims[2] / 2D]
        self.eye[2] = self.zclip[0] + ((self.zclip[0]^2 + self.zError * $
            self.zclip[0]) / (65536. * self.zError))
        updateView = 1B
    endif

    if (N_ELEMENTS(forceAR) eq 1) then $
        self.aspectRatio[0] = KEYWORD_SET(forceAR)

    if (N_ELEMENTS(fov) eq 2) then begin
        if (fov[0] gt 0) and (fov[1] gt 0) then begin
            fov = 0.000872665 > ((fov / 2.0) * !DTOR) < 1.56992
            self.viewDims[0] = TAN(fov[0]) * self.eye[2] * 2.0
            self.viewDims[1] = TAN(fov[1]) * self.eye[2] * 2.0
            self.viewRect = [(-self.viewDims[0] / 2.), (-self.viewDims[1] / 2.), $
                self.viewDims[0], self.viewDims[1]]
            updateView = 1B
        endif
    endif

    if (updateOrientation) then $
        self.oOrientation -> Set, self.pitch, self.yaw, self.roll

    if (updateView) then begin
        self.viewZ = self.eye[2] - self.thirdPerson
        self.depth_cue = self.dcue - self.viewZ
        self.view = self.viewRect / self.zoom[1]
        self.fov = [ATAN((self.view[2] / 2.) / self.eye[2]), $
            ATAN((self.view[3] / 2.) / self.eye[2])]
        self.frustum = RHTgrCamera_ComputeFrustum(self.zclip, self.fov, $
            self.eye[2], PLANES=planes)
        self.frustPlanes = planes
    endif

    if (N_ELEMENTS(extra) gt 0) then $
        self -> IDLgrView::SetProperty, _EXTRA=extra

end
;   }}}


;   RHTgrCamera::GetProperty {{{
pro RHTgrCamera::GetProperty,   camera_location=cameraLocation, $
                                depth_cue=depthCue, $
                                force_AR=forceAR, $
                                fov=fov, $
                                frustum_dims=viewDims, $
                                frustum_planes=frustPlanes, $
                                frustum_verts=frustVerts, $
                                lock=lock, $
                                lookat=lookat, $
                                pitch=pitch, $
                                quaternion=quaternion, $
                                roll=roll, $
                                third_person=thirdPerson, $
                                track=track, $
                                view_frustum=viewFrust, $
                                yaw=yaw, $
                                zError=zError, $
                                zoom=zoom, $
                                _ref_extra=extra


    compile_opt idl2

    cameraLocation = self.cameraLocation
    depthCue = self.dcue
    forceAR = self.aspectRatio[0]
    fov = self.fov * self.dRadeg * 2.0
    frustPlanes = self.frustPlanes
    frustVerts = self.frustum
    lock = self.lock
    lookat = self.lookat
    pitch = self.pitch
    quaternion = self.oOrientation
    roll = self.roll
    thirdPerson = self.thirdPerson
    track = self.track
    viewDims = [self.view[2:3],TOTAL(ABS(self.zclip))]
    viewFrust = self.frustum
    yaw = self.yaw
    zError = self.zError
    zoom = self.zoom[0]

    self -> IDLgrView::GetProperty, _EXTRA=extra

end
;   }}}


;   RHTgrCamera::Draw {{{
pro RHTgrCamera::Draw, destObject

    ;  Draw the contents of the view to the destination object.

    compile_opt idl2

    if (self.aspectRatio[0]) then begin

        destObject -> GetProperty, DIMENSIONS=destDims
        if (self.destDims[0] eq 0) then self.destDims = destDims

        aspectRatio = [destDims[0] / self.destDims[0], $
            destDims[1] / self.destDims[1]]

        if (aspectRatio[0] ne self.aspectRatio[1]) or $
            (aspectRatio[1] ne self.aspectRatio[2]) then begin

            self.aspectRatio[1:2] = aspectRatio
            viewDims = self.viewDims * aspectRatio
            self.viewRect = [(-viewDims[0] / 2.), (-viewDims[1] / 2.), $
                viewDims[0], viewDims[1]]

            self.view = self.viewRect / self.zoom[1]

            self.fov = [ATAN((self.view[2] / 2.) / self.eye[2]), $
                ATAN((self.view[3] / 2.) / self.eye[2])]

            self.frustum = RHTgrCamera_ComputeFrustum(self.zclip, self.fov, $
                self.eye[2], PLANES=planes)
            self.frustPlanes = planes
        endif

    endif

    self -> Transform

    self -> IDLgrView::Draw, destObject

end
;   }}}


;   RHTgrCamera::Transform {{{
pro RHTgrCamera::Transform

    ;  Apply the current transform to the models contained in the camera.

    compile_opt idl2

    ;  Check if we're tracking and update.
    if (self.track) then self -> Lookat, self.lookat

    ;  Calculate transform.
    transform = RHTgrCamera_Transform(self.oOrientation -> GetCTM(), $
        self.cameraLocation, self.viewZ)
    self.oCamModel -> SetProperty, TRANSFORM=transform

    ;  Cull static content.
    if (self.nStatic gt 0) then begin

        ;  Apply transform to static model.
        self.oStaticModel -> SetProperty, TRANSFORM=transform

        ;  Test frustum / B-tree intersection.
        self -> CullStatic, self.pRootNode, transform, /ROOT
        change = *self.pTempMask xor *self.pStaticMask
        *self.pStaticMask = *self.pTempMask

        ;  Set static model visibility properties.
        chIdx = WHERE(change eq 1, nChange)
        for n=0, nChange-1 do $
            (*self.pStaticModels)[chIdx[n]] -> SetProperty, $
                HIDE=1 xor (*self.pStaticMask)[chIdx[n]]

    endif

    ;  Cull dynamic content.
    if (self.nDynamic gt 0) then begin

        ;  Apply transform to dynamic model.
        self.oDynamicModel -> SetProperty, TRANSFORM=transform

        ;  Get the bounding boxes for the dynamic models.
        self.oDynamicModel -> GetAABB, POSITION=pos, EXTENTS=ext, /ALL

        ;  Test frustum / bounding box intersection.
        inview = RHTgrCamera_AABBIntersectFrustum(pos,ext,self.frustPlanes)
        change = inView xor *self.pDynamicMask
        *self.pDynamicMask = inView

        ;  Set dynamic model visibility properties.
        chIdx = WHERE(change eq 1, nChange)
        for n=0, nChange-1 do  $
            (*self.pDynamicModels)[chIdx[n]] -> SetProperty, $
                HIDE=1 xor (*self.pDynamicMask)[chIdx[n]]

    endif

end
;   }}}


;   RHTgrCamera::BuildBTree {{{
pro RHTgrCamera::BuildBTree,    node

    ;  Construct the binary tree used for static frustum culling.

    compile_opt IDL2

    ;  Determine bounding box long axis and bisect
    null = MAX(ABS((*node).data.extents), axis)
    location = ((*node).data.position)[axis]
    oAABB = OBJ_NEW('RHTgrAABB', (*self.pStaticModels)[(*node).data.models], $
        /ALIAS)
    data = oAABB -> Bisect(axis, location, DUPLICATES=duplicates)
    OBJ_DESTROY, oAABB

    ;  Store duplicates.  They need special treatment during culling.
    *(*node).data.duplicates = duplicates
    nDuplicates = N_ELEMENTS(duplicates)

    ;  Create the leaves.
    if (data.right.nModels gt 0) then begin
        models = LONARR(data.right.nModels, /NOZERO)
        for n=0, data.right.nModels-1 do  $
            models[n] = WHERE(*self.pStaticModels eq data.right.models[n])
        (*node).right = PTR_NEW({data:{position:data.right.position, $
            extents:data.right.extents, models:models, $
            duplicates:PTR_NEW([[-1],[-1]])}, $
            left:PTR_NEW(), right:PTR_NEW()})
        if (data.right.nModels gt nDuplicates) then $
            self -> BuildBTree, (*node).right
    endif

    if (data.left.nModels gt 0) then begin
        models = LONARR(data.left.nModels, /NOZERO)
        for n=0, data.left.nModels-1 do  $
            models[n] = WHERE(*self.pStaticModels eq data.left.models[n])
        (*node).left = PTR_NEW({data:{position:data.left.position, $
            extents:data.left.extents, models:models, $
            duplicates:PTR_NEW([[-1],[-1]])}, $
            left:PTR_NEW(), right:PTR_NEW()})
         if (data.left.nModels gt nDuplicates) then $
            self -> BuildBTree, (*node).left
    endif

end
;   }}}


;   RHTgrCamera::FreeBTree {{{
pro RHTgrCamera::FreeBTree,    pNode

    ;  Free pointers associated with the binary tree.

    compile_opt IDL2

    PTR_FREE, (*pNode).data.duplicates

    if (PTR_VALID((*pNode).left)) then self -> FreeBTree, (*pNode).left
    if (PTR_VALID((*pNode).right)) then self -> FreeBTree, (*pNode).right

    PTR_FREE, pNode

end
;   }}}


;   RHTgrCamera::CullStatic {{{
pro RHTgrCamera::CullStatic,    node, $
                                transform, $
                                root=root

    ;  Traverse binary tree and create static model visibility mask
    ;  based on current transformation and frustum dimensions.

    compile_opt idl2

    root = KEYWORD_SET(root)
    if (root) then *self.pTempMask = REPLICATE(0B, self.nStatic)

    ;  Calculate node min and max, transform and test intersection
    minMax = DBLARR(3,2, /NOZERO)
    minMax[*,0] = (*node).data.position - (*node).data.extents
    minMax[*,1] = (*node).data.position + (*node).data.extents
    minMax = RHTgrAABB_CalcBB(minMax[0,*], minMax[1,*], minMax[2,*], [0D,1D], $
        [0D,1D], [0D,1D], transform)
    ext = (minMax[*,1] - minMax[*,0]) * 0.5
    pos = minMax[*,0] + ext
    inview = RHTgrCamera_AABBIntersectFrustum(pos, ext, self.frustPlanes, $
        CLIPMASK=clip)

    ;  Node completely out of view.
    if (not(inview)) then begin
        (*self.ptempmask)[(*node).data.models] = 0B
        RETURN
    endif

    ;  Node completely in view.
    if (clip eq 0) then begin
        (*self.ptempmask)[(*node).data.models] = 1B
        RETURN
    endif

    ;  Node partially in view.  Continue with right node.
    if (PTR_VALID((*node).right)) then begin
        (*self.ptempmask)[(*(*node).right).data.models] = 1B
        self -> CullStatic, (*node).right, transform
    endif

    ;  Save the state of any duplicate models.
    if ((*(*node).data.duplicates)[0] ge 0) then $
        c = (*self.ptempmask)[(*(*node).right).data.models[ $
            (*(*node).data.duplicates)[*,1]]]

    ;  On to the left node...
    if (PTR_VALID((*node).left)) then begin
        (*self.ptempmask)[(*(*node).left).data.models] = 1B
        self -> CullStatic, (*node).left, transform
    endif

    ;  'OR' left vs right duplicates.
    if ((*(*node).data.duplicates)[0] ge 0) then $
        (*self.ptempmask)[(*(*node).left).data.models[ $
            (*(*node).data.duplicates)[*,0]]] = (*self.ptempmask)[$
            (*(*node).left).data.models[(*(*node).data.duplicates)[*,0]]] or c

end
;   }}}


;   RHTgrCamera::GetRootNode {{{
function RHTgrCamera::GetRootNode,  null=null

    ;  Return root btree node.

    compile_opt IDL2

    if (KEYWORD_SET(null)) then begin
        pNode = PTR_NEW({data:{position:0, extents:0, $
            models:0, duplicates:PTR_NEW([[-1],[-1]])}, $
            left:PTR_NEW(), right:PTR_NEW()})
    endif else begin
        self.oStaticModel -> GetAABB, POSITION=position, EXTENTS=extents
        pNode = PTR_NEW({data:{position:position, extents:extents, $
            models:LINDGEN(self.nstatic), duplicates:PTR_NEW([[-1],[-1]])}, $
            left:PTR_NEW(), right:PTR_NEW()})
    endelse

    RETURN, pNode

end
;   }}}


;   RHTgrCamera::Cleanup {{{
pro RHTgrCamera::Cleanup

    compile_opt IDL2

    self -> FreeBTree, self.pRootNode

    OBJ_DESTROY, [self.oOrientation, self.oQuatA, self.oQuatB, $
        self.oDynamicModel, self.oCamModel, self.oStaticModel]

    PTR_FREE, self.pDynamicMask, self.pDynamicModels, self.pStaticModels, $
        self.pStaticMask, self.pRootNode, self.pTempMask

    self -> IDLgrView::Cleanup

end
;   }}}


;   RHTgrCamera__Define {{{
pro RHTgrCamera__Define

    struct={RHTgrCamera, $
            inherits IDLgrView, $

            oCamModel:OBJ_NEW(), $
            oDynamicModel:OBJ_NEW(), $
            oStaticModel:OBJ_NEW(), $
            oMotherOfAllModels:OBJ_NEW(), $
            oOrientation:OBJ_NEW(), $
            oQuatA:OBJ_NEW(), $
            oQuatB:OBJ_NEW(), $

            pDynamicMask:PTR_NEW(), $
            pDynamicModels:PTR_NEW(), $
            pStaticMask:PTR_NEW(), $
            pTempMask:PTR_NEW(), $
            pStaticModels:PTR_NEW(), $
            pRootNode:PTR_NEW(), $

            aspectRatio:FLTARR(3), $
            cameraLocation:DBLARR(3), $
            dcue:DBLARR(2), $
            destDims:INTARR(2), $
            dRadeg:0D, $
            fov:DBLARR(2), $
            frustum:DBLARR(3,8), $
            lock:0B, $
            lookat:DBLARR(3), $
            nDynamic:0L, $
            nStatic:0L, $
            pitch:0D, $
            frustPlanes:DBLARR(4,6), $
            roll:0D, $
            thirdPerson:0D, $
            track:0B, $
            viewZ:0D, $
            viewDims:DBLARR(3), $
            viewRect:DBLARR(4), $
            yaw:0D, $
            zError:0L, $
            zoom:DBLARR(2) $
           }

end
;   }}}


