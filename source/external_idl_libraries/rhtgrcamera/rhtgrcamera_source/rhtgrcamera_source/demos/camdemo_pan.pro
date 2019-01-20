;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       CAMDEMO_PAN
;
; PURPOSE:
;       The purpose of this routine is to provide a basic example of
;       using the pan method of the camera object.  This example
;       also introduces the "Heads up Display" view which can be used
;       to hold atoms you do not want transformed by the camera such
;       as text labels and legends and the Zoom method.
;
;       In this example the camera is located at the origin [0,0,0]
;       and orbs are located about the scene.  You can change the
;       pitch and yaw of the camera by left clicking and dragging in
;       the window.  To zoom the camera in, right click and drag up.
;       To zoom out, right click and drag down.
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
;   software:       Set this keyword to force rendering the scene using IDL's
;                   software renderer.
;
;
; DEPENDENCIES:     camera__define.pro
;                   quaternion__define.pro
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 16 June 2001.
;
;
; LICENSE
;
;   CAMDEMO_PAN.PRO Copyright (C) 2001-2003  Rick Towler
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
    ;  Handle window events

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  What kind of an event is this?
    possibleEvents = ['DOWN', 'UP', 'MOTION', 'SCROLL', 'EXPOSE']
    possibleButtons = ['NONE', 'LEFT', 'MIDDLE', 'NONE', 'RIGHT', $
            'RIGHTLEFT','MIDDLERIGHT']
    thisEvent = possibleEvents(event.type)
    thisButton = possibleButtons(event.press)

    ;  "do the right thing"(tm)
    case thisEvent of

        'DOWN': begin
            ;  Turn motion events ON, record starting position
            WIDGET_CONTROL, info.drawID, DRAW_MOTION_EVENTS=1
            info.button = thisbutton
            info.xstart = event.x
            info.ystart = event.y
         end

        'UP': begin
            ;  Turn motion events OFF.
            WIDGET_CONTROL, info.drawID, DRAW_MOTION_EVENTS=0, $
                /CLEAR_EVENTS

            ;  Clear button status
            info.button=''
        end

        'MOTION': begin
            ;  Calculate movement in relative coordinates.
            ;  Clamp dx & dy  movement a little bit
            dx = -4. > (event.x - info.xstart) < 4.
            dy = -4. > (event.y - info.ystart) < 4.

            case info.button of

                'LEFT':begin
                    ;  Pan the camera

                    ;  Invert the x delta so camera movement corresponds to mouse
                    ;  movement.  We need to do this because rotation about the
                    ;  y axis in a right handed coordinate system is opposite of
                    ;  our mouse movement.
                    info.camera -> pan, -dx, dy

                    ;  Get the camera's perspective and update the HUD
                    info.camera -> getproperty, pitch=pitch, yaw=yaw, roll=roll

                    ;  Update the camera orientation values in the HUD
                    info.pan -> SetProperty, strings=string([pitch,yaw,roll], $
                            format='(3(I3.3,1x))')
                end
                'RIGHT':begin
                    ;  Zoom the camera

                    ;  Calculate the new zoom factor
                    if (dy gt 0) then begin
                        info.zoom = info.zoom + (sqrt(dx^2 + dy^2) / 10.)
                    endif else begin
                        info.zoom = info.zoom - (sqrt(dx^2 + dy^2) / 10.)
                    endelse

                    ;  Zoom the camera by the specified amount
                    info.camera -> zoom, info.zoom

                    ;  Update the camera zoom value in the HUD
                    info.zoomtext -> SetProperty, STRINGS=STRING(info.zoom, $
                            FORMAT='(f6.2)')
                end
                else:
            endcase
        end
        else:
    endcase

    ;  Store our new pointer position
    info.xstart = event.x
    info.ystart = event.y

    ;  Draw the scene
    info.window -> draw, info.viewgroup

    WIDGET_CONTROL, event.top, SET_UVALUE=info

end
;   }}}

