#lang racket

(require redex)
(require "clighter.rkt")
(require "utils.rkt")
(require rackunit)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST LANGUAGE SYNTAX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
; n
(test-match Clighter n (term 0))
(test-match Clighter n (term 3))
(test-match Clighter n (term -1))
(test-no-match Clighter n (term 10.0))

; id
(test-match Clighter id (term u))
(test-match Clighter id (term var))
(test-no-match Clighter id (term 10))
(test-no-match Clighter id (term void))

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
(test-no-match Clighter τ (term (union IntOptional (void none) (int some))))

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
(test-match Clighter a (term (¦ (o (pointer void)) (7 (union temp (w int) (x int) (y void))))))
(test-match Clighter a (term (* (h int))))
(test-match Clighter a (term (* (o (pointer void)))))
(test-match Clighter a (term (@ (h (struct abc (y int))) y)))
(test-match Clighter a (term (@ (var (union xyz (i int) (j void))) j)))
(test-match Clighter a (term (& (h int))))
(test-match Clighter a (term (& (o (pointer void)))))
(test-match Clighter a (term (? ((== (5 int) (10 int)) void) (xyz (array int 10)) (hjk void))))

; a+τ
(test-match Clighter a+τ (term (id int)))
(test-match Clighter a+τ (term ((sizeof (3 int)) int)))
(test-match Clighter a+τ (term ((sizeof (3 (array int 3))) int)))
(test-match Clighter a+τ (term ((* (var int)) (pointer int))))
(test-match Clighter a+τ (term ((* (var (pointer int))) (pointer (pointer int)))))
(test-match Clighter a+τ (term (oint (union OptionalInt (none void) (some int)))))
(test-match Clighter a+τ (term ((@ (oint (union OptionalInt (none void) (some int))) some) int)))
(test-match Clighter a+τ (term ((@ (oint (union OptionalInt (none void) (some int))) maybe) void)))
(test-match Clighter a+τ (term ((& (oint (union OptionalInt (none void) (some int)))) (pointer void))))
(test-match Clighter a+τ (term ((& (oint (union OptionalInt (none void) (some int)))) (pointer void))))
(test-equal #t (redex-match? Clighter a+τ (term ((? (1 int) (1 int) (0 int)) int))))
(test-equal #t (redex-match? Clighter a+τ (term ((? (0 int) (some (array int 1)) (0 void)) void))))

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
(test-match Clighter bop (term ¦))
(test-match Clighter bop (term ^))
(test-match Clighter bop (term <))
(test-match Clighter bop (term <=))
(test-match Clighter bop (term >))
(test-match Clighter bop (term >=))
(test-match Clighter bop (term ==))
(test-match Clighter bop (term !=))

; *op+τ
(test-match Clighter a+τ (term ((- (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((- (var1 int)) int)))
(test-no-match Clighter a+τ (term ((~ (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((~ (var1 int)) int)))
(test-match Clighter a+τ (term ((! (var1 int)) int)))
(test-match Clighter a+τ (term ((! (var1 (pointer int))) int)))
(test-match Clighter a+τ (term ((+ (var1 int) (var2 int)) int)))
(test-no-match Clighter a+τ (term ((+ (var1 int)) int)))
(test-match Clighter a+τ (term ((* (var1 int) (var2 int)) (pointer int))))
(test-match Clighter a+τ (term ((/ (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((% (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((<< ((sizeof (0 int)) int) (var2 int)) int)))
(test-match Clighter a+τ (term ((>> (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((< (var1 int) (0 void)) int)))
(test-match Clighter a+τ (term ((> (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((<= (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((>= (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((== (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((& (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((^ (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((¦ (var1 int) (var2 int)) int)))

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
(test-match Clighter s (term (while ((> (aaa int) (bbb int)) (pointer void))
                                    ((= (arr (array int 10)) (pntr (pointer (union abc)))) continue))))
(test-match Clighter s (term (for skip (1 int) (= (h int) (100 int)) skip)))
(test-match Clighter s (term (for (= (h int) (100 int))
                               ((> (aaa int) (bbb int)) (pointer void))
                               ((= (arr (array int 10)) (pntr (pointer (union abc)))) continue)
                               (= (h int) ((+ (1 int) (100 int)) int)))))
(test-match Clighter s (term (for (= (i int) (0 int))
                               ((< (i int) (10 int)) int)
                               (= (i int) ((+ (i int) (1 int)) int))
                               skip)))
(test-match Clighter s (term (for (= (i int) (0 int))
                               ((< (i int) (10 int)) int)
                               (= (i int) ((+ (i int) (1 int)) int))
                               (if (var1 int) skip skip))))
(test-match Clighter s (term (for (= (i int) (0 int))
                               ((< (i int) (10 int)) int)
                               (= (i int) ((+ (i int) (1 int)) int))
                               (if (var1 int)
                                   break
                                   (if (var2 int)
                                       continue
                                       (return (0 int)))))))
(test-match Clighter s (term break))
(test-match Clighter s (term continue))
(test-match Clighter s (term return))
(test-match Clighter s (term (return (8 int))))
(test-match Clighter s (term (return (iii (array (struct abc (x int)) 60)))))

; dcl
(test-match Clighter dcl (term (int aaa)))
(test-match Clighter dcl (term ((struct abc (x int) (y int)) bbb)))
(test-match Clighter dcl (term ((array int 700) eee)))
(test-match Clighter dcl (term ((pointer int) pint)))
(test-match Clighter dcl (term ((pointer (array int 3)) pint3)))
(test-no-match Clighter dcl (term (int i (10 int))))

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
(test-no-match Clighter l (term (-1 -1)))

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
(test-match Clighter M (term ((4 (23 undef) (43 undef) (0 (ptr (0 0))))
                              (6 (4 (int 10)) (0 (ptr (0 0)))))))
(test-match Clighter M (term ((0)
                              (1 (0 (int 3)))
                              (2 (0 (int 3)) (1 (int 3)))
                              (3 (0 (ptr (0 0))) (1 (int 3)) (2 undef)) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST HELPER META-FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; size-of
(test-equal?
 "size-of int"
 (term (size-of int))
 (term 4))
(test-equal?
 "size-of array"
 (term (size-of (array int 60)))
 (term 240))
(test-equal?
 "size-of array"
 (term (size-of (array (pointer int) 10)))
 (term 80))
(test-equal?
 "size-of array"
 (term (size-of (array (struct abc (xyz int) (hjk int)) 20)))
 (term 160))
(test-equal?
 "size-of pointer"
 (term (size-of (pointer int)))
 (term 8))
(test-equal?
 "size-of pointer"
 (term (size-of (pointer (array (pointer int) 10))))
 (term 8))
(test-equal?
 "size-of struct"
 (term (size-of (struct aaa)))
 (term 0))
(test-equal?
 "size-of struct"
 (term (size-of (struct aaa (bbb int))))
 (term 4))
(test-equal?
 "size-of struct"
 (term (size-of (struct aaa (bbb int) (ccc (pointer int)))))
 (term 12))
(test-equal?
 "size-of struct"
 (term (size-of (struct aaa (bbb int) (ddd (array int 10)) (ccc (pointer int)))))
 (term 52))
(test-equal?
 "size-of struct"
 (term (size-of (struct aaa (bbb int) (eee (struct hjk)) (ddd (array int 10)) (ccc (pointer int)))))
 (term 52))
(test-equal?
 "size-of struct"
 (term (size-of (struct aaa (bbb int) (eee (struct hjk (lll int))) (ddd (array int 10)) (ccc (pointer int)))))
 (term 56))
(test-equal?
 "size-of union"
 (term (size-of (union aaa)))
 (term 0))
(test-equal?
 "size-of union"
 (term (size-of (union aaa (bbb int))))
 (term 4))
(test-equal?
 "size-of union"
 (term (size-of (union aaa (bbb int) (ccc (pointer int)))))
 (term 8))
(test-equal?
 "size-of union"
 (term (size-of (union aaa (bbb int) (ddd (array int 10)) (ccc (pointer int)))))
 (term 40))
(test-equal?
 "size-of union"
 (term (size-of (union aaa (bbb int) (eee (struct hjk)) (ddd (array int 10)) (ccc (pointer int)))))
 (term 40))
(test-equal?
 "size-of union"
 (term (size-of (union aaa (bbb int) (eee (struct hjk (lll (pointer int)) (mmm int))) (ccc (pointer int)))))
 (term 12))
(test-equal?
 "size-of union"
 (term (size-of (union dummyu
                      (s1 (struct ds1 (x int) (y int) (z int)))
                      (s2 (struct ds2 (x int) (y int))))))
 (term 12))
(test-exn
 "size-of void"
 exn:fail?
 (λ () (term (size-of void))))
(test-exn
 "size-of nested void"
 exn:fail?
 (λ () (term (size-of (union OptionalInt (none void) (some int) (many (array int 2)))))))

; field-offset
(test-equal?
 "field-offset existing id"
 (term (field-offset aaa ((aaa int)) 0))
 (term 0))
(test-equal?
 "field-offset existing id"
 (term (field-offset aaa ((aaa int) (bbb int)) 0))
 (term 0))
(test-equal?
 "field-offset existing id"
 (term (field-offset bbb ((aaa int) (bbb int)) 0))
 (term 4))
(test-equal?
 "field-offset existing id"
 (term (field-offset ccc ((aaa int) (bbb (pointer int)) (ccc int)) 0))
 (term 12))
(test-equal?
 "field-offset existing id"
 (term (field-offset bbb ((aaa int) (bbb (pointer int)) (ccc int)) 0))
 (term 4))
(test-equal?
 "field-offset existing id"
 (term (field-offset bbb ((aaa (struct hjk)) (bbb (pointer int)) (ccc int)) 0))
 (term 0))
(test-equal?
 "field-offset existing id"
 (term (field-offset ccc ((aaa (struct hjk (yyy int) (xxx int))) (bbb (pointer int)) (ccc int)) 0))
 (term 16))
(test-equal?
 "field-offset existing id"
 (term (field-offset ddd ((aaa (struct hjk (yyy int) (xxx int))) (bbb (pointer int)) (ccc (array (pointer int) 10)) (ddd int)) 0))
 (term 96))
(test-equal?
 "field-offset existing id non-zero initial offset"
 (term (field-offset ccc ((aaa (struct hjk (yyy int) (xxx int))) (bbb (pointer int)) (ccc int)) 24))
 (term 40))
(test-equal?
 "field-offset existing id non-zero initial offset"
 (term (field-offset ddd ((aaa (struct hjk (yyy int) (xxx int))) (bbb (pointer int)) (ccc (array (pointer int) 10)) (ddd int)) 100))
 (term 196))
(test-equal?
 "field-offset duplicate nested id"
 (term (field-offset z ((x (array (union dummyu
                                    (s1 (struct dummys1 (x int) (y int) (z int)))
                                    (s2 (struct dummys2 (x int) (y int))))
                            3))
                        (y int)
                        (z (pointer int))
                        )
        4))
 (term 44))
(test-exn
 "field-offset non-existing id"
 exn:fail?
 (λ () (term (field-offset abc ((aaa (struct hjk (yyy int) (xxx int))) (bbb (pointer int)) (ccc int)) 0))))
(test-exn
 "field-offset non-existing id"
 exn:fail?
 (λ () (term (field-offset abc () 0))))

; get-next-block
(test-equal?
 "get-next-block empty memory"
 (term (get-next-block ()))
 (term 0))
(test-equal?
 "get-next-block filled memory"
 (term (get-next-block ((1))))
 (term 2))
(test-equal?
 "get-next-block filled memory"
 (term (get-next-block ((1) (2) (3))))
 (term 4))
(test-equal?
 "get-next-block filled memory"
 (term (get-next-block ((1) (2) (3) (8))))
 (term 9))
(test-equal?
 "get-next-block filled memory"
 (term (get-next-block ((1) (2) (3) (8) (7) (6) (4))))
 (term 9))
(test-equal?
 "get-next-block filled memory"
 (term (get-next-block ((1 (0 undef) (1 undef) (2 undef)) (2 (0 undef) (1 undef) (2 undef)))))
 (term 3))
(test-equal?
 "get-next-block filled memory"
 (term (get-next-block ((1 (0 undef) (1 undef) (2 undef)) (2) (3 (0 undef) (1 undef) (2 undef)) (4 (10 (int 0))))))
 (term 5))

; init-struct-fields
(test-equal?
 "init-struct-fields no fields"
 (term (init-struct-fields (1 (2 (int 3))) 0 ()))
 (term (1 (2 (int 3)))))
(test-equal?
 "init-struct-fields no fields"
 (term (init-struct-fields (1 (2 (int 3)) (3 (ptr (0 0))) (4 (int 3))) 0 ()))
 (term (1 (2 (int 3)) (3 (ptr (0 0))) (4 (int 3)))))
(test-equal?
 "init-struct-fields with fields"
 (term (init-struct-fields (0) 0 ((aaa int))))
 (term (0 (0 undef))))
(test-equal?
 "init-struct-fields with fields"
 (term (init-struct-fields (0) 0 ((aaa int) (bbb (pointer int)))))
 (term (0 (0 undef) (4 undef))))
(test-equal?
 "init-struct-fields with fields"
 (term (init-struct-fields (1) 3 ((aaa int) (bbb (pointer int)))))
 (term (1 (3 undef) (7 undef))))
(test-equal?
 "init-struct-fields with fields"
 (term (init-struct-fields (1 (2 (int 1))) 3 ((aaa int) (bbb (pointer int)))))
 (term (1 (2 (int 1)) (3 undef) (7 undef))))
(test-equal?
 "init-struct-fields with fields"
 (term (init-struct-fields (1 (0 (ptr (0 0))) (1 (int 1)) (2 (int 2))) 3 ((aaa int) (bbb (pointer int)))))
 (term (1 (0 (ptr (0 0))) (1 (int 1)) (2 (int 2)) (3 undef) (7 undef))))
(test-equal?
 "init-struct-fields with array field"
 (term (init-struct-fields (1 (2 (int 1))) 10 ((aaa int) (ccc (array int 3)) (bbb (pointer int)))))
 (term (1 (2 (int 1)) (10 undef) (14 undef) (18 undef) (22 undef) (26 undef))))
(test-equal?
 "init-struct-fields with struct field"
 (term (init-struct-fields (1 (2 (int 1))) 10 ((aaa int) (ccc (array int 3)) (bbb (struct iii (i1 int) (i2 (pointer int)))))))
 (term (1 (2 (int 1)) (10 undef) (14 undef) (18 undef) (22 undef) (26 undef) (30 undef))))
(test-equal?
 "init-struct-fields with nested arrays"
 (term (init-struct-fields (1 (2 (int 1))) 10 ((aaa int) (ccc (array (array int 3) 2)) (bbb (pointer int)))))
 (term (1 (2 (int 1)) (10 undef) (14 undef) (18 undef) (22 undef) (26 undef) (30 undef) (34 undef) (38 undef))))
(test-equal?
 "init-struct-fields with nested structs"
 (term (init-struct-fields (1 (2 (int 1))) 10 ((aaa int) (ccc (array int 3)) (bbb (struct iii (i1 (struct jjj (j1 int) (j2 int))) (i2 (pointer int)))))))
 (term (1 (2 (int 1)) (10 undef) (14 undef) (18 undef) (22 undef) (26 undef) (30 undef) (34 undef))))

; init-array
(test-equal?
 "init-array no elements"
 (term (init-array (1 (2 (int 3))) 0 int 0))
 (term (1 (2 (int 3)))))
(test-equal?
 "init-array no elements"
 (term (init-array (1 (2 (int 3)) (3 (ptr (0 0))) (4 (int 3))) 0 (pointer int) 0))
 (term (1 (2 (int 3)) (3 (ptr (0 0))) (4 (int 3)))))
(test-equal?
 "init-array with elements"
 (term (init-array (0) 0 int 1))
 (term (0 (0 undef))))
(test-equal?
 "init-array with elements"
 (term (init-array (3 (2 undef)) 10 int 3))
 (term (3 (2 undef) (10 undef) (14 undef) (18 undef))))
(test-equal?
 "init-array with elements"
 (term (init-array (3 (2 undef) (3 (int 1))) 4 (pointer int) 4))
 (term (3 (2 undef) (3 (int 1)) (4 undef) (12 undef) (20 undef) (28 undef))))
(test-equal?
 "init-array with array elements"
 (term (init-array (3 (2 undef) (3 (int 1))) 10 (array int 4) 2))
 (term (3 (2 undef) (3 (int 1)) (10 undef) (14 undef) (18 undef) (22 undef) (26 undef) (30 undef) (34 undef) (38 undef))))
(test-equal?
 "init-array with struct elements"
 (term (init-array (3 (2 undef) (3 (int 1))) 10 (struct aaa (iii (pointer int)) (jjj int)) 2))
 (term (3 (2 undef) (3 (int 1)) (10 undef) (18 undef) (22 undef) (30 undef))))
(test-equal?
 "init-array with struct elements containing arrays"
 (term (init-array (3 (2 undef) (3 (int 1))) 10 (struct aaa (iii (pointer int)) (jjj (array int 2))) 2))
 (term (3 (2 undef) (3 (int 1)) (10 undef) (18 undef) (22 undef) (26 undef) (34 undef) (38 undef))))

; init
(test-equal?
 "init no declarations"
 (term (init () () ()))
 (term (() ())))
(test-equal?
 "init with declarations"
 (term (init () () ((int aaa))))
 (term (((aaa 0)) ((0 (0 undef))))))
(test-equal?
 "init with declarations"
 (term (init () () ((int aaa) (int bbb))))
 (term (((aaa 0) (bbb 1)) ((0 (0 undef)) (1 (0 undef))))))
(test-equal?
 "init with declarations"
 (term (init () () ((int aaa) ((pointer int) ccc) (int bbb))))
 (term (((aaa 0) (ccc 1) (bbb 2)) ((0 (0 undef)) (1 (0 undef)) (2 (0 undef))))))
(test-equal?
 "init with declarations"
 (term (init () () ((int aaa) ((pointer int) ccc) (int bbb) ((union abc (aa int) (bb int)) ddd))))
 (term (((aaa 0) (ccc 1) (bbb 2) (ddd 3)) ((0 (0 undef)) (1 (0 undef)) (2 (0 undef)) (3 (0 undef))))))
(test-equal?
 "init with array declarations"
 (term (init () () (((array int 3) aaa))))
 (term (((aaa 0)) ((0 (0 undef) (4 undef) (8 undef))))))
(test-equal?
 "init with array declarations"
 (term (init () () (((array int 3) aaa) ((array (pointer int) 2) bbb))))
 (term (((aaa 0) (bbb 1)) ((0 (0 undef) (4 undef) (8 undef)) (1 (0 undef) (8 undef))))))
(test-equal?
 "init with struct declarations"
 (term (init () () (((struct abc (aa int) (bb (pointer int))) aaa))))
 (term (((aaa 0)) ((0 (0 undef) (4 undef))))))
(test-equal?
 "init with struct declarations"
 (term (init () () (((struct abc (aa int) (bb (pointer int))) aaa) ((struct xyz (aa (pointer int)) (bb (array int 3))) bbb))))
 (term (((aaa 0) (bbb 1)) ((0 (0 undef) (4 undef)) (1 (0 undef) (8 undef) (12 undef) (16 undef))))))
(test-equal?
 "init with struct declarations"
 (term (init () () (((union abc (aa int) (bb (pointer int))) aaa) ((struct xyz (aa (pointer int)) (bb (array int 3))) bbb))))
 (term (((aaa 0) (bbb 1)) ((0 (0 undef)) (1 (0 undef) (8 undef) (12 undef) (16 undef))))))
(test-equal?
 "init with struct declarations"
 (term (init ((ccc 2)) ((2) (3 (0 undef))) (((union abc (aa int) (bb (pointer int))) aaa) ((struct xyz (aa (pointer int)) (bb (array int 3))) bbb))))
 (term (((ccc 2) (aaa 4) (bbb 5)) ((2) (3 (0 undef)) (4 (0 undef)) (5 (0 undef) (8 undef) (12 undef) (16 undef))))))

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
(test-equal?
 "loadval int"
 (term (loadval int ((1 (0 (int 1)) (1 (int 2))) (2 (0 (int 3)))) (2 0)))
 (term (int 3)))
(test-equal?
 "loadval pointer"
 (term (loadval (pointer int) ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3)))) (1 1)))
 (term (ptr (1 0))))
(test-equal?
 "loadval pointer"
 (term (loadval (pointer int) ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3))) (3 (0 (int 1)) (1 (ptr (2 0))))) (3 1)))
 (term (ptr (2 0))))
(test-equal?
 "loadval array"
 (term (loadval (array (pointer int) 100) ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3))) (3 (0 (int 1)) (1 (ptr (2 0))))) (3 1)))
 (term (ptr (3 1))))
(test-equal?
 "loadval array"
 (term (loadval (array (struct abc (aa int) (bb (pointer int))) 15) ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3))) (3 (0 (int 1)) (1 (ptr (2 0))))) (2 0)))
 (term (ptr (2 0))))
(test-exn
 "loadval void"
 exn:fail?
 (λ () (term (loadval void ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3))) (3 (0 (int 1)) (1 (ptr (2 0))))) (1 0)))))
(test-exn
 "loadval struct"
 exn:fail?
 (λ () (term (loadval (struct abc (aa int)) ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3))) (3 (0 (int 1)) (1 (ptr (2 0))))) (1 1)))))
(test-exn
 "loadval union"
 exn:fail?
 (λ () (term (loadval (union xyz (bb (pointer int)) (cc (array int 10))) ((1 (0 (int 1)) (1 (ptr (1 0)))) (2 (0 (int 3))) (3 (0 (int 1)) (1 (ptr (2 0))))) (3 0)))))

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
 (term (eval-binop ¦ (int 4) int (int 5) int))
 (term (int 5)))
(test-equal?
 "eval-binop integer bitwise or"
 (term (eval-binop ¦ (int 10) int (int 60) int))
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
 (λ () (term (eval-binop - (int 100) int (ptr (3 8)) (pointer int)))))
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

; is-break-or-return
(test-equal?
 "is-break-or-return? Break"
 (term (is-break-or-return? Break))
 #true)
(test-equal?
 "is-break-or-return? Return"
 (term (is-break-or-return? Return))
 #true)
(test-equal?
 "is-break-or-return? (Return v)"
 (term (is-break-or-return? (Return (int 55))))
 #true)
(test-equal?
 "is-break-or-return? Normal"
 (term (is-break-or-return? Normal))
 #false)
(test-equal?
 "is-break-or-return? Continue"
 (term (is-break-or-return? Continue))
 #false)

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
; lval 1
(test-judgment-holds (lval ((aaa 0) (bbb 1))
                           ()
                           (aaa int)
                           (0 0)))
(test-judgment-holds (lval ((aaa 0) (bbb 1) (ccc 2))
                           ()
                           (ccc int)
                           (2 0)))
(test-judgment-holds (lval ((aaa 0) (bbb 1) (ccc 2))
                           ()
                           (bbb (pointer (array int 6)))
                           (1 0)))

; lval 2
(test-judgment-holds (lval ((aaa 0) (bbb 1))
                           ((0 (0 (ptr (0 0)))))
                           ((* (aaa (pointer int))) int)
                           (0 0)))
(test-judgment-holds (lval ((aaa 0) (bbb 1) (ccc 2))
                           ((2 (0 (ptr (1 1)))))
                           ((* (ccc (pointer int))) int)
                           (1 1)))
(test-judgment-holds (lval ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (ptr (1 0)))) (1 (0 (ptr (1 3)))) (2 (0 (ptr (1 2)))))
                           ((* (bbb (pointer (pointer int)))) (pointer int))
                           (1 3)))

; lval 3
(test-judgment-holds (lval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((@ (abc (struct xyz (aa int) (bb int))) aa) int)
                           (1 0)))
(test-judgment-holds (lval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((@ (abc (struct xyz (aa int) (bb int))) bb) int)
                           (1 4)))
(test-judgment-holds (lval ((ddd 1) (bbb 2) (ccc 3) (abc 4))
                           ((0 (0 (ptr (0 0))))
                            (1 (0 (int 4))
                               (4 (int 5)))
                            (4 (0 (int 4))
                               (4 (int 5))
                               (8 (ptr (0 0)))
                               (16 (ptr (1 0)))))
                           ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) dd) (pointer int))
                           (4 16)))
(test-judgment-holds (lval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5)) (8 (int 6))))
                           ((@ ((@ (abc (struct xyz (aa int) (bb (struct hjk (ii int) (jj int))))) bb) (struct hjk (ii int) (jj int))) jj) int)
                           (1 8)))

; lval 4
(test-judgment-holds (lval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((@ (abc (union xyz (aa int) (bb int))) aa) int)
                           (1 0)))
(test-judgment-holds (lval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((@ (abc (union xyz (aa int) (bb int))) bb) int)
                           (1 0)))
(test-judgment-holds (lval ((ddd 1) (bbb 2) (ccc 3) (abc 4))
                           ((0 (0 (ptr (0 0))))
                            (1 (0 (int 4))
                               (4 (int 5)))
                            (4 (0 (int 4))
                               (4 (int 5))
                               (8 (ptr (0 0)))
                               (16 (ptr (1 0)))))
                           ((@ (abc (union xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) dd) (pointer int))
                           (4 0)))

; rval 5
(test-judgment-holds (rval () () (100 int)
                           (int 100)))
(test-judgment-holds (rval ((abc 1) (bbb 2)) ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5)))) (100 int)
                           (int 100)))
(test-judgment-holds (rval ((abc 1) (bbb 2)) ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5)))) (-5 int)
                           (int -5)))

; rval 7
(test-judgment-holds (rval () () ((sizeof (10 int)) int) (int 4)))
(test-judgment-holds (rval () () ((sizeof (abc (union xyz (jj (pointer int)) (ii (array int 10))))) int) (int 40)))
(test-judgment-holds (rval () () ((sizeof (abc (struct xyz (jj (pointer int)) (ii (array int 10))))) int) (int 48)))

; rval 8
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((@ (abc (struct xyz (aa int) (bb int))) aa) int)
                           (int 4)))
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((@ (abc (struct xyz (aa int) (bb int))) bb) int)
                           (int 5)))
