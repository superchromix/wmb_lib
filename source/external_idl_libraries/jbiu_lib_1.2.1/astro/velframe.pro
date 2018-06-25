;+
; NAME:
;    VELFRAME
;
; PURPOSE:
;    Converts radial velocities between Local Standard of Rest, Heliocentric and Galactocentric velocity frames.
;
; CATEGORY:
;    Astro
;
; CALLING SEQUENCE:
;    Result = VELFRAME(Velocity, Longitude, Latitude)
;
; INPUTS:
;    Velocity:    Scalar or vector of radial velocity to be converted, in km/s.
;
;    Longitude:   Scalar or vector of longitudinal coordinates at which the transformation is computed.
;                 Assumed to be decimal RA degrees unless /GALACTIC is specified, in which case it is
;                 decimal galactic l.
;
;    Latitude:    Scalar or vector of latitudinal coordinates at which the transformation is computed.
;                 Assumed to be decimal Dec degrees unless /GALACTIC is specified, in which case it is
;                 decimal galactic b.
;
; KEYWORD PARAMETERS:
;    GALACTIC: If set, input coordinates are in decimal galactic coordinates (l,b) rather than RA and Dec.
;
;    INFRAME:  Input frame. One of 'LSR', 'HELIO' or 'GSR'.
;
;    OUTFRAME: Output frame. One of 'LSR', 'HELIO' or 'GSR'.
;
;    EQUINOX:  Equinox year of Coords. Default: 2000.0.
;
; OUTPUTS:
;    Output radial velocity in desired frame, assuming no proper motion.
;
; MODIFICATION HISTORY:
;    Written by:   Jeremy Bailin
;    29 July 2016  Initial writing
;-
function velframe, velocity, longitude, latitude, galactic=galacticp, vlsr=vlsr, vhelio=vhelio, vgsr=vgsr, $
    inframe=inframe, outframe=outframe, equinox=equinox

degrad = 1./!radeg   ; faster to multiply than divide

setdefaultvalue, equinox, 2000.0

; transform coordinates to galactic
if keyword_set(galacticp) then begin
    gal_l = longitude
    gal_b = latitude
endif else begin
    glactc, longitude, latitude, equinox, gal_l, gal_b, 1, /degree
endelse

; velocity transformation is defined by an apex and a magnitude
lsr_info = {vmag:19.7, apex_l:56.16, apex_b:22.77}
gsr_info = {vmag:232.3, apex_l:87.8, apex_b:1.7}
helio_info = {vmag:0.0, apex_l:0.0, apex_b:0.0}

case strupcase(inframe) of
    'LSR': ininfo = lsr_info
    'GSR': ininfo = gsr_info
    'HELIO': ininfo = helio_info
    else: message, 'INFRAME must be one of LSR, GSR, or HELIO.'
endcase

vshift_in = ininfo.vmag * ( sin(gal_b*degrad) * sin(ininfo.apex_b*degrad) + $
    cos(gal_b*degrad) * cos(ininfo.apex_b*degrad) * cos((gal_l-ininfo.apex_l)*degrad) )

case strupcase(outframe) of
    'LSR': outinfo = lsr_info
    'GSR': outinfo = gsr_info
    'HELIO': outinfo = helio_info
    else: message, 'OUTFRAME must be one of LSR, GSR, or HELIO.'
endcase
           
vshift_out = outinfo.vmag * ( sin(gal_b*degrad) * sin(outinfo.apex_b*degrad) + $
    cos(gal_b*degrad) * cos(outinfo.apex_b*degrad) * cos((gal_l-outinfo.apex_l)*degrad) )

return, velocity - vshift_in + vshift_out

end

