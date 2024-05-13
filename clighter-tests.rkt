#lang racket

(require redex)
(require "./clighter.rkt")

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