(test-judgment-holds (rval ((ddd 1) (bbb 2) (ccc 3) (abc 4))
                           ((0 (0 (ptr (0 0))))
                            (1 (0 (int 4))
                               (4 (int 5)))
                            (4 (0 (int 4))
                               (4 (int 5))
                               (8 (ptr (0 0)))
                               (16 (ptr (1 0)))))
                           ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) dd) (pointer int))
                           (ptr (1 0))))

; rval 9
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((& ((@ (abc (struct xyz (aa int) (bb int))) bb) int)) (pointer int))
                           (ptr (1 4))))
(test-judgment-holds (rval ((ddd 1) (bbb 2) (ccc 3) (abc 4))
                           ((0 (0 (ptr (0 0))))
                            (1 (0 (int 4))
                               (4 (int 5)))
                            (4 (0 (int 4))
                               (4 (int 5))
                               (8 (ptr (0 0)))
                               (16 (ptr (1 0)))))
                           ((& ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) dd) (pointer int))) (pointer int))
                           (ptr (4 16))))
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5)) (8 (int 6))))
                           ((& ((@ ((@ (abc (struct xyz (aa int) (bb (struct hjk (ii int) (jj int))))) bb) (struct hjk (ii int) (jj int))) jj) int)) (pointer int))
                           (ptr (1 8))))

