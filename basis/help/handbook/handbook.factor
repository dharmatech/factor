USING: help help.markup help.syntax help.definitions help.topics
namespaces words sequences classes assocs vocabs kernel arrays
prettyprint.backend prettyprint.custom kernel.private io generic
math system strings sbufs vectors byte-arrays quotations
io.streams.byte-array classes.builtin parser lexer
classes.predicate classes.union classes.intersection
classes.singleton classes.tuple tools.vocabs.browser math.parser
accessors ;
IN: help.handbook

ARTICLE: "conventions" "Conventions"
"Various conventions are used throughout the Factor documentation and source code."
{ $heading "Documentation conventions" }
"Factor documentation consists of two distinct bodies of text. There is a hierarchy of articles, much like this one, and there is word documentation. Help articles reference word documentation, and vice versa, but not every documented word is referenced from some help article."
$nl
"Every article has links to parent articles at the top. These can be persued if the article is too specific."
$nl
"Some generic words have " { $strong "Description" } " headings, and others have " { $strong "Contract" } " headings. A distinction is made between words which are not intended to be extended with user-defined methods, and those that are."
{ $heading "Vocabulary naming conventions" }
"A vocabulary name ending in " { $snippet ".private" } " contains words which are either implementation detail, unsafe, or both. For example, the " { $snippet "sequence.private" } " vocabulary contains words which access sequence elements without bounds checking (" { $link "sequences-unsafe" } ")."
$nl
"You should should avoid using internal words from the Factor library unless absolutely necessary. Similarly, your own code can place words in internal vocabularies if you do not want other people to use them unless they have a good reason."
{ $heading "Word naming conventions" }
"These conventions are not hard and fast, but are usually a good first step in understanding a word's behavior:"
{ $table
    { "General form" "Description" "Examples" }
    { { $snippet { $emphasis "foo" } "?" } "outputs a boolean" { { $link empty? } } }
    { { $snippet "?" { $emphasis "foo" } } { "conditionally performs " { $snippet { $emphasis "foo" } } } { { $links ?nth } } }
    { { $snippet "<" { $emphasis "foo" } ">" } { "creates a new " { $snippet "foo" } } { { $link <array> } } }
    { { $snippet ">" { $emphasis "foo" } } { "converts the top of the stack into a " { $snippet "foo" } } { { $link >array } } }
    { { $snippet { $emphasis "foo" } ">" { $emphasis "bar" } } { "converts a " { $snippet "foo" } " into a " { $snippet "bar" } } { { $link number>string } } }
    { { $snippet "new-" { $emphasis "foo" } } { "creates a new " { $snippet "foo" } ", taking some kind of parameter from the stack which determines the type of the object to be created" } { { $link new-sequence } ", " { $link new-lexer } ", " { $link new } } }
    { { $snippet { $emphasis "foo" } "*" } { "alternative form of " { $snippet "foo" } ", or a generic word called by " { $snippet "foo" } } { { $links at* pprint* } } }
    { { $snippet "(" { $emphasis "foo" } ")" } { "implementation detail word used by " { $snippet "foo" } } { { $link (clone) } } }
    { { $snippet "set-" { $emphasis "foo" } } { "sets " { $snippet "foo" } " to a new value" } { $links set-length } }
    { { $snippet { $emphasis "foo" } ">>" } { "gets the " { $snippet "foo" } " slot of the tuple at the top of the stack; see " { $link "accessors" } } { { $link >>name } } }
    { { $snippet ">>" { $emphasis "foo" } } { "sets the " { $snippet "foo" } " slot of the tuple at the top of the stack; see " { $link "accessors" } } { { $link name>> } } }
    { { $snippet "with-" { $emphasis "foo" } } { "performs some kind of initialization and cleanup related to " { $snippet "foo" } ", usually in a new dynamic scope" } { $links with-scope with-input-stream with-output-stream } }
    { { $snippet "$" { $emphasis "foo" } } { "help markup" } { $links $heading $emphasis } }
}
{ $heading "Stack effect conventions" }
"Stack effect conventions are documented in " { $link "effect-declaration" } "."
{ $heading "Glossary of terms" }
"Common terminology and abbreviations used throughout Factor and its documentation:"
{ $table
    { "Term" "Definition" }
    { "alist" { "an association list; see " { $link "alists" } } }
    { "assoc" { "an associative mapping; see " { $link "assocs" } } }
    { "associative mapping" { "an object whose class implements the " { $link "assocs-protocol" } } }
    { "boolean"               { { $link t } " or " { $link f } } }
    { "class"                 { "a set of objects identified by a " { $emphasis "class word" } " together with a discriminating predicate. See " { $link "classes" } } }
    { "definition specifier"  { "a " { $link word } ", " { $link method-spec } ", " { $link link } ", vocabulary specifier, or any other object whose class implements the " { $link "definition-protocol" } } }
    { "generalized boolean"   { "an object interpreted as a boolean; a value of " { $link f } " denotes false and anything else denotes true" } }
    { "generic word"          { "a word whose behavior depends can be specialized on the class of one of its inputs. See " { $link "generic" } } }
    { "method"                { "a specialized behavior of a generic word on a class. See " { $link "generic" } } }
    { "object"                { "any datum which can be identified" } }
    { "ordering specifier"    { "see " { $link "order-specifiers" } } }
    { "pathname string"       { "an OS-specific pathname which identifies a file" } }
    { "sequence" { "a sequence; see " { $link "sequence-protocol" } } }
    { "slot"                  { "a component of an object which can store a value" } }
    { "stack effect"          { "a pictorial representation of a word's inputs and outputs, for example " { $snippet "+ ( x y -- z )" } ". See " { $link "effects" } } }
    { "true value"            { "any object not equal to " { $link f } } }
    { "vocabulary" { "a named set of words. See " { $link "vocabularies" } } }
    { "vocabulary specifier"  { "a " { $link vocab } ", " { $link vocab-link } " or a string naming a vocabulary" } }
    { "word"                  { "the basic unit of code, analogous to a function or procedure in other programming languages. See " { $link "words" } } }
} ;

