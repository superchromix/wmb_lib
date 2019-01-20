;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       CAMDEMO_CULLNFLY
;
; PURPOSE:
;       The purpose of this routine is to provide an example of
;       navigating 3 space using the keyboard and mouse and it also
;       serves as an example of using the view frustum culling feature
;       of RHTgrCamera.
;
;       Use the NORBS and ORBDENSITY keywords to explore how object
;       numbers and complexity affect rendering performace.
;
;       *NOTE*
;
;       This example REQUIRES my modified orb class.  Use of the
;       standard IDL orb will severly diminish culling performance
;       since the standard orb class rebuilds the orb vertices upon
;       every call to SetProperty.
;
;
;       Controls:
;
;           Forward: Up arrow
;           Back:    Down arrow
;           Right:   Right arrow
;           Left:    Left arrow
;           Pan:     Left mouse click and drag
;           Zoom:    Right mouse click and drag
;
;
;       Camera menu:
;
;       The camera drop down menu has a few items which you can select
;       to alter how the camera is operating:
;
;       Reset: Resets your location, orientation and zoom level.
;
;       Force Aspect Ratio:  Selecting this toggles the "Force
;           aspect ratio" mode.  Force AR forces the view to
;           match the original pixel aspect ratio based upon the
;           initial view settings and the dimensions of the destination
;           device at the time of the first draw.  If enabled,
;           the pixel aspect ratio is preserved regardles of the
;           aspect ratio of the destination device.
;
;           In this example, the pixel aspect ratio is set at 1:1.
;           So, when changing window dimensions with force AR enabled
;           the orbs will still appear round.  Disabling force AR and
;           changing the window dimensions will distort the orbs (and
;           everything else in the scene).
;
;       Culling:  The culling menu allows you to alter the view frustum
;           culling mode of the camera.  Application performance will
;           depend on the number and density of the orb objects and
;           the current culling mode.
;
;
;       This program *requires* IDL5.6+ as it relies on the
;       KEYBOARD_EVENTS feature of WIDGET_DRAW().  Keyboard events
;       are generated for a single key only (no key combinations are
;       returned) and the rate is linked to your systems key repeate
;       rate.  The default repeat rate in windows is adequate, your
;       platform may differ.  A modified, windows only version of
;       this demo which uses my directInput DLM will be made available
;       and should allow this to run on older versions of win32 IDL.
;
;
;       There are issues with this demo and the software renderer.
;       Lighting seems to be the big one, the "floor" is very dark
;       unless you are looking directly down.  There are a number of
;       stitching artifacts too.
;
;
;
;       DISCLAIMER: The camdemo_* programs are quick examples of some
;                   of the features of my camera object.  They are
;                   NOT provided as examples of proper programming
;                   technique. Use at your own risk!
;
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
; CATEGORY:
;       Object Graphics
;
;
; KEYWORDS:
;      nOrbs:       Set this keyword to a scalar value defining the number
;                   of orbs that will be sprinkled about the scene.
;
; orbDensity:       Set this keyword to a scaler value defining the density
;                   of the individual orb vertices.  Small values will
;                   generate orbs with fewer vertices while larger values
;                   will generate orbs with many more vertices. Reasonable
;                   values are 0.3 - 15.0.
;
;   software:       Set this keyword to force rendering the scene using IDL's
;                   software renderer. Note that there are issues with this
;                   demo and the software renderer.
;
;
; DEPENDENCIES:     RHTgrCamera__define.pro
;
;
; LIMITATIONS:      This program requires IDL 5.6 or better.
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 05 February 2004.
;
;
; LICENSE
;
;   CAMDEMO_CULLNFLY.PRO Copyright (C) 2004  Rick Towler
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


