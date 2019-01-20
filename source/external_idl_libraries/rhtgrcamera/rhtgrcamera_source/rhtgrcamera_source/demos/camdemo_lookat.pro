;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       CAMDEMO_LOOKAT.PRO
;
; PURPOSE:
;       The purpose of this routine is to provide a basic example of
;       using the lookat method of the camera object.  This example
;       also introduces the "Heads up Display" view which can be used
;       to hold atoms you do not want transformed by the camera such
;       as text labels and legends.
;
;       In this example the camera orbits a set of OBR objects. Clicking
;       on the window will change the lookat point, cycling it thru
;       a set of predefined lookat points.
;
;
;       DISCLAIMER: The camdemo_* programs are quick examples of some
;                   of the features of my camera object.  They are
;                   NOT provided as examples of proper programming
;                   technique. Use at your own risk!
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
;
;    density:       Set this keyword to a float value defining the
;                   vertex density of the orb objects.
;
;                   Default: 1.0  (800 triangles per orb)
;
;
;   software:       Set this keyword to force rendering the scene using IDL's
;                   software renderer.
;
;
; DEPENDENCIES:     RHTgrCamera__define.pro
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 16 June 2001.
;                   RHT 07/11/02: Added FPS display.
;
;
; LICENSE
;
; Copyright (C) 2001-2003  Rick Towler
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

;   camdemo_animate {{{
pro camdemo_animate, event

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
    WIDGET_CONTROL, event.id, GET_UVALUE=uval

    case uval of
        'START':begin
            ;  Set the run flag
            info.run=1

            ;  Unhide the FPS text
            info.fpstext -> SetProperty, HIDE=0
            info.fpslabel -> SetProperty, HIDE=0

            ;  Set an insane timer interval so it isn't limiting
            WIDGET_CONTROL, info.animateID, TIMER=.000001
        end
        'STOP':begin
            ;  Unset the run flag
            info.run=0

            ;  Hide the FPS text
            info.fpstext -> SetProperty, /HIDE
            info.fpslabel -> SetProperty, /HIDE
        end
        'RUN':begin

            ;  Calculate the new camera position
            info.cam_loc = info.cam_loc + info.step
            if (info.cam_loc[0] gt 720.) then info.step = info.step - 0.1
            if (info.cam_loc[0] lt 0.) then  info.step = info.step + 0.1

            x = 6.0 * SIN(info.cam_loc[0] * !DTOR)
            y = (info.cam_loc[1] / 60.) * COS(info.cam_loc[1] * !DTOR)
            z = 6.0 * COS(info.cam_loc[2] * !DTOR)

            ;  Set the camera's location to this new position
            info.camera -> setproperty, camera_loc=[x,y,z]

            ;  Calculate FPS
            thisframe = SYSTIME(/SECONDS)
            info.count = info.count + (thisframe-info.lastframe)
            info.frame = info.frame + 1
            info.lastframe = thisframe
            ;  Average FPS values over ~0.5 second intervals
            if (info.count gt 0.5D) then begin
                info.fpstext -> setproperty, strings = $
                        STRING((info.frame / info.count), FORMAT='(f7.2)')
                info.count = 0D
                info.frame = 0
            endif

            ;  Update the camera location label in the HUD
            info.location -> SetProperty, STRINGS=STRING([x,y,z], $
                    FORMAT='(3(f5.2,1x))')

            ;  If we are still running, set another timer event
            if (info.run) then WIDGET_CONTROL, info.animateID, TIMER=.000001

        end
    endcase

    ;  Draw the scene
    info.window -> Draw, info.viewgroup

    WIDGET_CONTROL, event.top, SET_UVALUE=info

end
;   }}}

;   camdemo_draw_event {{{
pro camdemo_draw_event, event

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  Cycle the lookat point on down button events
    if (event.type eq 0) then begin
        ;  Down button event

        ;  Increment our lookat index
        info.lookat_index = info.lookat_index + 1

        ;  Get all of the orbs in our top model
        models = info.topmodel -> Get(/ALL, COUNT=nmodels)

        ;  Clamp lookat_index
        if (info.lookat_index gt nmodels) then info.lookat_index = 0

        ;  Get the new lookat position
        ;  Cycle thru all of the orbs positions and the origin
        if (info.lookat_index eq nmodels) then begin
            ;  Set the lookat to the origin
            lookat=[0,0,0]
            COLOR=[255,255,255]
        endif else begin
            models[info.lookat_index] -> GetProperty, POS=lookat, $
                    COLOR=COLOR
        endelse

        ;  Set the camera's lookat point to this orb's location
        ;  The track keyword was set at camera initialization
        ;  so we don't have to set it here.
        info.camera -> Lookat, lookat

        ;  Update the lookat label in the HUD
        info.lookat -> SetProperty, COLOR=COLOR, STRINGS = $
                STRING(lookat, FORMAT='(3(f5.2,1x))')

    endif

    ;  Draw the scene
    ;  Remember, you have to draw the viewgroup, NOT just the camera
    info.window -> Draw, info.viewgroup

    WIDGET_CONTROL, event.top, SET_UVALUE=info

end
;   }}}

