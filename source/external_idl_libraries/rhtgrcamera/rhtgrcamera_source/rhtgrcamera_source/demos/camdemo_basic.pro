;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:
;       CAMDEMO_BASIC
;
; PURPOSE:
;       The purpose of this routine is to provide a VERY basic example of
;       using the camera object.  This example doesn't actually do anything
;       you can't do with the IDLgrView object but like I said, this
;       is a very basic example.
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
; DEPENDENCIES:     RHTgrCamera__define.pro
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 16 June 2001.
;
;
; LICENSE
;
;   CAMDEMO_BASIC.PRO Copyright (C) 2001-2003  Rick Towler
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


;   camdemo_event {{{
pro camdemo_event, event

    WIDGET_CONTROL, event.top, GET_UVALUE=info

    ;  Draw the window when it is exposed
    info.oWindow -> Draw, info.oCamera

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
    OBJ_DESTROY, info.oContainer

end
;   }}}

;   camdemo_basic {{{
pro camdemo_basic, software=software

    ;  Check our keyword.
    software = (N_ELEMENTS(software) eq 0) ? 0 : KEYWORD_SET(software)

    ;  Create a container for easy cleanup.
    oContainer = OBJ_NEW('IDL_Container')

    ;  Define the top level base widget.
    tlb = WIDGET_BASE(COLUMN=1, MBAR=menuid, TITLE='Basic RHTgrCamera Demo', $
        TLB_FRAME_ATTR=1)

    ;  File menu
    fileID=WIDGET_BUTTON(menuID, VALUE='File')
    exitID=WIDGET_BUTTON(fileID, VALUE='Exit', EVENT_PRO='camdemo_exit')

    ;  Create our graphics window.  Force software renderer if software
    ;  keyword is set.
    drawID=WIDGET_DRAW(tlb, XSIZE=600, YSIZE=600, /EXPOSE_EVENTS, $
            GRAPHICS_LEVEL=2, RENDERER=software)

    ;  Realize the widget heirarchy.
    WIDGET_CONTROL, tlb, /REALIZE

    ;  Get the window object reference.
    WIDGET_CONTROL, drawID, GET_VALUE = oWindow
    oContainer -> Add, oWindow

    ;  Create the camera
    oCamera = OBJ_NEW('RHTgrCamera', CAMERA_LOCATION=[0,0,3])
    oContainer -> Add, oCamera

    ;  Something to look at.
    orb = OBJ_NEW('orb', RADIUS=1, POS=[0,0,0], COLOR=[255,0,0], DENSITY=2.0, $
            STYLE=1)

    ;  Rotate the orb so we view it side on.
    orb -> Rotate, [1,0,0], 90.

    ;  and this model to our camera.
    oCamera -> Add, orb

    info={  oContainer:oContainer, $
            oWindow:oWindow, $
            oCamera:oCamera}

    ;  Insert our structure into the tlb widget.
    WIDGET_CONTROL, tlb, SET_UVALUE=info

    ;  Fire up xmanager.
    XMANAGER, 'camdemo_basic', tlb, CLEANUP='camdemo_cleanup', /NO_BLOCK, $
        EVENT_HANDLER='camdemo_event'

end
;   }}}



