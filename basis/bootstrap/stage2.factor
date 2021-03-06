! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors init namespaces words words.symbol io
kernel.private math memory continuations kernel io.files
io.pathnames io.backend system parser vocabs sequences
vocabs.loader combinators splitting source-files strings
definitions assocs compiler.errors compiler.units math.parser
generic sets command-line ;
IN: bootstrap.stage2

SYMBOL: core-bootstrap-time

SYMBOL: bootstrap-time

: default-image-name ( -- string )
    vm file-name os windows? [ "." split1 drop ] when
    ".image" append resource-path ;

: do-crossref ( -- )
    "Cross-referencing..." print flush
    H{ } clone crossref set-global
    xref-words
    xref-generics
    xref-sources ;

: load-components ( -- )
    "include" "exclude"
    [ get-global " " split harvest ] bi@
    diff
    [ "bootstrap." prepend require ] each ;

: count-words ( pred -- )
    all-words swap count number>string write ;

: print-time ( ms -- )
    1000 /i
    60 /mod swap
    number>string write
    " minutes and " write number>string write " seconds." print ;

: print-report ( -- )
    "Core bootstrap completed in " write core-bootstrap-time get print-time
    "Bootstrap completed in "      write bootstrap-time      get print-time

    [ optimized>> ] count-words " compiled words" print
    [ symbol? ] count-words " symbol words" print
    [ ] count-words " words total" print

    "Bootstrapping is complete." print
    "Now, you can run Factor:" print
    vm write " -i=" write "output-image" get print flush ;

[
    ! We time bootstrap
    millis

    default-image-name "output-image" set-global

    "math compiler threads help io tools ui ui.tools unicode handbook" "include" set-global
    "" "exclude" set-global

    (command-line) parse-command-line

    do-crossref

    ! Set dll paths
    os wince? [ "windows.ce" require ] when
    os winnt? [ "windows.nt" require ] when

    "staging" get "deploy-vocab" get or [
        "stage2: deployment mode" print
    ] [
        "listener" require
        "none" require
    ] if

    [
        load-components

        millis over - core-bootstrap-time set-global

        run-bootstrap-init
    ] with-compiler-errors
    :errors

    f error set-global
    f error-continuation set-global

    millis swap - bootstrap-time set-global
    print-report

    "deploy-vocab" get [
        "tools.deploy.shaker" run
    ] [
        "staging" get [
            "resource:basis/bootstrap/finish-staging.factor" run-file
        ] [
            "resource:basis/bootstrap/finish-bootstrap.factor" run-file
        ] if

        "output-image" get save-image-and-exit
    ] if
] [
    drop
    [
        load-help? off
        "resource:basis/bootstrap/bootstrap-error.factor" run-file
    ] with-scope
] recover