;   camdemo_draw_event {{{
pro camdemo_draw_event, event
    ;  Handle oWindow events

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY


    ;  Check if this event is a timer event.
    if (event.id eq info.fileID) then begin
        ;  Event is a timer event.

        ;  Draw the scene.
        info.oWindow -> draw, info.viewgroup

        ;  Increment frame counter.
        info.frame = info.frame + 1

        ;  Set another timer event.
        WIDGET_CONTROL, info.fileID, TIMER=0.0001

    endif else begin
        ;  Event is *not* timer event.

        case event.type of

            0: begin
                ;  Turn motion events ON, record starting position.
                WIDGET_CONTROL, info.drawID, DRAW_MOTION_EVENTS=1
                info.button = event.press
                info.xstart = event.x
                info.ystart = event.y
             end

            1: begin
                ;  Turn motion events OFF.
                WIDGET_CONTROL, info.drawID, DRAW_MOTION_EVENTS=0, /CLEAR_EVENTS

                ;  Clear button status.
                info.button=-1
            end

            2: begin

                ;  Calculate movement in relative coordinates.
                dx = -4. > (event.x - info.xstart) / 4. < 4.
                dy = -4. > (event.y - info.ystart) / 4. < 4.

                case info.button of

                    1:begin
                        ;  Pan the camera on left mouse drag.
                        info.camera -> pan, -dx, dy

                        ;  Get the camera's orientation
                        info.camera -> GetProperty, PITCH=pitch, YAW=yaw, $
                            ROLL=roll

                        ;  Update the camera orientation values in the HUD.
                        info.panText -> SetProperty, STRINGS= $
                            STRING([pitch,yaw,roll], format='(3(I3.3,1x))')
                    end
                    4:begin
                        ;  Zoom the camera on right mouse down

                        ;  Calculate the new zoom factor
                        if (dy gt 0) then begin
                            info.zoom = info.zoom + (SQRT(dx^2 + dy^2) / 10.)
                        endif else begin
                            info.zoom = info.zoom - (SQRT(dx^2 + dy^2) / 10.)
                        endelse

                        ;  Zoom the camera by the specified amount
                        info.camera -> zoom, info.zoom

                        ;  Update the camera zoom value in the HUD
                        info.zoomText -> SetProperty, STRINGS=STRING(info.zoom, $
                                FORMAT='(f6.2)')
                    end
                    else:
                endcase
            end

            ;  Move or "truck" the camera using the arrow keys.
            6:begin
                case event.key of
                    5:info.camera -> Truck, [-1,0,0], info.truckStep
                    6:info.camera -> Truck, [1,0,0], info.truckStep
                    7:info.camera -> Truck, [0,0,1], info.truckStep
                    8:info.camera -> Truck, [0,0,-1], info.truckStep
                    else:
                endcase

                ;  Clamp camera location to bounding box.
                info.camera -> GetProperty, CAMERA_LOCATION=camLoc
                camLoc[0] = info.boxBounds[0,0] > camLoc[0] < info.boxBounds[0,1]
                camLoc[1] = info.boxBounds[1,0] > camLoc[1] < info.boxBounds[1,1]
                camLoc[2] = info.boxBounds[2,0] > camLoc[2] < info.boxBounds[2,1]

                ;  Update the camera position.
                info.camera -> SetProperty, CAMERA_LOCATION=camLoc

                ;  Update the camera position in the HUD
                info.locText -> SetProperty, STRINGS= $
                    STRING(camLoc,format='(3(F6.1,1x))')
            end
            else:
        endcase

        ;  Store our new pointer position.
        info.xstart = event.x
        info.ystart = event.y
    endelse

    ;  Calculate frames drawn per second.
    thisframe = SYSTIME(/SECONDS)
    info.count = info.count + (thisframe-info.lastframe)
    info.lastframe = thisframe
    ;  Average FPS values over ~0.5 second intervals.
    if (info.count gt 0.5D) then begin
        info.fpstext -> setproperty, strings = $
                STRING((info.frame / info.count), FORMAT='(f5.1)')
        info.count = 0D
        info.frame = 0
    endif

    WIDGET_CONTROL, event.top, SET_UVALUE=info

end
;   }}}