ARTICLE: "tail-call-opt" "Tail-call optimization"
"If the last action performed is the execution of a word, the current quotation is not saved on the call stack; this is known as " { $emphasis "tail-call optimization" } " and the Factor implementation guarantees that it will be performed."
$nl
"Tail-call optimization allows iterative algorithms to be implemented in an efficient manner using recursion, without the need for any kind of primitive looping construct in the language. However, in practice, most iteration is performed via combinators such as " { $link while } ", " { $link each } ", " { $link map } ", " { $link assoc-each } ", and so on. The definitions of these combinators do bottom-out in recursive words, however." ;

ARTICLE: "evaluator" "Evaluation semantics"
{ $link "quotations" } " are evaluated sequentially from beginning to end. When the end is reached, the quotation returns to its caller. As each object in the quotation is evaluated in turn, an action is taken based on its type:"
{ $list
    { "a " { $link word } " - the word's definition quotation is called. See " { $link "words" } }
    { "a " { $link wrapper } " - the wrapped object is pushed on the data stack. Wrappers are used to push word objects directly on the stack when they would otherwise execute. See the " { $link POSTPONE: \ } " parsing word." }
    { "All other types of objects are pushed on the data stack." }
}
{ $subsection "tail-call-opt" }
{ $see-also "compiler" } ;

ARTICLE: "objects" "Objects"
"An " { $emphasis "object" } " is any datum which may be identified. All values are objects in Factor. Each object carries type information, and types are checked at runtime; Factor is dynamically typed."
{ $subsection "equality" }
{ $subsection "math.order" }
{ $subsection "destructors" }
{ $subsection "classes" }
{ $subsection "tuples" }
{ $subsection "generic" }
{ $subsection "slots" }
{ $subsection "mirrors" } ;

ARTICLE: "numbers" "Numbers"
{ $subsection "arithmetic" }
{ $subsection "math-constants" }
{ $subsection "math-functions" }
{ $subsection "number-strings" }
"Number implementations:"
{ $subsection "integers" }
{ $subsection "rationals" }
{ $subsection "floats" }
{ $subsection "complex-numbers" }
"Advanced features:"
{ $subsection "math-vectors" }
{ $subsection "math-intervals" }
{ $subsection "math-bitfields" }
"Implementation:"
{ $subsection "math.libm" } ;

USE: io.buffers

