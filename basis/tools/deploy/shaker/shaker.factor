! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.backend io.streams.c init fry
namespaces make assocs kernel parser lexer strings.parser vocabs
sequences words words.private memory kernel.private
continuations io vocabs.loader system strings sets
vectors quotations byte-arrays sorting compiler.units
definitions generic generic.standard tools.deploy.config ;
QUALIFIED: bootstrap.stage2
QUALIFIED: classes
QUALIFIED: command-line
QUALIFIED: compiler.errors
QUALIFIED: continuations
QUALIFIED: definitions
QUALIFIED: init
QUALIFIED: layouts
QUALIFIED: source-files
QUALIFIED: vocabs
IN: tools.deploy.shaker

! This file is some hairy shit.

: strip-init-hooks ( -- )
    "Stripping startup hooks" show
    { "cpu.x86" "command-line" "libc" "system" "environment" }
    [ init-hooks get delete-at ] each
    deploy-threads? get [
        "threads" init-hooks get delete-at
    ] unless
    native-io? [
        "io.thread" init-hooks get delete-at
    ] unless
    strip-io? [
        "io.files" init-hooks get delete-at
        "io.backend" init-hooks get delete-at
    ] when
    strip-dictionary? [
        "compiler.units" init-hooks get delete-at
        "tools.vocabs" init-hooks get delete-at
    ] when ;

: strip-debugger ( -- )
    strip-debugger? "debugger" vocab and [
        "Stripping debugger" show
        "resource:basis/tools/deploy/shaker/strip-debugger.factor"
        run-file
    ] when ;

: strip-libc ( -- )
    "libc" vocab [
        "Stripping manual memory management debug code" show
        "resource:basis/tools/deploy/shaker/strip-libc.factor"
        run-file
    ] when ;

: strip-cocoa ( -- )
    "cocoa" vocab [
        "Stripping unused Cocoa methods" show
        "resource:basis/tools/deploy/shaker/strip-cocoa.factor"
        run-file
    ] when ;

: strip-word-names ( words -- )
    "Stripping word names" show
    [ f >>name f >>vocabulary drop ] each ;

: strip-word-defs ( words -- )
    "Stripping symbolic word definitions" show
    [ "no-def-strip" word-prop not ] filter
    [ [ ] >>def drop ] each ;

: sift-assoc ( assoc -- assoc' ) [ nip ] assoc-filter ;

: strip-word-props ( stripped-props words -- )
    "Stripping word properties" show
    [
        swap '[
            [
                [ drop _ member? not ] assoc-filter sift-assoc
                >alist f like
            ] change-props drop
        ] each
    ] [
        H{ } clone '[
            [ [ _ [ ] cache ] map ] change-props drop
        ] each
    ] bi ;

: stripped-word-props ( -- seq )
    [
        strip-dictionary? [
            {
                "alias"
                "boa-check"
                "cannot-infer"
                "coercer"
                "combination"
                "compiled-effect"
                "compiled-generic-uses"
                "compiled-uses"
                "constraints"
                "custom-inlining"
                "declared-effect"
                "default"
                "default-method"
                "default-output-classes"
                "derived-from"
                "ebnf-parser"
                "engines"
                "forgotten"
                "identities"
                "if-intrinsics"
                "infer"
                "inferred-effect"
                "inline"
                "inlined-block"
                "input-classes"
                "interval"
                "intrinsics"
                "lambda"
                "loc"
                "local-reader"
                "local-reader?"
                "local-writer"
                "local-writer?"
                "local?"
                "macro"
                "members"
                "memo-quot"
                "methods"
                "mixin"
                "method-class"
                "method-generic"
                "modular-arithmetic"
                "no-compile"
                "optimizer-hooks"
                "outputs"
                "participants"
                "predicate"
                "predicate-definition"
                "predicating"
                "primitive"
                "reader"
                "reading"
                "recursive"
                "register"
                "register-size"
                "shuffle"
                "slot-names"
                "slots"
                "special"
                "specializer"
                "step-into"
                "step-into?"
                "transform-n"
                "transform-quot"
                "tuple-dispatch-generic"
                "type"
                "writer"
                "writing"
            } %
        ] when
        
        strip-prettyprint? [
            {
                "break-before"
                "break-after"
                "delimiter"
                "flushable"
                "foldable"
                "inline"
                "lambda"
                "macro"
                "memo-quot"
                "parsing"
                "word-style"
            } %
        ] when
    ] { } make ;

: strip-words ( props -- )
    [ word? ] instances
    deploy-word-props? get [ 2dup strip-word-props ] unless
    deploy-word-defs? get [ dup strip-word-defs ] unless
    strip-word-names? [ dup strip-word-names ] when
    2drop ;

: strip-default-methods ( -- )
    strip-debugger? [
        "Stripping default methods" show
        [
            [ generic? ] instances
            [ "No method" throw ] define-temp
            dup t "default" set-word-prop
            '[
                [ _ "default-method" set-word-prop ] [ make-generic ] bi
            ] each
        ] with-compilation-unit
    ] when ;

: strip-vocab-globals ( except names -- words )
    [ child-vocabs [ words ] map concat ] map concat swap diff ;

