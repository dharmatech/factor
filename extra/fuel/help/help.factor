! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators help help.crossref
help.markup help.topics io io.streams.string kernel make memoize
namespaces parser prettyprint sequences summary tools.vocabs
tools.vocabs.browser vocabs vocabs.loader words ;

IN: fuel.help

<PRIVATE

MEMO: fuel-find-word ( name -- word/f )
    [ [ name>> ] dip = ] curry all-words swap filter
    dup empty? not [ first ] [ drop f ] if ;

: fuel-value-str ( word -- str )
    [ pprint-short ] with-string-writer ; inline

: fuel-definition-str ( word -- str )
    [ see ] with-string-writer ; inline

: fuel-methods-str ( word -- str )
    methods dup empty? not [
        [ [ see nl ] each ] with-string-writer
    ] [ drop f ] if ; inline

: fuel-related-words ( word -- seq )
    dup "related" word-prop remove ; inline

: fuel-parent-topics ( word -- seq )
    help-path [ dup article-title swap 2array ] map ; inline

: (fuel-word-element) ( word -- element )
    \ article swap dup article-title swap
    [
        {
            [ fuel-parent-topics [ \ $doc-path prefix , ] unless-empty ]
            [ \ $vocabulary swap vocabulary>> 2array , ]
            [ word-help % ]
            [ fuel-related-words [ \ $related swap 2array , ] unless-empty ]
            [ get-global [ \ $value swap fuel-value-str 2array , ] when* ]
            [ \ $definition swap fuel-definition-str 2array , ]
            [ fuel-methods-str [ \ $methods swap 2array , ] when* ]
        } cleave
    ] { } make 3array ;

: fuel-vocab-help-row ( vocab -- element )
    [ vocab-status-string ] [ vocab-name ] [ summary ] tri 3array ;

: fuel-vocab-help-root-heading ( root -- element )
    [ "Children from " prepend ] [ "Other children" ] if* \ $heading swap 2array ;

SYMBOL: vocab-list

: fuel-vocab-help-table ( vocabs -- element )
    [ fuel-vocab-help-row ] map vocab-list prefix ;

: fuel-vocab-list ( assoc -- seq )
    [
        [ drop f ] [
            [ fuel-vocab-help-root-heading ]
            [ fuel-vocab-help-table ] bi*
            [ 2array ] [ drop f ] if*
        ] if-empty
    ] { } assoc>map [  ] filter ;

: fuel-vocab-children-help ( name -- element )
    all-child-vocabs fuel-vocab-list ; inline

: fuel-vocab-describe-words ( name -- element )
    [ describe-words ] with-string-writer \ describe-words swap 2array ; inline

: (fuel-vocab-element) ( name -- element )
    dup require \ article swap dup >vocab-link
    [
        {
            [ vocab-authors [ \ $authors prefix , ] when* ]
            [ vocab-tags [ \ $tags prefix , ] when* ]
            [ summary [ { $heading "Summary" } swap 2array , ] when* ]
            [ drop \ $nl , ]
            [ vocab-help [ article content>> % ] when* ]
            [ name>> fuel-vocab-describe-words , ]
            [ name>> fuel-vocab-children-help % ]
        } cleave
    ] { } make 3array ;

PRIVATE>

: (fuel-word-help) ( object -- object )
    fuel-find-word [ [ auto-use? on (fuel-word-element) ] with-scope ] [ f ] if* ;

: (fuel-word-see) ( word -- elem )
    [ name>> \ article swap ]
    [ [ see ] with-string-writer \ $code swap 2array ] bi 3array ; inline

: (fuel-vocab-summary) ( name -- str ) >vocab-link summary ; inline

: (fuel-vocab-help) ( name -- str )
    dup empty? [ fuel-vocab-children-help ] [ (fuel-vocab-element) ] if ;

MEMO: (fuel-get-vocabs/author) ( author -- element )
    [ "Vocabularies by " prepend \ $heading swap 2array ]
    [ authored fuel-vocab-list ] bi 2array ;

MEMO: (fuel-get-vocabs/tag) ( tag -- element )
    [ "Vocabularies tagged " prepend \ $heading swap 2array ]
    [ tagged fuel-vocab-list ] bi 2array ;