#lang racket

(require redex)
(require "./clighter.rkt")
(require rackunit)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST LANGUAGE SYNTAX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
; n
(test-match Clighter n (term 0))
(test-match Clighter n (term 3))
(test-match Clighter n (term -1))

; id
(test-match Clighter id (term u))
(test-match Clighter id (term var))

; τ
(test-match Clighter τ (term int))
(test-match Clighter τ (term void))
(test-match Clighter τ (term (array int 6)))
(test-match Clighter τ (term (array (pointer int) 100)))
(test-match Clighter τ (term (pointer (array int 10))))
(test-match Clighter τ (term (struct abc)))
(test-match Clighter τ (term (struct xyz (var1 int) (var2 (pointer int)))))
(test-match Clighter τ (term (union abc)))
(test-match Clighter τ (term (union xyz (var1 int) (var2 (pointer int)))))

; φ
(test-match Clighter φ (term (hi int)))
(test-match Clighter φ (term (bye (struct o (var int)))))

; a
(test-match Clighter a (term myVar))
(test-match Clighter a (term 0))
(test-match Clighter a (term (sizeof (h int))))
(test-match Clighter a (term (sizeof (o (pointer void)))))
(test-match Clighter a (term (- (8 int))))
(test-match Clighter a (term (~ (o (pointer void)))))
(test-match Clighter a (term (<= (100 int) (j void))))
(test-match Clighter a (term (\| (o (pointer void)) (7 (union temp (w int) (x int) (y void))))))
(test-match Clighter a (term (* (h int))))
(test-match Clighter a (term (* (o (pointer void)))))
(test-match Clighter a (term (@ (h (struct abc (y int))) y)))
(test-match Clighter a (term (@ (var (union xyz (i int) (j void))) j)))
(test-match Clighter a (term (& (h int))))
(test-match Clighter a (term (& (o (pointer void)))))
(test-match Clighter a (term (? ((== (5 int) (10 int)) void) (xyz (array int 10)) (hjk void))))

; uop
(test-match Clighter uop (term -))
(test-match Clighter uop (term ~))
(test-match Clighter uop (term !))

; bop
(test-match Clighter bop (term +))
(test-match Clighter bop (term -))
(test-match Clighter bop (term *))
(test-match Clighter bop (term /))
(test-match Clighter bop (term %))
(test-match Clighter bop (term <<))
(test-match Clighter bop (term >>))
(test-match Clighter bop (term &))
(test-match Clighter bop (term \|))
(test-match Clighter bop (term ^))
(test-match Clighter bop (term <))
(test-match Clighter bop (term <=))
(test-match Clighter bop (term >))
(test-match Clighter bop (term >=))
(test-match Clighter bop (term ==))
(test-match Clighter bop (term !=))

; s
(test-match Clighter s (term skip))
(test-match Clighter s (term (= (h int) (100 int))))
(test-match Clighter s (term (= (arr (array int 10)) (pntr (pointer (union abc))))))
(test-match Clighter s (term (skip skip)))
(test-match Clighter s (term (break continue)))
(test-match Clighter s (term ((= (h int) (100 int)) return)))
(test-match Clighter s (term ((= (h int) (100 int)) (= (arr (array int 10)) (pntr (pointer (union abc)))))))
(test-match Clighter s (term (if (10 int) continue break)))
(test-match Clighter s (term (if ((* (p (pointer int))) int) (return (8 int)) (return (9 int)))))
(test-match Clighter s (term (while (1 int) (= (h int) (100 int)))))
(test-match Clighter s (term (while ((> (aaa int) (bbb int)) (pointer void)) ((= (arr (array int 10)) (pntr (pointer (union abc)))) continue))))
(test-match Clighter s (term (for skip (1 int) (= (h int) (100 int)) skip)))
(test-match Clighter s (term (for (= (h int) (100 int)) ((> (aaa int) (bbb int)) (pointer void)) ((= (arr (array int 10)) (pntr (pointer (union abc)))) continue) (= (h int) ((+ (1 int) (100 int)) int)))))
(test-match Clighter s (term break))
(test-match Clighter s (term continue))
(test-match Clighter s (term return))
(test-match Clighter s (term (return (8 int))))
(test-match Clighter s (term (return (iii (array (struct abc (x int)) 60)))))