ARTICLE: "collections" "Collections" 
{ $heading "Sequences" }
{ $subsection "sequences" }
{ $subsection "virtual-sequences" }
{ $subsection "namespaces-make" }
"Fixed-length sequences:"
{ $subsection "arrays" }
{ $subsection "quotations" }
"Fixed-length specialized sequences:"
{ $subsection "strings" }
{ $subsection "byte-arrays" }
"Resizable sequences:"
{ $subsection "vectors" }
{ $subsection "byte-vectors" }
{ $subsection "sbufs" }
{ $subsection "growable" }
{ $heading "Associative mappings" }
{ $subsection "assocs" }
{ $subsection "namespaces" }
{ $subsection "refs" }
"Implementations:"
{ $subsection "hashtables" }
{ $subsection "alists" }
{ $subsection "enums" }
{ $heading "Double-ended queues" }
{ $subsection "deques" }
"Implementations:"
{ $subsection "dlists" }
{ $subsection "search-deques" }
{ $heading "Other collections" }
{ $subsection "boxes" }
{ $subsection "heaps" }
{ $subsection "graphs" }
{ $subsection "buffers" }
"There are also many other vocabularies tagged " { $link T{ vocab-tag { name "collections" } } } " in the library." ;

USING: io.encodings.utf8 io.encodings.utf16 io.encodings.binary io.encodings.ascii io.files ;

ARTICLE: "encodings-introduction" "An introduction to encodings"
"In order to express text in terms of binary, some sort of encoding has to be used. In a modern context, this is understood as a two-way mapping between Unicode code points (characters) and some amount of binary. Since English isn't the only language in the world, ASCII is not sufficient as a mapping from binary to Unicode; it can't even express em-dashes or curly quotes. Unicode was designed as a universal character set that could potentially represent everything." $nl
"Not all encodings can represent all Unicode code points, but Unicode can represent basically everything that exists in modern encodings. Some encodings are language-specific, and some can represent everything in Unicode. Though the world is moving toward Unicode and UTF-8, the reality today is that there are several encodings which must be taken into account." $nl
"Factor uses a system of encoding descriptors to denote encodings. Encoding descriptors are objects which describe encodings. Examples are " { $link utf8 } ", " { $link ascii } " and " { $link binary } ". Encoding descriptors can be passed around independently. Each encoding descriptor has some method for constructing an encoded or decoded stream, and the resulting stream has an encoding descriptor stored which has methods for reading or writing characters." $nl
"Constructors for streams which deal with bytes usually take an encoding as an explicit parameter. For example, to open a text file for reading whose contents are in UTF-8, use the following"
{ $code "\"file.txt\" utf8 <file-reader>" }
"If there is an error in the encoded stream, a replacement character (0xFFFD) will be inserted. To throw an exception upon error, use a strict encoding as follows"
{ $code "\"file.txt\" utf8 strict <file-reader>" }
"In a similar way, encodings can be specified when opening a file for writing."
{ $code "\"file.txt\" ascii <file-writer>" }
"An encoding is also needed for some words that don't return streams, such as " { $link file-contents } ", for example"
{ $code "\"file.txt\" utf16 file-contents" }
"Encoding descriptors are also used by " { $link "io.streams.byte-array" } " and taken by combinators like " { $link with-file-writer } " and " { $link with-byte-reader } " which deal with streams. It is " { $emphasis "not" } " used with " { $link "io.streams.string" } " because these deal with abstract text."
$nl
"When the " { $link binary } " encoding is used, a " { $link byte-array } " is expected for writing and returned for reading, since the stream deals with bytes. All other encodings deal with strings, since they are used to represent text."
{ $see-also "stream-elements" } ;

ARTICLE: "io" "Input and output"
{ $heading "Streams" }
{ $subsection "streams" }
{ $subsection "io.files" }
{ $heading "The file system" }
{ $subsection "io.pathnames" }
{ $subsection "io.files.info" }
{ $subsection "io.files.links" }
{ $subsection "io.directories" }
{ $heading "Encodings" }
{ $subsection "encodings-introduction" }
{ $subsection "io.encodings" }
{ $heading "Wrapper streams" }
{ $subsection "io.streams.duplex" }
{ $subsection "io.streams.plain" }
{ $subsection "io.streams.string" }
{ $subsection "io.streams.byte-array" }
{ $heading "Utilities" }
{ $subsection "stream-binary" }
{ $subsection "io.styles" }
{ $subsection "checksums" }
{ $heading "Implementation" }
{ $subsection "io.streams.c" }
{ $subsection "io.ports" }
{ $see-also "destructors" } ;

