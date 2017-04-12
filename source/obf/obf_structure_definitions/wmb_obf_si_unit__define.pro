;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_unit__define.pro
; 
; Note that the fractions set the value of the exponents that are applied
; to the SI base units in order to define any given SI derived unit
; 
; The order of the exponents array is as follows:
; 
; exponent[0]: length [m]
; exponent[1]: mass [kg]
; exponent[2]: time [s]
; exponent[3]: current [A]
; exponent[4]: temperature [K]
; exponent[5]: particle number [mol]
; exponent[6]: luminosity [cd]
; exponent[7]: radians [rad]
; exponent[8]: steradians [sr]
;

pro wmb_obf_si_unit__define

    compile_opt idl2, strictarrsubs

    tmpa = {wmb_obf_si_fraction}
    
    tmpb = replicate(tmpa, 9)

    tags = ['exponent', 'scalefactor']

    tmps = create_struct(tags, tmpb, $
                               double(0.0), $
                               NAME='wmb_obf_si_unit')

end