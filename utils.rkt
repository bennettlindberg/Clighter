#lang racket

(provide (all-defined-out))
(require redex)

; (define (parse-statement-sequence list-of-stmts parsed-nested-stmts)
;   (if (empty? list-of-stmts)
;       parsed-nested-stmts
;       (parse-statement-sequence (rest list-of-stmts)
;                                 (term (,parsed-nested-stmts
;                                        ,(first list-of-stmts))))))

(define-syntax (stmts->seq+term stx)
  (syntax-case stx ()
    [(_ [elem])
     #'(term elem)]
    [(_ [first rest ...])
     #'(term (first ,(stmts->seq+term [rest ...])))]))