;   camdemo_camprop_event {{{
pro camdemo_camprop_event, event

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
    WIDGET_CONTROL, event.id, GET_UVALUE=uval

    case uval of

        'RESET':begin

            ;  Reset the camera's orientation
            info.camera -> SetProperty, PITCH=0., YAW=0., ROLL=0., $
                CAMERA_LOCATION=[0,10,130]

            ;  Reset the zoom level
            info.camera -> zoom, 0.0
            info.zoom = 0.0

            ;  Update the camera orientation values in the HUD
            info.panText -> SetProperty, STRINGS=STRING([0,0,0], $
                FORMAT='(3(I3.3,1x))')
            info.locText -> SetProperty, STRINGS=STRING([0,10,130], $
                FORMAT='(3(F5.1,1x))')

            ;  Update the camera zoom value in the HUD
            info.zoomtext -> SetProperty, STRINGS=STRING(info.zoom, $
                FORMAT='(f5.2)')
        end

        'FORCE':begin
            info.forceMode = info.forceMode xor 1
            info.camera -> SetProperty, FORCE_AR=info.forceMode
            case info.forceMode of
                1:info.forceText -> SetProperty, STRINGS='On'
                0:info.forceText -> SetProperty, STRINGS='Off'
            endcase
        end

        'NONE':begin
            ;  Remove the orbs from the camera.
            info.camera -> Remove, info.orbArray

            ;  Add the content as non-culled content and update interface.
            info.camera -> Add, info.orbArray
            info.cullText -> SetProperty, STRINGS='None'
        end

        'STATIC':begin
            ;  Remove the orbs from the camera.
            info.camera -> Remove, info.orbArray

            ;  Add the content as statically culled content
            ;  and update interface.
            info.camera -> Add, info.orbArray, /STATIC
            info.cullText -> SetProperty, STRINGS='Static'
        end

        'DYNAMIC':begin
            ;  Remove the orbs from the camera.
            info.camera -> Remove, info.orbArray

            ;  Add the content as statically culled content
            ;  and update interface.
            info.camera -> Add, info.orbArray, /DYNAMIC
            info.cullText -> SetProperty, STRINGS='Dynamic'
        end

    endcase

    ;  Draw the scene
    info.oWindow -> draw, info.viewgroup

    WIDGET_CONTROL, event.top, SET_UVALUE=info
end
;   }}}

;   camdemo_event {{{
pro camdemo_event, event
    ;  Handle oWindow resize events

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    if (event.id eq event.top) then begin

        ;  Resize the tlb - set min and max dimensions
        xsize = 300 > event.x < 3200
        ysize = 300 > event.y < 1200
        WIDGET_CONTROL, event.top, XSIZE=xsize, YSIZE=ysize

        ;  Resize the draw oWindow - compensate for any other widgets in oWindow
        info.oWindow -> SetProperty, DIMENSIONS=[xsize - 6,ysize - 6]

        ;  Scale HUD text relative to default oWindow size
        text_scale = MIN([xsize,ysize]) / 600.
        info.titleFont -> SetProperty, SIZE = 18. * text_scale
        info.statsFont -> SetProperty, SIZE = 8. * text_scale

        ;  Redisplay the graphic.
        info.oWindow -> draw, info.viewgroup
    endif

    WIDGET_CONTROL, event.top, SET_UVALUE=info
end
;   }}}

;   camdemo_exit {{{
pro camdemo_exit, event

    WIDGET_CONTROL, event.top, /Destroy

end
;   }}}

;   camdemo_cleanup {{{
pro camdemo_cleanup, tlb

    WIDGET_CONTROL, tlb, GET_UVALUE=info
    OBJ_DESTROY, info.oContainer

end
;   }}}

