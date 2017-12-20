(let ([ff (lambda (ff) (lambda (a b c d e f g h i j)
                       (if (= '0 a)
                           b
                           ((ff ff) (- a '1) c d e f g h i j b))))])
  ((ff ff) '250 '17 '13 '22 '11 '17 '90 '88 '7 '6))