; rval 10
(test-judgment-holds (rval () () ((- (4 int)) int)
                           (int -4)))
(test-judgment-holds (rval () () ((! (4 int)) int)
                           (int 0)))
(test-judgment-holds (rval () () ((~ (4 int)) int)
                           (int -5)))
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 5))))
                           ((- ((@ (abc (struct xyz (aa int) (bb int))) bb) int)) int)
                           (int -5)))
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 4)) (4 (int 0))))
                           ((! ((@ (abc (struct xyz (aa int) (bb int))) bb) int)) int)
                           (int 1)))

; rval 11
(test-judgment-holds (rval () () ((- (4 int) (4 int)) int)
                           (int 0)))
(test-judgment-holds (rval () () ((< (3 int) (4 int)) int)
                           (int 1)))
(test-judgment-holds (rval () () ((& (3 int) (4 int)) int)
                           (int 0)))
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 10)) (4 (int 11))))
                           ((* ((@ (abc (struct xyz (aa int) (bb int))) bb) int)
                               ((@ (abc (struct xyz (aa int) (bb int))) aa) int)) int)
                           (int 110)))
(test-judgment-holds (rval ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))
                           ((% ((@ (abc (struct xyz (aa int) (bb int))) bb) int)
                               ((@ (abc (struct xyz (aa int) (bb int))) aa) int)) int)
                           (int 1)))

