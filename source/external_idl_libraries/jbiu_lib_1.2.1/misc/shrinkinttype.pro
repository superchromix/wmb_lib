;+
; NAME:
;    SHRINKINTTYPE
;
; PURPOSE:
;    Reduces the memory occupied by an integer-type array if possible by
;    shrinking it into a byte or unsigned short int.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    SHRINKINTTYPE, Array
;
; INPUTS:
;    Array:   Array to be shrunk. Usually of type long. Must not be negative.
;
; EXAMPLE:
;    IDL> q = lindgen(300)
;    IDL> help, q
;    Q               LONG      = Array[300]
;    IDL> shrinkinttype, q
;    IDL> help, q         
;    Q               UINT      = Array[300]
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    6 Dec 2012    First release
pro shrinkinttype, array

maxsizes = [255,65535,4294967296]

maxarray = max(array)

arrayshrinktype = value_locate(maxsizes, maxarray)

case arrayshrinktype of
  -1: array = byte(temporary(array))
  0: array = uint(temporary(array))
  1: array = ulong(temporary(array))
  ; otherwise it must already be in a lon64, and can't be shrunk
endcase

end

