! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: delegate sequences.private sequences assocs
io io.styles definitions kernel continuations ;
IN: delegate.protocols

PROTOCOL: sequence-protocol
    clone clone-like like new-sequence new-resizable nth
    nth-unsafe set-nth set-nth-unsafe length set-length
    lengthen ;

PROTOCOL: assoc-protocol
    at* assoc-size >alist set-at assoc-clone-like
    delete-at clear-assoc new-assoc assoc-like ;

PROTOCOL: input-stream-protocol
    stream-read1 stream-read stream-read-partial stream-readln
    stream-read-until ;

PROTOCOL: output-stream-protocol
    stream-flush stream-write1 stream-write stream-format
    stream-nl make-span-stream make-block-stream
    make-cell-stream stream-write-table ;

PROTOCOL: definition-protocol
    where set-where forget uses
    synopsis* definer definition ;