; rval 12
(test-judgment-holds (rval () () ((? (3 int) (10 int) (20 int)) int)
                           (int 10)))
(test-judgment-holds (rval ((ddd 1) (bbb 2) (ccc 3) (abc 4))
                           ((0 (0 (ptr (0 0))))
                            (1 (0 (int 4))
                               (4 (int 5)))
                            (4 (0 (int 4))
                               (4 (int 5))
                               (8 (ptr (0 0)))
                               (16 (ptr (1 0)))))
                           ((? ((& (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int))))) (pointer (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))))
                               ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) dd) (pointer int))
                               ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) cc) (pointer int)))
                            (pointer int))
                           (ptr (1 0))))

; rval 13
(test-judgment-holds (rval () () ((? (0 int) (10 int) (20 int)) int)
                           (int 20)))
(test-judgment-holds (rval ((ddd 1) (bbb 2) (ccc 3) (abc 4))
                           ((0 (0 (ptr (0 0))))
                            (1 (0 (int 4))
                               (4 (int 5)))
                            (4 (0 (int 0))
                               (4 (int 5))
                               (8 (ptr (4 4)))
                               (16 (ptr (1 0)))))
                           ((? ((* ((& (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int))))) (pointer (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))))) int)
                               ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) dd) (pointer int))
                               ((@ (abc (struct xyz (aa int) (bb int) (cc (pointer int)) (dd (pointer int)))) cc) (pointer int)))
                            (pointer int))
                           (ptr (4 4))))

