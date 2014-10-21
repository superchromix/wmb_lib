;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_numbered_filename
;   
;   Create a numbered filename of the form :
;   
;   basename_0001.ext
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_numbered_filename, basename, number, ndigits, extension

    fmtcode = '(I0' + strtrim(string(ndigits),2) + ')'
    
    outname = strtrim(basename,2)
    
    outnum = '_' + strtrim(string(number,format=fmtcode,/print),2)
    
    outext = strtrim(extension,2)
    
    if strmid(outext,0,1) ne '.' then outext = '.' + outext

    return, outname + outnum + outext
    
end