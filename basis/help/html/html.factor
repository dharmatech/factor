! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.utf8 io.encodings.ascii io.encodings.binary
io.files io.files.temp io.directories html.streams html.elements help kernel
assocs sequences make words accessors arrays help.topics vocabs
tools.vocabs tools.vocabs.browser namespaces prettyprint io
vocabs.loader serialize fry memoize unicode.case math.order
sorting debugger ;
IN: help.html

: escape-char ( ch -- )
    dup H{
        { CHAR: " "__quo__" }
        { CHAR: * "__star__" }
        { CHAR: : "__colon__" }
        { CHAR: < "__lt__" }
        { CHAR: > "__gt__" }
        { CHAR: ? "__que__" }
        { CHAR: \\ "__back__" }
        { CHAR: | "__pipe__" }
        { CHAR: / "__slash__" }
        { CHAR: , "__comma__" }
        { CHAR: @ "__at__" }
    } at [ % ] [ , ] ?if ;

: escape-filename ( string -- filename )
    [ [ escape-char ] each ] "" make ;

GENERIC: topic>filename* ( topic -- name prefix )

M: word topic>filename*
    dup vocabulary>> [
        [ name>> ] [ vocabulary>> ] bi 2array "word"
    ] [ drop f f ] if ;

M: link topic>filename* name>> dup [ "article" ] [ topic>filename* ] if ;
M: word-link topic>filename* name>> topic>filename* ;
M: vocab-spec topic>filename* vocab-name "vocab" ;
M: vocab-tag topic>filename* name>> "tag" ;
M: vocab-author topic>filename* name>> "author" ;
M: f topic>filename* drop \ f topic>filename* ;

: topic>filename ( topic -- filename )
    topic>filename* dup [
        [
            % "-" %
            dup array?
            [ [ escape-filename ] map "," join ]
            [ escape-filename ]
            if % ".html" %
        ] "" make
    ] [ 2drop f ] if ;

M: topic browser-link-href topic>filename ;

: help-stylesheet ( -- )
    "resource:basis/help/html/stylesheet.css" ascii file-contents write ;

: help>html ( topic -- )
    dup topic>filename utf8 [
        dup article-title
        [ <style> help-stylesheet </style> ]
        [ [ help ] with-html-writer ] simple-page
    ] with-file-writer ;

: all-vocabs-really ( -- seq )
    #! Hack.
    all-vocabs values concat
    vocabs [ find-vocab-root not ] filter [ vocab ] map append ;

: all-topics ( -- topics )
    [
        articles get keys [ >link ] map %
        all-words [ >link ] map %
        all-authors [ <vocab-author> ] map %
        all-tags [ <vocab-tag> ] map %
        all-vocabs-really %
    ] { } make ;

: serialize-index ( index file -- )
    [ [ [ topic>filename ] dip ] { } assoc-map-as object>bytes ] dip
    binary set-file-contents ;

: generate-indices ( -- )
    articles get keys [ [ >link ] [ article-title ] bi ] { } map>assoc "articles.idx" serialize-index
    all-words [ dup name>> ] { } map>assoc "words.idx" serialize-index
    all-vocabs-really [ dup vocab-name ] { } map>assoc "vocabs.idx" serialize-index ;

: generate-help-files ( -- )
    all-topics [ '[ _ help>html ] try ] each ;

: generate-help ( -- )
    "docs" temp-file
    [ make-directories ]
    [
        [
            generate-indices
            generate-help-files
        ] with-directory
    ] bi ;

MEMO: load-index ( name -- index )
    binary file-contents bytes>object ;

TUPLE: result title href ;

: offline-apropos ( string index -- results )
    load-index swap >lower
    '[ [ drop _ ] dip >lower subseq? ] assoc-filter
    [ swap result boa ] { } assoc>map
    [ [ title>> ] compare ] sort ;

: article-apropos ( string -- results )
    "articles.idx" offline-apropos ;

: word-apropos ( string -- results )
    "words.idx" offline-apropos ;

: vocab-apropos ( string -- results )
    "vocabs.idx" offline-apropos ;
