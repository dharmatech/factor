! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs cocoa kernel
math cocoa.messages cocoa.subclassing cocoa.classes cocoa.views
cocoa.application cocoa.pasteboard cocoa.types cocoa.windows
sequences ui ui.gadgets ui.gadgets.worlds ui.gestures
core-foundation.strings threads combinators math.geometry.rect ;
IN: ui.cocoa.views

: send-mouse-moved ( view event -- )
    [ mouse-location ] [ drop window ] 2bi move-hand fire-motion ;

: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    -> buttonNumber H{ { 0 1 } { 2 2 } { 1 3 } } at ;

: modifiers
    {
        { S+ HEX: 20000 }
        { C+ HEX: 40000 }
        { A+ HEX: 100000 }
        { M+ HEX: 80000 }
    } ;

: key-codes
    H{
        { 71 "CLEAR" }
        { 36 "RET" }
        { 76 "ENTER" }
        { 53 "ESC" }
        { 48 "TAB" }
        { 51 "BACKSPACE" }
        { 115 "HOME" }
        { 117 "DELETE" }
        { 119 "END" }
        { 122 "F1" }
        { 120 "F2" }
        { 99 "F3" }
        { 118 "F4" }
        { 96 "F5" }
        { 97 "F6" }
        { 98 "F7" }
        { 100 "F8" }
        { 123 "LEFT" }
        { 124 "RIGHT" }
        { 125 "DOWN" }
        { 126 "UP" }
        { 116 "PAGE_UP" }
        { 121 "PAGE_DOWN" }
    } ;

: key-code ( event -- string ? )
    dup -> keyCode key-codes at
    [ t ] [ -> charactersIgnoringModifiers CF>string f ] ?if ;

: event-modifiers ( event -- modifiers )
    -> modifierFlags modifiers modifier ;

: key-event>gesture ( event -- modifiers keycode action? )
    dup event-modifiers swap key-code ;

: send-key-event ( view gesture -- )
    swap window propagate-key-gesture ;

: interpret-key-event ( view event -- )
    NSArray swap -> arrayWithObject: -> interpretKeyEvents: ;

: send-key-down-event ( view event -- )
    [ key-event>gesture <key-down> send-key-event ]
    [ interpret-key-event ]
    2bi ;

: send-key-up-event ( view event -- )
    key-event>gesture <key-up> send-key-event ;

: mouse-event>gesture ( event -- modifiers button )
    dup event-modifiers swap button ;

: send-button-down$ ( view event -- )
    [ nip mouse-event>gesture <button-down> ]
    [ mouse-location ]
    [ drop window ]
    2tri send-button-down ;

: send-button-up$ ( view event -- )
    [ nip mouse-event>gesture <button-up> ]
    [ mouse-location ]
    [ drop window ]
    2tri send-button-up ;

: send-wheel$ ( view event -- )
    [ nip [ -> deltaX ] [ -> deltaY ] bi [ sgn neg ] bi@ 2array ]
    [ mouse-location ]
    [ drop window ]
    2tri send-wheel ;

: send-action$ ( view event gesture -- junk )
    [ drop window ] dip send-action f ;

: add-resize-observer ( observer object -- )
    [
        "updateFactorGadgetSize:"
        "NSViewFrameDidChangeNotification" <NSString>
    ] dip add-observer ;

: string-or-nil? ( NSString -- ? )
    [ CF>string NSStringPboardType = ] [ t ] if* ;

: valid-service? ( gadget send-type return-type -- ? )
    over string-or-nil? over string-or-nil? and
    [ drop [ gadget-selection? ] [ drop t ] if ] [ 3drop f ] if ;

: NSRect>rect ( NSRect world -- rect )
    [ [ [ NSRect-x ] [ NSRect-y ] bi ] [ dim>> second ] bi* swap - 2array ]
    [ drop [ NSRect-w ] [ NSRect-h ] bi 2array ]
    2bi <rect> ;

: rect>NSRect ( rect world -- NSRect )
    [ [ rect-loc first2 ] [ dim>> second ] bi* swap - ]
    [ drop rect-dim first2 ]
    2bi <NSRect> ;