; stmt 15
(test-judgment-holds (stmt () () skip Normal ()))
(test-judgment-holds (stmt ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))
                           skip
                           Normal
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))))

; stmt 16
(test-judgment-holds (stmt () () break Break ()))
(test-judgment-holds (stmt ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))
                           break
                           Break
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))))

; stmt 17
(test-judgment-holds (stmt () () continue Continue ()))
(test-judgment-holds (stmt ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))
                           continue
                           Continue
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))))

; stmt 18
(test-judgment-holds (stmt () () return Return ()))
(test-judgment-holds (stmt ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))
                           return
                           Return
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))))

; stmt 19
(test-judgment-holds (stmt () () (return (50 int)) (Return (int 50)) ()))
(test-judgment-holds (stmt ((abc 1) (bbb 2))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))
                           (return ((+ (4 int) ((& (abc (struct xyz (aa int) (bb int)))) (pointer int))) (pointer int)))
                           (Return (ptr (1 4)))
                           ((0 (0 (ptr (0 0)))) (1 (0 (int 3)) (4 (int 10))))))

; stmt 20
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (= (aaa int)
                              (30 int))
                           Normal
                           ((0 (0 (int 30))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 8))))
                           (= ((* (bbb (pointer int))) int)
                              (30 int))
                           Normal
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 30))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (= ((@ (ccc (struct xyz (aa int) (bb (pointer int)))) aa) int)
                              ((* (bbb (pointer int))) int))
                           Normal
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 99)) (4 (ptr (2 0)))))))

