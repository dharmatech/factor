! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.entities ;
IN: xml.entities.html

ARTICLE: "xml.entities.html" "HTML entities"
{ $vocab-link "xml.entities.html" } " defines words for using entities defined in HTML/XHTML."
    { $subsection html-entities }
    { $subsection with-html-entities } ;

HELP: html-entities
{ $description "a hash table from HTML entity names to their character values" }
{ $see-also entities with-html-entities } ;

HELP: with-html-entities
{ $values { "quot" "a quotation ( -- )" } }
{ $description "calls the given quotation using HTML entity values" }
{ $see-also html-entities with-entities } ;
