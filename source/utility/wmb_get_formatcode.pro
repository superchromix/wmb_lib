;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_get_formatcode
;
;   Given a scalar input, this function returns a generic format 
;   code for use with the FORMAT keyword in print, printf, etc.  
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_get_formatcode, x

    chktype = size(x,/TYPE)
    
    outstr = 'A'
    
    case chktype of
    
        0: 
        1: outstr = 'I0'
        2: outstr = 'I0'
        3: outstr = 'I0'
        
        4: outstr = 'G0'

        5: outstr = 'G0'
        6: 
        7: outstr = 'A'
        8: 
        9: 
        10: 
        11: 
        12: outstr = 'I0'
        13: outstr = 'I0'
        14: outstr = 'I0'
        15: outstr = 'I0'

    end

    return, outstr
    
end