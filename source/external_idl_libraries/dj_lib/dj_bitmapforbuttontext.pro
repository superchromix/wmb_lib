FUNCTION DJ_BitmapForButtonText, str, textColorRGB=textColorRGB, font=font, $
    BackgroundColorRGB=bgColorRGB, xsize=inXSize, ysize=inYSize

    wTLB = Widget_Base()
    wBtn = Widget_Button(wTLB)
    if n_elements(font) eq 0 then begin
        font = Widget_Info(wBtn, /FontName)
    endif
    sysColors = Widget_Info(wBtn, /System_Colors)
    if not keyword_set(textColorRGB) then textColorRGB = sysColors.Button_Text
    if n_elements(bgColorRGB) eq 0 then bgColorRGB = syscolors.face_3d
    xs = 1000
    ys = 200
    border=3
    Window, XSize=xs, YSize=ys, /Pixmap, /Free
    Erase, Color=Total(bgColorRGB * [1, 256, 65536L])
    blankRGB = TVRD(True=3)
    device, get_current_font=currFont   ; Save currently used font
    Device, Set_Font=font
    XYOutS, xs/2, ys/2, str, /Device, Alignment=0.5, Font=0, $
        Color=Total(textColorRGB * [1, 256, 65536L])
    textRGB = TVRD(True=3)
    Device, Set_Font=currFont           ; Restore previous font
    WDelete, !D.Window
    text2D = Total(textRGB NE blankRGB, 3)
    whereX = Where(Total(text2D, 2) NE 0, nWhereX)
    whereY = Where(Total(text2D, 1) NE 0, nWhereY)
    IF nWhereX * nWhereY EQ 0 THEN Return, blankRGB[0, 0, *]

    xSize = N_Elements(inXSize) EQ 0 ? whereX[nWhereX-1] - whereX[0]+1 + 2*border : inXSize
    ySize = N_Elements(inYSize) EQ 0 ? whereY[nWhereY-1] - whereY[0]+1 + 2*border : inYSize
    middleX = Ceil((whereX[nWhereX-1] + whereX[0])/2.0)
    middleY = Ceil((whereY[nWhereY-1] + whereY[0])/2.0)
    result = textRGB[ (middleX - xsize/2) : (middleX + xsize-1-(xsize/2)), $
        (middleY - ysize/2) : (middleY + ysize-1-(ysize/2)), *]

    ;;    In Windows 7, an RGB value passed to Widget_Button will be rendered with
    ;;    its lower-left pixel transparent, as well as any pixels that match that
    ;;    RGB triple.

    IF ~Array_Equal(bgColorRGB, syscolors.face_3d) THEN BEGIN

        ;;    Make first pixel different from all others.

        ;;    Find all unique 24-bit RGB values.
        nPixels = N_Elements(result)/3
        pixels24bit = Total(Reform(result, [nPixels, 3]) * $
            Rebin(Transpose([1, 256, 65536L]), [nPixels, 3]), 2, $
            /Preserve_Type)
        uniq24bit = pixels24bit[Uniq(pixels24bit, Sort(pixels24bit))]
        IF N_Elements(uniq24bit) LT 256L^3 THEN BEGIN ; Some RGB value is not present
            IF uniq24bit[0] NE 0 THEN unused24bit = 0L $
            ELSE BEGIN
                diff24bit = [uniq24bit[1:*], 256L^3]-uniq24bit
                whNot1 = Where(diff24bit NE 1) ; There will be at least one
                unused24bit = whNot1[0]+1L     ; First one with step>1 was not present
            ENDELSE ; 0L did appear in result
            result[0, 0, *] = (Byte(unused24bit, 0, 4))[0:2]
        ENDIF ; Some RGB value is not present

    ENDIF ; Need to make lower-left pixel unique

    RETURN, result

END