; dcl
(test-match Clighter dcl (term (int aaa)))
(test-match Clighter dcl (term ((struct abc (x int) (y int)) bbb)))
(test-match Clighter dcl (term ((array int 700) eee)))

; P
(test-match Clighter P (term (skip)))
(test-match Clighter P (term ((return (100 int)))))
(test-match Clighter P (term ((int aaa) (void bbb) (return (100 int)))))
(test-match Clighter P (term (((union aaa (aa int) (bb (pointer int))) ccc) (int bbb) (skip (break (return (100 int)))))))

; b
(test-match Clighter b (term 10))
(test-match Clighter b (term 0))
(test-match Clighter b (term 5))

; δ
(test-match Clighter δ (term 10))
(test-match Clighter δ (term 0))
(test-match Clighter δ (term 5))

; l
(test-match Clighter l (term (6 100)))
(test-match Clighter l (term (0 0)))
(test-match Clighter l (term (10 2)))

; v
(test-match Clighter v (term (int 10)))
(test-match Clighter v (term (int 0)))
(test-match Clighter v (term (int -20)))
(test-match Clighter v (term (ptr (0 0))))
(test-match Clighter v (term (ptr (1 4))))
(test-match Clighter v (term undef))

; out
(test-match Clighter out (term Normal))
(test-match Clighter out (term Continue))
(test-match Clighter out (term Break))
(test-match Clighter out (term Return))
(test-match Clighter out (term (Return undef)))
(test-match Clighter out (term (Return (int 100))))
(test-match Clighter out (term (Return (ptr (0 2)))))

; id↦b
(test-match Clighter id↦b (term (aaa 10)))
(test-match Clighter id↦b (term (xyz 0)))
(test-match Clighter id↦b (term (var 68)))

; G
(test-match Clighter G (term ()))
(test-match Clighter G (term ((xyz 10))))
(test-match Clighter G (term ((a1 0) (a2 1) (a3 2))))

; δ↦v
(test-match Clighter δ↦v (term (0 (ptr (0 0)))))
(test-match Clighter δ↦v (term (10 (int 0))))
(test-match Clighter δ↦v (term (23 undef)))

; b↦δ↦v
(test-match Clighter b↦δ↦v (term (0)))
(test-match Clighter b↦δ↦v (term (0 (0 (ptr (0 0))))))
(test-match Clighter b↦δ↦v (term (4 (23 undef) (43 undef) (0 (ptr (0 0))))))

