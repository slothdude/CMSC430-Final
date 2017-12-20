need to test from top level to llvm, need to go through top level,
desugar/simplify ir, anf convert, cps convert, closure convert, llvm something

compare result of eval llvm to eval top level
write tests that use clang so probably need assignment 4 tests.rkt , model after
assignment 5 one and somehow convert

tests.rkt
test-top-level compares eval-top level on input to eval-top-level on output of top level function
test-desugar does
(if eq? (eval-scheme scheme-prog) (eval-ir(simplify-ir (desugar scheme-prog))))
