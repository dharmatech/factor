USING: help.markup help.syntax math math.private math.functions
math.complex.private ;
IN: math.complex

ARTICLE: "complex-numbers-zero" "Embedding of real numbers in complex numbers"
"Constructing a complex number with an imaginary component equal to an integer zero simply returns the real number corresponding to the real component:"
{ $example "USING: math prettyprint ;" "C{ 1 2 } C{ 3 -2 } + ." "4" }
"Constructing a complex number with an imaginary component equal to floating point zero will still output a new complex number, however:"
{ $example "USING: math prettyprint ;" "C{ 0.0 2.0 } C{ 0.0 1.0 } * ." "C{ 2.0 0.0 }" }
"Unlike math, where all real numbers are also complex numbers, Factor only considers a number to be a complex number if its imaginary part is non-zero. However, complex number operations are fully supported for real numbers; they are treated as having an imaginary part of zero." ;

ARTICLE: "complex-numbers" "Complex numbers"
{ $subsection complex }
"Complex numbers arise as solutions to quadratic equations whose graph does not intersect the " { $emphasis "x" } " axis. Their literal syntax is covered in " { $link "syntax-complex-numbers" } "."
$nl
"Complex numbers can be taken apart:"
{ $subsection real-part }
{ $subsection imaginary-part }
{ $subsection >rect }
"Complex numbers can be constructed from real numbers:"
{ $subsection rect> }
{ $subsection "complex-numbers-zero" }
{ $see-also "syntax-complex-numbers" } ;
HELP: complex
{ $class-description "The class of complex numbers with non-zero imaginary part." } ;

ABOUT: "complex-numbers"

HELP: 2>rect
{ $values { "x" "a complex number" } { "y" "a complex number" } { "xr" "real part of " { $snippet "x" } } { "xi" "imaginary part of " { $snippet "x" } } { "yr" "real part of " { $snippet "y" } } { "yi" "imaginary part of " { $snippet "y" } } }
{ $description "Extracts real and imaginary components of two numbers at once." } ;

HELP: complex/
{ $values { "x" "a complex number" } { "y" "a complex number" } { "r" "a real number" } { "i" "a real number" } { "m" "a real number" } }
{ $description
    "Complex division kernel. If we use the notation from " { $link 2>rect } ", this word computes:"
    { $code
        "r = xr*yr+xi*yi"
        "i = xi*yr-xr*yi"
        "m = yr*yr+yi*yi"
    }
} ;

HELP: <complex> ( x y -- z )
{ $values { "x" "a real number" } { "y" "a real number" } { "z" "a complex number" } }
{ $description "Low-level complex number constructor. User code should call " { $link rect> } " instead." } ;
