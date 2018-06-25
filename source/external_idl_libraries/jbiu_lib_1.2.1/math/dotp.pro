;+
; NAME:
;    DOTP
;
; PURPOSE:
;    Calculates the scalar product of two vectors.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = DOTP(A, B)
;
; INPUTS:
;    A:   First vector.
;
;    B:   Second vector.
;
; OUTPUTS:
;    The scalar product of A and B.
;
; EXAMPLE:
;    a = [1., -1.5, 2.]
;    b = [-3., -2., 1.5]
;    adotb = DOTP(a,b)
;
; MODIFICATION HISTORY:
;    Written by:  Jeremy Bailin
;    12 June 2008 Public release in JBIU
;-
function dotp, a, b

return, matrix_multiply(a, b, /atranspose)

end

