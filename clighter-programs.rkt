#lang racket

(require redex)
(require "clighter.rkt")
(require "utils.rkt")

;;;;;;;;;;;;
;; TRACES ;;
;;;;;;;;;;;;

#| Collatz Conjecture |#
;; (traces run (term ((int start)
;;                    (int count)
;;                    ,(stmts->seq+term [
;;                                       (= (start int) (19 int))
;;                                       (= (count int) (0 int))
;;                                       (while ((!= (start int) (1 int)) int)
;;                                              ,(stmts->seq+term [
;;                                                                 (= (count int) ((+ (1 int) (count int)) int))
;;                                                                 (if ((== (1 int) ((% (start int) (2 int)) int)) int)
;;                                                                     (= (start int) ((+ (1 int) ((* (3 int) (start int)) int)) int))
;;                                                                     (= (start int) ((/ (start int) (2 int)) int)))
;;                                                                 ]))
;;                                       (return (count int))
;;                                       ]))))

#| Maximum Array Element |#
;; (traces run (term ((int max)
;;                    (int i)
;;                    (int j)
;;                    ((array (array int 3) 3) arr)
;;                    ((pointer int) arrij)
;;                    ,(stmts->seq+term [
;;                                       (= (max int) (-1 int))
;;                                       (= (arrij (pointer int)) ((& (arr (array (array int 3) 3))) (pointer int)))
;;                                       ; initialize array
;;                                       (for (= (i int) (0 int))
;;                                         ((< (i int) (3 int)) int)
;;                                         (= (i int) ((+ (i int) (1 int)) int))
;;                                         (for (= (j int) (0 int))
;;                                           ((< (j int) (3 int)) int)
;;                                           (= (j int) ((+ (j int) (1 int)) int))
;;                                           (= ((* ((+ (arrij (pointer int)) ((+ (j int) ((* (i int) (3 int)) int)) int)) (pointer int))) int)
;;                                              ((* (i int) (j int)) int))))
;;                                       ; find maximum
;;                                       (for (= (i int) (0 int))
;;                                         ((< (i int) (3 int)) int)
;;                                         (= (i int) ((+ (i int) (1 int)) int))
;;                                         (for (= (j int) (0 int))
;;                                           ((< (j int) (3 int)) int)
;;                                           (= (j int) ((+ (j int) (1 int)) int))
;;                                           (if ((> ((* ((+ (arrij (pointer int)) ((+ (j int) ((* (i int) (3 int)) int)) int)) (pointer int))) int) (max int)) int)
;;                                               (= (max int)
;;                                                  ((* ((+ (arrij (pointer int)) ((+ (j int) ((* (i int) (3 int)) int)) int)) (pointer int))) int))
;;                                               skip)))
;;                                       (return (max int))]))))

#| Binary Search |#
;; (traces run (term ((int lo)
;;                      (int hi)
;;                      (int mi)
;;                      (int target)
;;                      ((array int 10) arr)
;;                      ((pointer int) arrp)
;;                      ,(stmts->seq+term [
;;                                         ; initialize array
;;                                         (= (arrp (pointer int)) ((& (arr (array int 10))) (pointer int)))
;;                                         (= ((* ((+ (arrp (pointer int)) (0 int)) (pointer int))) int) (20 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (1 int)) (pointer int))) int) (24 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (2 int)) (pointer int))) int) (50 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (3 int)) (pointer int))) int) (58 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (4 int)) (pointer int))) int) (95 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (5 int)) (pointer int))) int) (128 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (6 int)) (pointer int))) int) (572 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (7 int)) (pointer int))) int) (683 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (8 int)) (pointer int))) int) (934 int))
;;                                         (= ((* ((+ (arrp (pointer int)) (9 int)) (pointer int))) int) (1024 int))
;;                                         ; binsearch
;;                                         (= (target int) (1024 int))
;;                                         (= (lo int) (0 int))
;;                                         (= (hi int) ((- ((/ ((sizeof (arr (array int 10))) int) ((sizeof (target int)) int)) int) (1 int)) int))
;;                                         (while ((<= (lo int) (hi int)) int)
;;                                                ,(stmts->seq+term [
;;                                                                   (= (mi int) ((/ ((+ (lo int) (hi int)) int) (2 int)) int))
;;                                                                   (if ((< ((* ((+ (arrp (pointer int)) (mi int)) (pointer int))) int) (target int)) int)
;;                                                                       (= (lo int) ((+ (mi int) (1 int)) int))
;;                                                                       (if ((> ((* ((+ (arrp (pointer int)) (mi int)) (pointer int))) int) (target int)) int)
;;                                                                           (= (hi int) ((- (mi int) (1 int)) int))
;;                                                                           (return (mi int))))]))
;;                                         (return (-1 int))]))))

;;;;;;;;;;;;;;;;;
;; DERIVATIONS ;;
;;;;;;;;;;;;;;;;;

#| Simple Addition |#
;; (show-derivations (build-derivations (run ((int aaa)
;;                                            (int bbb)
;;                                            (((= (aaa int) (4 int))
;;                                              (= (bbb int) (5 int)))
;;                                             (return ((+ (aaa int) (bbb int)) int))))
;;                                           ((int 9)
;;                                            ((0 (0 (int 4))) (1 (0 (int 5))))))))

#| Collatz Conjecture |#
;; (show-derivations (build-derivations (run ((int start)
;;                                            (int count)
;;                                            ,(stmts->seq+term [
;;                                                               (= (start int) (2 int))
;;                                                               (= (count int) (0 int))
;;                                                               (while ((!= (start int) (1 int)) int)
;;                                                                      ,(stmts->seq+term [
;;                                                                                         (= (count int) ((+ (1 int) (count int)) int))
;;                                                                                         (if ((== (1 int) ((% (start int) (2 int)) int)) int)
;;                                                                                             (= (start int) ((+ (1 int) ((* (3 int) (start int)) int)) int))
;;                                                                                             (= (start int) ((/ (start int) (2 int)) int)))
;;                                                                                         ]))
;;                                                               (return (count int))
;;                                                               ]))
;;                                           ((int 1)
;;                                            ((0 (0 (int 1))) (1 (0 (int 1))))))))