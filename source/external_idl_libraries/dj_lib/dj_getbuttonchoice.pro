;+
; :Author: Dick Jackson Software Consulting Inc., www.d-jackson.com
;-

PRO DJ_GetButtonChoiceSetOrderLabels, p

    COMPILE_OPT IDL2, STRICTARRSUBS
    @DJ_ErrorCatchPro

    FOR choiceI=0, N_Elements((*p).wChoices)-1 DO $ ; Clear all to ''
        Widget_Control, (*p).wChoices[choiceI], Set_Value=''
    FOR pickedI=0, Total(*(*p).pOrderedIs NE -1)-1 DO $ ; Add numbers where needed
        Widget_Control, (*p).wChoices[(*(*p).pOrderedIs)[pickedI]], $
        Set_Value=StrTrim(pickedI+1, 2)

END ;; DJ_GetButtonChoiceSetOrderLabels

;----------------------------------------

PRO DJ_GetButtonChoiceChoiceButtonHandler, event

    COMPILE_OPT IDL2, STRICTARRSUBS
    @DJ_ErrorCatchPro

    ;;    Handle click on "choice" button (not OK, Cancel, etc.)

    ;;    Only handle events if /Ordered
    Widget_Control, event.top, Get_UValue = p
    IF ~(*p).ordered THEN RETURN

    choiceI = (Where((*p).wChoices EQ event.id))[0]

    nExisting = Total(*(*p).pOrderedIs NE -1)
    IF Total(*(*p).pOrderedIs EQ choiceI) EQ 0 THEN $ ; Clicked an unclicked btn
        ;;    Add to array of ordered indices ("ordered I's")
        *(*p).pOrderedIs = nExisting EQ 0 ? [choiceI] : [*(*p).pOrderedIs, choiceI] $
    ELSE *(*p).pOrderedIs = nExisting EQ 1 ? [-1] : $
        (*(*p).pOrderedIs)[Where(*(*p).pOrderedIs NE choiceI)]

    DJ_GetButtonChoiceSetOrderLabels, p

END ;; DJ_GetButtonChoiceChoiceButtonHandler

;----------------------------------------