; stmt 21
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           ((= ((@ (ccc (struct xyz (aa int) (bb (pointer int)))) aa) int)
                               ((* (bbb (pointer int))) int))
                            (= (aaa int)
                               (30 int)))
                           Normal
                           ((0 (0 (int 30))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 99)) (4 (ptr (2 0)))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           ((= ((@ (ccc (struct xyz (aa int) (bb (pointer int)))) bb) (pointer int))
                               (bbb (pointer int)))
                            (= (aaa int)
                               ((* ((@ (ccc (struct xyz (aa int) (bb (pointer int)))) bb) (pointer int))) int)))
                           Normal
                           ((0 (0 (int 99))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (1 8)))))))
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (skip
                            (= (aaa int)
                               (30 int)))
                           Normal
                           ((0 (0 (int 30))))))
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           ((= (aaa int)
                               (30 int))
                            break)
                           Break
                           ((0 (0 (int 30))))))
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           ((= (aaa int)
                               (30 int))
                            (= (aaa int)
                               (40 int)))
                           Normal
                           ((0 (0 (int 40))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 8))))
                           ((= ((* (bbb (pointer int))) int)
                               (30 int))
                            (return ((* (bbb (pointer int))) int)))
                           (Return (int 30))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 30))))))

; stmt 22
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (((= (aaa int)
                                (30 int))
                             break)
                            (= (aaa int)
                               (40 int)))
                           Break
                           ((0 (0 (int 30))))))
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (break
                            (= (aaa int)
                               (40 int)))
                           Break
                           ((0 (0 (int 4))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 8))))
                           (((= ((* (bbb (pointer int))) int)
                                (30 int))
                             (return ((* (bbb (pointer int))) int)))
                            (= (aaa int)
                               (40 int)))
                           (Return (int 30))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 30))))))

