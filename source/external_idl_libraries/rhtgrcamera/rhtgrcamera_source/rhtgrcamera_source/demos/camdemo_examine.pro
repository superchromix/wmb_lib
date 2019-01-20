;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       CAMDEMO_EXAMINE
;
; PURPOSE:
;       The purpose of this routine is to provide an example of
;       using the third_person keyword to get a trackball like effect
;       where you can examine a model in a scene.
;
;       In this example the camera is located at the origin [0,0,0]
;       as is an "earth" orb.  You can change the latitude and longitude
;       of the earth by left clicking and dragging in the window.
;       To zoom the camera in, right click and drag up. To zoom out,
;       right click and drag down.
;
;       *The Latitude and Longitude values are gross approximations!*
;       *There is no actual mapping going on here so don't plan your*
;       *next big trip using this demo.                             *
;
;       DISCLAIMER: The camdemo_* programs are quick examples of some
;                   of the features of my camera object.  They are
;                   NOT provided as examples of proper programming
;                   technique.
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
; DEPENDENCIES:     RHTgrCamera__define.pro
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 21 June 2001.
;
;
; LICENSE
;
;   CAMDEMO_EXAMINE.PRO Copyright (C) 2001-2003  Rick Towler
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

    widget_control, event.top, get_uvalue=info, /no_copy

    ;  What kind of an event is this?
    possibleEvents = ['DOWN', 'UP', 'MOTION', 'SCROLL', 'EXPOSE']
    possibleButtons = ['NONE', 'LEFT', 'MIDDLE', 'NONE', 'RIGHT', $
            'RIGHTLEFT','MIDDLERIGHT']
    thisEvent = possibleEvents(event.type)
    thisButton = possibleButtons(event.press)

    ;"do the right thing"(tm)
    case thisEvent of

        ;a down button event
        'DOWN': begin
            widget_control, info.drawID, draw_motion_events=1
            info.button = thisbutton
            info.xstart = event.x
            info.ystart = event.y
         end

        'UP': begin
            ;  Turn motion events OFF.
            widget_control, info.drawID, draw_motion_events=0, /Clear_Events
            ;  Clear button status
            info.button=''
        end

        'MOTION': begin
            ;  Calculate movement - clamp a little bit
            dx = -32. > (event.x - info.xstart) < 32.
            dy = -32. > (event.y - info.ystart) < 32.

            case info.button of

                'LEFT':begin
                    ;  Pan the camera

                    ;  invert the x delta so camera movement corresponds to mouse
                    ;  movement.  Also, throttle panning by the zoom factor
                    ;  to give smoother panning at high zoom levels.
                    info.camera -> Pan, -dx / (1. + abs(info.zoom)), $
                        dy / (1. + abs(info.zoom))

                    ;  Get the camera's orientation
                    info.camera -> GetProperty, pitch=pitch, yaw=yaw, roll=roll

                    ;  Adjust the pitch and yaw values to rough lat/lon
                    case 1 of
                        (pitch lt 90):lat = -pitch
                        (pitch le 180):lat = -90. + (pitch - 90.)
                        (pitch lt 270):lat = pitch - 180.
                        (pitch le 360):lat = -(pitch - 360.)
                    endcase
                    case 1 of
                        (yaw le 180):lon = yaw
                        (yaw le 360):lon = -180 + (yaw - 180.)
                    endcase

                    ;  Update the camera orientation values in the HUD
                    info.pan -> setproperty, strings=string([lat,lon], $
                            format='(2(f6.1,1x))')
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
                    info.zoomtext -> setproperty, strings=string(info.zoom, $
                            format='(f6.2)')
                end
                else:
            endcase
        end
        else:
    endcase

    ;  Store our new mouse pointer position
    info.xstart = event.x
    info.ystart = event.y

    ;  Draw the scene
    info.window -> draw, info.viewgroup

    widget_control, event.top, set_uvalue=info

end
;   }}}

;   camdemo_event {{{
pro camdemo_event, event
    ;  Handle tlb resize events

    widget_control, event.top, get_uvalue=info, /no_copy

    if (event.id eq event.top) then begin
        ;  Resize the tlb - set min and max dimensions
        xsize = 300 > event.x < 3200
        ysize = 300 > event.y < 1200
        widget_control, event.top, XSize=xsize, YSize=ysize

        ;  resize the draw window - compensate for any other widgets in window
        info.Window -> SetProperty, dimensions=[xsize - 6,ysize - 6]

        ;  Resize the HUD text
        ;  Scale text relative to default window size
        text_scale = xsize / 600.
        info.titleFont -> setproperty, size = 18. * text_scale
        info.statsFont -> setproperty, size = 8. * text_scale

        ;  Redisplay the graphic.
        info.window -> draw, info.viewgroup
    endif

    widget_control, event.top, set_uvalue=info

end
;   }}}

