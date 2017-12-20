#lang racket
(eval-top-level(top-level '(case (+ 7 5)
   [(1 2 3) 'a 'small]
   [(10 11 12) 'c 'big])))

(eval-top-level(top-level '(case (+ 7 10)
   [(1 2 3) 'a 'small]
   [(10 11 12) 'c 'big]
   [else 'd 'else])))

(eval-top-level(top-level
                '(begin (define (x y)
                          (display "hello")
                          (+ y 1))
                        (x 5))))