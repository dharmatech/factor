! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces xml.tokenize xml.state xml.name
xml.data accessors arrays make xml.char-classes fry assocs sequences
math xml.errors sets combinators io.encodings io.encodings.iana
unicode.case xml.dtd strings ;
IN: xml.elements

: parse-attr ( -- )
    parse-name pass-blank CHAR: = expect pass-blank
    t parse-quote* 2array , ;

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start?
    [ parse-attr (middle-tag) ] when ;

: assure-no-duplicates ( attrs-alist -- attrs-alist )
    H{ } clone 2dup '[ swap _ push-at ] assoc-each
    [ nip length 2 >= ] assoc-filter >alist
    [ first first2 duplicate-attr ] unless-empty ;

: middle-tag ( -- attrs-alist )
    ! f make will make a vector if it has any elements
    [ (middle-tag) ] f make pass-blank
    assure-no-duplicates ;

: end-tag ( name attrs-alist -- tag )
    tag-ns pass-blank get-char CHAR: / =
    [ pop-ns <contained> next CHAR: > expect ]
    [ depth inc <opener> close ] if ;

: take-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: assure-no-extra ( seq -- )
    [ first ] map {
        T{ name f "" "version" f }
        T{ name f "" "encoding" f }
        T{ name f "" "standalone" f }
    } diff
    [ extra-attrs ] unless-empty ; 

: good-version ( version -- version )
    dup { "1.0" "1.1" } member? [ bad-version ] unless ;

: prolog-version ( alist -- version )
    T{ name f "" "version" f } swap at
    [ good-version ] [ versionless-prolog ] if* ;

: prolog-encoding ( alist -- encoding )
    T{ name f "" "encoding" f } swap at "UTF-8" or ;

: yes/no>bool ( string -- t/f )
    {
        { "yes" [ t ] }
        { "no" [ f ] }
        [ not-yes/no ]
    } case ;

: prolog-standalone ( alist -- version )
    T{ name f "" "standalone" f } swap at
    [ yes/no>bool ] [ f ] if* ;

: prolog-attrs ( alist -- prolog )
    [ prolog-version ]
    [ prolog-encoding ]
    [ prolog-standalone ]
    tri <prolog> ;

SYMBOL: string-input?
: decode-input-if ( encoding -- )
    string-input? get [ drop ] [ decode-input ] if ;

: parse-prolog ( -- prolog )
    pass-blank middle-tag "?>" expect-string
    dup assure-no-extra prolog-attrs
    dup encoding>> dup "UTF-16" =
    [ drop ] [ name>encoding [ decode-input-if ] when* ] if
    dup prolog-data set ;

: instruct ( -- instruction )
    take-name {
        { [ dup "xml" = ] [ drop parse-prolog ] }
        { [ dup >lower "xml" = ] [ capitalized-prolog ] }
        { [ dup valid-name? not ] [ bad-name ] }
        [ "?>" take-string append <instruction> ]
    } cond ;

: take-cdata ( -- string )
    depth get zero? [ bad-cdata ] when
    "[CDATA[" expect-string "]]>" take-string ;

DEFER: make-tag ! Is this unavoidable?

: expand-pe ( -- ) ; ! Make this run the contents of the pe within a DOCTYPE

: (take-internal-subset) ( -- )
    pass-blank get-char {
        { CHAR: ] [ next ] }
        { CHAR: % [ expand-pe ] }
        { CHAR: < [
            next make-tag dup dtd-acceptable?
            [ bad-doctype ] unless , (take-internal-subset)
        ] }
        [ 1string bad-doctype ]
    } case ;

: take-internal-subset ( -- seq )
    [
        H{ } pe-table set
        t in-dtd? set
        (take-internal-subset)
    ] { } make ;

: nontrivial-doctype ( -- external-id internal-subset )
    pass-blank get-char CHAR: [ = [
        next take-internal-subset f swap close
    ] [
        " >" take-until-one-of {
            { CHAR: \s [ (take-external-id) ] }
            { CHAR: > [ only-blanks f ] }
        } case f
    ] if ;

: take-doctype-decl ( -- doctype-decl )
    pass-blank " >" take-until-one-of {
        { CHAR: \s [ nontrivial-doctype ] }
        { CHAR: > [ f f ] }
    } case <doctype-decl> ;

: take-directive ( -- doctype )
    take-name dup "DOCTYPE" =
    [ drop take-doctype-decl ] [
        in-dtd? get
        [ take-inner-directive ]
        [ misplaced-directive ] if
    ] if ;

: direct ( -- object )
    get-char {
        { CHAR: - [ take-comment ] }
        { CHAR: [ [ take-cdata ] }
        [ drop take-directive ]
    } case ;

: make-tag ( -- tag )
    {
        { [ get-char dup CHAR: ! = ] [ drop next direct ] }
        { [ CHAR: ? = ] [ next instruct ] }
        [
            start-tag [ dup add-ns pop-ns <closer> depth dec close ]
            [ middle-tag end-tag ] if
        ]
    } cond ;