CLASS: {
    { +superclass+ "NSOpenGLView" }
    { +name+ "FactorView" }
    { +protocols+ { "NSTextInput" } }
}

! Rendering
{ "drawRect:" "void" { "id" "SEL" "NSRect" }
    [ 2drop window relayout-1 ]
}

! Events
{ "acceptsFirstMouse:" "char" { "id" "SEL" "id" }
    [ 3drop 1 ]
}

{ "mouseEntered:" "void" { "id" "SEL" "id" }
    [ nip send-mouse-moved ]
}

{ "mouseExited:" "void" { "id" "SEL" "id" }
    [ 3drop forget-rollover ]
}

{ "mouseMoved:" "void" { "id" "SEL" "id" }
    [ nip send-mouse-moved ]
}

{ "mouseDragged:" "void" { "id" "SEL" "id" }
    [ nip send-mouse-moved ]
}

{ "rightMouseDragged:" "void" { "id" "SEL" "id" }
    [ nip send-mouse-moved ]
}

{ "otherMouseDragged:" "void" { "id" "SEL" "id" }
    [ nip send-mouse-moved ]
}

{ "mouseDown:" "void" { "id" "SEL" "id" }
    [ nip send-button-down$ ]
}

{ "mouseUp:" "void" { "id" "SEL" "id" }
    [ nip send-button-up$ ]
}

{ "rightMouseDown:" "void" { "id" "SEL" "id" }
    [ nip send-button-down$ ]
}

{ "rightMouseUp:" "void" { "id" "SEL" "id" }
    [ nip send-button-up$ ]
}

{ "otherMouseDown:" "void" { "id" "SEL" "id" }
    [ nip send-button-down$ ]
}

{ "otherMouseUp:" "void" { "id" "SEL" "id" }
    [ nip send-button-up$ ]
}

{ "scrollWheel:" "void" { "id" "SEL" "id" }
    [ nip send-wheel$ ]
}

{ "keyDown:" "void" { "id" "SEL" "id" }
    [ nip send-key-down-event ]
}

{ "keyUp:" "void" { "id" "SEL" "id" }
    [ nip send-key-up-event ]
}

{ "cut:" "id" { "id" "SEL" "id" }
    [ nip T{ cut-action } send-action$ ]
}

{ "copy:" "id" { "id" "SEL" "id" }
    [ nip T{ copy-action } send-action$ ]
}

{ "paste:" "id" { "id" "SEL" "id" }
    [ nip T{ paste-action } send-action$ ]
}

{ "delete:" "id" { "id" "SEL" "id" }
    [ nip T{ delete-action } send-action$ ]
}

{ "selectAll:" "id" { "id" "SEL" "id" }
    [ nip T{ select-all-action } send-action$ ]
}

! Multi-touch gestures: this is undocumented.
! http://cocoadex.com/2008/02/nsevent-modifications-swipe-ro.html
{ "magnifyWithEvent:" "void" { "id" "SEL" "id" }
    [
        nip
        dup -> deltaZ sgn {
            {  1 [ T{ zoom-in-action } send-action$ ] }
            { -1 [ T{ zoom-out-action } send-action$ ] }
            {  0 [ 2drop ] }
        } case
    ]
}

{ "swipeWithEvent:" "void" { "id" "SEL" "id" }
    [
        nip
        dup -> deltaX sgn {
            {  1 [ T{ left-action } send-action$ ] }
            { -1 [ T{ right-action } send-action$ ] }
            {  0
                [
                    dup -> deltaY sgn {
                        {  1 [ T{ up-action } send-action$ ] }
                        { -1 [ T{ down-action } send-action$ ] }
                        {  0 [ 2drop ] }
                    } case
                ]
            }
        } case
    ]
}

! "rotateWithEvent:" "void" { "id" "SEL" "id" }}

{ "acceptsFirstResponder" "char" { "id" "SEL" }
    [ 2drop 1 ]
}

