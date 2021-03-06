
USING: kernel fry sequences
       vocabs.loader tools.vocabs.browser
       ui ui.gadgets ui.gadgets.buttons ui.gadgets.packs ui.gadgets.scrollers
       ui.tools.listener
       accessors ;

IN: demos

: demo-vocabs ( -- seq ) "demos" tagged [ second ] map concat [ name>> ] map ;

: <run-vocab-button> ( vocab-name -- button )
  dup '[ drop [ _ run ] call-listener ] <bevel-button> { 0 0 } >>align ;

: <demo-runner> ( -- gadget )
  <pile> 1 >>fill demo-vocabs [ <run-vocab-button> add-gadget ] each ;

: demos ( -- ) [ <demo-runner> <scroller> "Demos" open-window ] with-ui ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: demos