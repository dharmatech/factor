USING: tools.test kernel unicode.categories words sequences unicode.syntax ;

[ { f f t t f t t f f t } ] [ CHAR: A { 
    blank? letter? LETTER? Letter? digit? 
    printable? alpha? control? uncased? character? 
} [ execute ] with map ] unit-test
[ "Nd" ] [ CHAR: 3 category ] unit-test
[ "Lo" ] [ HEX: 3400 category ] unit-test
[ "Lo" ] [ HEX: 3450 category ] unit-test
[ "Lo" ] [ HEX: 4DB5 category ] unit-test
[ "Cs" ] [ HEX: DD00 category ] unit-test
