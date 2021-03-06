! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel quotations help.syntax help.markup
io.sockets strings calendar ;
IN: smtp

HELP: smtp-domain
{ $var-description "The name of the machine that is sending the email.  This variable will be filled in by the " { $link host-name } " word if not set by the user." } ;

HELP: smtp-server
{ $var-description "Holds an " { $link inet } " object with the address of an SMTP server." } ;

HELP: smtp-tls?
{ $var-description "If set to true, secure socket communication will be established after connecting to the SMTP server. The server must support the " { $snippet "STARTTLS" } " command. Off by default." } ;

HELP: smtp-read-timeout
{ $var-description "Holds a " { $link duration } " object that specifies how long to wait for a response from the SMTP server." } ;

HELP: smtp-auth
{ $var-description "Holds either " { $link no-auth } " or an instance of " { $link plain-auth } ", specifying how to authenticate with the SMTP server. Set to " { $link no-auth } " by default." } ;

HELP: no-auth
{ $class-description "If the " { $link smtp-auth } " variable is set to this value, no authentication will be performed." } ;

HELP: plain-auth
{ $class-description "If the " { $link smtp-auth } " variable is set to this value, plain authentication will be performed, with the username and password stored in the " { $slot "username" } " and " { $slot "password" } " slots of the tuple sent to the server as plain-text." } ;

HELP: <plain-auth>
{ $values { "username" string } { "password" string } { "plain-auth" plain-auth } }
{ $description "Creates a new " { $link plain-auth } " instance." } ;

HELP: with-smtp-connection
{ $values { "quot" quotation } }
{ $description "Connects to an SMTP server stored in " { $link smtp-server } " and calls the quotation." }
{ $notes "This word is used to implement " { $link send-email } " and there is probably no reason to call it directly." } ;

HELP: email
{ $class-description "An e-mail. E-mails have the following slots:"
    { $table
        { { $slot "from" } "The sender of the e-mail. An e-mail address." }
        { { $slot "to" } "The recipients of the e-mail. A sequence of e-mail addresses." }
        { { $slot "cc" } "Carbon-copy. A sequence of e-mail addresses." }
        { { $slot "bcc" } "Blind carbon-copy. A sequence of e-mail addresses." }
        { { $slot "subject" } " The subject of the e-mail. A string." }
        { { $slot "body" } " The body of the e-mail. A string." }
    }
"The " { $slot "from" } " and " { $slot "to" } " slots are required; the rest are optional."
$nl
"An e-mail address is a string in one of the following two formats:"
{ $list
    { $snippet "joe@groff.com" }
    { $snippet "Joe Groff <joe@groff.com>" }
} } ;

HELP: <email>
{ $values { "email" email } }
{ $description "Creates an empty " { $link email } " object." } ;

HELP: send-email
{ $values { "email" email } }
{ $description "Sends an e-mail." }
{ $examples
    { $code "USING: accessors smtp ;"
    "<email>"
    "    \"groucho@marx.bros\" >>from"
    "    { \"chico@marx.bros\" \"harpo@marx.bros\" } >>to"
    "    { \"gummo@marx.bros\" } >>cc"
    "    { \"zeppo@marx.bros\" } >>bcc"
    "    \"Pickup line\" >>subject"
    "    \"If I said you had a beautiful body, would you hold it against me?\" >>body"
    "send-email"
    ""
    }
} ;

ARTICLE: "smtp" "SMTP client library"
"The " { $vocab-link "smtp" } " vocabulary sends e-mail via an SMTP server."
$nl
"This library is configured by a set of dynamically-scoped variables:"
{ $subsection smtp-server }
{ $subsection smtp-tls? }
{ $subsection smtp-read-timeout }
{ $subsection smtp-domain }
{ $subsection smtp-auth }
"The latter is set to an instance of one of the following:"
{ $subsection no-auth }
{ $subsection plain-auth }
"Constructing an e-mail:"
{ $subsection email }
{ $subsection <email> }
"Sending an email:"
{ $subsection send-email } ;

ABOUT: "smtp"