;   camdemo_reset {{{
pro camdemo_reset, event
    ;  Reset the camera orientation and zoom

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  Reset the camera's orientation
    info.camera -> SetProperty, pitch=0., yaw=0., roll=0.

    ;  Reset the zoom level
    info.camera -> zoom, 0.0
    info.zoom = 0.0

    ;  Update the camera orientation values in the HUD
    info.pan -> SetProperty, STRINGS=STRING([0,0,0], $
            FORMAT='(3(I3.3,1x))')

    ;  Update the camera zoom value in the HUD
    info.zoomtext -> SetProperty, STRINGS=STRING(info.zoom, $
            FORMAT='(f5.2)')

    ;  Draw the scene
    info.window -> draw, info.viewgroup

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

        ;  Resize the draw window - compensate for any other widgets in window
        info.Window -> SetProperty, DIMENSIONS=[xsize - 6,ysize - 6]

        ;  Resize the HUD text
        ;  Scale text relative to default window size
        text_scale = xsize / 600.
        info.titleFont -> SetProperty, SIZE = 18. * text_scale
        info.statsFont -> SetProperty, SIZE = 8. * text_scale

        ;  Redisplay the graphic.
        info.window -> draw, info.viewgroup
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
    OBJ_DESTROY, info.container

end
;   }}}

