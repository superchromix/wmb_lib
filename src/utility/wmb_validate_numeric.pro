;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Validate that the input string, value, can be interpreted as a number by
;   IDL.  Note that IDL will accept some strange things as a number including
;   the string '32lksd342sdl' - this would come out as 321.0
;


function wmb_validate_numeric, value

    compile_opt strictarr

    on_ioerror, badValue

    if value eq '' then goto, badValue

    f = float(value)
    return, 1B

    badValue: return, 0B

end