ARTICLE: "tools" "Developer tools"
{ $subsection "tools.vocabs" }
"Exploratory tools:"
{ $subsection "editor" }
{ $subsection "listener" }
{ $subsection "tools.crossref" }
{ $subsection "inspector" }
{ $subsection "tools.completion" }
{ $subsection "summary" }
"Debugging tools:"
{ $subsection "tools.annotations" }
{ $subsection "tools.test" }
{ $subsection "tools.threads" }
"Performance tools:"
{ $subsection "tools.memory" }
{ $subsection "profiling" }
{ $subsection "timing" }
{ $subsection "tools.disassembler" }
"Deployment tools:"
{ $subsection "tools.deploy" }
{ $see-also "ui-tools" } ;

ARTICLE: "article-index" "Article index"
{ $index [ articles get keys ] } ;

ARTICLE: "primitive-index" "Primitive index"
{ $index [ all-words [ primitive? ] filter ] } ;

ARTICLE: "error-index" "Error index"
{ $index [ all-errors ] } ;

ARTICLE: "type-index" "Type index"
{ $index [ builtins get sift ] } ;

ARTICLE: "class-index" "Class index"
{ $heading "Built-in classes" }
{ $index [ classes [ builtin-class? ] filter ] }
{ $heading "Tuple classes" }
{ $index [ classes [ tuple-class? ] filter ] }
{ $heading "Singleton classes" }
{ $index [ classes [ singleton-class? ] filter ] }
{ $heading "Union classes" }
{ $index [ classes [ union-class? ] filter ] }
{ $heading "Intersection classes" }
{ $index [ classes [ intersection-class? ] filter ] }
{ $heading "Predicate classes" }
{ $index [ classes [ predicate-class? ] filter ] } ;

ARTICLE: "program-org" "Program organization"
{ $subsection "definitions" }
{ $subsection "vocabularies" }
{ $subsection "parser" }
{ $subsection "vocabs.loader" }
{ $subsection "source-files" } ;

USING: help.cookbook help.tutorial ;

ARTICLE: "handbook-language-reference" "Language reference"
{ $subsection "conventions" }
{ $subsection "syntax" }
{ $subsection "dataflow" }
{ $subsection "objects" }
{ $subsection "program-org" }
{ $subsection "numbers" }
{ $subsection "collections" }
{ $subsection "io" }
"Vocabularies tagged " { $link T{ vocab-tag { name "extensions" } } } " implement various additional language abstractions." ;

ARTICLE: "handbook-environment-reference" "Environment reference"
{ $subsection "prettyprint" }
{ $subsection "tools" }
{ $subsection "cli" }
{ $subsection "rc-files" }
{ $subsection "help" }
{ $subsection "inference" }
{ $subsection "compiler" }
{ $subsection "system" }
{ $subsection "images" }
{ $subsection "alien" }
{ $subsection "init" }
{ $subsection "layouts" }
{ $see-also "program-org" } ;

ARTICLE: "handbook-library-reference" "Library reference"
"This index only includes articles from loaded vocabularies. To explore more vocabularies, see " { $link "vocab-index" } "."
{ $index [ "handbook" orphan-articles remove ] } ;

ARTICLE: "handbook" "Factor documentation"
"Welcome to Factor."
$nl
"Explore the code base:"
{ $subsection "vocab-index" }
"Learn the language:"
{ $subsection "cookbook" }
{ $subsection "first-program" }
{ $subsection "handbook-language-reference" }
{ $subsection "handbook-environment-reference" }
{ $subsection "handbook-library-reference" }
"The below indices only include articles from loaded vocabularies. To explore more vocabularies, see " { $link "vocab-index" } "."
{ $subsection "article-index" }
{ $subsection "primitive-index" }
{ $subsection "error-index" }
{ $subsection "type-index" }
{ $subsection "class-index" } ;

ABOUT: "handbook"
