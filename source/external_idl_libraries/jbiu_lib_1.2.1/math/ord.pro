;+
; NAME:
;    ORD
;
; PURPOSE:
;    Calculates the ordinal of each value of an array in terms of the
;    sorted values. This can be very useful for shrinking sparse
;    arrays before using histogram.
;
; CATEGORY:
;    Math
;
; CALLING SEQUENCE:
;    Result = ORD(Values)
;
; INPUTS:
;    Values:  A vector of values.
;
; EXAMPLE:
;    Calculate the ordinals of values in an array.
;
;    IDL> array = [5,6,7,4,5,6,-2]
;    IDL> print, ord(array)
;               2           3           4           1           2           3
;               0
;
; OUTPUTS:
;    Returns a long array with the same number of elements as Values,
;    where each value is replaced by its ordinal (starting at 0).
;    Identical values are given the same ordinal.
;
; MODIFICATION HISTORY:
;    Written by:      Jeremy Bailin
;    28 March 2009    Public release in JBIU
;    17 June 2011     Output same dimensional array as input, rather than flat.
;     7 March 2013    Bugfix when there is only one unique value - Mats Loefdahl
;    27 May 2015      Switched to use value_locate.
;-
function ord, values

uniqvalues = uniqify(values)
return, value_locate(uniqvalues, values)

end

