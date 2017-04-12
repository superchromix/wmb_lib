;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; wmb_obf_si_fraction__define.pro
;
;

pro wmb_obf_si_fraction__define

    compile_opt idl2, strictarrsubs

    tags = ['numerator', 'denominator']

    tmps = create_struct(tags, ulong(0), $
                               ulong(0), $
                               NAME='wmb_obf_si_fraction')

end