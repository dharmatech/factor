IN: benchmark.fib6
USING: math kernel alien ;

: fib
    "int" { "int" } "cdecl" [
        dup 1 <= [ drop 1 ] [
            1- dup fib swap 1- fib +
        ] if
    ] alien-callback
    "int" { "int" } "cdecl" alien-indirect ;

: fib-main 25 fib drop ;

MAIN: fib-main
