
USING: kernel io io.files io.launcher io.sockets hashtables math threads
       system continuations namespaces sequences splitting math.parser
       prettyprint tools.time calendar bake vars http.client
       combinators bootstrap.image bootstrap.image.download
       combinators.cleave ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: log-runtime ( quot file -- )
  >r runtime r> <file-writer> [ . ] with-stream ;

: log-object ( object file -- ) <file-writer> [ . ] with-stream ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: datestamp ( -- string )
  now `{ ,[ dup timestamp-year   ]
         ,[ dup timestamp-month  ]
         ,[ dup timestamp-day    ]
         ,[ dup timestamp-hour   ]
         ,[     timestamp-minute ] }
  [ pad-00 ] map "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builder-recipients

: host-name* ( -- name ) host-name "." split first ;

: tag-subject ( str -- str ) `{ "builder@" ,[ host-name* ] ": " , } concat ;

: email-string ( subject -- )
  `{ "mutt" "-s" ,[ tag-subject ] %[ builder-recipients get ] }
  [ ] with-process-stream drop ;

: email-file ( subject file -- )
  `{
    { +stdin+ , }
    { +arguments+
      { "mutt" "-s" ,[ tag-subject ] %[ builder-recipients get ] } }
  }
  >hashtable run-process drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run-or-notify ( desc message -- )
  [ [ try-process ]        curry ]
  [ [ email-string throw ] curry ]
  bi*
  recover ;

: run-or-send-file ( desc message file -- )
  >r >r [ try-process ]         curry
  r> r> [ email-file throw ] 2curry
  recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: target ( -- target ) `{ ,[ os ] %[ cpu "." split ] } "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: factor-binary ( -- name )
  os
  { { "macosx" [ "./Factor.app/Contents/MacOS/factor" ] }
    { "winnt" [ "./factor-nt.exe" ] }
    [ drop "./factor" ] }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: stamp

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-pull ( -- desc )
  {
    "git"
    "pull"
    "--no-summary"
    "git://factorcode.org/git/factor.git"
    "master"
  } ;

: git-clone ( -- desc ) { "git" "clone" "../factor" } ;

: enter-build-dir ( -- )
  datestamp >stamp
  "/builds" cd
  stamp> make-directory
  stamp> cd ;

: git-id ( -- id )
  { "git" "show" } <process-stream> [ readln ] with-stream " " split second ;

: record-git-id ( -- ) git-id "../git-id" log-object ;

: make-clean ( -- desc ) { "make" "clean" } ;

: make-vm ( -- )
  `{
     { +arguments+ { "make" ,[ target ] } }
     { +stdout+    "../compile-log" }
     { +stderr+    +stdout+ }
   }
  >hashtable ;

: retrieve-boot-image ( -- )
  [ my-arch download-image ]
  [ ]
  [ "builder: image download" email-string ]
  cleanup
  flush ;

: bootstrap ( -- desc )
  `{
     { +arguments+ {
                     ,[ factor-binary ]
                     ,[ "-i=" my-boot-image-name append ]
                     "-no-user-init"
                   } }
     { +stdout+   "../boot-log" }
     { +stderr+   +stdout+ }
   }
  >hashtable ;

: builder-test ( -- desc ) `{ ,[ factor-binary ] "-run=builder.test" } ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: build-status

: build ( -- )

  enter-build-dir
  
  git-clone "git clone error" run-or-notify

  "factor" cd

  record-git-id

  make-clean "make clean error" run-or-notify

  make-vm "vm compile error" "../compile-log" run-or-send-file

  retrieve-boot-image

  bootstrap "bootstrap error" "../boot-log" run-or-send-file

  builder-test "builder.test fatal error" run-or-notify
  
  "../load-everything-log" exists?
  [ "load-everything" "../load-everything-log" email-file ]
  when

  "../failing-tests" exists?
  [ "failing tests" "../failing-tests" email-file ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: minutes>ms ( min -- ms ) 60 * 1000 * ;

: updates-available? ( -- ? )
  git-id
  git-pull run-process drop
  git-id
  = not ;

: build-loop ( -- )
  [
    "/builds/factor" cd
    updates-available?
      [ build ]
    when
  ]
  [ drop ]
  recover
  5 minutes>ms sleep
  build-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build-loop