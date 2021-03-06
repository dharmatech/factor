! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit sequences io.files
io.encodings.ascii kernel values splitting accessors math.parser
ascii io assocs strings math namespaces make sorting combinators
math.order arrays unicode.normalize unicode.data locals
unicode.syntax macros sequences.deep words unicode.breaks
quotations combinators.short-circuit ;
IN: unicode.collation

<PRIVATE
VALUE: ducet

TUPLE: weight primary secondary tertiary ignorable? ;

: parse-weight ( string -- weight )
    "]" split but-last [
        weight new swap rest unclip CHAR: * = swapd >>ignorable?
        swap "." split first3 [ hex> ] tri@
        [ >>primary ] [ >>secondary ] [ >>tertiary ] tri*
    ] map ;

: parse-line ( line -- code-poing weight )
    ";" split1 [ [ blank? ] trim ] bi@
    [ " " split [ hex> ] "" map-as ] [ parse-weight ] bi* ;

: parse-ducet ( stream -- ducet )
    lines filter-comments
    [ parse-line ] H{ } map>assoc ;

"resource:basis/unicode/collation/allkeys.txt"
ascii <file-reader> parse-ducet to: ducet

! Fix up table for long contractions
: help-one ( assoc key -- )
    ! Need to be more general? Not for DUCET, apparently
    2 head 2dup swap key? [ 2drop ] [
        [ [ 1string swap at ] with { } map-as concat ]
        [ swap set-at ] 2bi
    ] if ;

: insert-helpers ( assoc -- )
    dup keys [ length 3 >= ] filter
    [ help-one ] with each ;

ducet insert-helpers

: base ( char -- base )
    {
        { [ dup HEX: 3400 HEX:  4DB5 between? ] [ drop HEX: FB80 ] } ! Extension A
        { [ dup HEX: 20000 HEX: 2A6D6 between? ] [ drop HEX: FB80 ] } ! Extension B
        { [ dup HEX: 4E00 HEX: 9FC3 between? ] [ drop HEX: FB40 ] } ! CJK
        [ drop HEX: FBC0 ] ! Other
    } cond ;

: AAAA ( char -- weight )
    [ base ] [ -15 shift ] bi + HEX: 20 2 f weight boa ;

: BBBB ( char -- weight )
    HEX: 7FFF bitand HEX: 8000 bitor 0 0 f weight boa ;

: illegal? ( char -- ? )
    { [ "Noncharacter_Code_Point" property? ] [ category "Cs" = ] } 1|| ;

: derive-weight ( char -- weights )
    first dup illegal?
    [ drop { } ]
    [ [ AAAA ] [ BBBB ] bi 2array ] if ;

: last ( -- char )
    building get empty? [ 0 ] [ building get peek peek ] if ;

: blocked? ( char -- ? )
    combining-class dup { 0 f } member?
    [ drop last non-starter? ]
    [ last combining-class = ] if ;

: possible-bases ( -- slice-of-building )
    building get dup [ first non-starter? not ] find-last
    drop [ 0 ] unless* tail-slice ;

:: ?combine ( char slice i -- ? )
    [let | str [ i slice nth char suffix ] |
        str ducet key? dup
        [ str i slice set-nth ] when
    ] ;

: add ( char -- )
    dup blocked? [ 1string , ] [
        dup possible-bases dup length
        [ ?combine ] with with contains?
        [ drop ] [ 1string , ] if
    ] if ;

: string>graphemes ( string -- graphemes )
    [ [ add ] each ] { } make ;

: graphemes>weights ( graphemes -- weights )
    [
        dup weight? [ 1array ] ! From tailoring
        [ dup ducet at [ ] [ derive-weight ] ?if ] if
    ] { } map-as concat ;

: append-weights ( weights quot -- )
    [ [ ignorable?>> not ] filter ] dip
    map [ zero? not ] filter % 0 , ; inline

: variable-weight ( weight -- )
    dup ignorable?>> [ primary>> ] [ drop HEX: FFFF ] if , ;

: weights>bytes ( weights -- byte-array )
    [
        {
            [ [ primary>> ] append-weights ]
            [ [ secondary>> ] append-weights ]
            [ [ tertiary>> ] append-weights ]
            [ [ variable-weight ] each ]
        } cleave
    ] { } make ;
PRIVATE>

: completely-ignorable? ( weight -- ? )
    [ primary>> ] [ secondary>> ] [ tertiary>> ] tri
    [ zero? ] tri@ and and ;

: filter-ignorable ( weights -- weights' )
    f swap [
        [ nip ] [ primary>> zero? and ] 2bi
        [ swap ignorable?>> or ]
        [ swap completely-ignorable? or not ] 2bi
    ] filter nip ;

: collation-key ( string -- key )
    nfd string>graphemes graphemes>weights
    filter-ignorable weights>bytes ;

<PRIVATE
: insensitive= ( str1 str2 levels-removed -- ? )
    [
        [ collation-key ] dip
        [ [ 0 = not ] trim-right but-last ] times
    ] curry bi@ = ;
PRIVATE>

: primary= ( str1 str2 -- ? )
    3 insensitive= ;

: secondary= ( str1 str2 -- ? )
    2 insensitive= ;

: tertiary= ( str1 str2 -- ? )
    1 insensitive= ;

: quaternary= ( str1 str2 -- ? )
    0 insensitive= ;

<PRIVATE
: w/collation-key ( str -- {str,key} )
    [ collation-key ] keep 2array ;
PRIVATE>

: sort-strings ( strings -- sorted )
    [ w/collation-key ] map natural-sort values ;

: string<=> ( str1 str2 -- <=> )
    [ w/collation-key ] compare ;
