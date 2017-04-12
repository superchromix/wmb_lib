;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_get_dimensionless.pro
;
;

function wmb_obf_si_get_dimensionless

    compile_opt idl2, strictarrsubs

    tmpa = {wmb_obf_si_unit}
    tmpa.exponent.denominator[*] = 1
    tmpa.scalefactor = 1.0
        
    return, tmpa
    
end