IN: compiler.tree.normalization.tests
USING: compiler.tree.builder compiler.tree.recursive
compiler.tree.normalization
compiler.tree.normalization.introductions
compiler.tree.normalization.renaming
compiler.tree compiler.tree.checker
sequences accessors tools.test kernel math ;

\ count-introductions must-infer
\ normalize must-infer

[ 3 ] [ [ 3drop 1 2 3 ] build-tree count-introductions ] unit-test

[ 4 ] [ [ 3drop 1 2 3 3drop drop ] build-tree count-introductions ] unit-test

[ 3 ] [ [ [ drop ] [ 2drop 3 ] if ] build-tree count-introductions ] unit-test

[ 2 ] [ [ 3 [ drop ] [ 2drop 3 ] if ] build-tree count-introductions ] unit-test

: foo ( -- ) swap ; inline recursive

: recursive-inputs ( nodes -- n )
    [ #recursive? ] find nip child>> first in-d>> length ;

[ 0 2 ] [
    [ foo ] build-tree
    [ recursive-inputs ]
    [ analyze-recursive normalize recursive-inputs ] bi
] unit-test

: test-normalization ( quot -- )
    build-tree analyze-recursive normalize check-nodes ;

[ ] [ [ [ 1 ] [ 2 ] if + * ] test-normalization ] unit-test

DEFER: bbb
: aaa ( x -- ) dup [ dup [ bbb ] dip aaa ] [ drop ] if ; inline recursive
: bbb ( x -- ) [ drop 0 ] dip aaa ; inline recursive

[ ] [ [ bbb ] test-normalization ] unit-test

: ccc ( -- ) ccc drop 1 ; inline recursive

[ ] [ [ ccc ] test-normalization ] unit-test

DEFER: eee
: ddd ( -- ) eee ; inline recursive
: eee ( -- ) swap ddd ; inline recursive

[ ] [ [ eee ] test-normalization ] unit-test

: call-recursive-5 ( -- ) call-recursive-5 ; inline recursive

[ ] [ [ call-recursive-5 swap ] test-normalization ] unit-test