;   camdemo_reset {{{
pro camdemo_reset, event
    ;   Reset the camera orientation and zoom

    widget_control, event.top, get_uvalue=info, /no_copy

    ;  Reset the camera's orientation
    info.camera -> setproperty, pitch=0., yaw=0., roll=0.

    ;  Reset the zoom level
    info.camera -> zoom, 0.0
    info.zoom = 0.0

    ;  Update the camera orientation values in the HUD
    info.pan -> setproperty, strings=string([0,0], $
            format='(2(f6.1,1x))')

    ;  Update the camera zoom value in the HUD
    info.zoomtext -> setproperty, strings=string(info.zoom, $
            format='(f6.2)')

    ;  Draw the scene
    info.window -> draw, info.viewgroup

    widget_control, event.top, set_uvalue=info
end
;   }}}

;   camdemo_exit {{{
pro camdemo_exit, event

    widget_control, event.top, /Destroy

end
;   }}}

;   camdemo_cleanup {{{
pro camdemo_cleanup, tlb

    widget_control, tlb, get_uvalue=info
    obj_destroy, info.container

end
;   }}}

;   camdemo_examine {{{
pro camdemo_examine,    software=software

    ;  Check our keyword
    software = (n_elements(software) eq 0) ? 0 : keyword_set(software)

    ;  Create a container for easy cleanup
    container = obj_new('IDL_Container')

    ;  Define the top level base widget and some menu bar items
    tlb=widget_base(column=1, mbar=menuid, title='Camera Examine Demo', $
            /TLB_size_events)

    ;  Menus
    fileID=widget_button(menuID, value='File')
    exitID=widget_button(fileID, value='Exit', event_pro='camdemo_exit')
    orientID=widget_button(menuID, value='Orientation')
    resetID=widget_button(orientID, value='Reset', event_pro='camdemo_reset')

    ;  Create the graphics window
    ;  Force software renderer if software keyword is set.
    drawID=widget_draw(tlb, xsize=600, ysize=600, /expose_events, $
            graphics_level=2, renderer=software, /button_events, $
            event_pro='camdemo_draw_event')

    ;  Realize the widget heirarchy
    widget_control, tlb, /realize

    ;  Get the window object reference and add to our container
    widget_control, drawID, get_value = window
    container -> add, window

    ;  Create the camera. For this demo we place the camera at the origin.
    camera = OBJ_NEW('RHTgrCamera', COLOR=[0,0,0], FRUSTUM_DIMS=[8,8,20], $
        CAMERA_LOCATION=[0,0,0])
    container -> add, camera

    ;  Load the texture map
    read_jpeg,'earth.jpg' ,texture, /true, /order
    texmap = obj_new('idlgrimage', texture)
    container -> add, texmap

    ;  Create the "globe" -
    globe = obj_new('orb', radius=1, pos=[0,0,0], color=[255,255,255], $
            density=3.0, texture_map=texmap, /tex_coords)
    container -> add, globe

    ;  Rotate globe to 0 lat, 0 lon
    globe -> rotate, [1,0,0], 90
    globe -> rotate, [0,1,0], 90

    ;  To use the camera to examine an object in a manner similar to using
    ;  the trackball object, we fix the camera's position at the location of the
    ;  object and pan the camera with the third_person keyword set to the
    ;  distance you want the camera from the object.

    ;  The globe is centered at [0,0,0] with a radius of 1.0
    ;  Set third_person so we are two units away from our orb
    camera -> SetProperty, third_person=3.0

    ;  Since we want to view the globe "thru the lens",
    ;  add the model to the camera
    camera -> add, globe

    ;  Create the "HUD"

    ;  Create the HUD view. Make sure we set the transparent keyword
    hudview = obj_new('IDLgrView', viewplane_rect=[0.,0.,1,1], $
            zclip=[1,-1], color=[0,0,0], eye=2, projection=1, /transparent)
    container -> add, hudview


    ;  Create the text that we'll stick in our hud
    titleFont = obj_new('idlgrfont', 'Helvetica', size=18)
    title = obj_new('idlgrtext','Camera Examine Demo', $
            color=[255,255,255], /onglass, locations=[.5,.95], $
            font=titleFont, alignment=0.5)
    container -> add, [titleFont,title]

    statsFont = obj_new('idlgrfont', 'Helvetica', size=8.)
    render = obj_new('idlgrtext','Renderer:', $
            color=[255,255,255], /onglass, locations=[.21,.1], $
            font=statsFont, alignment=1.0)
    window -> getproperty, renderer=renderer
    if (renderer) then text='Software' else text='Hardware(OpenGL)'
    rendertext = obj_new('idlgrtext',text, $
            color=[255,255,255], /onglass, locations=[.22,.1], $
            font=statsFont, alignment=0.0)
    panlabel = obj_new('idlgrtext','Latitude, Longitude:', $
            color=[255,255,255], /onglass, locations=[.21,.08], $
            font=statsFont, alignment=1.0)
    pan = obj_new('idlgrtext','  0.0  0.0',locations=[.22,.08], $
            color=[255,255,255], /onglass,font=statsFont, alignment=0.0)
    zoomlabel = obj_new('idlgrtext','Zoom Level:', $
            color=[255,255,255], /onglass, locations=[.21,.06], $
            font=statsFont, alignment=1.0)
    zoomtext = obj_new('idlgrtext','  1.0',locations=[.22,.06], $
            color=[255,255,255], /onglass,font=statsFont, alignment=0.0)
    blurbtext = 'Left click and drag on the window to rotate the earth'
    blurb = obj_new('idlgrtext',blurbtext, locations=[.5,.03], $
            color=[255,255,255], /onglass, font=statsFont, alignment=0.5)
    blurbtext = 'Right click and drag up on the window to zoom in, drag down' + $
            ' to zoom out'
    zoomblurb = obj_new('idlgrtext',blurbtext, locations=[.5,.01], $
            color=[255,255,255], /onglass, font=statsFont, alignment=0.5)
    container -> add, [statsFont,render,rendertext,panlabel,pan, $
            zoomlabel,zoomtext,blurb,zoomblurb]


    ;  Create the cross-hair
    verts = [[.48,.48,1.],[.52,.48,1.],[.52,.52,1.],[.48,.52,1.]]
    polys = [4,0,1,2,3]
    HUD_COLOR = [255,255,255]
    CURSOR_OPACITY = 255

    image = bytarr(4,24,24)
    image[0,11:12,*] = HUD_COLOR[0]
    image[1,11:12,*] = HUD_COLOR[1]
    image[2,11:12,*] = HUD_COLOR[2]
    image[3,11:12,*] = CURSOR_OPACITY
    image[0,*,11:12] = HUD_COLOR[0]
    image[1,*,11:12] = HUD_COLOR[1]
    image[2,*,11:12] = HUD_COLOR[2]
    image[3,*,11:12] = CURSOR_OPACITY
    image[3,10:13,10:13] = 0

    texcoord = [[0,0],[1,0],[1,1],[0,1]]
    cursor_texmap = obj_new('IDLgrImage', image)
    cursor = obj_new('IDLgrPolygon', verts, polygons=polys, $
            color=[255,255,255], texture_coord=texcoord, texture_map= $
            cursor_texmap, /texture_interp)
    container -> add, [cursor_texmap,cursor]

    ;  Create a model to put all of our HUD atoms in
    hudmodel = obj_new('idlgrmodel')
    container -> add, hudmodel
    hudmodel -> add, [title,render,rendertext,panlabel,pan, $
            zoomlabel,zoomtext,blurb,zoomblurb,cursor]

    ;  Add this model to our hud view
    hudview->add, hudmodel

    ;  Create a viewgroup
    viewgroup = obj_new('IDLgrViewgroup')
    container -> add, viewgroup

    ;  Add the camera and HUD views to the viewgroup
    viewgroup -> add, [camera, hudview]

    info={  container:container, $
            window:window, $
            camera:camera, $
            viewgroup:viewgroup, $
            drawID:drawID, $


            zoomtext:zoomtext, $
            titleFont:titleFont, $
            statsFont:statsFont, $

            pan:pan, $
            xstart:0., $
            ystart:0., $
            zoom:0., $
            button:'' $
         }


    ;  Insert our data structure into the tlb widget
    widget_control, tlb, set_uvalue=info

    ;  Fire up xmanager
    XManager, 'camdemo_examine', tlb, Cleanup='camdemo_cleanup', /No_Block, $
        Event_Handler='camdemo_event'

end
;   }}}


