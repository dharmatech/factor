! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.builtin
classes.intersection classes.mixin classes.predicate
classes.singleton classes.tuple classes.union combinators
definitions effects fry generic help help.markup help.stylesheet
help.topics io io.files io.pathnames io.styles kernel macros
make namespaces prettyprint sequences sets sorting summary
tools.vocabs vocabs vocabs.loader words words.symbol ;
IN: tools.vocabs.browser

: vocab-status-string ( vocab -- string )
    {
        { [ dup not ] [ drop "" ] }
        { [ dup vocab-main ] [ drop "[Runnable]" ] }
        [ drop "[Loaded]" ]
    } cond ;

: write-status ( vocab -- )
    vocab vocab-status-string write ;

: vocab. ( vocab -- )
    [
        [ [ write-status ] with-cell ]
        [ [ ($link) ] with-cell ]
        [ [ vocab-summary write ] with-cell ] tri
    ] with-row ;

: vocab-headings. ( -- )
    [
        [ "State" write ] with-cell
        [ "Vocabulary" write ] with-cell
        [ "Summary" write ] with-cell
    ] with-row ;

: root-heading. ( root -- )
    [ "Children from " prepend ] [ "Children" ] if*
    $heading ;

: $vocabs ( assoc -- )
    [
        [ drop ] [
            [ root-heading. ]
            [
                standard-table-style [
                    vocab-headings. [ vocab. ] each
                ] ($grid)
            ] bi*
        ] if-empty
    ] assoc-each ;

TUPLE: vocab-tag name ;

INSTANCE: vocab-tag topic

C: <vocab-tag> vocab-tag

: $tags ( seq -- ) [ <vocab-tag> ] map $links ;

TUPLE: vocab-author name ;

INSTANCE: vocab-author topic

C: <vocab-author> vocab-author

: $authors ( seq -- ) [ <vocab-author> ] map $links ;

: describe-help ( vocab -- )
    [
        dup vocab-help
        [ "Documentation" $heading ($link) ]
        [ "Summary" $heading vocab-summary print-element ]
        ?if
    ] unless-empty ;

: describe-children ( vocab -- )
    vocab-name all-child-vocabs $vocabs ;

: describe-files ( vocab -- )
    vocab-files [ <pathname> ] map [
        "Files" $heading
        [
            snippet-style get [
                code-style get [
                    stack.
                ] with-nesting
            ] with-style
        ] ($block)
    ] unless-empty ;

: describe-tuple-classes ( classes -- )
    [
        "Tuple classes" $subheading
        [
            [ <$link> ]
            [ superclass <$link> ]
            [ "slots" word-prop [ name>> ] map " " join \ $snippet swap 2array ]
            tri 3array
        ] map
        { { $strong "Class" } { $strong "Superclass" } { $strong "Slots" } } prefix
        $table
    ] unless-empty ;

: describe-predicate-classes ( classes -- )
    [
        "Predicate classes" $subheading
        [
            [ <$link> ]
            [ superclass <$link> ]
            bi 2array
        ] map
        { { $strong "Class" } { $strong "Superclass" } } prefix
        $table
    ] unless-empty ;

: (describe-classes) ( classes heading -- )
    '[
        _ $subheading
        [ <$link> 1array ] map $table
    ] unless-empty ;

: describe-builtin-classes ( classes -- )
    "Builtin classes" (describe-classes) ;

: describe-singleton-classes ( classes -- )
    "Singleton classes" (describe-classes) ;

: describe-mixin-classes ( classes -- )
    "Mixin classes" (describe-classes) ;

: describe-union-classes ( classes -- )
    "Union classes" (describe-classes) ;

: describe-intersection-classes ( classes -- )
    "Intersection classes" (describe-classes) ;

: describe-classes ( classes -- )
    [ builtin-class? ] partition
    [ tuple-class? ] partition
    [ singleton-class? ] partition
    [ predicate-class? ] partition
    [ mixin-class? ] partition
    [ union-class? ] partition
    [ intersection-class? ] filter
    {
        [ describe-builtin-classes ]
        [ describe-tuple-classes ]
        [ describe-singleton-classes ]
        [ describe-predicate-classes ]
        [ describe-mixin-classes ]
        [ describe-union-classes ]
        [ describe-intersection-classes ]
    } spread ;

