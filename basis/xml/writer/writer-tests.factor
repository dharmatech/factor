! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml.data xml.writer tools.test fry xml kernel multiline
xml.writer.private io.streams.string xml.utilities sequences ;
IN: xml.writer.tests

\ write-xml must-infer
\ xml>string must-infer
\ pprint-xml must-infer
\ pprint-xml-but must-infer

[ "foo" ] [ T{ name { main "foo" } } name>string ] unit-test
[ "foo" ] [ T{ name { space "" } { main "foo" } } name>string ] unit-test
[ "ns:foo" ] [ T{ name { space "ns" } { main "foo" } } name>string ] unit-test

: reprints-as ( to from -- )
     [ '[ _ ] ] [ '[ _ string>xml xml>string ] ] bi* unit-test ;

: pprint-reprints-as ( to from -- )
     [ '[ _ ] ] [ '[ _ string>xml pprint-xml>string ] ] bi* unit-test ;

: reprints-same ( string -- ) dup reprints-as ;

"<?xml version=\"1.0\" encoding=\"UTF-8\"?><x/>" reprints-same

{" <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY foo "bar">]>
<x>bar</x> "}
{" <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY foo 'bar'>]>
<x>&foo;</x> "} reprints-as

{" <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY foo "bar">
  <!ELEMENT br EMPTY>
  <!ATTLIST list type    (bullets|ordered|glossary)  "ordered">
  <!NOTATION foo bar>
  <?baz bing bang bong?>
  <!--wtf-->
]>
<x>
  bar
</x>"}
{" <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [ <!ENTITY foo 'bar'> <!ELEMENT br EMPTY>
<!ATTLIST list
          type    (bullets|ordered|glossary)  "ordered">
<!NOTATION 	foo bar> <?baz bing bang bong?>
      		<!--wtf-->
]>
<x>&foo;</x>"} pprint-reprints-as

[ t ] [ "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd' >" dup string>xml-chunk xml-chunk>string = ] unit-test
[ V{ "hello" } ] [ "hello" string>xml-chunk ] unit-test
[ "<?xml version=\"1.0\" encoding=\"UTF-8\"?><a b=\"c\"/>" ]
    [ "<a b='c'/>" string>xml xml>string ] unit-test
[ "<?xml version=\"1.0\" encoding=\"UTF-8\"?><foo>bar baz</foo>" ]
[ "<foo>bar</foo>" string>xml [ " baz" append ] map xml>string ] unit-test
[ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<foo>\n  bar\n</foo>" ]
[ "<foo>         bar            </foo>" string>xml pprint-xml>string ] unit-test