PRO DJ_GetButtonChoice_Event, event

    COMPILE_OPT IDL2, STRICTARRSUBS
    @DJ_ErrorCatchPro

    ;;    Only handle button events and timer events (for AutoClickButton).
    eventType = Tag_Names(event, /Structure_Name)
    IF eventType NE 'WIDGET_BUTTON' AND eventType NE 'WIDGET_TIMER' THEN RETURN
    Widget_Control, event.top, Get_UValue = pState
    Widget_Control, event.id, Get_UValue = buttonUValue
    IF StrMid(buttonUValue, 0, 2) EQ 'OK' THEN BEGIN ; Expect 'OK0', 'OK1'...
        (*pState).okIndex = Long(StrMid(buttonUValue, 2)) ; Extract index from UValue
        ;; Get results from multiple buttons
        IF (*pState).ordered THEN BEGIN   ; Get ordered set of chosen indices
            whSet = *(*pstate).pOrderedIs  ; Will be -1 or an array of indices
            nSet = Total(whSet NE -1, /Integer)
            nChoices = N_Elements((*pState).choices)
            btnsSet = BytArr(nChoices)
            IF nSet GT 0 THEN btnsSet[whSet] = 1B
            ignoredSet = Where(btnsSet, nSet, Complement=complement, $
                NComplement=nComplement)
        ENDIF ELSE BEGIN                  ; Get unordered set of chosen indices
            wBtns = Widget_Info((*pState).wMultipleBase, /All_Children)
            btnsSet = Widget_Info(wBtns, /Button_Set)
            whSet = Where(btnsSet, nSet, Complement=complement, $
                NComplement=nComplement)
        ENDELSE
        IF (*pState).returnIndex THEN *(*pState).pResult = whSet $
        ELSE BEGIN
            IF nSet EQ 0 THEN *(*pState).pResult = '' $
            ELSE *(*pState).pResult = (*pState).choices[whSet]
        ENDELSE ;; not returnIndex
        (*pState).nChosen = nSet
        *(*pState).pComplement = complement
        (*pState).nComplement = nComplement
        (*pState).cancel = 0B
        Widget_Control, event.top, /Destroy     ; Destroy window
    ENDIF ELSE CASE buttonUValue OF
    'SelectAll': IF (*pState).ordered THEN BEGIN ; Add all remaining ones
        nChoices = N_Elements((*pState).choices)
        IF (*(*pState).pOrderedIs)[0] EQ -1 THEN $
            *(*pState).pOrderedIs = LIndGen(nChoices) $
        ELSE IF N_Elements(*(*pState).pOrderedIs) LT nChoices THEN BEGIN
            toBeAdded = Replicate(1B, nChoices)
            toBeAdded[*(*pState).pOrderedIs] = 0B
            *(*pState).pOrderedIs = [*(*pState).pOrderedIs, Where(toBeAdded)]
        ENDIF
        DJ_GetButtonChoiceSetOrderLabels, pState
    ENDIF ELSE BEGIN             ; Set all *sensitive* buttons to Selected state
        wBtns = Widget_Info((*pState).wMultipleBase, /All_Children)
        wSensBtns = wBtns[Where(Widget_Info(wBtns, /Sensitive))]
        IF wSensBtns[0] NE -1 THEN $
            FOR btnI=0, N_Elements(wSensBtns)-1 DO $
            Widget_Control, wSensBtns[btnI], Set_Button=1
    END ;; 'Select All' button clicked
    'ClearAll': IF (*pState).ordered THEN BEGIN
        (*pState).pOrderedIs = Ptr_New(-1)
        DJ_GetButtonChoiceSetOrderLabels, pState
    ENDIF ELSE BEGIN              ; Set all *sensitive* buttons to Cleared state
        wBtns = Widget_Info((*pState).wMultipleBase, /All_Children)
        wSensBtns = wBtns[Where(Widget_Info(wBtns, /Sensitive))]
        IF wSensBtns[0] NE -1 THEN $
            FOR btnI=0, N_Elements(wSensBtns)-1 DO $
            Widget_Control, wSensBtns[btnI], Set_Button=0
    END ;; 'Select All' button clicked
    'Cancel': BEGIN                      ; Prepare 'Cancel' result
        *(*pState).pResult = ''
        (*pState).nChosen = 0
        (*pState).cancel = 1B
        Widget_Control, event.top, /Destroy     ; Destroy window
    END ;; 'Cancel' button clicked
    ELSE: IF (*pState).multiple THEN RETURN $ ; In 'multiple' ignore choice btns
    ELSE BEGIN                                ; Return single button result
        IF (*pState).returnIndex THEN $
            *(*pState).pResult = Long(buttonUValue) $ ; index stored in UValue
        ELSE BEGIN
            IF (*pState).lookupChoices THEN $
                *(*pState).pResult = (*pState).choices[Long(buttonUValue)] $
            ELSE BEGIN
                Widget_Control, event.id, Get_Value=buttonValue
                *(*pState).pResult = buttonValue
            ENDELSE
        ENDELSE
        (*pState).nChosen = 1
        Widget_Control, event.top, /Destroy     ; Destroy window
    ENDELSE
ENDCASE
END ;; DJ_GetButtonChoice_Event

; DJ_GetButtonChoice
;+
; :Description:
; Presents a dialog with buttons containing the strings provided and returns
; the string corresponding to the button that the user presses.
;
; :Params:

; @param    choices    {in}{type=String array}
;           The choices to be presented to the user

; @keyword  WindowTitle {in}{optional}{type=String}
;           A title to be displayed in the window's title bar

; @keyword  Title      {in}{optional}{type=String scalar or array}
;           One or more strings to be displayed inside the window, above the
;           buttons. If a single '' is given, no line is displayed.
;           Default: a helpful message depending on options, such as:
;           'Click to Indicate Sequence Then Click OK, or Cancel',
;           'Make Selection Then Click OK, or Cancel'
;           'Click One of These Choices, or Cancel'

; @keyword  CenterTLB  {in}{optional}{type=Boolean}
;           If set, the window will be centered on the screen

; @keyword  CenterOnTLB  {in}{optional}{type=Long}
;           If set, the window will be centered on the TLB given here

