! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel math.bitwise core-foundation ;
IN: core-foundation.file-descriptors

TYPEDEF: void* CFFileDescriptorRef
TYPEDEF: int CFFileDescriptorNativeDescriptor
TYPEDEF: void* CFFileDescriptorCallBack

FUNCTION: CFFileDescriptorRef CFFileDescriptorCreate (
    CFAllocatorRef allocator,
    CFFileDescriptorNativeDescriptor fd,
    Boolean closeOnInvalidate,
    CFFileDescriptorCallBack callout, 
    CFFileDescriptorContext* context
) ;

: kCFFileDescriptorReadCallBack 1 ; inline
: kCFFileDescriptorWriteCallBack 2 ; inline
   
FUNCTION: void CFFileDescriptorEnableCallBacks (
    CFFileDescriptorRef f,
    CFOptionFlags callBackTypes
) ;

: enable-all-callbacks ( fd -- )
    { kCFFileDescriptorReadCallBack kCFFileDescriptorWriteCallBack } flags
    CFFileDescriptorEnableCallBacks ;

: <CFFileDescriptor> ( fd callback -- handle )
    [ f swap ] [ t swap ] bi* f CFFileDescriptorCreate
    [ "CFFileDescriptorCreate failed" throw ] unless* ;