: word-syntax ( word -- string/f )
    \ $syntax swap word-help elements dup length 1 =
    [ first second ] [ drop f ] if ;

: describe-parsing ( words -- )
    [
        "Parsing words" $subheading
        [
            [ <$link> ]
            [ word-syntax dup [ \ $snippet swap 2array ] when ]
            bi 2array
        ] map
        { { $strong "Word" } { $strong "Syntax" } } prefix
        $table
    ] unless-empty ;

: (describe-words) ( words heading -- )
    '[
        _ $subheading
        [
            [ <$link> ]
            [ stack-effect dup [ effect>string \ $snippet swap 2array ] when ]
            bi 2array
        ] map
        { { $strong "Word" } { $strong "Stack effect" } } prefix
        $table
    ] unless-empty ;

: describe-generics ( words -- )
    "Generic words" (describe-words) ;

: describe-macros ( words -- )
    "Macro words" (describe-words) ;

: describe-primitives ( words -- )
    "Primitives" (describe-words) ;

: describe-compounds ( words -- )
    "Ordinary words" (describe-words) ;

: describe-predicates ( words -- )
    "Class predicate words" (describe-words) ;

: describe-symbols ( words -- )
    [
        "Symbol words" $subheading
        [ <$link> 1array ] map $table
    ] unless-empty ;

: describe-words ( vocab -- )
    words [
        "Words" $heading

        natural-sort
        [ [ class? ] filter describe-classes ]
        [
            [ [ class? ] [ symbol? ] bi and not ] filter
            [ parsing-word? ] partition
            [ generic? ] partition
            [ macro? ] partition
            [ symbol? ] partition
            [ primitive? ] partition
            [ predicate? ] partition swap
            {
                [ describe-parsing ]
                [ describe-generics ]
                [ describe-macros ]
                [ describe-symbols ]
                [ describe-primitives ]
                [ describe-compounds ]
                [ describe-predicates ]
            } spread
        ] bi
    ] unless-empty ;

: words. ( vocab -- )
    last-element off
    vocab-name describe-words ;

: describe-metadata ( vocab -- )
    [
        [ vocab-tags [ "Tags:" swap \ $tags prefix 2array , ] unless-empty ]
        [ vocab-authors [ "Authors:" swap \ $authors prefix 2array , ] unless-empty ]
        bi
    ] { } make
    [ "Meta-data" $heading $table ] unless-empty ;

: $describe-vocab ( element -- )
    first {
        [ describe-help ]
        [ describe-metadata ]
        [ describe-words ]
        [ describe-files ]
        [ describe-children ]
    } cleave ;

: keyed-vocabs ( str quot -- seq )
    all-vocabs [
        swap [
            [ [ 2dup ] dip swap call member? ] filter
        ] dip swap
    ] assoc-map 2nip ; inline

: tagged ( tag -- assoc )
    [ vocab-tags ] keyed-vocabs ;

: authored ( author -- assoc )
    [ vocab-authors ] keyed-vocabs ;

: $tagged-vocabs ( element -- )
    first tagged $vocabs ;

: $authored-vocabs ( element -- )
    first authored $vocabs ;

: $all-tags ( element -- )
    drop "Tags" $heading all-tags $tags ;

: $all-authors ( element -- )
    drop "Authors" $heading all-authors $authors ;

INSTANCE: vocab topic

INSTANCE: vocab-link topic

M: vocab-spec article-title vocab-name " vocabulary" append ;

M: vocab-spec article-name vocab-name ;

M: vocab-spec article-content
    vocab-name \ $describe-vocab swap 2array ;

M: vocab-spec article-parent drop "vocab-index" ;

M: vocab-tag >link ;

M: vocab-tag article-title
    name>> "Vocabularies tagged ``" "''" surround ;

M: vocab-tag article-name name>> ;

M: vocab-tag article-content
    \ $tagged-vocabs swap name>> 2array ;

M: vocab-tag article-parent drop "vocab-index" ;

M: vocab-tag summary article-title ;

M: vocab-author >link ;

M: vocab-author article-title
    name>> "Vocabularies by " prepend ;

M: vocab-author article-name name>> ;

M: vocab-author article-content
    \ $authored-vocabs swap name>> 2array ;

M: vocab-author article-parent drop "vocab-index" ;

M: vocab-author summary article-title ;
