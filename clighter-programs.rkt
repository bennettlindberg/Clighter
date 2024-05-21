#lang racket

(require redex)
(require "./clighter.rkt")
(require rackunit)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

; (show-derivations (build-derivations ...))

(define (parse-statement-sequence list-of-stmts parsed-nested-stmts)
  (if (empty? list-of-stmts)
      parsed-nested-stmts
      (parse-statement-sequence (rest list-of-stmts)
                                (term (,parsed-nested-stmts
                                       ,(first list-of-stmts))))))