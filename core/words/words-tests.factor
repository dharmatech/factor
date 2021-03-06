USING: arrays generic assocs kernel math namespaces
sequences tools.test words definitions parser quotations
vocabs continuations classes.tuple compiler.units
io.streams.string accessors eval words.symbol ;
IN: words.tests

[ 4 ] [
    [
        "poo" "words.tests" create [ 2 2 + ] define
    ] with-compilation-unit
    "poo" "words.tests" lookup execute
] unit-test

[ t ] [ t vocabs [ words [ word? and ] each ] each ] unit-test

DEFER: plist-test

[ t ] [
    \ plist-test t "sample-property" set-word-prop
    \ plist-test "sample-property" word-prop
] unit-test

[ f ] [
    \ plist-test f "sample-property" set-word-prop
    \ plist-test "sample-property" word-prop
] unit-test

"create-test" "scratchpad" create { 1 2 } "testing" set-word-prop
[ { 1 2 } ] [
    "create-test" "scratchpad" lookup "testing" word-prop
] unit-test

[
    [ t ] [ \ array? "array?" "arrays" lookup = ] unit-test

    [ ] [ "test-scope" "scratchpad" create drop ] unit-test
] with-scope

[ "test-scope" ] [
    "test-scope" "scratchpad" lookup name>> 
] unit-test

[ t ] [ vocabs array? ] unit-test
[ t ] [ vocabs [ words [ word? ] all? ] all? ] unit-test

[ f ] [ gensym gensym = ] unit-test

SYMBOL: a-symbol
[ t ] [ \ a-symbol symbol? ] unit-test

! See if redefining a generic as a colon def clears some
! word props.
GENERIC: testing
"IN: words.tests : testing ;" eval

[ f ] [ \ testing generic? ] unit-test

: forgotten ;
: another-forgotten ;

FORGET: forgotten

FORGET: another-forgotten
: another-forgotten ;

! I forgot remove-crossref calls!
: fee ;
: foe fee ;
: fie foe ;

[ t ] [ \ fee usage [ word? ] filter empty? ] unit-test
[ t ] [ \ foe usage empty? ] unit-test
[ f ] [ \ foe crossref get key? ] unit-test

FORGET: foe

! xref should not retain references to gensyms
[ ] [
    [ gensym [ * ] define ] with-compilation-unit
] unit-test

[ t ] [
    \ * usage [ word? ] filter [ crossref? ] all?
] unit-test

DEFER: calls-a-gensym
[ ] [
    [
        \ calls-a-gensym
        gensym dup "x" set 1quotation
        define
    ] with-compilation-unit
] unit-test

[ f ] [ "x" get crossref get at ] unit-test

! more xref buggery
[ f ] [
    GENERIC: xyzzle ( x -- x )
    : a ; \ a
    M: integer xyzzle a ;
    FORGET: a
    M: object xyzzle ;
    crossref get at
] unit-test

! regression
GENERIC: freakish ( x -- y )
: bar freakish ;
M: array freakish ;
[ t ] [ \ bar \ freakish usage member? ] unit-test

DEFER: x
[ x ] [ undefined? ] must-fail-with

[ ] [ "no-loc" "words.tests" create drop ] unit-test
[ f ] [ "no-loc" "words.tests" lookup where ] unit-test

[ ] [ "IN: words.tests : no-loc-2 ;" eval ] unit-test
[ f ] [ "no-loc-2" "words.tests" lookup where ] unit-test

[ ] [ "IN: words.tests : test-last ( -- ) ;" eval ] unit-test
[ "test-last" ] [ word name>> ] unit-test

! regression
SYMBOL: quot-uses-a
SYMBOL: quot-uses-b

[ ] [
    [
        quot-uses-a [ 2 3 + ] define
    ] with-compilation-unit
] unit-test

[ { + } ] [ \ quot-uses-a uses ] unit-test

[ ] [
    [
        quot-uses-b 2 [ 3 + ] curry define
    ] with-compilation-unit
] unit-test

[ { + } ] [ \ quot-uses-b uses ] unit-test

"undef-test" "words.tests" lookup [
    [ forget ] with-compilation-unit
] when*

[ "IN: words.tests : undef-test ; << undef-test >>" eval ]
[ error>> undefined? ] must-fail-with

[ ] [
    "IN: words.tests GENERIC: symbol-generic" eval
] unit-test

[ ] [
    "IN: words.tests SYMBOL: symbol-generic" eval
] unit-test

[ t ] [ "symbol-generic" "words.tests" lookup symbol? ] unit-test
[ f ] [ "symbol-generic" "words.tests" lookup generic? ] unit-test

[ ] [
    "IN: words.tests GENERIC: symbol-generic" <string-reader>
    "symbol-generic-test" parse-stream drop
] unit-test

[ ] [
    "IN: words.tests TUPLE: symbol-generic ;" <string-reader>
    "symbol-generic-test" parse-stream drop
] unit-test

[ t ] [ "symbol-generic" "words.tests" lookup symbol? ] unit-test
[ f ] [ "symbol-generic" "words.tests" lookup generic? ] unit-test

! Regressions
[ ] [ "IN: words.tests : decl-forget-test ; foldable" eval ] unit-test
[ t ] [ "decl-forget-test" "words.tests" lookup "foldable" word-prop ] unit-test
[ ] [ "IN: words.tests : decl-forget-test ;" eval ] unit-test
[ f ] [ "decl-forget-test" "words.tests" lookup "foldable" word-prop ] unit-test

[ ] [ "IN: words.tests : decl-forget-test ; flushable" eval ] unit-test
[ t ] [ "decl-forget-test" "words.tests" lookup "flushable" word-prop ] unit-test
[ ] [ "IN: words.tests : decl-forget-test ;" eval ] unit-test
[ f ] [ "decl-forget-test" "words.tests" lookup "flushable" word-prop ] unit-test

[ { } ]
[
    all-words [
        "compiled-uses" word-prop
        keys [ "forgotten" word-prop ] contains?
    ] filter
] unit-test

[ { } ] [
    crossref get keys
    [ word? ] filter [ "forgotten" word-prop ] filter
] unit-test