;   camdemo_reset {{{
pro camdemo_reset, event
    ;  Reset the camera orientation and animation timestep

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  Reset the camera's orientation
    info.camera -> SetProperty, PITCH=0., YAW=0., ROLL=0., $
        CAMERA_LOCATION=[0,0,6]

    ;  Reset camera timestep
    info.cam_loc = [0,0,0]

    ;  Update the camera location label in the HUD
    info.location -> SetProperty, STRINGS=STRING([0,0,6], $
            FORMAT='(3(f5.2,1x))')

    ;  Draw the scene
    info.window -> Draw, info.viewgroup

    WIDGET_CONTROL, event.top, SET_UVALUE=info
end
;   }}}

;   camdemo_event {{{
pro camdemo_event, event
    ;  Handle window resize events

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    if (event.id eq event.top) then begin

        ;  Resize the tlb - set min and max dimensions
        xsize = 300 > event.x < 3200
        ysize = 300 > event.y < 1200
        WIDGET_CONTROL, event.top, XSIZE=xsize, YSIZE=ysize

        ;  Resize the draw window
        info.Window -> SetProperty, DIMENSIONS=[xsize - 6,ysize - 6]

        ;  Resize the HUD text scale text relative to default window size
        text_scale = xsize / 600.
        info.titleFont -> SetProperty, SIZE = 18. * text_scale
        info.statsFont -> SetProperty, SIZE = 8. * text_scale

        ;  Redisplay the graphic.
        info.window -> Draw, info.viewgroup
    endif

    WIDGET_CONTROL, event.top, SET_UVALUE=info
end
;   }}}

;   camdemo_exit {{{
pro camdemo_exit, event

    WIDGET_CONTROL, event.top, /DESTROY

end
;   }}}

;   camdemo_cleanup {{{
pro camdemo_cleanup, tlb

    WIDGET_CONTROL, tlb, GET_UVALUE=info
    OBJ_DESTROY, info.container

end
;   }}}

