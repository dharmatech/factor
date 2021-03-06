USING: help.markup help.syntax quotations hashtables kernel
classes strings continuations destructors math byte-arrays ;
IN: io

HELP: stream-readln
{ $values { "stream" "an input stream" } { "str/f" "a string or " { $link f } } }
{ $contract "Reads a line of input from the stream. Outputs " { $link f } " on stream exhaustion." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link readln } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-read1
{ $values { "stream" "an input stream" } { "elt" "an element or " { $link f } } }
{ $contract "Reads an element from the stream. Outputs " { $link f } " on stream exhaustion." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link read1 } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-read
{ $values { "n" "a non-negative integer" } { "stream" "an input stream" } { "seq" { $or byte-array string f } } }
{ $contract "Reads " { $snippet "n" } " elements from the stream. Outputs a truncated string or " { $link f } " on stream exhaustion." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link read } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-read-until
{ $values { "seps" string } { "stream" "an input stream" } { "seq" { $or byte-array string f } } { "sep/f" "a character or " { $link f } } }
{ $contract "Reads elements from the stream, until the first occurrence of a separator character, or stream exhaustion. In the former case, the separator is pushed on the stack, and is not part of the output string. In the latter case, the entire stream contents are output, along with " { $link f } "." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link read-until } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-read-partial
{ $values
     { "n" "a non-negative integer" } { "stream" "an input stream" }
     { "seq" { $or byte-array string f } } }
{ $description "Reads at most " { $snippet "n" } " elements from a stream and returns up to that many characters without blocking. If no characters are available, blocks until some are and returns them." } ;

