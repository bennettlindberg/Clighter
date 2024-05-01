#lang racket

(require redex)

(define-language Clighter
  ;;; Abs Syntax
  (signedness ::= Signed Unsigned)
  (intsize    ::= I8 I16 I32)
  (floatsize  ::= F32 F64)
  (n          ::= integer)
  (f          ::= float)
  (id         ::= variable-not-otherwise-mentioned)
  (τ          ::= (int intsize signedness)
                  (float floatsize)
                  (void)
                  (array τ n)
                  (pointer τ)
                  (function τ τ ...)
                  (struct id φ ...)
                  (union id φ ...)
                  (comp-pointer id))
  (φ          ::= (id τ))

  ;;; Exprs
  (a          ::= id
                  n
                  f
                  (sizeof τ)
                  (uop a)
                  (bop a a)
                  (* a)
                  (@ a id)
                  (& a)
                  ((τ) a)
                  (? a a a))
  (uop        ::= - ~ !)
  (bop        ::= + - * / %
                  << >> & \| ^
                  < <= > >= == !=)

  ;; Stmts
  (s          ::= skip
                  (= a a)
                  (= a (a a ...))
                  (a a ...)
                  (s s)
                  (if a s1 s2)
                  (switch a sw)
                  (while a s)
                  (do-while s a)
                  (for s a s s)
                  break
                  continue
                  return
                  (return a))
  (sw         ::= (default s) (case n (s sw)))

  ;;; Fun & Prog
  (dcl        ::= (τ id))
  (F          ::= (τ id dcl ... dcl ... s))
  (Fe         ::= (extern τ id dcl ...))
  (Fd         ::= F Fe)
  (P          ::= (dcl ... Fd ...)) ; main = id

  ;;; Semantic Elements
  (b          ::= natural)
  (δ          ::= natural)
  (l          ::= (b δ))
  (v          ::= (int n)
                  (float f)
                  (ptr l)
                  undef)
  (out        ::= Normal
                  Continue
                  Break
                  Return
                  (Return v))
  (G          ::= (id↦b ... b↦Fd ...))
  (E          ::= (id↦b ...))
  (id↦b       ::= (id b))
  (b↦Fd       ::= (b Fd))
  (M          ::= (b↦δ↦v ...))
  (b↦δ↦v      ::= (b δ↦v))
  (δ↦v        ::= (δ v))
  (κ          ::= int8signed
                  int8unsigned
                  int16signed
                  int16unsigned
                  int32
                  float32
                  float64)
  (io-v       ::= (int n)
                  (float f))
  (io-e       ::= (id io-v ... io-v))
  (t          ::= ε
                  (io-e t))
  (T          ::= ε
                  (io-e T))
  (B          ::= (terminates t n)
                  (diverges T))
)