;   camdemo_lookat {{{
pro camdemo_lookat, density=density, $
                    software=software

    ;  Check our keywords
    software = (N_ELEMENTS(software) eq 0) ? 0 : KEYWORD_SET(software)
    density = (N_ELEMENTS(density) eq 0) ? 1.0 : FLOAT(density)

    ;  Create a container for easy cleanup
    container = OBJ_NEW('IDL_Container')

    ;  Define the top level base widget and some menu bar items
    tlb = WIDGET_BASE(COLUMN=1, MBAR=menuid, TITLE='RHTgrCamera Lookat Demo', $
            /TLB_SIZE_EVENTS)

    ;  File menu
    fileID = WIDGET_BUTTON(menuID, VALUE='File')
    exitID = WIDGET_BUTTON(fileID, VALUE='Exit', EVENT_PRO='camdemo_exit')

    ;  Fnimate menu
    animateID = WIDGET_BUTTON(menuID, VALUE='Animate', EVENT_PRO='camdemo_animate', $
            UVALUE='RUN')
    anim_startID = WIDGET_BUTTON(animateID, VALUE='Start', UVALUE='START')
    anim_stopID = WIDGET_BUTTON(animateID, VALUE='Stop', UVALUE='STOP')

    ;  Orientation menu
    orientID = WIDGET_BUTTON(menuID, VALUE='Orientation')
    resetID = WIDGET_BUTTON(orientID, VALUE='Reset', EVENT_PRO='camdemo_reset')

    ;  Create our graphics window force software renderer if software keyword is set.
    drawID=WIDGET_DRAW(tlb, XSIZE=600, YSIZE=600, /EXPOSE_EVENTS, $
            GRAPHICS_LEVEL=2, RENDERER=software, /BUTTON_EVENTS, $
            EVENT_PRO='camdemo_draw_event')

    ;  Realize the widget heirarchy
    WIDGET_CONTROL, tlb, /REALIZE

    ;  Get the window object reference and add to our container
    WIDGET_CONTROL, drawID, GET_VALUE = window
    container -> add, window

    ;  Create the camera. This time make the view volume a little larger
    ;  to accomodate more orbs.  Also, set the initial lookat point to the origin
    ;  and set the track keyword to follow the lookat point thru subsequent
    ;  tranformations.
    camera = OBJ_NEW('RHTgrCamera', COLOR=[0,0,0], FRUSTUM_DIMS=[10,10,20], $
            CAMERA_LOCATION=[0,0,6], LOOKAT=[0,0,0], /TRACK)
    container -> add, camera

    ;  Create something to look at
    red_orb = OBJ_NEW('orb', RADIUS=1, POS=[4,0,0], COLOR=[255,0,0], $
            DENSITY=density, STYLE=1)
    blue_orb = OBJ_NEW('orb', RADIUS=1, POS=[-4,0,0], COLOR=[0,0,255], $
            DENSITY=density, STYLE=1)
    green_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,0,4], COLOR=[0,255,0], $
            DENSITY=density, STYLE=1)
    yellow_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,0,-4], COLOR=[255,255,0], $
            DENSITY=density, STYLE=1)
    ltblue_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,-4,0], COLOR=[0,255,255], $
            DENSITY=density, STYLE=1)
    purple_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,4,0], COLOR=[255,0,255], $
            DENSITY=density, STYLE=1)
    container -> add, [red_orb,blue_orb,green_orb,yellow_orb,purple_orb,ltblue_orb]

    ;  Report triangle count
    red_orb -> GetProperty, POLYGONS=polys
    ntriangles = MESH_NUMTRIANGLES(polys)
    PRINT, 'Scene triangle count: ' + STRTRIM(STRING(ntriangles * 6),2)

    topmodel = OBJ_NEW('IDLgrModel')
    container -> Add, topmodel

    topmodel -> add, [red_orb,blue_orb,green_orb,yellow_orb,purple_orb,ltblue_orb]

    ;  Since we want to view the items in top model "thru the lens",
    ;  Add this model to the camera
    camera -> Add, topmodel


    ;  Create the "HUD"

    ;  Create the HUD view. Make sure you set the transparent keyword
    hudview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0.,0.,1,1], $
            ZCLIP=[1,-1], COLOR=[0,0,0], EYE=2, PROJECTION=1, /TRANSPARENT)
    container -> add, hudview


    ;  Create the text that we'll stick in our hud
    titleFont = OBJ_NEW('idlgrfont', 'Helvetica', size=18)
    title = OBJ_NEW('idlgrtext','Camera Lookat Demo', $
            COLOR=[255,255,255], /onglass, LOCATIONS=[.5,.95], $
            FONT=titleFont, ALIGNMENT=0.5)
    container -> add, [titleFont,title]

    statsFont = OBJ_NEW('idlgrfont', 'Helvetica', size=8.)
    render = OBJ_NEW('idlgrtext','Renderer:', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.1], $
            FONT=statsFont, ALIGNMENT=1.0)
    window -> getproperty, renderer=renderer
    if (renderer) then text='Software' else text='Hardware(OpenGL)'
    rendertext = OBJ_NEW('idlgrtext',text, $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.21,.1], $
            FONT=statsFont, ALIGNMENT=0.0)
    looklabel = OBJ_NEW('idlgrtext','Lookat Point:', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.08], $
            FONT=statsFont, ALIGNMENT=1.0)
    lookat = OBJ_NEW('idlgrtext',' 0.0 0.0 0.0',LOCATIONS=[.21,.08], $
            COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)
    loclabel = OBJ_NEW('idlgrtext','Camera Location:', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.06], $
            FONT=statsFont, ALIGNMENT=1.0)
    location = OBJ_NEW('idlgrtext',' 0.00 0.00 6.00',LOCATIONS=[.21,.06], $
            COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)
    blurbtext = 'Click on the window to cycle the lookat point'
    blurb = OBJ_NEW('idlgrtext',blurbtext, LOCATIONS=[.5,.02], $
            COLOR=[255,255,255], /ONGLASS, FONT=statsFont, ALIGNMENT=0.5)
    fpslabel = OBJ_NEW('idlgrtext','FPS:', /hide, $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.09,.96], $
            FONT=statsFont, ALIGNMENT=1.0)
    fpstext = OBJ_NEW('idlgrtext',' 0.0',LOCATIONS=[.1,.96], /hide, $
            COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)

    container -> add, [statsFont,render,rendertext,looklabel,lookat, $
            loclabel,location,blurb,fpslabel,fpstext]

    ;  Create a model to put all of our HUD atoms in
    hudmodel = OBJ_NEW('idlgrmodel')
    container -> add, hudmodel
    hudmodel -> add, [title,render,rendertext,looklabel,lookat, $
            loclabel,location,blurb,fpslabel,fpstext]

    ;  Add this model to our hud view
    hudview->add, hudmodel

    ;  Create a viewgroup
    viewgroup = OBJ_NEW('IDLgrViewgroup')
    container -> add, viewgroup

    ;  Add the camera and HUD views to the viewgroup
    ;  It is important that the views are orderd from back to front
    ;  in the viewgroup.
    viewgroup -> add, [camera,hudview]

    info={  container:container, $
            window:window, $
            camera:camera, $
            topmodel:topmodel, $
            viewgroup:viewgroup, $

            animateID:animateID, $

            fpslabel:fpslabel, $
            fpstext:fpstext, $
            titleFont:titleFont, $
            statsFont:statsFont, $

            frame:0, $
            count:0D, $
            lastframe:0D, $
            cam_loc:FLTARR(3), $
            lookat_index:0, $
            location:location, $
            lookat:lookat, $
            step:2.0, $
            run:0 $
         }


    ;  Insert our data structure into the tlb widget
    WIDGET_CONTROL, tlb, SET_UVALUE=info

    ;fire up xmanager
    XMANAGER, 'camdemo_lookat', tlb, CLEANUP='camdemo_cleanup', /NO_BLOCK, $
        EVENT_HANDLER='camdemo_event'

end
;   }}}



