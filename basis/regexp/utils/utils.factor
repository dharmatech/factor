! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs io kernel math math.order
namespaces regexp.backend sequences unicode.categories
math.ranges fry combinators.short-circuit vectors ;
IN: regexp.utils

: (while-changes) ( obj quot: ( obj -- obj' ) pred: ( obj -- <=> ) pred-ret -- obj )
    [ [ dup slip ] dip pick over call ] dip dupd =
    [ 3drop ] [ (while-changes) ] if ; inline recursive

: while-changes ( obj quot pred -- obj' )
    pick over call (while-changes) ; inline

: assoc-with ( param assoc quot -- assoc curry )
    swapd [ [ -rot ] dip call ] 2curry ; inline

: insert-at ( value key hash -- )
    2dup at* [
        2nip push
    ] [
        drop
        [ dup vector? [ 1vector ] unless ] 2dip set-at
    ] if ;

: ?insert-at ( value key hash/f -- hash )
    [ H{ } clone ] unless* [ insert-at ] keep ;

ERROR: bad-octal number ;
ERROR: bad-hex number ;
: check-octal ( octal -- octal ) dup 255 > [ bad-octal ] when ;
: check-hex ( hex -- hex ) dup number? [ bad-hex ] unless ;

: ascii? ( n -- ? ) 0 HEX: 7f between? ;
: octal-digit? ( n -- ? ) CHAR: 0 CHAR: 7 between? ;
: decimal-digit? ( n -- ? ) CHAR: 0 CHAR: 9 between? ;

: hex-digit? ( n -- ? )
    [
        [ decimal-digit? ]
        [ CHAR: a CHAR: f between? ]
        [ CHAR: A CHAR: F between? ]
    ] 1|| ;

: control-char? ( n -- ? )
    [
        [ 0 HEX: 1f between? ]
        [ HEX: 7f = ]
    ] 1|| ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? )
    [ [ alpha? ] [ CHAR: _ = ] ] 1|| ;

: java-blank? ( n -- ? )
    {
        CHAR: \s CHAR: \t CHAR: \n
        HEX: b HEX: 7 CHAR: \r
    } member? ;

: java-printable? ( n -- ? )
    [ [ alpha? ] [ punct? ] ] 1|| ;
