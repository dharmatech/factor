USING: tools.test unicode.breaks sequences math kernel splitting
unicode.categories io.pathnames io.encodings.utf8 io.files
strings quotations math.parser locals ;
IN: unicode.breaks.tests

[ "\u001112\u001161\u0011abA\u000300a\r\r\n" ]
[ "\r\n\raA\u000300\u001112\u001161\u0011ab" string-reverse ] unit-test
[ "dcba" ] [ "abcd" string-reverse ] unit-test
[ 3 ] [ "\u001112\u001161\u0011abA\u000300a"
        dup last-grapheme head last-grapheme ] unit-test

: grapheme-break-test ( -- filename )
    "resource:basis/unicode/breaks/GraphemeBreakTest.txt" ;

: word-break-test ( -- filename )
    "resource:basis/unicode/breaks/WordBreakTest.txt" ;

: parse-test-file ( file-name -- tests )
    utf8 file-lines
    [ "#" split1 drop ] map harvest [
        "÷" split
        [ "×" split [ [ blank? ] trim hex> ] map harvest >string ] map
        harvest
    ] map ;

:: test ( tests quot -- )
    tests [
        [ 1quotation ]
        [ concat [ quot call [ "" like ] map ] curry ] bi unit-test
    ] each ;

: grapheme-test ( tests quot -- )
    [
        [ 1quotation ]
        [ concat [ >graphemes [ "" like ] map ] curry ] bi unit-test
    ] each ;

grapheme-break-test parse-test-file [ >graphemes ] test
word-break-test parse-test-file [ >words ] test
