USING: sorting.human tools.test ;
IN: sorting.human.tests

\ human-sort must-infer

[ { "x1y" "x2" "x10y" } ] [ { "x1y" "x10y" "x2" } human-sort ] unit-test