;   camdemo_pan {{{
pro camdemo_pan, software=software

    ;  Check our keywords
    software = (N_ELEMENTS(software) eq 0) ? 0 : KEYWORD_SET(software)

    ;  Create a container for easy cleanup
    container = OBJ_NEW('IDL_Container')

    ;  Define the top level base widget and some menu bar items
    tlb=WIDGET_BASE(COLUMN=1, MBAR=menuid, TITLE='Camera Pan Demo', $
            /TLB_SIZE_EVENTS)

    ;  Menus
    fileID=WIDGET_BUTTON(menuID, VALUE='File')
    exitID=WIDGET_BUTTON(fileID, VALUE='Exit', EVENT_PRO='camdemo_exit')
    orientID=WIDGET_BUTTON(menuID, VALUE='Orientation')
    resetID=WIDGET_BUTTON(orientID, VALUE='Reset', EVENT_PRO='camdemo_reset')

    ;  Create our graphics window
    ;  Force software renderer if software keyword is set.
    drawID=widget_draw(tlb, XSIZE=600, YSIZE=600, /EXPOSE_EVENTS, $
            GRAPHICS_LEVEL=2, RENDERER=software, /BUTTON_EVENTS, $
            EVENT_PRO='camdemo_draw_event')

    ;  Realize the widget heirarchy
    WIDGET_CONTROL, tlb, /realize

    ;  Get the window object reference and add to our container
    WIDGET_CONTROL, drawID, get_value = window
    container -> add, window

    ;  Create the camera. This time make the view volume a little larger
    ;  to accomodate more orbs.  For this demo we place the camera at the
    ;  origin.
    camera = OBJ_NEW('RHTgrCamera', COLOR=[0,0,0], FRUSTUM_DIMS=[10,10,20], $
            CAMERA_LOCATION=[0,0,0])
    container -> add, camera

    ; Ccreate something to look at...
    red_orb = OBJ_NEW('orb', RADIUS=1, POS=[4,0,0], COLOR=[255,0,0], $
            STYLE=1)
    blue_orb = OBJ_NEW('orb', RADIUS=1, POS=[-4,0,0], COLOR=[0,0,255], $
            STYLE=1)
    green_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,0,4], COLOR=[0,255,0], $
            STYLE=1)
    yellow_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,0,-4], COLOR=[255,255,0], $
            STYLE=1)
    ltblue_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,-4,0], COLOR=[0,255,255], $
            STYLE=1)
    purple_orb = OBJ_NEW('orb', RADIUS=1, POS=[0,4,0], COLOR=[255,0,255], $
            STYLE=1)
    container -> add, [red_orb,blue_orb,green_orb,yellow_orb,purple_orb,ltblue_orb]

    ;  Create a top level model whose transform will be manipulated directly
    ;  by the camera.  Since the ORB is a subclass of IDLgrModel you could
    ;  throw the orbs directly into the camera and unlike in camdemo_basic.pro
    ;  This would actually produce the expected result since we haven't
    ;  manipulated any of the orb's transform matricies.
    topmodel = OBJ_NEW('IDLgrModel')
    container -> add, topmodel

    topmodel -> add, [red_orb,blue_orb,green_orb,yellow_orb,purple_orb,ltblue_orb]

    ;  Since we want to view the items in top model "thru the lens",
    ;  add this model to the camera
    camera -> add, topmodel


    ;create the "HUD"

    ;  Create the HUD view. Make sure you set the transparent keyword
    hudview = OBJ_NEW('IDLgrView', viewplane_rect=[0.,0.,1,1], $
            zclip=[1,-1], color=[0,0,0], eye=2, projection=1, /transparent)
    container -> add, hudview

    ;  Create the text that we'll stick in our hud
    titleFont = OBJ_NEW('idlgrfont', 'Helvetica', size=18)
    title = OBJ_NEW('IDLgrText','Camera Pan Demo', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.5,.95], $
            FONT=titleFont, ALIGNMENT=0.5)
    container -> add, [titleFont,title]

    statsFont = OBJ_NEW('idlgrfont', 'Helvetica', SIZE=8.)
    render = OBJ_NEW('IDLgrText','Renderer:', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.1], $
            FONT=statsFont, ALIGNMENT=1.0)
    window -> getproperty, renderer=renderer
    if (renderer) then text='Software' else text='Hardware(OpenGL)'
    rendertext = OBJ_NEW('IDLgrText',text, $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.21,.1], $
            FONT=statsFont, ALIGNMENT=0.0)
    panlabel = OBJ_NEW('IDLgrText','Pitch, Yaw, Roll:', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.08], $
            FONT=statsFont, ALIGNMENT=1.0)
    pan = OBJ_NEW('IDLgrText','000 000 000',LOCATIONS=[.21,.08], $
            COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)
    zoomlabel = OBJ_NEW('IDLgrText','Zoom Level:', $
            COLOR=[255,255,255], /ONGLASS, LOCATIONS=[.2,.06], $
            FONT=statsFont, ALIGNMENT=1.0)
    zoomtext = OBJ_NEW('IDLgrText',' 1.0',LOCATIONS=[.21,.06], $
            COLOR=[255,255,255], /ONGLASS,FONT=statsFont, ALIGNMENT=0.0)
    blurbtext = 'Left click and drag on the window to pan the camera'
    blurb = OBJ_NEW('IDLgrText',blurbtext, LOCATIONS=[.5,.03], $
            COLOR=[255,255,255], /ONGLASS, FONT=statsFont, ALIGNMENT=0.5)
    blurbtext = 'Right click and drag up on the window to zoom in, drag down' + $
            ' to zoom out'
    zoomblurb = OBJ_NEW('IDLgrText',blurbtext, LOCATIONS=[.5,.01], $
            COLOR=[255,255,255], /ONGLASS, FONT=statsFont, ALIGNMENT=0.5)
    container -> add, [statsFont,render,rendertext,panlabel,pan, $
            zoomlabel,zoomtext,blurb,zoomblurb]

    ;  Create a model to put all of our HUD atoms in
    hudmodel = OBJ_NEW('IDLgrModel')
    container -> add, hudmodel
    hudmodel -> add, [title,render,rendertext,panlabel,pan, $
            zoomlabel,zoomtext,blurb,zoomblurb]

    ;  Add this model to our hud view
    hudview->add, hudmodel

    ;  Create a viewgroup
    viewgroup = OBJ_NEW('IDLgrViewgroup')
    container -> add, viewgroup

    ;  Add the camera and HUD views to the viewgroup
    ;  It is important that the views are orderd from back to front
    ;  in the viewgroup. At the very back (last) must be the camera
    ;  (or any opaque view) and in front of the camera view you can
    ;  place your HUD.
    viewgroup -> add, [camera, hudview]

    info={  container:container, $
            window:window, $
            camera:camera, $
            topmodel:topmodel, $
            viewgroup:viewgroup, $

            pan:pan, $
            zoomtext:zoomtext, $
            titleFont:titleFont, $
            statsFont:statsFont, $

            drawID:drawID, $
            xstart:0., $
            ystart:0., $
            zoom:0., $
            button:''}


    ;  Insert our data structure into the tlb widget
    WIDGET_CONTROL, tlb, SET_UVALUE=info

    ;  Fire up xmanager
    XMANAGER, 'camdemo_pan', tlb, CLEANUP='camdemo_cleanup', /NO_BLOCK, $
        EVENT_HANDLER='camdemo_event'

end
;   }}}



