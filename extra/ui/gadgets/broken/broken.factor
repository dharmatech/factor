! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ui ui.gadgets ui.gadgets.buttons ui.render ;
IN: ui.gadgets.broken

! An intentionally broken gadget -- used to test UI error handling,
! make sure that one bad gadget doesn't bring the whole system down

: <bad-button> ( -- button )
    "Click me if you dare"
    [ "Haha" throw ]
    <bevel-button> ;

TUPLE: bad-gadget < gadget ;

M: bad-gadget draw-gadget* "Lulz" throw ;

M: bad-gadget pref-dim* drop { 100 100 } ;

: <bad-gadget> ( -- gadget ) bad-gadget new-gadget ;

: bad-gadget-test ( -- )
    <bad-button> "Test 1" open-window
    <bad-gadget> "Test 2" open-window ;

MAIN: bad-gadget-test
