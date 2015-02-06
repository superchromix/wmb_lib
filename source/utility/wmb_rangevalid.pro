;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Helper method for testing valid indices and ranges
;   
;   positive_range is an output keyword which returns the 
;   range with positive indices
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_Rangevalid, range, $
                         dimension_size, $
                         positive_range=positive_range

    compile_opt idl2, strictarrsubs

    chkdim = dimension_size
    
    rangestart = long64(range[0])
    if rangestart lt 0 then rangestart = rangestart + chkdim
    rangeend = long64(range[1])
    if rangeend lt 0 then rangeend = rangeend + chkdim
    rangestride = long64(range[2])

    positive_range = [rangestart,rangeend,rangestride]

    ; the full range is always valid
    if (rangestart eq 0) and $
       (rangeend eq chkdim-1) and $
       (rangestride eq 1) then return, 1

    minrange = 0LL
    maxrange = chkdim - 1LL
    
    maxstride = abs(rangeend-rangestart) > 1
    minstride = -maxstride

    if (rangestart lt minrange) or (rangestart gt maxrange) then return, 0
    if (rangeend lt minrange) or (rangeend gt maxrange) then return, 0
    
    if (rangestride eq 0) then return, 0
    if (rangestride lt minstride) or (rangestride gt maxstride) then return, 0

    if (rangestart lt rangeend) and (rangestride lt 0) then return, 0
    if (rangestart gt rangeend) and (rangestride gt 0) then return, 0

    return, 1

end
