; docformat = 'idl rst'

;+
; NAME:
;    JBSYMBOL
;
; PURPOSE:
;    Loads one of a series of useful user-defined symbols.
;
; CATEGORY:
;    Plot
;
; CALLING SEQUENCE:
;    JBSYMBOL, Sym
;
; INPUTS:
;    Sym:     Symbol number, chosen from: ::
;             0   Square
;             1   Triangle
;             2   Diamond
;             3   Half circle (left)
;             4   Upside-down triangle
;             5   5-pointed star
;             6   Circle
;             7   6-pointed star
;             8   Pentagon
;             9   Half circle (right)
;             10  Sun symbol
;
; KEYWORD PARAMETERS:
;    _Extra:  All extra keywords (such as /FILL or THICK) are passed to
;             VSYM or USERSYM as appropriate.
;
; EXAMPLE:
;    JBSYMBOL, 7
;    PLOT, [0.5], [0.5], PSYM=8, XRANGE=[0,1], YRANGE=[0,1]
;
; PROCEDURE:
;    Uses VSYM for symbols 5, 7 and 8, and USERSYM for the others.
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;-
pro jbsymbol, sym, _extra=extra

if (sym lt 0) or (sym gt 10) then message, 'Symbols available: 0-10'

angles = (360./24.)*findgen(25) / !radeg

squarex = [-1,1,1,-1,-1]
squarey = [1,1,-1,-1,1]
triangx = [-1,0,1,-1]
triangy = [-1,1,-1,-1]
triangdownx = triangx
triangdowny = -triangy
diamondx = [0,1,0,-1,0]
diamondy = [1,0,-1,0,1]
circlex = cos(angles)
circley = sin(angles)
circleleftx = cos([angles[6:18],angles[6]])+0.5
circlelefty = sin([angles[6:18],angles[6]])
circlerightx = cos([angles[18:*],angles[0:6],angles[18]])-0.5
circlerighty = sin([angles[18:*],angles[0:6],angles[18]])


case sym of
  0 : usersym, squarex, squarey, thick=1, _extra=extra
  1 : usersym, triangx, triangy, thick=1, _extra=extra
  2 : usersym, diamondx, diamondy, thick=1, _extra=extra
  3 : usersym, circleleftx, circlelefty, thick=1, _extra=extra
  4 : usersym, triangdownx, triangdowny, thick=1, _extra=extra
  5 : vsym, 5, /star, thick=1, _extra=extra
  6 : usersym, circlex, circley, thick=1, _extra=extra
  7 : vsym, 6, /star, thick=1, _extra=extra
  8 : vsym, 5, thick=1, _extra=extra
  9 : usersym, circlerightx, circlerighty, thick=1, _extra=extra
endcase

end

