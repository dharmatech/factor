! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry generalizations kernel macros math.order
stack-checker math ;
IN: combinators.smart

MACRO: output>sequence ( quot exemplar -- newquot )
    [ dup infer out>> ] dip
    '[ @ _ _ nsequence ] ;

: output>array ( quot -- newquot )
    { } output>sequence ; inline

MACRO: input<sequence ( quot -- newquot )
    [ infer in>> ] keep
    '[ _ firstn @ ] ;

MACRO: reduce-outputs ( quot operation -- newquot )
    [ dup infer out>> 1 [-] ] dip n*quot compose ;

: sum-outputs ( quot -- n )
    [ + ] reduce-outputs ; inline

MACRO: append-outputs-as ( quot exemplar -- newquot )
    [ dup infer out>> ] dip '[ @ _ _ nappend-as ] ;

: append-outputs ( quot -- seq )
    { } append-outputs-as ; inline
