! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays accessors grouping math.order
sorting binary-search math assocs locals namespaces make ;
IN: interval-maps

TUPLE: interval-map array ;

<PRIVATE

: find-interval ( key interval-map -- interval-node )
    [ first <=> ] with search nip ;

: interval-contains? ( key interval-node -- ? )
    first2 between? ;

: all-intervals ( sequence -- intervals )
    [ [ dup number? [ dup 2array ] when ] dip ] { } assoc-map-as ;

: disjoint? ( node1 node2 -- ? )
    [ second ] [ first ] bi* < ;

: ensure-disjoint ( intervals -- intervals )
    dup [ disjoint? ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;

: >intervals ( specification -- intervals )
    [ suffix ] { } assoc>map concat 3 <groups> ;

PRIVATE>

: interval-at* ( key map -- value ? )
    [ drop ] [ array>> find-interval ] 2bi
    [ nip ] [ interval-contains? ] 2bi
    [ third t ] [ drop f f ] if ;

: interval-at ( key map -- value ) interval-at* drop ;

: interval-key? ( key map -- ? ) interval-at* nip ;

: <interval-map> ( specification -- map )
    all-intervals [ [ first second ] compare ] sort
    >intervals ensure-disjoint interval-map boa ;

: <interval-set> ( specification -- map )
    [ dup 2array ] map <interval-map> ;

:: coalesce ( alist -- specification )
    ! Only works with integer keys, because they're discrete
    ! Makes 2array keys
    [
        alist sort-keys unclip first2 dupd roll
        [| oldkey oldval key val | ! Underneath is start
            oldkey 1+ key =
            oldval val = and
            [ oldkey 2array oldval 2array , key ] unless
            key val
        ] assoc-each [ 2array ] bi@ ,
    ] { } make ;
