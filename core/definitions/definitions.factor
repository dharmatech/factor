! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: kernel sequences namespaces assocs graphs math math.order ;

ERROR: no-compilation-unit definition ;

SYMBOL: inlined-dependency
SYMBOL: flushed-dependency
SYMBOL: called-dependency

<PRIVATE

: set-in-unit ( value key assoc -- )
    [ set-at ] [ no-compilation-unit ] if* ;

PRIVATE>

SYMBOL: changed-definitions

: changed-definition ( defspec -- )
    inlined-dependency swap changed-definitions get set-in-unit ;

SYMBOL: changed-generics

: changed-generic ( class generic -- )
    changed-generics get set-in-unit ;

SYMBOL: remake-generics

: remake-generic ( generic -- )
    dup remake-generics get set-in-unit ;

SYMBOL: new-classes

: new-class ( word -- )
    dup new-classes get set-in-unit ;

: new-class? ( word -- ? )
    new-classes get key? ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget* ( defspec -- )

M: object forget* drop ;

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    dup forgotten-definitions get
    [ no-compilation-unit ] unless*
    set-at ;

: forget ( defspec -- ) dup forgotten-definition forget* ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: synopsis* ( defspec -- )

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )

SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

M: object uses drop f ;

: xref ( defspec -- ) dup uses crossref get add-vertex ;

: usage ( defspec -- seq ) crossref get at keys ;

GENERIC: irrelevant? ( defspec -- ? )

M: object irrelevant? drop f ;

GENERIC: smart-usage ( defspec -- seq )

M: f smart-usage drop \ f smart-usage ;

M: object smart-usage usage [ irrelevant? not ] filter ;

: unxref ( defspec -- )
    dup uses crossref get remove-vertex ;

: delete-xref ( defspec -- )
    dup unxref crossref get delete-at ;