; stmt if-true
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (if (11 int)
                               (= (aaa int)
                                  (30 int))
                               (= (aaa int)
                                  (40 int)))
                           Normal
                           ((0 (0 (int 30))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 4))) (1 (0 (ptr (0 0)))))
                           (if ((* (bbb (pointer int))) int)
                               ((= (aaa int)
                                   (30 int))
                                break)
                               ((= (aaa int)
                                   (40 int))
                                continue))
                           Break
                           ((0 (0 (int 30))) (1 (0 (ptr (0 0)))))))

; stmt if-false
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (if (0 int)
                               (= (aaa int)
                                  (30 int))
                               (= (aaa int)
                                  (40 int)))
                           Normal
                           ((0 (0 (int 40))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 0))) (1 (0 (ptr (0 0)))))
                           (if ((* (bbb (pointer int))) int)
                               ((= (aaa int)
                                   (30 int))
                                break)
                               ((= (aaa int)
                                   (40 int))
                                continue))
                           Continue
                           ((0 (0 (int 40))) (1 (0 (ptr (0 0)))))))

; stmt 23
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (while ((- (10 int) (10 int)) int)
                                  (= (aaa int)
                                     (30 int)))
                           Normal
                           ((0 (0 (int 4))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (while ((* (bbb (pointer int))) int)
                                  (= (aaa int)
                                     (30 int)))
                           Normal
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 24
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (while ((- (10 int) (11 int)) int)
                                  ((= (aaa int)
                                      (30 int))
                                   break))
                           Normal
                           ((0 (0 (int 30))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (while ((* (bbb (pointer int))) int)
                                  ((= (aaa int)
                                      (30 int))
                                   return))
                           Return
                           ((0 (0 (int 30))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 25a
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 1)) (1 (int 0))) (1 (0 (ptr (0 0)))))
                           (while ((* (bbb (pointer int))) int)
                                  (= (bbb (pointer int))
                                     ((+ (1 int) (bbb (pointer int))) (pointer int))))
                           Normal
                           ((0 (0 (int 1)) (1 (int 0))) (1 (0 (ptr (0 1)))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (while (aaa int)
                                  (= (aaa int)
                                     ((- (aaa int) (1 int)) int)))
                           Normal
                           ((0 (0 (int 0))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 25b
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 1)) (1 (int 0))) (1 (0 (ptr (0 0)))))
                           (while ((* (bbb (pointer int))) int)
                                  ((= (bbb (pointer int))
                                      ((+ (1 int) (bbb (pointer int))) (pointer int)))
                                   continue))
                           Normal
                           ((0 (0 (int 1)) (1 (int 0))) (1 (0 (ptr (0 1)))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (while (aaa int)
                                  ((= (aaa int)
                                      ((- (aaa int) (1 int)) int))
                                   (if (aaa int)
                                       continue
                                       break)))
                           Normal
                           ((0 (0 (int 0))) (1 (0 (ptr (1 8))) (8 (int 99))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 26
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4)) (4 (int 0))))
                           (for skip
                             (aaa int)
                             (= (aaa int)
                                ((- (aaa int) (1 int)) int))
                             (= ((* ((+ ((& (aaa int)) (pointer int)) (4 int)) (pointer int))) int)
                                (aaa int)))
                           Normal
                           ((0 (0 (int 0)) (4 (int 1))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int -9))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (for skip
                             ((* (bbb (pointer int))) int)
                             (= ((* (bbb (pointer int))) int)
                                ((+ ((* (bbb (pointer int))) int) (1 int)) int))
                             (= (aaa int)
                                ((+ (10 int) (aaa int)) int)))
                           Normal
                           ((0 (0 (int 94))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 27
(test-judgment-holds (stmt ((aaa 0) (bbb 1))
                           ((0 (0 (int 1)) (1 (int 0))) (1 (0 (ptr (0 0)))))
                           (for skip
                             (0 int)
                             (= (aaa int)
                                (30 int))
                             (= (aaa int)
                                (40 int)))
                           Normal
                           ((0 (0 (int 1)) (1 (int 0))) (1 (0 (ptr (0 0)))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (for skip
                             ((* (bbb (pointer int))) int)
                             (= (aaa int)
                                (30 int))
                             (= (aaa int)
                                (40 int)))
                           Normal
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 28
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4)) (4 (int 0))))
                           (for skip
                             (aaa int)
                             (= (aaa int)
                                ((- (aaa int) (1 int)) int))
                             ((= ((* ((+ ((& (aaa int)) (pointer int)) (4 int)) (pointer int))) int)
                                 (aaa int))
                              break))
                           Normal
                           ((0 (0 (int 4)) (4 (int 4))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int -9))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (for skip
                             ((* (bbb (pointer int))) int)
                             (= ((* (bbb (pointer int))) int)
                                ((+ ((* (bbb (pointer int))) int) (1 int)) int))
                             ((= (aaa int)
                                 ((+ (10 int) (aaa int)) int))
                              (if ((== (44 int) (aaa int)) int)
                                  (return (aaa int))
                                  continue)))
                           (Return (int 44))
                           ((0 (0 (int 44))) (1 (0 (ptr (1 8))) (8 (int -6))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 29a
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4)) (4 (int 0))))
                           (for skip
                             (aaa int)
                             (= (aaa int)
                                ((- (aaa int) (1 int)) int))
                             ((= ((* ((+ ((& (aaa int)) (pointer int)) (4 int)) (pointer int))) int)
                                 (aaa int))
                              skip))
                           Normal
                           ((0 (0 (int 0)) (4 (int 1))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int -9))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (for skip
                             ((* (bbb (pointer int))) int)
                             (= ((* (bbb (pointer int))) int)
                                ((+ ((* (bbb (pointer int))) int) (1 int)) int))
                             ((= (aaa int)
                                 ((+ (10 int) (aaa int)) int))
                              (if (0 int)
                                  continue
                                  skip)))
                           Normal
                           ((0 (0 (int 94))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; stmt 29b
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4)) (4 (int 0))))
                           (for skip
                             (aaa int)
                             (= (aaa int)
                                ((- (aaa int) (1 int)) int))
                             ((= ((* ((+ ((& (aaa int)) (pointer int)) (4 int)) (pointer int))) int)
                                 (aaa int))
                              continue))
                           Normal
                           ((0 (0 (int 0)) (4 (int 1))))))
