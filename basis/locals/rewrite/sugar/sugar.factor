! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple fry
generalizations hashtables kernel locals locals.backend
locals.errors locals.types make quotations sequences vectors
words ;
IN: locals.rewrite.sugar

! Step 1: rewrite [| [let [let* [wlet into :> forms, turn
! literals with locals in them into code which constructs
! the literal after pushing locals on the stack

GENERIC: rewrite-sugar* ( obj -- )

: (rewrite-sugar) ( form -- form' )
    [ rewrite-sugar* ] [ ] make ;

GENERIC: quotation-rewrite ( form -- form' )

M: callable quotation-rewrite [ [ rewrite-sugar* ] each ] [ ] make ;

: var-defs ( vars -- defs ) <reversed> [ <def> ] [ ] map-as ;

M: lambda quotation-rewrite
    [ body>> ] [ vars>> var-defs ] bi
    prepend quotation-rewrite ;

M: callable rewrite-sugar* quotation-rewrite , ;

M: lambda rewrite-sugar* quotation-rewrite , ;

GENERIC: rewrite-literal? ( obj -- ? )

M: special rewrite-literal? drop t ;

M: array rewrite-literal? [ rewrite-literal? ] contains? ;

M: quotation rewrite-literal? [ rewrite-literal? ] contains? ;

M: wrapper rewrite-literal? drop t ;

M: hashtable rewrite-literal? drop t ;

M: vector rewrite-literal? drop t ;

M: tuple rewrite-literal? drop t ;

M: object rewrite-literal? drop f ;

GENERIC: rewrite-element ( obj -- )

: rewrite-elements ( seq -- )
    [ rewrite-element ] each ;

: rewrite-sequence ( seq -- )
    [ rewrite-elements ] [ length , ] [ 0 head , ] tri \ nsequence , ;

M: array rewrite-element
    dup rewrite-literal? [ rewrite-sequence ] [ , ] if ;

M: vector rewrite-element rewrite-sequence ;

M: hashtable rewrite-element >alist rewrite-sequence \ >hashtable , ;

M: tuple rewrite-element
    [ tuple-slots rewrite-elements ] [ class literalize , ] bi \ boa , ;

M: quotation rewrite-element rewrite-sugar* ;

M: lambda rewrite-element rewrite-sugar* ;

M: binding-form rewrite-element binding-form-in-literal-error ;

M: local rewrite-element , ;

M: local-reader rewrite-element , ;

M: local-writer rewrite-element
    local-writer-in-literal-error ;

M: local-word rewrite-element
    local-word-in-literal-error ;

M: word rewrite-element literalize , ;

M: wrapper rewrite-element
    dup rewrite-literal? [ wrapped>> rewrite-element ] [ , ] if ;

M: object rewrite-element , ;

M: array rewrite-sugar* rewrite-element ;

M: vector rewrite-sugar* rewrite-element ;

M: tuple rewrite-sugar* rewrite-element ;

M: def rewrite-sugar* , ;

M: hashtable rewrite-sugar* rewrite-element ;

M: wrapper rewrite-sugar* rewrite-element ;

M: word rewrite-sugar*
    dup { load-locals get-local drop-locals } memq?
    [ >r/r>-in-lambda-error ] [ call-next-method ] if ;

M: object rewrite-sugar* , ;

: let-rewrite ( body bindings -- )
    [ quotation-rewrite % <def> , ] assoc-each
    quotation-rewrite % ;

M: let rewrite-sugar*
    [ body>> ] [ bindings>> ] bi let-rewrite ;

M: let* rewrite-sugar*
    [ body>> ] [ bindings>> ] bi let-rewrite ;

M: wlet rewrite-sugar*
    [ body>> ] [ bindings>> ] bi
    [ '[ _ ] ] assoc-map
    let-rewrite ;