HELP: stream-write1
{ $values { "elt" "an element" } { "stream" "an output stream" } }
{ $contract "Writes an element to the stream. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link write1 } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-write
{ $values { "seq" "a byte array or string" } { "stream" "an output stream" } }
{ $contract "Writes a sequence of elements to the stream. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link write } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-flush
{ $values { "stream" "an output stream" } }
{ $contract "Waits for any pending output to complete." }
{ $notes "With many output streams, written output is buffered and not sent to the underlying resource until either the buffer is full, or this word is called." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link flush } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-nl
{ $values { "stream" "an output stream" } }
{ $contract "Writes a line terminator. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link nl } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-print
{ $values { "str" string } { "stream" "an output stream" } }
{ $description "Writes a newline-terminated string." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link print } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-copy
{ $values { "in" "an input stream" } { "out" "an output stream" } }
{ $description "Copies the contents of one stream into another, closing both streams when done." } 
$io-error ;

HELP: input-stream
{ $var-description "Holds an input stream for various implicit stream operations. Rebound using " { $link with-input-stream } " and " { $link with-input-stream* } "." } ;

HELP: output-stream
{ $var-description "Holds an output stream for various implicit stream operations. Rebound using " { $link with-output-stream } " and " { $link with-output-stream* } "." } ;

HELP: error-stream
{ $var-description "Holds an error stream." } ;

HELP: readln
{ $values { "str/f" "a string or " { $link f } } }
{ $description "Reads a line of input from " { $link input-stream } ". Outputs " { $link f } " on stream exhaustion." }
$io-error ;

HELP: read1
{ $values { "elt" "an element or " { $link f } } }
{ $description "Reads an element from " { $link input-stream } ". Outputs " { $link f } " on stream exhaustion." }
$io-error ;

HELP: read
{ $values { "n" "a non-negative integer" } { "seq" { $or byte-array string f } } }
{ $description "Reads " { $snippet "n" } " elements from " { $link input-stream } ". If there is no input available, outputs " { $link f } ". If there are less than " { $snippet "n" } " elements available, outputs a sequence shorter than " { $snippet "n" } " in length." }
$io-error ;

HELP: read-until
{ $values { "seps" string } { "seq" { $or byte-array string f } } { "sep/f" "a character or " { $link f } } }
{ $contract "Reads elements from " { $link input-stream } ". until the first occurrence of a separator, or stream exhaustion. In the former case, the separator character is pushed on the stack, and is not part of the output. In the latter case, the entire stream contents are output, along with " { $link f } "." }
$io-error ;

HELP: read-partial
{ $values { "n" integer } { "seq" { $or byte-array string f } } }
{ $description "Reads at most " { $snippet "n" } " elements from " { $link input-stream } " and returns them in a sequence. This word should be used instead of " { $link read } " when processing the entire element a chunk at a time, since on some stream implementations it may be slightly faster." } ;

HELP: write1
{ $values { "elt" "an element" } }
{ $contract "Writes an element to " { $link output-stream } ". If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
$io-error ;

HELP: write
{ $values { "seq" { $or byte-array string f } } }
{ $description "Writes a sequence of elements to " { $link output-stream } ". If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
$io-error ;

HELP: flush
{ $description "Waits for any pending output on " { $link output-stream } " to complete." }
$io-error ;

HELP: nl
{ $description "Writes a line terminator to " { $link output-stream } ". If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
$io-error ;

HELP: print
{ $values { "str" string } }
{ $description "Writes a newline-terminated string to " { $link output-stream } "." }
$io-error ;

HELP: with-input-stream
{ $values { "stream" "an input stream" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with " { $link input-stream } " rebound to  " { $snippet "stream" } ". The stream is closed if the quotation returns or throws an error." } ;

HELP: with-output-stream
{ $values { "stream" "an output stream" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with " { $link output-stream } " rebound to  " { $snippet "stream" } ". The stream is closed if the quotation returns or throws an error." } ;

HELP: with-streams
{ $values { "input" "an input stream" } { "output" "an output stream" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with " { $link input-stream } " rebound to  " { $snippet "input" } " and " { $link output-stream } " rebound to  " { $snippet "output" } ". The stream is closed if the quotation returns or throws an error." } ;

HELP: with-streams*
{ $values { "input" "an input stream" } { "output" "an output stream" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with " { $link input-stream } " rebound to  " { $snippet "input" } " and " { $link output-stream } " rebound to  " { $snippet "output" } "." }
{ $notes "This word does not close the stream. Compare with " { $link with-streams } "." } ;

{ with-input-stream with-input-stream* } related-words

{ with-output-stream with-output-stream* } related-words

HELP: with-input-stream*
{ $values { "stream" "an input stream" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with " { $link input-stream } " rebound to  " { $snippet "stream" } "." }
{ $notes "This word does not close the stream. Compare with " { $link with-input-stream } "." } ;

HELP: with-output-stream*
{ $values { "stream" "an output stream" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with " { $link output-stream } " rebound to  " { $snippet "stream" } "." }
{ $notes "This word does not close the stream. Compare with " { $link with-output-stream } "." } ;

HELP: bl
{ $description "Outputs a space character (" { $snippet "\" \"" } ") to " { $link output-stream } "." }
$io-error ;

HELP: lines
{ $values { "stream" "an input stream" } { "seq" "a sequence of strings" } }
{ $description "Reads lines of text until the stream is exhausted, collecting them in a sequence of strings." } ;

HELP: each-line
{ $values { "quot" { $quotation "( str -- )" } } }
{ $description "Calls the quotation with successive lines of text, until the current " { $link input-stream } " is exhausted." } ;

HELP: each-block
{ $values { "quot" { $quotation "( block -- )" } } }
{ $description "Calls the quotation with successive blocks of data, until the current " { $link input-stream } " is exhausted." } ;

HELP: contents
{ $values { "stream" "an input stream" } { "seq" "a string, byte array or " { $link f } } }
{ $description "Reads the entire contents of a stream. If the stream is empty, outputs"  { $link f } "." }
$io-error ;

ARTICLE: "stream-protocol" "Stream protocol"
"The stream protocol consists of a large number of generic words, many of which are optional."
$nl
"Stream protocol words are rarely called directly, since code which only works with one stream at a time should be written use " { $link "stdio" } " instead, wrapping I/O operations such as " { $link read } " and " { $link write } " in " { $link with-input-stream } " and " { $link with-output-stream } "."
$nl
"All streams must implement the " { $link dispose } " word in addition to the stream protocol."
$nl
"These words are required for binary and string input streams:"
{ $subsection stream-read1 }
{ $subsection stream-read }
{ $subsection stream-read-until }
{ $subsection stream-read-partial }
"This word is only required for string input streams:"
{ $subsection stream-readln }
"These words are required for binary and string output streams:"
{ $subsection stream-flush }
{ $subsection stream-write1 }
{ $subsection stream-write }
"This word is only required for string output streams:"
{ $subsection stream-nl }
"For a discussion of the distinction between binary and string streams, see " { $link "stream-elements" } "."
{ $see-also "io.timeouts" } ;

ARTICLE: "stdio-motivation" "Motivation for default streams"
"Most I/O code only operates on one stream at a time. The " { $link input-stream } " and " { $link output-stream } " variables are implicit parameters used by many I/O words. Using this idiom improves code in three ways:"
{ $list
    { "Code becomes simpler because there is no need to keep a stream around on the stack." }
    { "Code becomes more robust because " { $link with-input-stream } " and " { $link with-output-stream } " automatically close the streams if there is an error." }
    { "Code becomes more reusable because it can be written to not worry about which stream is being used, and instead the caller can use " { $link with-input-stream } " or " { $link with-output-stream } " to specify the source or destination for I/O operations." }
}
"For example, here is a program which reads the first line of a file, converts it to an integer, then reads that many characters, and splits them into groups of 16:"
{ $code
    "USING: continuations kernel io io.files math.parser splitting ;"
    "\"data.txt\" utf8 <file-reader>"
    "dup stream-readln number>string over stream-read 16 group"
    "swap dispose"
}
"This code has two problems: it has some unnecessary stack shuffling, and if either " { $link stream-readln } " or " { $link stream-read } " throws an I/O error, the stream is not closed because " { $link dispose } " is never reached. So we can add a call to " { $link with-disposal } " to ensure the stream is always closed:"
{ $code
    "USING: continuations kernel io io.files math.parser splitting ;"
    "\"data.txt\" utf8 <file-reader> ["
    "    dup stream-readln number>string over stream-read"
    "    16 group"
    "] with-disposal"
}
"This code is robust however it is more complex than it needs to be since. This is where the default stream words come in; using them, the above can be rewritten as follows:"
{ $code
    "USING: continuations kernel io io.files math.parser splitting ;"
    "\"data.txt\" utf8 <file-reader> ["
    "    readln number>string read 16 group"
    "] with-input-stream"
}
"An even better implementation that takes advantage of a utility word:"
{ $code
    "USING: continuations kernel io io.files math.parser splitting ;"
    "\"data.txt\" utf8 ["
    "    readln number>string read 16 group"
    "] with-file-reader"
} ;

ARTICLE: "stdio" "Default input and output streams"
{ $subsection "stdio-motivation" }
"The default input stream is stored in a dynamically-scoped variable:"
{ $subsection input-stream }
"Unless rebound in a child namespace, this variable will be set to a console stream for reading input from the user."
$nl
"Words reading from the default input stream:"
{ $subsection read1 }
{ $subsection read }
{ $subsection read-until }
{ $subsection read-partial }
"If the default input stream is a string stream (" { $link "stream-elements" } "), lines of text can be read:"
{ $subsection readln }
"A pair of combinators for rebinding the " { $link input-stream } " variable:"
{ $subsection with-input-stream }
{ $subsection with-input-stream* }
"The default output stream is stored in a dynamically-scoped variable:"
{ $subsection output-stream }
"Unless rebound in a child namespace, this variable will be set to a console stream for showing output to the user."
$nl
"Words writing to the default input stream:"
{ $subsection flush }
{ $subsection write1 }
{ $subsection write }
"If the default output stream is a string stream (" { $link "stream-elements" } "), lines of text can be written:"
{ $subsection readln }
{ $subsection print }
{ $subsection nl }
{ $subsection bl }
"A pair of combinators for rebinding the " { $link output-stream } " variable:"
{ $subsection with-output-stream }
{ $subsection with-output-stream* }
"A pair of combinators for rebinding both default streams at once:"
{ $subsection with-streams }
{ $subsection with-streams* } ;

ARTICLE: "stream-utils" "Stream utilities"
"There are a few useful stream-related words which are not generic, but merely built up from the stream protocol."
$nl
"First, a simple composition of " { $link stream-write } " and " { $link stream-nl } ":"
{ $subsection stream-print }
"Processing lines one by one:"
{ $subsection lines }
{ $subsection each-line }
"Processing blocks of data:"
{ $subsection contents }
{ $subsection each-block }
"Copying the contents of one stream to another:"
{ $subsection stream-copy } ;

ARTICLE: "stream-elements" "Stream elements"
"There are two types of streams:"
{ $list
  { { $strong "Binary streams" } " - the elements are integers between 0 and 255, inclusive; they represent bytes. Reading a sequence of elements produces a " { $link byte-array } "." }
  { { $strong "String streams" } " - the elements are non-negative integers, representing Unicode code points. Reading a sequence of elements produces a " { $link string } "." }
}
"Most external streams are binary streams, and can be wrapped in string streams once a suitable encoding has been provided; see " { $link "io.encodings" } "." ;

ARTICLE: "streams" "Streams"
"Input and output centers on the concept of a " { $emphasis "stream" } ", which is a source or sink of elements."
{ $subsection "stream-elements" }
"A stream can either be passed around on the stack or bound to a dynamic variable and used as one of the two implicit " { $emphasis "default streams" } "."
{ $subsection "stream-protocol" }
{ $subsection "stdio" }
{ $subsection "stream-utils" }
{ $see-also "io.streams.string" "io.streams.plain" "io.streams.duplex" } ;

ABOUT: "streams"