; @keyword  PositionTLB  {in}{optional}{type=2-element Numeric Array}
;           If set, the window will be positioned on the screen according to
;           the normalized [x, y] value passed here. For example, to position
;           along the top edge, midway between left and right edge, specify
;           PositionTLB=[0.5, 1.0].

; @keyword  Columns  {in}{optional}{type=Numeric}
;           Specifies the number of columns of buttons to present.
;           Column and Rows must not both be provided.
;           Default is to lay buttons out in as few columns as needed to
;           fit the height of the screen.

; @keyword  Rows  {in}{optional}{type=Numeric}
;           Specifies the number of rows of buttons to present.
;           Column and Rows must not both be provided.

; @keyword  Grid_Layout  {in}{optional}{type=Boolean}
;           Passed to Widget_Base for the base of buttons. Set this keyword to
;           force the base to have a grid layout, in which all rows have the
;           same height, and all columns have the same width. The row heights
;           and column widths are taken from the largest child widget.

; @keyword  Multiple     {in}{optional}{type=Boolean}
;           If set, the buttons will be presented as checkboxes and buttons
;           labeled 'OK' and 'Cancel' will be provided. If Cancel is clicked,
;           output keyword Cancel will be set. If OK is clicked, an array
;           containing a subset of the input values (corresponding to the items
;           checked by the user) will be returned. Note: these will be of the
;           same type as the originals, not necessarily strings (as is the case
;           with single choice, Multiple=0).

; @keyword  Ordered      {in}{optional}{type=Boolean}
;           If set (which implies /Multiple), a blank button will be placed
;           beside each choice, which the user can click in sequence to indicate
;           the desired ordering of selected items. Result is returned as
;           described for Multiple. If called with Ordered=1 and Multiple=0, an
;           error is signalled.

; @keyword  Align_Left     {in}{optional}{type=Boolean}
;           If set, the buttons will have their left sides aligned, and the text
;           in them will also be left-aligned

; @keyword  Align_Center     {in}{optional}{type=Boolean}
;           If set, the buttons will be center-aligned (not filling the width of
;           the window), and the text in them will also be center-aligned)

; @keyword  Align_Right     {in}{optional}{type=Boolean}
;           If set, the buttons will have their right sides aligned, and the text
;           in them will also be right-aligned

; @keyword  ArrowButtons     {in}{optional}{type=Boolean}
;           If set, instead of each choice's text being in a button, an 'arrow'
;           button will be shown with the text to the right. This is useful with
;           choices of varying length, to avoid buttons of varying width or
;           center-aligning the text.

; @keyword  NChosen     {out}{optional}
;           Set this keyword to a named variable to receive the number of items
;           chosen by the user (0 if Cancelled or if none chosen).

; @keyword  ReturnIndex      {in}{optional}
;           If set, return a vector of index values of the selected buttons,
;           rather than the selected strings.

; @keyword  Complement      {out}{optional}
;           Set this keyword to a named variable to receive the index values of
;           the items *not* chosen by the user (-1 if all chosen).

; @keyword  NComplement      {out}{optional}
;           Set this keyword to a named variable to receive the number of items
;           *not* chosen by the user (0 if Cancelled or if all chosen).

; @keyword  OKButtons  {in}{optional}{type=String}{default='OK'}
;           An array of strings for several 'OK'-type buttons, where the index
;           value of the one clicked by the user will be returned in OKIndex.
;           If Cancel is clicked, -1 will be returned.

; @keyword  OKIndex    {out}{optional}{type=Long}
;           Set this keyword to a named variable to receive the index value of
;           the OKButtons that was clicked by the user. If Cancel was clicked,
;           -1 will be returned.

; @keyword  Cancel     {out}{optional}
;           Set this keyword to a named variable to receive a value 1B if
;           Cancel was clicked, 0B otherwise.

; @keyword  Selected   {in}{optional}{type=Boolean Array}{default=0}
;           When Multiple is set, set this to an array of values corresponding
;           to the choices provided. If the element for a given button is set,
;           its checkbox will be selected, otherwise it will be clear. If not
;           enough elements are provided, this array is reused from the start
;           as needed, and extra elements are ignored.

