! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel symbols namespaces continuations
destructors io.sockets sequences inspector calendar ;
IN: io.sockets.secure

SYMBOL: secure-socket-timeout

1 minutes secure-socket-timeout set-global

SYMBOL: secure-socket-backend

SINGLETONS: SSLv2 SSLv23 SSLv3 TLSv1 ;

TUPLE: secure-config
method
key-file password
ca-file ca-path
dh-file
ephemeral-key-bits ;

: <secure-config> ( -- config )
    secure-config new
        SSLv23 >>method
        1024 >>ephemeral-key-bits ;

TUPLE: secure-context config handle disposed ;

HOOK: <secure-context> secure-socket-backend ( config -- context )

: with-secure-context ( config quot -- )
    [
        [ <secure-context> ] [ [ secure-context set ] prepose ] bi*
        with-disposal
    ] with-scope ; inline

TUPLE: secure addrspec ;

C: <secure> secure

: resolve-secure-host ( host port passive? -- seq )
    resolve-host [ <secure> ] map ;

HOOK: check-certificate secure-socket-backend ( host handle -- )

<PRIVATE

PREDICATE: secure-inet < secure addrspec>> inet? ;

M: secure-inet (client)
    [
        addrspec>>
        [ [ host>> ] [ port>> ] bi f resolve-secure-host (client) >r |dispose r> ] keep
        host>> pick handle>> check-certificate
    ] with-destructors ;

PRIVATE>

ERROR: premature-close ;

M: premature-close summary
    drop "Connection closed prematurely - potential truncation attack" ;

ERROR: certificate-verify-error result ;

M: certificate-verify-error summary
    drop "Certificate verification failed" ;

ERROR: common-name-verify-error expected got ;

M: common-name-verify-error summary
    drop "Common name verification failed" ;