; M
(test-match Clighter M (term ()))
(test-match Clighter M (term ((0) (1) (2))))
(test-match Clighter M (term ((4 (23 undef) (43 undef) (0 (ptr (0 0)))) (6 (4 (int 10)) (0 (ptr (0 0)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST HELPER META-FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; size-of




; field-offset




; get-next-block




; init-struct-fields




; init-array




; init




; get-G
(test-equal?
 "get-G"
 (term (get-G (() ())))
 (term ()))
(test-equal?
 "get-G"
 (term (get-G (((aaa 0) (bbb 1)) ((0 (0 (int 1))) (1 (0 (int 1)))))))
 (term ((aaa 0) (bbb 1))))

; get-M
(test-equal?
 "get-M"
 (term (get-M (() ())))
 (term ()))
(test-equal?
 "get-M"
 (term (get-M (((aaa 0) (bbb 1)) ((0 (0 (int 1))) (1 (0 (int 1)))))))
 (term ((0 (0 (int 1))) (1 (0 (int 1))))))

; loadval




; storeval
(test-equal?
 "storeval int at valid location"
 (term (storeval int ((0 (0 (int 1)))
                      (0 (0 (int 2)))
                      (1 (0 (int 3)))
                      (1 (1 (int 4)))
                      (1 (2 (int 5))))
                 (1 1) (int 6)))
 (term ((0 (0 (int 1)))
        (0 (0 (int 2)))
        (1 (0 (int 3)))
        (1 (1 (int 6)))
        (1 (2 (int 5))))))
(test-equal?
 "storeval int at valid location"
 (term (storeval int ((0 (0 (int 1)))
                      (1 (0 (int 2)))
                      (2 (0 (int 3)))
                      (2 (1 (int 4)))
                      (4 (2 (int 5))))
                 (4 2) (int 46)))
 (term ((0 (0 (int 1)))
        (1 (0 (int 2)))
        (2 (0 (int 3)))
        (2 (1 (int 4)))
        (4 (2 (int 46))))))
(test-equal?
 "storeval pointer at valid location"
 (term (storeval (pointer int) ((2 (0 (int 1)))
                                (1 (0 (int 2)))
                                (4 (0 (int 3)))
                                (2 (1 (int 4)))
                                (4 (2 (int 5))))
                 (2 1) (ptr (4 0))))
 (term ((2 (0 (int 1)))
        (1 (0 (int 2)))
        (4 (0 (int 3)))
        (2 (1 (ptr (4 0))))
        (4 (2 (int 5))))))
(test-exn
 "storeval wrong type"
 exn:fail?
 (λ () (term (storeval void ((2 (0 (int 1)))
                             (1 (0 (int 2)))
                             (4 (0 (int 3)))
                             (2 (1 (int 4)))
                             (4 (2 (int 5))))
                       (2 1) undef))))
(test-exn
 "storeval wrong type"
 exn:fail?
 (λ () (term (storeval (array int 50) ((0 (0 (int 1)))
                                       (0 (0 (int 2)))
                                       (1 (0 (int 3)))
                                       (1 (1 (int 4)))
                                       (1 (2 (int 5))))
                       (1 1) (int 6)))))
(test-exn
 "storeval wrong type"
 exn:fail?
 (λ () (term (storeval (union xyz) ((0 (0 (int 1)))
                                    (1 (0 (int 2)))
                                    (2 (0 (int 3)))
                                    (2 (1 (int 4)))
                                    (4 (2 (int 5))))
                       (4 2) undef))))

; eval-unop
(test-equal?
 "eval-unop integer value negation"
 (term (eval-unop - (int 10) int))
 (term (int -10)))
(test-equal?
 "eval-unop integer value negation"
 (term (eval-unop - (int -233) int))
 (term (int 233)))
(test-equal?
 "eval-unop integer value negation"
 (term (eval-unop - (int 0) int))
 (term (int 0)))
(test-equal?
 "eval-unop integer bitwise not"
 (term (eval-unop ~ (int 5) int))
 (term (int -6)))
(test-equal?
 "eval-unop integer logical negation"
 (term (eval-unop ! (int 0) int))
 (term (int 1)))
(test-equal?
 "eval-unop integer logical negation"
 (term (eval-unop ! (int 100) int))
 (term (int 0)))
(test-exn
 "eval-unop wrong type"
 exn:fail?
 (λ () (term (eval-unop ! (ptr (0 0)) (pointer int)))))
(test-exn
 "eval-unop wrong type"
 exn:fail?
 (λ () (term (eval-unop ~ undef (array int 50)))))

; eval-binop
(test-equal?
 "eval-binop integer addition"
 (term (eval-binop + (int 10) int (int 11) int))
 (term (int 21)))
(test-equal?
 "eval-binop integer addition"
 (term (eval-binop + (int -4) int (int 1) int))
 (term (int -3)))
(test-equal?
 "eval-binop integer subtraction"
 (term (eval-binop - (int 10) int (int 11) int))
 (term (int -1)))
(test-equal?
 "eval-binop integer subtraction"
 (term (eval-binop - (int 67) int (int 200) int))
 (term (int -133)))
(test-equal?
 "eval-binop integer multiplication"
 (term (eval-binop * (int 10) int (int 11) int))
 (term (int 110)))
(test-equal?
 "eval-binop integer multiplication"
 (term (eval-binop * (int -6) int (int -5) int))
 (term (int 30)))
(test-equal?
 "eval-binop integer division"
 (term (eval-binop / (int 10) int (int 1) int))
 (term (int 10)))
(test-equal?
 "eval-binop integer division"
 (term (eval-binop / (int 10) int (int 7) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer modulus"
 (term (eval-binop % (int 10) int (int 7) int))
 (term (int 3)))
(test-equal?
 "eval-binop integer modulus"
 (term (eval-binop % (int 30) int (int 29) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer modulus"
 (term (eval-binop % (int 30) int (int 29) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer left shift"
 (term (eval-binop << (int 1) int (int 1) int))
 (term (int 2)))
(test-equal?
 "eval-binop integer left shift"
 (term (eval-binop << (int 3) int (int 2) int))
 (term (int 12)))
(test-equal?
 "eval-binop integer right shift"
 (term (eval-binop >> (int 2) int (int 1) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer right shift"
 (term (eval-binop >> (int 8) int (int 2) int))
 (term (int 2)))
(test-equal?
 "eval-binop integer bitwise and"
 (term (eval-binop & (int 4) int (int 5) int))
 (term (int 4)))
(test-equal?
 "eval-binop integer bitwise and"
 (term (eval-binop & (int 10) int (int 60) int))
 (term (int 8)))
(test-equal?
 "eval-binop integer bitwise or"
 (term (eval-binop \| (int 4) int (int 5) int))
 (term (int 5)))
(test-equal?
 "eval-binop integer bitwise or"
 (term (eval-binop \| (int 10) int (int 60) int))
 (term (int 62)))
(test-equal?
 "eval-binop integer bitwise xor"
 (term (eval-binop ^ (int 4) int (int 5) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer bitwise xor"
 (term (eval-binop ^ (int 10) int (int 60) int))
 (term (int 54)))
(test-equal?
 "eval-binop integer relational lt"
 (term (eval-binop < (int 10) int (int 60) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational lt"
 (term (eval-binop < (int 10) int (int -3) int))
 (term (int 0)))
(test-equal?
 "eval-binop integer relational lte"
 (term (eval-binop <= (int 60) int (int 60) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational lte"
 (term (eval-binop <= (int 10) int (int -3) int))
 (term (int 0)))
(test-equal?
 "eval-binop integer relational gt"
 (term (eval-binop > (int 10) int (int 60) int))
 (term (int 0)))
(test-equal?
 "eval-binop integer relational gt"
 (term (eval-binop > (int -3) int (int -3) int))
 (term (int 0)))
(test-equal?
 "eval-binop integer relational gt"
 (term (eval-binop > (int 0) int (int -3) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational gte"
 (term (eval-binop >= (int 60) int (int 60) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational gte"
 (term (eval-binop >= (int 10) int (int -3) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational gte"
 (term (eval-binop >= (int -100) int (int -3) int))
 (term (int 0)))
(test-equal?
 "eval-binop integer relational eq"
 (term (eval-binop == (int -100) int (int -3) int))
 (term (int 0)))
(test-equal?
 "eval-binop integer relational eq"
 (term (eval-binop == (int 10) int (int 10) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational neq"
 (term (eval-binop != (int -100) int (int -3) int))
 (term (int 1)))
(test-equal?
 "eval-binop integer relational neq"
 (term (eval-binop != (int 10) int (int 10) int))
 (term (int 0)))
(test-equal?
 "eval-binop pointer arithmetic addition"
 (term (eval-binop + (ptr (0 0)) (pointer int) (int 10) int))
 (term (ptr (0 10))))
(test-equal?
 "eval-binop pointer arithmetic addition"
 (term (eval-binop + (ptr (3 8)) (pointer int) (int 90) int))
 (term (ptr (3 98))))
(test-equal?
 "eval-binop pointer arithmetic subtraction"
 (term (eval-binop - (ptr (0 11)) (pointer int) (int 10) int))
 (term (ptr (0 1))))
(test-equal?
 "eval-binop pointer arithmetic subtraction"
 (term (eval-binop - (ptr (3 8)) (pointer int) (int 3) int))
 (term (ptr (3 5))))
(test-exn
 "eval-binop wrong type"
 exn:fail?
 (λ () (term (eval-binop - (ptr (3 8)) (pointer int) (ptr (3 8)) (pointer int)))))
(test-exn
 "eval-binop wrong type"
 exn:fail?
 (λ () (term (eval-binop + (int 100) int (ptr (3 8)) (pointer int)))))
(test-exn
 "eval-binop wrong type"
 exn:fail?
 (λ () (term (eval-binop <= (struct aaa (abc int)) (ptr (3 8)) (pointer int)))))

; is-true
(test-equal?
 "is-true pointer"
 (term (is-true (ptr (0 4)) (pointer int)))
 #true)
(test-equal?
 "is-true pointer"
 (term (is-true (ptr (12 0)) (pointer (array int 6))))
 #true)
(test-equal?
 "is-true non-zero int"
 (term (is-true (int 100) int))
 #true)
(test-equal?
 "is-true non-zero int"
 (term (is-true (int 3) int))
 #true)
(test-equal?
 "is-true zero int"
 (term (is-true (int 0) int))
 #false)

; is-false
(test-equal?
 "is-false pointer"
 (term (is-false (ptr (0 4)) (pointer int)))
 #false)
(test-equal?
 "is-false pointer"
 (term (is-false (ptr (12 0)) (pointer (array int 6))))
 #false)
(test-equal?
 "is-false non-zero int"
 (term (is-false (int 100) int))
 #false)
(test-equal?
 "is-false non-zero int"
 (term (is-false (int 3) int))
 #false)
(test-equal?
 "is-false zero int"
 (term (is-false (int 0) int))
 #true)

; loop-exit-out-update
(test-equal?
 "loop-exit-out-update Break->Normal"
 (term (loop-exit-out-update Break))
 (term Normal))
(test-equal?
 "loop-exit-out-update Return->Return"
 (term (loop-exit-out-update Return))
 (term Return))
(test-equal?
 "loop-exit-out-update (Return v)->(Return v)"
 (term (loop-exit-out-update (Return undef)))
 (term (Return undef)))
(test-exn
 "loop-exit-out-update error case"
 exn:fail?
 (λ () (term (loop-exit-out-update Continue))))
(test-exn
 "loop-exit-out-update error case"
 exn:fail?
 (λ () (term (loop-exit-out-update Normal))))

; is-not-normal?
(test-equal?
 "is-not-normal? non-Normal"
 (term (is-not-normal? Continue))
 #true)
(test-equal?
 "is-not-normal? non-Normal"
 (term (is-not-normal? Return))
 #true)
(test-equal?
 "is-not-normal? non-Normal"
 (term (is-not-normal? (Return (int 50))))
 #true)
(test-equal?
 "is-not-normal? Normal"
 (term (is-not-normal? Normal))
 #false)

; is-not-skip?
(test-equal?
 "is-not-skip? non-skip"
 (term (is-not-skip? break))
 #true)
(test-equal?
 "is-not-skip? non-skip"
 (term (is-not-skip? (continue break)))
 #true)
(test-equal?
 "is-not-skip? non-skip"
 (term (is-not-skip? (= (iii int) ((* (jjj (pointer int))) int))))
 #true)
(test-equal?
 "is-not-skip? skip"
 (term (is-not-skip? skip))
 #false)

; convert-out-to-return
(test-equal?
 "convert-out-to-return non-(Return v)"
 (term (convert-out-to-return Normal))
 (term undef))
(test-equal?
 "convert-out-to-return non-(Return v)"
 (term (convert-out-to-return Return))
 (term undef))
(test-equal?
 "convert-out-to-return (Return v)"
 (term (convert-out-to-return (Return (ptr (0 1)))))
 (term (ptr (0 1))))
(test-equal?
 "convert-out-to-return (Return v)"
 (term (convert-out-to-return (Return (int 90))))
 (term (int 90)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST BIG-STEP REDUCTION RULES ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;