; @keyword  Sensitive   {in}{optional}{type=Boolean Array}
;           Set this to an array of values corresponding to the choices
;           provided. If the element for a given button is set, it appears and
;           functions normally. If not set (value 0), the button appears dimmed
;           and does not function.

; @keyword  Map   {in}{optional}{type=Boolean Array}
;           Set this to an array of values corresponding to the choices
;           provided. If the element for a given button is set, it appears and
;           functions normally. If not set (value 0), the button does not appear
;           at all, leaving blank space.

; @keyword  Tab_Mode    {in}{optional}{type=Boolean}
;           This is passed to the Widget_Base() call for the top-level base,
;           and, if set, causes the first choice button to receive the input
;           focus.

; @keyword  Space    {in}{optional}{type=Numeric}
;           This is passed to the Widget_Base() call for the base that contains
;           the buttons, to allow control of their spacing.

; @keyword  Font     {in}{optional}{type=String}
;           This is passed to the Widget_Label() and Widget_Button calls for all
;           text to appear in the window.

; @keyword  ButtonTextColor    {in}{optional}{type=Numeric}
;           Specifies the color(s) to be used for text in the choice buttons
;           Three elements at a time are used as RGB values, and the values are
;           reused as needed.
;           E.g.: ButtonTextColor=[255,0,0] makes all choices' text red,
;           ButtonTextColor=[[255,0,0],[0,255,0],[0,0,255]] would make the
;           choices' text red, green, blue, then repeating as needed. This is
;           handled by making a bitmap image for the button contents, rather
;           than a string, so the button may appear slightly differently from
;           usual. Note: does not apply to the text when using /ArrowButtons

; @keyword  ButtonBackgroundColor    {in}{optional}{type=Numeric}
;           Specifies the color(s) to be used for the background behind the text
;           in the choice buttons. Usage is the same as ButtonTextColor above.
;           Note: does not apply to the text when using /ArrowButtons

; @keyword  BackgroundImage    {in}{optional}{type=Byte Array or String}
;           Specifies an image array or filename of an image to be displayed at
;           the top of the window, above the button choices.

; @keyword  AutoClickButton    {in}{optional}{type=String or Integer}
;           If provided, this indicates a button that should be "clicked"
;           automatically after a delay (given in AutoClickDelay). It can be
;           a string (matching a choice or an OK string or 'Cancel'), or an
;           integer (taken as an index into the choices array).

; @keyword  AutoClickDelay    {in}{optional}{type=Numeric}
;           The length of time to wait before the AutoClickButton is "clicked",
;           in seconds.

; @keyword  _Extra     {in}{optional}
;           Any other keywords are passed to the Widget_Base() call for the
;           top-level base. Useful keywords are XOffset, YOffset.

; @returns  String corresponding to the button that the user presses.

; @examples
; <code>    x = DJ_GetButtonChoice(['One', 'Two'])
; <br>      x = DJ_GetButtonChoice(['red','green','blue'], Font='Arial*24', $
; <br>                          ButtonTextColor=[[255,0,0],[0,192,0],[0,0,255]])
; </code>

; @author   Dick Jackson, D-Jackson Software Consulting, www.d-jackson.com
;-

