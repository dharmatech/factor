! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vectors sequences hashtables
arrays kernel.private math strings assocs ;
IN: namespaces

<PRIVATE

: namestack* ( -- namestack ) 0 getenv { vector } declare ; inline
: >n ( namespace -- ) namestack* push ;
: ndrop ( -- ) namestack* pop* ;

PRIVATE>

: namespace ( -- namespace ) namestack* peek ; inline
: namestack ( -- namestack ) namestack* clone ;
: set-namestack ( namestack -- ) >vector 0 setenv ;
: global ( -- g ) 21 getenv { hashtable } declare ; inline
: init-namespaces ( -- ) global 1array set-namestack ;
: get ( variable -- value ) namestack* assoc-stack ; inline
: set ( value variable -- ) namespace set-at ;
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: get-global ( variable -- value ) global at ;
: set-global ( value variable -- ) global set-at ;
: change ( variable quot -- ) [ [ get ] keep ] dip dip set ; inline
: +@ ( n variable -- ) [ 0 or + ] change ;
: inc ( variable -- ) 1 swap +@ ; inline
: dec ( variable -- ) -1 swap +@ ; inline
: bind ( ns quot -- ) swap >n call ndrop ; inline
: counter ( variable -- n ) global [ 0 or 1+ dup ] change-at ;

: make-assoc ( quot exemplar -- hash )
    20 swap new-assoc [ >n call ndrop ] keep ; inline

: with-scope ( quot -- )
    H{ } clone >n call ndrop ; inline

: with-variable ( value key quot -- )
    [ associate >n ] dip call ndrop ; inline
