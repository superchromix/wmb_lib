;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_histogram_findlib
;   
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_histogram_findlib, libpath

    ; Returns 1 if the external library is found, or 0 if not
  
    libpath = ''
  
    Help, Calls=callStack
  
    callingRoutine = (StrSplit(StrCompress(callStack[0])," ", /Extract))[0]

    thisRoutine = Routine_Info(callingRoutine, /Functions, /Source)
    
    sourcePath = thisroutine.Path
    
    root = StrMid(sourcePath, 0, $
                  StrPos(sourcePath, Path_Sep(), /Reverse_Search) + 1)
    
    myarch = !version.arch
    myos = !version.os
    
    if myos ne 'Win32' then begin
    
        msgtxt = 'Error: Only Microscoft Windows OS is supported'
        result = DIALOG_MESSAGE(msgtxt, /ERROR)
        return, 0
    
    endif
    
    case myarch of
    
        'x86_64': fname = 'wmb_histogram.dll'
        
        else: begin
        
            libpath = ''
            msgtxt = 'Error: Unsupported architecture'
            result = DIALOG_MESSAGE(msgtxt, /ERROR)
            return, 0
        
        end
        
    endcase
    
    libpath = root + fname
    
    if ~file_test(libpath) then begin
    
        msgtxt = 'Error: ' + fname + ' not found'
        result = DIALOG_MESSAGE(msgtxt, /ERROR)
        return, 0
        
    endif

    return, 1

end