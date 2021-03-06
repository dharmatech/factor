! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.utf8 io.directories io.files kernel
sequences xml ;
IN: benchmark.xml

: xml-benchmark ( -- )
    "resource:basis/xmode/modes/" [
        [ utf8 <file-reader> read-xml drop ] each
    ] with-directory-files ;

MAIN: xml-benchmark
