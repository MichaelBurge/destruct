#lang racket

(provide destruct)

(require (for-syntax racket/syntax))
(require (for-syntax racket/list))
(require (for-syntax racket/struct-info))

(define-syntax (destruct stx)
  (syntax-case stx ()
    [(_ ty id)
     (let* ([ si             (extract-struct-info (syntax-local-value #'ty))]
            [ accessors      (reverse (fourth si ))]
            [ accessor->name (λ (acc) (with-syntax ([ acc acc ])
                                        (format-id stx "~a~a" #'id (strip-prefix #'ty #'acc))))]
            [ names          (map accessor->name accessors)]
            [ make-def       (λ (name acc)
                               (with-syntax ([ acc (datum->syntax stx acc)]
                                             [ name name ])
                                 #`(define name (acc id))))]
            [ defs           (map make-def names accessors)])
       #`(begin #,@defs))]))

(begin-for-syntax
  (define (strip-prefix prefix name)
    (string->symbol
     (substring (symbol->string (syntax->datum name))
                (string-length (symbol->string (syntax->datum prefix)))))))


(module+ test
  (require rackunit)

  (struct some-very-long-name-that-i-dont-want-to-type (foo bar baz))
  (define (test-foo qux)
    (destruct some-very-long-name-that-i-dont-want-to-type qux)
    (list qux-foo qux-bar qux-baz)
    )
  (define qux (some-very-long-name-that-i-dont-want-to-type 10 20 30))
  (check-equal?
   (test-foo qux)
   (list (some-very-long-name-that-i-dont-want-to-type-foo qux)
         (some-very-long-name-that-i-dont-want-to-type-bar qux)
         (some-very-long-name-that-i-dont-want-to-type-baz qux)
         )
   )
  (struct fruit (name calories color))

  (define banana (fruit "banana" 105 'yellow))
  (define apple (fruit "apple" 95 'red))
  ;; There is an IMPORT TAX for fattening fruits, fruits with long names, or fruits that confuse people with bright colors
  (define (bright? color) (equal? color 'yellow))
  (define (long? name) (> (string-length name) 5))
  (define (has-fruit-tariff1? fruit)
    (or (> (fruit-calories fruit) 100)
        (bright? (fruit-color fruit))
        (> (string-length (fruit-name fruit)) 5)
        ))
  
  (define (has-fruit-tariff2? f)
    (destruct fruit f)
    (or (> f-calories 100)
        (bright? f-name)
        (> (string-length f-name) 5)
        ))
  (for ([fruit (list banana apple)])
    (check-equal? (has-fruit-tariff1? fruit)
                  (has-fruit-tariff2? fruit)
                  ))
  )

