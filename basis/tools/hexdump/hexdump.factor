! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io io.streams.string kernel math math.parser
namespaces sequences splitting grouping strings ascii byte-arrays ;
IN: tools.hexdump

<PRIVATE

: write-header ( len -- )
    "Length: " write
    [ number>string write ", " write ]
    [ >hex write "h" write nl ] bi ;

: write-offset ( lineno -- )
    16 * >hex 8 CHAR: 0 pad-left write "h: " write ;

: >hex-digit ( digit -- str )
    >hex 2 CHAR: 0 pad-left " " append ;

: >hex-digits ( bytes -- str )
    [ >hex-digit ] { } map-as concat 48 CHAR: \s pad-right ;

: >ascii ( bytes -- str )
    [ [ printable? ] keep CHAR: . ? ] "" map-as ;

: write-hex-line ( bytes lineno -- )
    write-offset [ >hex-digits write ] [ >ascii write ] bi nl ;

PRIVATE>

GENERIC: hexdump. ( byte-array -- )

M: byte-array hexdump.
    [ length write-header ]
    [ 16 <sliced-groups> [ write-hex-line ] each-index ] bi ;

: hexdump ( byte-array -- str )
    [ hexdump. ] with-string-writer ;
