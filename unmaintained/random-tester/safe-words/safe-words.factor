USING: kernel namespaces sequences sets sorting vocabs ;
USING: arrays assocs generic hashtables 
math math.intervals math.parser math.order math.functions
refs shuffle vectors words ;
IN: random-tester.safe-words

: ?-words
    {
        /f

        bits>float bits>double
        float>bits double>bits

        >bignum >boolean >fixnum >float

        array? integer? complex? value-ref? ref? key-ref?
        interval? number?
        wrapper? tuple?
        [-1,1]? between? bignum? both? either? eq? equal? even? fixnum?
        float? fp-nan? hashtable? interval-contains? interval-subset?
        interval? key-ref? key? number? odd? pair? power-of-2?
        ratio? rational? real? zero? assoc? curry? vector? callstack?

        2^ not
        ! arrays
        resize-array <array>
        ! assocs
        (assoc-stack)
        new-assoc
        assoc-like
        <hashtable>
        all-integers? (all-integers?) ! hangs?
        assoc-push-if

        (clone) assoc-clone-like ! SYMBOL: foo foo dup (clone) =
    } ;

: bignum-words
    {
        next-power-of-2 (next-power-of-2)
        times
        hashcode hashcode*
    } ;

: initialization-words
    {
        init-namespaces
    } ;

: stack-words
    {
        dup
        drop 2drop 3drop
        roll -roll 2swap

        >r r>
    } ;

: stateful-words
    {
        counter
        gensym
    } ;

: foo-words
    {
        set-retainstack
        retainstack callstack
        datastack
        callstack>array

        curry 2curry 3curry compose 3compose
        (assoc-each)
    } ;

: exit-words
    {
        call-clear die
    } ;

: bad-words ( -- array )
    [
        ?-words %
        bignum-words %
        initialization-words %
        stack-words %
        stateful-words %
        exit-words %
        foo-words %
    ] { } make ;

: safe-words ( -- array )
    {
        ! "accessors"
        "alists" "arrays" "assocs" "bit-arrays" "byte-arrays"
        ! "classes" "combinators" "compiler" "continuations"
        ! "core-foundation" "definitions" "documents"
        ! "float-arrays" "generic" "graphs" "growable"
        "hashtables"  ! io.*
        "kernel" "math"
        "math.bitfields" "math.complex" "math.constants" "math.floats"
        "math.functions" "math.integers" "math.intervals" "math.libm"
        "math.parser" "math.order" "math.ratios" "math.vectors"
        ! "namespaces"
        "quotations" "sbufs"
        ! "queues" "strings" "sequences"
        "sets"
        "vectors"
        ! "words"
    } [ words ] map concat bad-words diff natural-sort ;
    
safe-words \ safe-words set-global

! foo dup (clone) = .
! foo dup clone = .
! f [ byte-array>bignum assoc-clone-like ] compile-1
! 2 3.14 [ number= ] compile-1
! 3.14 [ <vector> assoc? ] compile-1
! -3 [ ] 2 [ byte-array>bignum denominator ] compile-1
! : foo ( x -- y ) euler bitand ; { foo } compile 20 foo