(test-judgment-holds (stmt ((aaa 0) (bbb 1) (ccc 2))
                           ((0 (0 (int 4))) (1 (0 (ptr (1 8))) (8 (int -9))) (2 (0 (int 1)) (4 (ptr (2 0)))))
                           (for skip
                             ((* (bbb (pointer int))) int)
                             (= ((* (bbb (pointer int))) int)
                                ((+ ((* (bbb (pointer int))) int) (1 int)) int))
                             ((= (aaa int)
                                 ((+ (10 int) (aaa int)) int))
                              (if (220 int)
                                  continue
                                  skip)))
                           Normal
                           ((0 (0 (int 94))) (1 (0 (ptr (1 8))) (8 (int 0))) (2 (0 (int 1)) (4 (ptr (2 0)))))))

; run 40
(test-judgment-holds (run ((int aaa)
                            (int bbb)
                            (((= (aaa int) (4 int))
                              (= (bbb int) (5 int)))
                             (return ((+ (aaa int) (bbb int)) int))))
                           ((int 9)
                           ((0 (0 (int 4))) (1 (0 (int 5)))))))
(test-judgment-holds (run ((int aaa)
                            (int bbb)
                            (((= (aaa int) (4 int))
                              (= (bbb int) (1 int)))
                             (for skip
                               (aaa int)
                               (= (aaa int)
                                  ((- (aaa int) (1 int)) int))
                               (= (bbb int)
                                  ((* (bbb int) (2 int)) int)))))
                           (undef
                           ((0 (0 (int 0))) (1 (0 (int 16)))))))
(test-judgment-holds (run ((int aaa)
                            (int bbb)
                            (int ccc)
                            (((((= (aaa int) (2 int))
                                (= (bbb int) (2 int)))
                               (= (ccc int) (0 int)))
                              (for skip
                                (aaa int)
                                (= (aaa int)
                                   ((- (aaa int) (1 int)) int))
                                ((for skip
                                   (bbb int)
                                   (= (bbb int)
                                      ((- (bbb int) (1 int)) int))
                                   (= (ccc int)
                                      ((+ (ccc int) ((* (bbb int) (aaa int)) int)) int)))
                                 (= (bbb int)
                                    (2 int)))))
                             (return (ccc int))))
                           ((int 9)
                           ((0 (0 (int 0))) (1 (0 (int 2))) (2 (0 (int 9)))))))
(test-judgment-holds (run (((pointer int) aaa)
                            ((struct xyz (ii int) (jj int) (kk int)) bbb)
                            (((= (aaa (pointer int)) ((& (bbb (struct xyz (ii int) (jj int) (kk int)))) (pointer void)))
                              (= ((@ (bbb (struct xyz (ii int) (jj int) (kk int))) kk) int) (5 int)))
                             (return ((* ((+ (aaa (pointer int)) (8 int)) int)) int))))
                           ((int 5)
                           ((0 (0 (ptr (1 0)))) (1 (0 undef) (4 undef) (8 (int 5)))))))

; run 40 (using stmts->seq+term)
(test-judgment-holds (run (((pointer int) aaa)
                            ((struct xyz (ii int) (jj int) (kk int)) bbb)
                            ,(stmts->seq+term [
                              (= (aaa (pointer int)) ((& (bbb (struct xyz (ii int) (jj int) (kk int)))) (pointer void)))
                              (= ((@ (bbb (struct xyz (ii int) (jj int) (kk int))) kk) int) (5 int))
                              (return ((* ((+ (aaa (pointer int)) (8 int)) int)) int))
                            ]))
                           ((int 5)
                           ((0 (0 (ptr (1 0)))) (1 (0 undef) (4 undef) (8 (int 5)))))))

(test-judgment-holds (run (((array int 2) arr) ((pointer int) arrp)
                              ,(stmts->seq+term [
                                 (= (arrp (pointer (array int 2))) ((& (arr (array int 2))) (pointer (array int 2))))
                                 (= ((* ((+ (arrp (pointer int)) (1 int)) (pointer int))) int) (3 int))
                                 (return (0 int))
                              ]))
                              ((int 0)
                              (0 (0 undef) (4 (int 3))) (1 (0 (ptr (0 0)))))
                           ))

(test-judgment-not-hold (run (((array int 1) arr) ((pointer int) arrp)
                              ,(stmts->seq+term [
                                 (= (arrp (pointer (array int 1))) ((& (arr (array int 1))) (pointer (array int 1))))
                                 (= ((* ((+ (arrp (pointer int)) (1 int)) (pointer int))) int) (3 int))
                                 (return (0 int))
                              ]))
                              ((int 0)
                              (0 (0 undef) (4 (int 3))) (1 (0 (ptr (0 0)))))
                           ))
