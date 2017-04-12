;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_get_meter.pro
;
;

function wmb_obf_si_get_meter

    compile_opt idl2, strictarrsubs

    tmpa = {wmb_obf_si_unit}
    tmpa.exponent.numerator = [1,0,0,0,0,0,0,0,0]
    tmpa.exponent.denominator[*] = 1
    tmpa.scalefactor = 1.0
        
    return, tmpa
    
end