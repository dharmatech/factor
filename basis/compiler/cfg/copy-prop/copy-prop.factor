! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs accessors ;
IN: compiler.cfg.copy-prop

SYMBOL: copies

: resolve ( vreg -- vreg )
    dup copies get at swap or ;

: record-copy ( insn -- )
    [ src>> resolve ] [ dst>> ] bi copies get set-at ; inline
