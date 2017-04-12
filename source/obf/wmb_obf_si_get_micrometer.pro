;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_get_micrometer.pro
;
;

function wmb_obf_si_get_micrometer

    compile_opt idl2, strictarrsubs

    tmpa = {wmb_obf_si_unit}
    tmpa.exponent.numerator = [1,0,0,0,0,0,0,0,0]
    tmpa.exponent.denominator[*] = 1
    tmpa.scalefactor = 0.000001d
        
    return, tmpa
    
end