#lang racket

(require redex)
(require rackunit)
(require "clighter.rkt")

; ███████ ██    ██ ███    ██ ████████  █████  ██   ██
; ██       ██  ██  ████   ██    ██    ██   ██  ██ ██
; ███████   ████   ██ ██  ██    ██    ███████   ███
;      ██    ██    ██  ██ ██    ██    ██   ██  ██ ██
; ███████    ██    ██   ████    ██    ██   ██ ██   ██

(test-match Clighter n (term 10))
(test-no-match Clighter n (term 10.0))

(test-match Clighter id (term prog))
(test-no-match Clighter id (term 10))
(test-no-match Clighter id (term void))

(test-match Clighter τ (term (array int 3)))
; (test-no-match Clighter τ (term (array int -1)))              ; Should we make n a natural number?  Though this is somewhat valid in C
(test-match Clighter τ (term (pointer (array (array int 3) 3))))
(test-match Clighter τ (term (pointer (struct Point2d (x int) (y int)))))
(test-match Clighter τ (term (struct RealPointer3d (x (pointer int)) (y (pointer int)) (z (pointer void)))))
(test-match Clighter τ (term (union OptionalInt (none void) (some int))))
(test-no-match Clighter τ (term (union IntOptional (void none) (int some))))



(test-match Clighter a+τ (term (id int)))
(test-match Clighter a+τ (term ((sizeof (3 int)) int)))
(test-match Clighter a+τ (term ((sizeof (3 (array int 3))) int)))
(test-match Clighter a+τ (term ((* (var int)) (pointer int))))
(test-match Clighter a+τ (term ((* (var (pointer int))) (pointer (pointer int)))))
(test-match Clighter a+τ (term (oint (union OptionalInt (none void) (some int)))))
(test-match Clighter a+τ (term ((@ (oint (union OptionalInt (none void) (some int))) some) int)))
(test-match Clighter a+τ (term ((@ (oint (union OptionalInt (none void) (some int))) maybe) void)))
(test-match Clighter a+τ (term ((& (oint (union OptionalInt (none void) (some int)))) (pointer void))))  ; What is the ret type of &?  b?
(test-match Clighter a+τ (term ((& (oint (union OptionalInt (none void) (some int)))) (pointer void))))
; Seems `?' and (test-match) are not quite compatible
(test-equal #t (redex-match? Clighter a+τ (term ((? (1 int) (1 int) (0 int)) int))))
(test-equal #t (redex-match? Clighter a+τ (term ((? (0 int) (some (array int 1)) (0 void)) void))))



(test-match Clighter a+τ (term ((- (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((- (var1 int)) int)))
(test-no-match Clighter a+τ (term ((~ (var1 int) (var2 int)) int)))
(test-match Clighter a+τ (term ((~ (var1 int)) int)))
(test-match Clighter a+τ (term ((! (var1 int)) int)))
(test-match Clighter a+τ (term ((! (var1 (pointer int))) int)))
(test-match Clighter a+τ (term ((+ (var1 int) (var2 int)) int)))
(test-no-match Clighter a+τ (term ((+ (var1 int)) int))) ; Unary plus?
(test-match Clighter a+τ (term ((* (var1 int) (var2 int)) (pointer int))))  ; Not a pointer arithmetic
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



(test-match Clighter s (term skip))
(test-match Clighter s (term (skip skip)))
(test-no-match Clighter s (term (skip skip (= (var1 int) (var2 int))))) ; Making s ::= (s ...)?
(test-match Clighter s (term (= (var1 int) (var2 int))))
(test-match Clighter s (term (if (var1 int) skip skip)))
(test-match Clighter s (term (if (var1 int) skip (if (var2 int) skip skip))))
(test-match Clighter s (term (if (var1 int) (if (var2 int) skip skip) skip)))
(test-match Clighter s (term (if (var1 int) (if (var2 int) skip skip) (if (var3 int) skip skip))))
(test-match Clighter s (term (while (var1 int) skip)))
(test-match Clighter s (term (while (var1 int) (if (var2 int) skip skip))))
(test-match Clighter s (term (= (i int) ((+ (i int) (1 int)) int))))
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



(test-match Clighter dcl (term (int i)))
(test-no-match Clighter dcl (term (int i (10 int))))
(test-match Clighter dcl (term ((struct Point2d (x int) (y int)) p2d)))
(test-match Clighter dcl (term ((union OptionalInt (none void) (some int)) oint)))
(test-match Clighter dcl (term ((array int 3) arr)))
(test-match Clighter dcl (term ((pointer int) pint)))
(test-match Clighter dcl (term ((pointer (array int 3)) pint3)))



(test-match Clighter P (term ((int i) (return (i int)))))
(test-match Clighter P (term (skip)))



(test-match Clighter l (term (0 3)))
(test-no-match Clighter l (term (-1 -1)))



(test-match Clighter v (term (int 3)))
(test-match Clighter v (term (int -3)))
(test-match Clighter v (term (ptr (0 3))))
(test-match Clighter v (term undef))



(test-match Clighter G (term ((integer 0) (arr 1) (a-pointer 2))))
(test-match Clighter G (term ()))



(test-match Clighter M (term ((0)
                               (1 (0 (int 3)))
                               (2 (0 (int 3)) (1 (int 3)))
                               (3 (0 (ptr (0 0))) (1 (int 3)) (2 undef)) )))


; ███    ███ ███████ ████████  █████  ███████ ██    ██ ███    ██
; ████  ████ ██         ██    ██   ██ ██      ██    ██ ████   ██
; ██ ████ ██ █████      ██    ███████ █████   ██    ██ ██ ██  ██
; ██  ██  ██ ██         ██    ██   ██ ██      ██    ██ ██  ██ ██
; ██      ██ ███████    ██    ██   ██ ██       ██████  ██   ████

(test-equal (term (size-of int)) (term 4))
(test-exn "void" exn? (λ () (term (size-of void))))
(test-equal (term (size-of (array int 3))) (term 12))
(test-equal (term (size-of (pointer int))) (term 8))
(test-equal (term (size-of (struct Point2d (x int) (y int) (z (pointer int))))) (term 16))
; (test-equal (term (size-of (union OptionalInt (none void) (some int) (many (array int 2))))) (term 8))  ; This fails
(test-equal (term (size-of (union OptionalInt (none int) (some int) (many (array int 2))))) (term 8))
(test-equal (term (size-of (union Nothing))) (term 0))



(test-equal (term (field-offset x ((x int) (y int)) 0)) (term 0))
(test-equal (term (field-offset y ((x int) (y int)) 0)) (term 4))
(test-equal (term (field-offset z ((x int) (y int) (z (pointer int))) 0)) (term 8))
(test-equal (term (field-offset z ((x int) (y int) (z (pointer int))) 4)) (term 12))  ; alignment?
(test-equal (term (field-offset z ((x (array (union dummyu
                                                (struct dummys1 (x int) (y int) (z int))
                                                (struct dummys2 (x int) (y int))
                                        3)))
                                   (y int)
                                   (z (pointer int))
                                  ) 4)) (term 44))
(test-exn "undef val" exn? (λ () (term (field-offset t ((x int) (y int) (z (pointer int))) 0))))



(test-equal (term (get-next-block ())) (term 0))
(test-equal (term (get-next-block ((0)))) (term 1))
(test-equal (term (get-next-block ((1)))) (term 2))
(test-equal (term (get-next-block ((50) (40) (30) (60)))) (term 61))