FUNCTION DJ_GetButtonChoice, choices, WindowTitle=windowTitle, $
    Title=title, $
    Columns=columns, Rows=rows, Grid_Layout=grid, $
    CenterTLB=centerTLB, CenterOnTLB=centerOnTLB, PositionTLB=positionTLB, $
    Multiple=inMultiple, Ordered=ordered, ReturnIndex=returnIndex, $
    NChosen=nChosen, OKButtons=okButtons, OKIndex=okIndex, Cancel=cancel, $
    Complement=complement, NComplement=nComplement, $
    Selected=selected, Sensitive=sens, Map=maps, Tab_Mode=tabMode, $
    XOffset=xOffset, YOffset=yOffset, $
    Align_Left=alignLeft, Align_Center=alignCenter, Align_Right=alignRight, $
    ArrowButtons=arrowButtons, Space=space, $
    Font=font, ButtonTextColor=color, ButtonBackgroundColor=bgColor, $
    ButtonTextXSize=xSize, ButtonTextYSize=ySize, $
    BackgroundImage=backgroundImage, $
    AutoClickButton=autoClickButton, AutoClickDelay=autoClickDelay, $
    _Extra=extra

    COMPILE_OPT IDL2, STRICTARRSUBS
    @DJ_ErrorCatchFun

    columnOrRowPassed = (N_Elements(columns) EQ 1 && columns GT 0) || $
        (N_Elements(rows) EQ 1 && rows GT 0)
    IF ~columnOrRowPassed THEN columns = 0
    nChoices = N_Elements(choices)
    IF nChoices LT 1 THEN Return, -1

    ;;    /Ordered implies /Multiple, so report error if /Ordered and Multiple=0

    IF Keyword_Set(ordered) && N_Elements(inMultiple) NE 0 && $
        ~Keyword_Set(inMultiple) THEN Message, '/Ordered implies /Multiple, and '+ $
        'call had /Ordered with Multiple explicitly not set'
    multiple = Keyword_Set(ordered) || Keyword_Set(inMultiple)

    IF N_Elements(title) EQ 0 THEN title = Keyword_Set(multiple) ? $
        (Keyword_Set(ordered) ? 'Click to Indicate Sequence' : 'Make Selection')+ $
        ' Then Click OK, or Cancel' : $
        ('Click One of These Choices'+(Arg_Present(cancel) ? ', or Cancel' : '')+':')
    IF N_Elements(windowTitle) EQ 0 THEN windowTitle = ' '

    IF N_Elements(okButtons) GT 0 AND ~Keyword_Set(inMultiple) THEN $
        Message, 'OKButtons are to be used only with /Multiple. Reorganize to '+ $
        'include the "OK" buttons as regular button choices.'

    IF N_Elements(okButtons) EQ 0 THEN okButtons = ['OK']
    wOKButtons = LonArr((nOKButtons = N_Elements(okButtons)))

    nChars = Fix(ALog10(nChoices))+1
    blankStr = StrJoin(Replicate(' ', nChars))

    IF N_Elements(sens) EQ 0 THEN sens = Replicate(1B, nChoices)
    nSens = N_Elements(sens)
    IF N_Elements(maps) EQ 0 THEN maps = Replicate(1B, nChoices)
    nMaps = N_Elements(maps)

    scrSize = GetPrimaryScreenSize(/Exclude_Taskbar)
    wChoices = LonArr(nChoices)

    useBitmap = N_Elements(color) GE 3 OR N_Elements(bgColor) GE 3
    ;;    To cover the cases where one of 'color' and 'bgColor' is given, but not
    ;;    the other, set them both to default values if undefined.
    sysColors = Widget_Info((wTemp=Widget_Base()), /System_Colors)
    Widget_Control, wTemp, /Destroy
    IF N_Elements(color) EQ 0 THEN color = sysColors.Button_Text
    IF N_Elements(bgColor) EQ 0 THEN bgColor = sysColors.Face_3D

    IF N_Elements(backgroundImage) EQ 0 THEN Undefine, bgImgArray $
    ELSE BEGIN
        IF N_Elements(backgroundImage) EQ 1 AND $
            Size(backgroundImage, /TName) EQ 'STRING' THEN BEGIN

            bgImgArray = Read_Image(backgroundImage)
            IF bgImgArray[0] EQ -1 THEN Undefine, bgImgArray
        ENDIF ELSE bgImgArray = backgroundImage
    ENDELSE

    saveWIndex = !D.Window               ; Save so we can get back to current window

    REPEAT BEGIN                            ; Run with varying number of columns
        ; until base fits within height of
        ; screen
        IF ~columnOrRowPassed THEN columns++
        tlb = Widget_Base(/Column, /Base_Align_Center, Title=windowTitle, $
            Tab_Mode=tabMode, TLB_Frame_Attr=8, $
            XOffset=xOffset, YOffset=yOffset, _Extra=extra)
        if n_elements(bgImgArray) ne 0 then begin
            sz = size(bgImgArray, /dimensions)
            if n_elements(sz) eq 2 then begin
                imgxsize = sz[0]
                imgysize = sz[1]
                true = 0
            endif else begin
                imgxsize = sz[1]
                imgysize = sz[2]
                true = 1
            endelse
            wDraw = widget_draw(tlb,xsize=imgxsize, ysize=imgysize, retain=2)
        endif

        IF ~(N_Elements(title) EQ 1 && title EQ '') THEN $
            FOREACH titleStr, title DO $
            void = Widget_Label(tlb, Value = titleStr, Font=font)

        wButtonBase = Widget_Base(tlb, Column=columns, Row=rows, Grid_Layout=grid, $
            NonExclusive=Keyword_Set(multiple) AND $
            ~Keyword_Set(ordered), Space=space)
        FOR choiceI=0, nChoices-1 DO BEGIN
            wBaseForButton = Keyword_Set(arrowButtons) OR Keyword_Set(ordered) ? $
                Widget_Base(wButtonBase, /Row, Sensitive=sens[choiceI MOD nSens]) : $
                wButtonBase
            Widget_Control, wBaseForButton, Map=maps[choiceI MOD nMaps]
            choiceText = StrTrim(choices[choiceI], 2)
            wChoices[choiceI] = $
                Widget_Button(wBaseForButton, $
                Value=(Keyword_Set(arrowButtons) ? $
                FilePath('shift_right.bmp', $
                SubDir=['resource', 'bitmaps']) : $
                (Keyword_Set(ordered) ? blankStr : $
                (useBitmap ? $
                DJ_BitmapForButtonText(choiceText, TextColorRGB= $
                color[(choiceI*3) MOD N_Elements(color) : $
                (choiceI*3+2) MOD N_Elements(color)], $
                BackgroundColorRGB= $
                bgColor[(choiceI*3) MOD N_Elements(bgColor) : $
                (choiceI*3+2) MOD N_Elements(bgColor)], $
                Font=font, xsize=xsize, ysize=ysize) : $
                choiceText))),$
                Bitmap=Keyword_Set(arrowButtons), Font=font, $
                UValue=StrTrim(choiceI, 2), $ ; Store index as string
                Sensitive=sens[choiceI MOD nSens], $
                Event_Pro=(Keyword_Set(ordered) ? $
                'DJ_GetButtonChoiceChoiceButtonHandler' : ''), $
                Align_Left=alignLeft, Align_Center=alignCenter, $
                Align_Right=alignRight)

            IF Keyword_Set(arrowButtons) OR Keyword_Set(ordered) THEN $
                wVoid = Widget_Label(wBaseForButton, Value=choiceText, Font=font)

        ENDFOR ;; choiceI over nChoices

        IF Keyword_Set(multiple) THEN BEGIN ;; multiple selection
            IF N_Elements(selected) NE 0 THEN FOR choiceI=0, nChoices-1 DO $
                Widget_Control, wChoices[choiceI], $
                Set_Button=selected[choiceI MOD N_Elements(selected)]
            wBottomRow = Widget_Base(tlb, /Row)
            ;;    Add 'Select All' and 'Clear All' buttons here
            selectAllClearAllBase = Widget_Base(wBottomRow, /Row)
            wSelectAllBtn = Widget_Button(selectAllClearAllBase, $
                Value='Select All', UValue='SelectAll', $
                Font=font)
            wClearAllBtn = Widget_Button(selectAllClearAllBase, $
                Value='Clear All', UValue='ClearAll', $
                Font=font)
            okCancelBase = Widget_Base(wBottomRow, /Row)
            FOR okI=0, N_Elements(okButtons)-1 DO $
                wOKButtons[okI] = $
                Widget_Button(okCancelBase, Value=okButtons[okI], $
                UValue='OK'+StrTrim(okI, 2), $ ; 'OK0', 'OK1',...
                Font=font)
            wOKBtn = Widget_Info(okCancelBase, /Child) ; Use ID of first OK button
            wCancelBtn = Widget_Button(okCancelBase, Value='Cancel', UValue='Cancel',$
                Font=font)
        ENDIF $       ;; multiple selection
        ELSE IF Arg_Present(cancel) THEN BEGIN    ;; single selection with Cancel
            cancelBase = Widget_Base(tlb, /Row)
            wCancelBtn = Widget_Button(cancelBase, Value='Cancel', UValue='Cancel', $
                Font=font)
        ENDIF        ;; single selection
        geom = Widget_Info(tlb, /Geometry)
    ENDREP UNTIL columnOrRowPassed OR geom.scr_YSize LE scrSize[1]

    IF Keyword_Set(centerTLB) THEN DJ_CenterTLB, tlb
    IF N_Elements(centerOnTLB) EQ 1 THEN DJ_CenterTLB, tlb, CenterOnTLB=centerOnTLB
    IF N_Elements(positionTLB) EQ 2 THEN DJ_PositionTLB, tlb, positionTLB

    ;;    X/YOffset are not being respected when /Floating and Group_Leader are
    ;;    specified. Work around it as follows (note that Map does not work with
    ;;    modal widgets):
    IF ~Widget_Info(tlb, /Modal) THEN Widget_Control, tlb, Map=0
    Widget_Control, tlb, /Realize ; Choice will be stored in tlb's UValue
    Widget_Control, tlb, XOffset=xOffset, YOffset=yOffset
    IF ~Widget_Info(tlb, /Modal) THEN Widget_Control, tlb, Map=1
    if n_elements(bgImgArray) ne 0 then begin
        widget_control, wDraw, get_value=winID
        wset, winID
        tv, bgImgArray, true=true
    endif

    IF Keyword_Set(tabMode) THEN BEGIN ; Set input focus to first sensitive widget
        widSens = Widget_Info(wChoices, /Sensitive)
        whWidSens = Where(widSens, nWidSens)
        IF nWidSens GT 0 THEN $
            Widget_Control, wChoices[whWidSens[0]], /Input_Focus $
        ELSE IF Keyword_Set(multiple) && N_Elements(wOKBtn) EQ 1 && $
            Widget_Info(wOKBtn, /Valid_ID) THEN $
            Widget_Control, wOKBtn, /Input_Focus
    ENDIF ;; tabMode

    pResult = Ptr_New('')
    pComplement = Ptr_New('')
    state = {multiple:Keyword_Set(multiple), $
        ordered:Keyword_Set(ordered), $
        wMultipleBase:wButtonBase, $
        wChoices:wChoices, $
        pOrderedIs:Ptr_New(-1L), $
        lookupChoices:Keyword_Set(arrowButtons) OR useBitmap, $
        choices:choices, $
        returnIndex:Keyword_Set(returnIndex), $
        pResult:pResult, $
        nChosen:0L, $
        pComplement:pComplement, $
        nComplement:0L, $
        okIndex:-1L, $ ; Return -1 unless an OK button is clicked
        cancel:0B}
    pState = Ptr_New(state)
    Widget_Control, tlb, Set_UValue=pState

    Widget_Control, tlb, /Show

    ;;    Handle request for AutoClick (have a button click happen after delay)
    ;
    IF N_Elements(autoClickButton) EQ 1 THEN BEGIN
        IF N_Elements(autoClickDelay) EQ 0 THEN autoClickDelay=10
        CASE Size(autoClickButton, /TName) OF
            'STRING': BEGIN
                IF (choiceI = (Where(choices EQ autoClickButton))[0]) NE -1 THEN $
                    Widget_Control, wChoices[choiceI], Timer=autoClickDelay $
                ELSE IF (okI = (Where(okButtons EQ autoClickButton))[0]) NE -1 THEN $
                    Widget_Control, wOKButtons[okI], Timer=autoClickDelay $
                ELSE IF autoClickButton EQ 'Cancel' THEN $
                    Widget_Control, wCancelBtn, Timer=autoClickDelay
            END
            ELSE: Widget_Control, wChoices[autoClickButton], Timer=autoClickDelay
        ENDCASE ;; of types for autoClickButton
    ENDIF ;; autoClickButton provided

    XManager, 'DJ_GetButtonChoice', tlb

    result = *pResult
    complement = *pComplement
    Ptr_Free, pResult, pComplement
    nChosen = (*pState).nChosen
    nComplement = (*pState).nComplement
    okIndex = (*pState).okIndex
    cancel = (*pState).cancel
    Ptr_Free, pState
    ; Restore previous window focus, if it is still open
    IF saveWIndex NE -1 THEN BEGIN
        Device, Window_State=windowState
        IF windowState[saveWIndex] THEN WSet, saveWIndex
    ENDIF ;; saveWIndex NE -1

    Return, result

END ;; DJ_GetButtonChoice
