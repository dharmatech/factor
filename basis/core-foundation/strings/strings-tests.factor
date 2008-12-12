! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: core-foundation.strings core-foundation tools.test kernel ;
IN: core-foundation

[ ] [ "Hello" <CFString> CFRelease ] unit-test
[ "Hello" ] [ "Hello" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test
[ "Hello\u003456" ] [ "Hello\u003456" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test
[ "Hello\u013456" ] [ "Hello\u013456" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test
