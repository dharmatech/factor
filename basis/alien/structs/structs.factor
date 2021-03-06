! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic hashtables kernel kernel.private
math namespaces parser sequences strings words libc fry
alien.c-types alien.structs.fields cpu.architecture ;
IN: alien.structs

TUPLE: struct-type size align fields ;

M: struct-type heap-size size>> ;

M: struct-type c-type-class drop object ;

M: struct-type c-type-align align>> ;

M: struct-type c-type-stack-align? drop f ;

: if-value-struct ( ctype true false -- )
    [ dup value-struct? ] 2dip '[ drop "void*" @ ] if ; inline

M: struct-type unbox-parameter
    [ %unbox-large-struct ] [ unbox-parameter ] if-value-struct ;

M: struct-type box-parameter
    [ %box-large-struct ] [ box-parameter ] if-value-struct ;

: if-small-struct ( c-type true false -- ? )
    [ dup struct-small-enough? ] 2dip '[ f swap @ ] if ; inline

M: struct-type unbox-return
    [ %unbox-small-struct ] [ %unbox-large-struct ] if-small-struct ;

M: struct-type box-return
    [ %box-small-struct ] [ %box-large-struct ] if-small-struct ;

M: struct-type stack-size
    [ heap-size ] [ stack-size ] if-value-struct ;

: c-struct? ( type -- ? ) (c-type) struct-type? ;

: (define-struct) ( name size align fields -- )
    [ [ align ] keep ] dip
    struct-type boa
    swap typedef ;

: make-fields ( name vocab fields -- fields )
    [ first2 <field-spec> ] with with map ;

: compute-struct-align ( types -- n )
    [ c-type-align ] map supremum ;

: define-struct ( name vocab fields -- )
    [
        [ 2drop ] [ make-fields ] 3bi
        [ struct-offsets ] keep
        [ [ type>> ] map compute-struct-align ] keep
        [ (define-struct) ] keep
    ] [ 2drop '[ _ swap define-field ] ] 3bi each ;

: define-union ( name members -- )
    [ expand-constants ] map
    [ [ heap-size ] map supremum ] keep
    compute-struct-align f (define-struct) ;
