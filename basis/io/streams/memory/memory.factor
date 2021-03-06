! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors alien alien.c-types alien.accessors math io ;
IN: io.streams.memory

TUPLE: memory-stream alien index ;

: <memory-stream> ( alien -- stream )
    0 memory-stream boa ;

M: memory-stream stream-read1
    [ [ alien>> ] [ index>> ] bi alien-unsigned-1 ]
    [ [ 1+ ] change-index drop ] bi ;

M: memory-stream stream-read
    [
        [ index>> ] [ alien>> ] bi <displaced-alien>
        swap memory>byte-array
    ] [ [ + ] change-index drop ] 2bi ;