: stripped-globals ( -- seq )
    [
        "inspector-hook" "inspector" lookup ,

        {
            continuations:error
            continuations:error-continuation
            continuations:error-thread
            continuations:restarts
            init:init-hooks
            source-files:source-files
            input-stream
            output-stream
            error-stream
        } %

        "io-thread" "io.thread" lookup ,

        "mallocs" "libc.private" lookup ,

        deploy-threads? [
            "initial-thread" "threads" lookup ,
        ] unless

        strip-io? [ io-backend , ] when

        { } {
            "alarms"
            "tools"
            "io.launcher"
            "random"
            "compiler"
            "stack-checker"
            "bootstrap"
            "listener"
        } strip-vocab-globals %

        strip-dictionary? [
            "libraries" "alien" lookup ,

            { } { "cpu" } strip-vocab-globals %

            {
                gensym
                name>char-hook
                classes:next-method-quot-cache
                classes:class-and-cache
                classes:class-not-cache
                classes:class-or-cache
                classes:class<=-cache
                classes:classes-intersect-cache
                classes:implementors-map
                classes:update-map
                command-line:main-vocab-hook
                compiled-crossref
                compiled-generic-crossref
                recompile-hook
                update-tuples-hook
                remake-generics-hook
                definition-observers
                definitions:crossref
                interactive-vocabs
                layouts:num-tags
                layouts:num-types
                layouts:tag-mask
                layouts:tag-numbers
                layouts:type-numbers
                lexer-factory
                print-use-hook
                root-cache
                vocab-roots
                vocabs:dictionary
                vocabs:load-vocab-hook
                word
                parser-notes
            } %

            { } { "math.partial-dispatch" } strip-vocab-globals %

            { } { "peg" } strip-vocab-globals %
        ] when

        strip-prettyprint? [
            { } { "prettyprint.config" } strip-vocab-globals %
        ] when

        strip-debugger? [
            {
                compiler.errors:compiler-errors
                continuations:thread-error-hook
            } %
        ] when

        deploy-c-types? get [
            "c-types" "alien.c-types" lookup ,
        ] unless

        deploy-ui? get [
            "ui-error-hook" "ui.gadgets.worlds" lookup ,
        ] when

        "windows-messages" "windows.messages" lookup [ , ] when*
    ] { } make ;

: strip-globals ( stripped-globals -- )
    strip-globals? [
        "Stripping globals" show
        global swap
        '[ drop _ member? not ] assoc-filter
        [ drop string? not ] assoc-filter ! strip CLI args
        sift-assoc
        21 setenv
    ] [ drop ] if ;

: strip-c-io ( -- )
    deploy-io get 2 = os windows? or [
        [
            c-io-backend forget
            "io.streams.c" forget-vocab
        ] with-compilation-unit
    ] unless ;

: compress ( pred post-process string -- )
    "Compressing " prepend show
    [ instances dup H{ } clone [ [ ] cache ] curry map ] dip call
    become ; inline

: compress-byte-arrays ( -- )
    [ byte-array? ] [ ] "byte arrays" compress ;

: remain-compiled ( old new -- old new )
    #! Quotations which were formerly compiled must remain
    #! compiled.
    2dup [
        2dup [ compiled>> ] [ compiled>> not ] bi* and
        [ nip jit-compile ] [ 2drop ] if
    ] 2each ;

: compress-quotations ( -- )
    [ quotation? ] [ remain-compiled ] "quotations" compress ;

: compress-strings ( -- )
    [ string? ] [ ] "strings" compress ;

: compress-wrappers ( -- )
    [ wrapper? ] [ ] "wrappers" compress ;

: finish-deploy ( final-image -- )
    "Finishing up" show
    [ { } set-datastack ] dip
    { } set-retainstack
    V{ } set-namestack
    V{ } set-catchstack
    "Saving final image" show
    [ save-image-and-exit ] call-clear ;

SYMBOL: deploy-vocab

: set-boot-quot* ( word -- )
    [
        \ boot ,
        init-hooks get values concat %
        ,
        strip-io? [ \ flush , ] unless
        [ 0 exit ] %
    ] [ ] make
    set-boot-quot ;

: init-stripper ( -- )
    t "quiet" set-global
    f output-stream set-global ;

: compute-next-methods ( -- )
    [ standard-generic? ] instances [
        "methods" word-prop [
            nip
            dup next-method-quot "next-method-quot" set-word-prop
        ] assoc-each
    ] each
    "resource:basis/tools/deploy/shaker/next-methods.factor" run-file ;

: strip ( -- )
    init-stripper
    strip-default-methods
    strip-libc
    strip-cocoa
    strip-debugger
    compute-next-methods
    strip-init-hooks
    strip-c-io
    f 5 setenv ! we can't use the Factor debugger or Factor I/O anymore
    deploy-vocab get vocab-main set-boot-quot*
    stripped-word-props
    stripped-globals strip-globals
    compress-byte-arrays
    compress-quotations
    compress-strings
    compress-wrappers
    strip-words ;

: (deploy) ( final-image vocab config -- )
    #! Does the actual work of a deployment in the slave
    #! stage2 image
    [
        [
            deploy-vocab set
            deploy-vocab get require
            strip
            finish-deploy
        ] [ error-continuation get call>> callstack>array die 1 exit ] recover
    ] bind ;

: do-deploy ( -- )
    "output-image" get
    "deploy-vocab" get
    "Deploying " write dup write "..." print
    "deploy-config" get parse-file first
    (deploy) ;

MAIN: do-deploy
