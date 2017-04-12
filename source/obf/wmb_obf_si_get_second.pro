;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_get_second.pro
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_obf_si_get_second

    compile_opt idl2, strictarrsubs

    tmpa = {wmb_obf_si_unit}
    tmpa.exponent.numerator = [0,0,1,0,0,0,0,0,0]
    tmpa.exponent.denominator[*] = 1
    tmpa.scalefactor = 1.0
        
    return, tmpa
    
end