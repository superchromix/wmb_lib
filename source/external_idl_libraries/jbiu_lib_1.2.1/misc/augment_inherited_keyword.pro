;+
; NAME:
;    AUGMENT_INHERITED_KEYWORD
;
; PURPOSE:
;    Adds keywords to the _EXTRA structure.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    AUGMENT_INHERITED_KEYWORD, Extra, Label, Value
;
; INPUTS:
;    Extra:  A structure of the form passed via the _EXTRA facility
;            inside a procedure or function. On output, contains
;            all old keywords (if any) plus the new Label=Value pair.
;
;    Label:  String containing a new keyword to be added to Extra.
;
;    Value:  Value to assign to the keyword.
;
; EXAMPLE:
;    PRO FUNNYPLOT, x, y, _EXTRA=extraplot
;      IF x[0] GT y[0] THEN AUGMENT_INHERITED_KEYWORD, extraplot, 'color', 2
;      PLOT, x, y, _EXTRA=extraplot
;    END
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;-
pro augment_inherited_keyword, extra, label, value

if n_elements(extra) eq 0 then extra = create_struct(label,value) $
else extra = create_struct(label,value,extra)

end

