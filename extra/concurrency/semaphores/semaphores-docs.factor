IN: concurrency.semaphores
USING: help.markup help.syntax kernel quotations ;

HELP: semaphore
{ $class-description "The class of counting semaphores." } ;

HELP: <semaphore>
{ $values { "n" "a non-negative integer" } { "semaphore" semaphore } }
{ $description "Creates a counting semaphore with the specified initial count." } ;

HELP: acquire
{ $values { "semaphore" semaphore } { "timeout" "a timeout in milliseconds or " { $link f } } { "value" object } }
{ $description "If the semaphore has a non-zero count, decrements it and returns immediately. Otherwise, if the timeout is " { $link f } ", waits indefinitely for the semaphore to be released. If the timeout is not " { $link f } ", waits up to that number of milliseconds for the semaphore to be released." } ;

HELP: release
{ $values { "semaphore" semaphore } }
{ $description "Increments a semaphore's count. If the count was previously zero, any threads waiting on the semaphore are woken up." } ;

HELP: with-semaphore
{ $values { "semaphore" semaphore } { "quot" quotation } }
{ $description "Calls the quotation with the semaphore held." } ;

ARTICLE: "concurrency.semaphores" "Counting semaphores"
"Counting semaphores are used to ensure that no more than a fixed number of threads are executing in a critical section at a time; as such, they generalize " { $link "concurrency.locks.mutex" } ", since locks can be thought of as semaphores with an initial count of 1."
$nl
"A use-case would be a batch processing server which runs a large number of jobs which perform calculations but then need to fire off expensive external processes or perform heavy network I/O. While for most of the time, the threads can all run in parallel, it might be desired that the expensive operation is not run by more than 10 threads at once, to avoid thrashing swap space or saturating the network. This can be accomplished with a counting semaphore:"
{ $code
    "SYMBOL: expensive-section"
    "10 <semaphore> expensive-section set-global"
    "requests ["
    "    ..."
    "    expensive-section [ do-expensive-stuff ] with-semaphore"
    "    ..."
    "] parallel-map"
}
"Creating semaphores:"
{ $subsection semaphore }
{ $subsection <semaphore> }
"Unlike locks, where acquisition and release are always paired by a combinator, semaphores expose these operations directly and there is no requirement that they be performed in the same thread:"
{ $subsection acquire }
{ $subsection release }
"A combinator which pairs acquisition and release:"
{ $subsection with-semaphore } ;

ABOUT: "concurrency.semaphores"