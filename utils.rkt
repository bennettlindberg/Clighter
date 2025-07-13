#lang racket

(require redex)
(provide (all-defined-out))

(define-syntax (stmts->seq+term stx)
  (syntax-case stx ()
    [(_ [elem])
     #'(term elem)]
    [(_ [first rest ...])
     #'(term (first ,(stmts->seq+term [rest ...])))]))

(define-syntax (test-judgment-not-hold stx)
  (syntax-case stx ()
    [(_ j)
     #'(with-handlers ([exn:fail? (λ (e) (void))]) (test-equal #f (judgment-holds j)))]))