! Services
{ "validRequestorForSendType:returnType:" "id" { "id" "SEL" "id" "id" }
    [
        ! We return either self or nil
        [ over window-focus ] 2dip
        valid-service? [ drop ] [ 2drop f ] if
    ]
}

{ "writeSelectionToPasteboard:types:" "char" { "id" "SEL" "id" "id" }
    [
        CF>string-array NSStringPboardType swap member? [
            [ drop window-focus gadget-selection ] dip over
            [ set-pasteboard-string 1 ] [ 2drop 0 ] if
        ] [ 3drop 0 ] if
    ]
}

{ "readSelectionFromPasteboard:" "char" { "id" "SEL" "id" }
    [
        pasteboard-string dup [
            [ drop window ] dip swap user-input 1
        ] [ 3drop 0 ] if
    ]
}

! Text input
{ "insertText:" "void" { "id" "SEL" "id" }
    [ nip CF>string swap window user-input ]
}

{ "hasMarkedText" "char" { "id" "SEL" }
    [ 2drop 0 ]
}

{ "markedRange" "NSRange" { "id" "SEL" }
    [ 2drop 0 0 <NSRange> ]
}

{ "selectedRange" "NSRange" { "id" "SEL" }
    [ 2drop 0 0 <NSRange> ]
}

{ "setMarkedText:selectedRange:" "void" { "id" "SEL" "id" "NSRange" }
    [ 2drop 2drop ]
}

{ "unmarkText" "void" { "id" "SEL" }
    [ 2drop ]
}

{ "validAttributesForMarkedText" "id" { "id" "SEL" }
    [ 2drop NSArray -> array ]
}

{ "attributedSubstringFromRange:" "id" { "id" "SEL" "NSRange" }
    [ 3drop f ]
}

{ "characterIndexForPoint:" "NSUInteger" { "id" "SEL" "NSPoint" }
    [ 3drop 0 ]
}

{ "firstRectForCharacterRange:" "NSRect" { "id" "SEL" "NSRange" }
    [ 3drop 0 0 0 0 <NSRect> ]
}

{ "conversationIdentifier" "NSInteger" { "id" "SEL" }
    [ drop alien-address ]
}

! Initialization
{ "updateFactorGadgetSize:" "void" { "id" "SEL" "id" }
    [ 2drop dup view-dim swap window (>>dim) yield ]
}

{ "doCommandBySelector:" "void" { "id" "SEL" "SEL" }
    [ 3drop ]
}

{ "initWithFrame:pixelFormat:" "id" { "id" "SEL" "NSRect" "id" }
    [
        [ drop ] 2dip
        SUPER-> initWithFrame:pixelFormat:
        dup dup add-resize-observer
    ]
}

{ "dealloc" "void" { "id" "SEL" }
    [
        drop
        [ unregister-window ]
        [ remove-observer ]
        [ SUPER-> dealloc ]
        tri
    ]
} ;

: sync-refresh-to-screen ( GLView -- )
    -> openGLContext -> CGLContextObj NSOpenGLCPSwapInterval 1 <int>
    CGLSetParameter drop ;

: <FactorView> ( world -- view )
    FactorView over rect-dim <GLView>
    [ sync-refresh-to-screen ] keep
    [ register-window ] keep ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorWindowDelegate" }
}

{ "windowDidMove:" "void" { "id" "SEL" "id" }
    [
        2nip -> object
        dup window-content-rect NSRect-x-y 2array
        swap -> contentView window (>>window-loc)
    ]
}

{ "windowDidBecomeKey:" "void" { "id" "SEL" "id" }
    [
        2nip -> object -> contentView window focus-world
    ]
}

{ "windowDidResignKey:" "void" { "id" "SEL" "id" }
    [
        forget-rollover
        2nip -> object -> contentView window unfocus-world
    ]
}

{ "windowShouldClose:" "char" { "id" "SEL" "id" }
    [
        3drop 1
    ]
}

{ "windowWillClose:" "void" { "id" "SEL" "id" }
    [
        2nip -> object -> contentView window ungraft
    ]
} ;

: install-window-delegate ( window -- )
    FactorWindowDelegate install-delegate ;
