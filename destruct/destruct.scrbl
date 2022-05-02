#lang scribble/manual

@title{Destruct}

@defmodule[destruct]
@defform[(destruct struct-name variable)]{
Introduces variables with names @racket[variable-field] for each field in the struct @racket[struct-name], initialized with the value @racket[(field-accessor variable)].
}


@section{Why would I use this?}

Structs package related values into a single one:

@racketblock[
(struct fruit (name calories color))

(define banana (fruit "banana" 105 'yellow))
(define apple (fruit "apple" 95 'red))
]

Then you can unpack those values later to use them:

@#reader scribble/comment-reader (racketblock
  ;; There is an IMPORT TAX for fattening fruits, fruits with long names, or fruits that confuse people with bright colors
  (define (bright? color) (equal? color 'yellow))
  (define (long? name) (> (string-length name) 5))
  (define (has-fruit-tariff1? fruit)
    (or (> (fruit-calories fruit) 100)
        (bright? (fruit-color fruit))
        (> (string-length (fruit-name fruit)) 5)
        ))
)

It works, but is redundant: The expression @racket[(fruit-calories fruit)] mentions "fruit" twice, and needs a wrapping pair of parentheses. Visually scanning for the second argument @racket[5] is more difficult because the expression is so long, but it's not worth the vertical space putting @racket[5] onto its own line.

Here's how it looks with destruct:

@racketblock[
  (define (has-fruit-tariff2? f)
    (destruct fruit f)
    (or (> f-calories 100)
        (bright? f-name)
        (> (string-length f-name) 5)
        ))
]

Now only one mention of @racket[fruit] is needed, instead of twice for each use of a field.

A match statement is an alternative:
@racketblock[
(define (has-fruit-tariff? f)
  (match f
    [(struct fruit (name calories color))
     (or (> calories 100)
         (bright? name)
         (> (string-length name) 5)
         )]))
]

We still have to mention the fields twice, but it's all-at-once on a single line. But if you had to bind many structs, your indentation would spiral out of control.

So @racket[destruct] lets you unpack those structs while:
@itemlist[@item{Adding zero indentation}
	  @item{Using O(1) parentheses instead of O(uses)}
	  @item{Mentioning the type O(1) times instead of O(uses)}
	  ]

Its downside is that it introduces variables like @racket[f-calories] that aren't explicitly defined in the code: The parameter @racket[f] and the field accessor @racket[calories] are defined, but not the local variable @racket[f-calories].