;   camdemo_cullnfly {{{
pro camdemo_cullnfly,   nOrbs=nOrbs, $
                        orbDensity=orbDensity, $
                        software=software

    ;  Set initial application defaults.
    forceMode = 1B
    cullMode = 2B
    truckStep = 0.8

    ;  Check IDL version.
    useDepthTest = (FLOAT(!version.release) ge 6.0) ? 1B : 0B

    ;  Check our keywords.
    nOrbs = (N_ELEMENTS(nOrbs) eq 0) ? 20 : FIX(nOrbs)
    orbDensity = (N_ELEMENTS(orbDensity) eq 0) ? 4.0 : FLOAT(orbDensity)
    renderer = (N_ELEMENTS(software) eq 0) ? 0 : KEYWORD_SET(software)

    ;  Create a oContainer for easy cleanup.
    oContainer = OBJ_NEW('IDL_Container')

    ;  Define the top level base widget and some menu bar items.
    tlb=WIDGET_BASE(COLUMN=1, MBAR=menuid, TITLE='Camera Cull-N-Fly Demo', $
            /TLB_SIZE_EVENTS)

    ;  Menus.
    fileID=WIDGET_BUTTON(menuID, VALUE='File', EVENT_PRO='camdemo_draw_event')
    null=WIDGET_BUTTON(fileID, VALUE='Exit', EVENT_PRO='camdemo_exit')
    campropID=WIDGET_BUTTON(menuID, VALUE='Camera', $
        EVENT_PRO='camdemo_camprop_event')
    null=WIDGET_BUTTON(campropID, VALUE='Reset', UVALUE='RESET')
    null=WIDGET_BUTTON(campropID, VALUE='Force Aspect Ratio', $
        UVALUE='FORCE')
    cullID=WIDGET_BUTTON(campropID, VALUE='Culling', /MENU)
    null=WIDGET_BUTTON(cullID, VALUE='None', UVALUE='NONE')
    null=WIDGET_BUTTON(cullID, VALUE='Static', UVALUE='STATIC')
    null=WIDGET_BUTTON(cullID, VALUE='Dynamic', UVALUE='DYNAMIC')

    ;  Create our graphics oWindow.
    ;  Force software renderer if software keyword is set.
    drawID=widget_draw(tlb, XSIZE=600, YSIZE=600, /EXPOSE_EVENTS, $
            GRAPHICS_LEVEL=2, RENDERER=renderer, /BUTTON_EVENTS, $
            EVENT_PRO='camdemo_draw_event', /KEYBOARD_EVENTS)

    ;  Realize the widget heirarchy.
    WIDGET_CONTROL, tlb, /realize

    ;  Get the oWindow object reference and add to our oContainer.
    WIDGET_CONTROL, drawID, get_value = oWindow
    oContainer -> add, oWindow

    ;  Create the camera. Note that the depth of the frustum is large to
    ;  give a sense of depth to the scene and we also set a wide field of
    ;  view.  Position the camera in what will become one end of the viewer's
    ;  domain.
    camera = OBJ_NEW('RHTgrCamera', COLOR=[0,0,0], FRUSTUM_DIMS=[120,120,400], $
            CAMERA_LOCATION=[0,10,130], DEPTH_CUE=[250,400], $
            FORCE_AR=forceMode)
    oContainer -> add, camera

    ; Create something to look at...

    ;  Create a "floor" to orient user and define bounds.
    idata = REPLICATE(255B, 4,2,2)
    idata[*,0,1]=[175,175,175,255]
    idata[*,1,0]=[175,175,175,255]
    oSurfTexture = OBJ_NEW('IDLgrImage', idata)
    oContainer -> Add, oSurfTexture
    verts = [[-1,0,-1], $
             [1,0,-1], $
             [1,0,1], $
             [-1,0,1]] * 550
    polys = [4,0,1,2,3]
    texcoords = [[0,0],[100,0],[100,100],[0,100]]
    oSurf = OBJ_NEW('IDLgrPolygon', verts, POLYGONS=polys, $
        COLOR=[255,255,255], TEXTURE_COORD=texcoords, $
        TEXTURE_MAP=oSurfTexture)

    ;  Create a bounding box to contain the user.
    verts = [[-1.,0,-1.], $
             [1.,0.,-1.], $
             [1.,2.,-1.], $
             [-1.,2.,-1.], $
             [-1.,0.,1], $
             [1.,0.,1.], $
             [1.,2.,1.], $
             [-1.,2.,1.]]
    verts[0:1,*] = verts[0:1,*] * 50.
    verts[2,*] = verts[2,*] * 150.
    polys = [4,2,3,7,6,4,2,1,5,6,4,0,3,7,4,4,5,4,7,6,4,1,0,3,2]
    texcoords = [[0,0],[1,0],[1,1],[0,1],[1,0],[1,1],[0,1],[0,0]]
    idata = REPLICATE(255B, 4,2,2)
    idata[3,*,*]=80B
    oBoxTexture = OBJ_NEW('IDLgrImage', idata)
    oContainer -> Add, oBoxTexture
    oSurfBox = OBJ_NEW('IDLgrPolygon', verts, POLYGONS=polys, $
        COLOR=[255,30,30], STYLE=2, TEXTURE_COORD=texcoords, $
        TEXTURE_MAP=oBoxTexture)
    oBoxEdge = OBJ_NEW('IDLgrPolygon', verts, POLYGONS=polys, $
        COLOR=[255,30,30], STYLE=1, THICK=2, DEPTH_OFFSET=2)

    ;  Store the bounding box information
    boxBounds = FLTARR(3,2)
    boxBounds[0,*] = [MIN(verts[0,*]), MAX(verts[0,*])]
    boxBounds[1,*] = [MIN(verts[1,*]), MAX(verts[1,*])] + $
        [0.2, 0.0]
    boxBounds[2,*] = [MIN(verts[2,*]), MAX(verts[2,*])]
    boxBounds = (boxBounds) * 0.99

    ;  Add these items to a model
    oSurfModel = OBJ_NEW('IDLgrModel')
    oSurfModel -> Add, [oSurf, oBoxEdge, oSurfBox]

    ;  Add the surfModel to the camera
    camera -> Add, oSurfModel

    ;  Sprinkle a few orbs about
    orbArray = OBJARR(nOrbs)
    orbColor = BYTE(RANDOMU(seed,3,nOrbs) * 255)
    orbLocation = [[(RANDOMU(seed,nOrbs) - 0.5) * 50], $
        [RANDOMU(seed,nOrbs) * 50], $
        [(RANDOMU(seed,nOrbs) - 0.5) * 150]]
    for n=0, nOrbs-1 do begin
        orbArray[n] = OBJ_NEW('orb', COLOR=orbColor[*,n], STYLE=1, $
            POS=orbLocation[n,*], radius=(RANDOMU(seed)+1.) * 2., $
            DENSITY=orbDensity)
    endfor

    ;  Add the orbs to the camera.  The initial culling mode is
    ;  set by the cullMode variable defined above.
    case cullMode of
        0:camera -> Add, orbArray
        1:camera -> Add, orbArray, /STATIC
        2:camera -> Add, orbArray, /DYNAMIC
    endcase


    ;  Create the "Heads up display"

    ;  Create the HUD view - set the transparent keyword
    hudview = OBJ_NEW('IDLgrView', viewplane_rect=[0.,0.,1,1], $
        zclip=[1,-1], color=[0,0,0], eye=2, projection=1, $
        /transparent)
    oContainer -> add, hudview

    ;  Create a model to put all of our HUD atoms in
    hudmodel = OBJ_NEW('IDLgrModel')

    ;  Add this model to our hud view
    hudview->add, hudmodel

    ;create the HUD billboard
    verts = [[.005,.005,0.5],[.995,.005,0.],[.995,.15,0.],[.005,.15,0.]]
    polys = [4,0,1,2,3]
    image = BYTARR(4,10,10)
    image[3,*,*] = 120B
    texcoord = [[0,0],[1,0],[1,1],[0,1]]
    billboardTexmap = OBJ_NEW('IDLgrImage', image, INTERLEAVE=0, $
        blend_function=[3,4], name='billboard')

    ;  Disable depth tests (if available) to force billboard to top.
    ;  At extreme view dimensions the billboard can drop behind the floor.
    ;  Disabling deth tests on the billboard prevents this.
    if (useDepthTest) then begin
        billboard = OBJ_NEW('IDLgrPolygon', verts, POLYGONS=polys, $
            COLOR=[255,255,255], TEXTURE_COORD=texcoord, TEXTURE_MAP= $
            billboardTexmap, /DEPTH_TEST_DISABLE)
    endif else begin
        billboard = OBJ_NEW('IDLgrPolygon', verts, POLYGONS=polys, $
            COLOR=[255,255,255], TEXTURE_COORD=texcoord, TEXTURE_MAP= $
            billboardTexmap)
    endelse
    oContainer -> add, [billboardTexmap]
    hudmodel -> Add, billboard

    ;  Create the text that we'll stick in our hud
    titleFont = OBJ_NEW('idlgrfont', 'Helvetica', size=18)
    statsFont = OBJ_NEW('idlgrfont', 'Helvetica', SIZE=8.)
    oContainer -> add, [titleFont, statsFont]

    title = OBJ_NEW('IDLgrText','Camera Cull-N-Fly Demo', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.5,.95], $
        FONT=titleFont, ALIGNMENT=0.5)

    render = OBJ_NEW('IDLgrText','Renderer:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.12], $
        FONT=statsFont, ALIGNMENT=1.0)
    oWindow -> getproperty, renderer=renderer
    if (renderer) then text='Software' else text='Hardware(OpenGL)'
    renderText = OBJ_NEW('IDLgrText',text, $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.21,.12], $
        FONT=statsFont, ALIGNMENT=0.0)

    panLabel = OBJ_NEW('IDLgrText','Pitch, Yaw, Roll:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.09], $
        FONT=statsFont, ALIGNMENT=1.0)
    panText = OBJ_NEW('IDLgrText','000 000 000',LOCATIONS=[.21,.09], $
        COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    locLabel = OBJ_NEW('IDLgrText','X, Y, Z:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.06], $
        FONT=statsFont, ALIGNMENT=1.0)
    locText = OBJ_NEW('IDLgrText','  0.0   0.0   0.0',LOCATIONS=[.21,.06], $
        COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    zoomLabel = OBJ_NEW('IDLgrText','Zoom Level:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.03], $
        FONT=statsFont, ALIGNMENT=1.0)
    zoomText = OBJ_NEW('IDLgrText',' 1.0',LOCATIONS=[.21,.03], $
        COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    forceLabel = OBJ_NEW('IDLgrText','Force Aspect Ratio:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.7,.09], $
        FONT=statsFont, ALIGNMENT=1.0)
    if (forceMode) then blurb='On' else blurb='Off'
    forceText = OBJ_NEW('IDLgrText', blurb, LOCATIONS=[.71,.09], $
        COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    cullLabel = OBJ_NEW('IDLgrText','Culling Mode:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.7,.06], $
        FONT=statsFont, ALIGNMENT=1.0)
    case cullMode of
        0:blurb='None'
        1:blurb='Static'
        2:blurb='Dynamic'
    endcase
    cullText = OBJ_NEW('IDLgrText', blurb, LOCATIONS=[.71,.06], $
        COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    fpslabel = OBJ_NEW('idlgrtext','FPS:', $
        COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.09,.96], $
        FONT=statsFont, ALIGNMENT=1.0)
    fpstext = OBJ_NEW('idlgrtext',' 0.0',LOCATIONS=[.1,.96], $
        COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    hudModel -> add, [title, render, renderText, panLabel, panText, $
        zoomLabel, zoomtext, locText, locLabel, fpsLabel, fpsText, $
        forceLabel, forceText, cullLabel, cullText]


    ;  Create a viewgroup
    ;
    ;  Viewgroups contain other views and allow us to draw both
    ;  the HUD and the camera view in the same window.
    ;
    viewgroup = OBJ_NEW('IDLgrViewgroup')
    oContainer -> add, viewgroup

    ;  Add the camera and HUD views to the viewgroup.
    ;
    ;  Viewgroups must be odered back to front with the
    ;  opaque view in back.
    ;
    viewgroup -> add, [camera, hudview]

    info={  oContainer:oContainer, $
            oWindow:oWindow, $
            camera:camera, $
            viewgroup:viewgroup, $
            orbArray:orbArray, $

            panText:panText, $
            locText:locText, $
            zoomText:zoomText, $
            titleFont:titleFont, $
            statsFont:statsFont, $
            fpsText:fpsText, $
            cullText:cullText, $
            forceText:forceText, $

            boxBounds:boxBounds, $
            button:0S, $
            count:0D, $
            drawID:drawID, $
            fileID:fileID, $
            forceMode:forceMode, $
            frame:0L, $
            lastframe:0D, $
            truckStep:truckStep, $
            xstart:0., $
            ystart:0., $
            zoom:0. $
        }


    ;  Insert our data structure into the tlb widget
    WIDGET_CONTROL, tlb, SET_UVALUE=info

    ;  Set a timer event
    WIDGET_CONTROL, fileID, TIMER=0.0001

    ;  Fire up xmanager
    XMANAGER, 'camdemo_cullnfly', tlb, CLEANUP='camdemo_cleanup', /NO_BLOCK, $
        EVENT_HANDLER='camdemo_event'

end
;   }}}



