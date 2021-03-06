! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry assocs arrays byte-arrays strings accessors sequences
kernel slots classes.algebra classes.tuple classes.tuple.private
words math math.private combinators sequences.private namespaces
slots.private classes compiler.tree.propagation.info ;
IN: compiler.tree.propagation.slots

! Propagation of immutable slots and array lengths

! Revisit this code when delegation is removed and when complex
! numbers become tuples.

UNION: fixed-length-sequence array byte-array string ;

: sequence-constructor? ( word -- ? )
    { <array> <byte-array> (byte-array) <string> } memq? ;

: constructor-output-class ( word -- class )
    {
        { <array> array }
        { <byte-array> byte-array }
        { (byte-array) byte-array }
        { <string> string }
    } at ;

: propagate-sequence-constructor ( #call word -- infos )
    [ in-d>> first <sequence-info> ]
    [ constructor-output-class <class-info> ]
    bi* value-info-intersect 1array ;

: tuple-constructor? ( word -- ? )
    { <tuple-boa> <complex> } memq? ;

: fold-<tuple-boa> ( values class -- info )
    [ [ literal>> ] map ] dip prefix >tuple
    <literal-info> ;

: (propagate-tuple-constructor) ( values class -- info )
    [ [ value-info ] map ] dip [ read-only-slots ] keep
    over rest-slice [ dup [ literal?>> ] when ] all? [
        [ rest-slice ] dip fold-<tuple-boa>
    ] [
        <tuple-info>
    ] if ;

: propagate-<tuple-boa> ( #call -- info )
    in-d>> unclip-last
    value-info literal>> first (propagate-tuple-constructor) ;

: propagate-<complex> ( #call -- info )
    in-d>> [ value-info ] map complex <tuple-info> ;

: propagate-tuple-constructor ( #call word -- infos )
    {
        { \ <tuple-boa> [ propagate-<tuple-boa> ] }
        { \ <complex> [ propagate-<complex> ] }
    } case 1array ;

: read-only-slot? ( n class -- ? )
    all-slots [ offset>> = ] with find nip
    dup [ read-only>> ] when ;

: literal-info-slot ( slot object -- info/f )
    2dup class read-only-slot?
    [ swap slot <literal-info> ] [ 2drop f ] if ;

: length-accessor? ( slot info -- ? )
    [ 1 = ] [ length>> ] bi* and ;

: value-info-slot ( slot info -- info' )
    {
        { [ over 0 = ] [ 2drop fixnum <class-info> ] }
        { [ 2dup length-accessor? ] [ nip length>> ] }
        { [ dup literal?>> ] [ literal>> literal-info-slot ] }
        [ [ 1- ] [ slots>> ] bi* ?nth ]
    } cond [ object-info ] unless* ;
