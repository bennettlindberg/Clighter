#lang racket

(require redex)

;; (define-language Clighter
;;   ;; Types
;;   (signedness ::= Signed Unsigned)
;;   (intsize    ::= I8 I16 I32)
;;   (floatsize  ::= F32 F64)
;;   (n          ::= integer)
;;   (f          ::= float)
;;   (id         ::= variable-not-otherwise-mentioned)
;;   (τ          ::= (int intsize signedness)
;;                   (float floatsize)
;;                   (void)
;;                   (array τ n)
;;                   (pointer τ)
;;                   (function τ τ ...)
;;                   (struct id φ ...)
;;                   (union id φ ...)
;;                   (comp-pointer id))
;;   (φ          ::= (id τ))
;; 
;;   ;; Expressions
;;   (a          ::= id
;;                   n
;;                   f
;;                   (sizeof τ)
;;                   (uop a)
;;                   (bop a a)
;;                   (* a)
;;                   (@ a id)
;;                   (& a)
;;                   ((τ) a)
;;                   (? a a a))
;;   (uop        ::= - ~ !)
;;   (bop        ::= + - * / %
;;                   << >> & \| ^
;;                   < <= > >= == !=)
;; 
;;   ;; Statements
;;   (s          ::= skip
;;                   (= a a)
;;                   (= a (a a ...))
;;                   (a a ...)
;;                   (s s)
;;                   (if a s1 s2)
;;                   (switch a sw)
;;                   (while a s)
;;                   (do-while s a)
;;                   (for s a s s)
;;                   break
;;                   continue
;;                   return
;;                   (return a))
;;   (sw         ::= (default s) (case n (s sw)))
;; 
;;   ;; Functions and Programs
;;   (dcl        ::= (τ id))
;;   (F          ::= (τ id dcl ... dcl ... s))
;;   (Fe         ::= (extern τ id dcl ...))
;;   (Fd         ::= F Fe)
;;   (P          ::= (dcl ... Fd ...)) ; main = id
;; 
;;   ;; Semantic Elements
;;   (b          ::= natural)
;;   (δ          ::= natural)
;;   (l          ::= (b δ))
;;   (v          ::= (int n)
;;                   (float f)
;;                   (ptr l)
;;                   undef)
;;   (out        ::= Normal
;;                   Continue
;;                   Break
;;                   Return
;;                   (Return v))
;;   (G          ::= (id↦b ... b↦Fd ...))
;;   (E          ::= (id↦b ...))
;;   (id↦b       ::= (id b))
;;   (b↦Fd       ::= (b Fd))
;;   (M          ::= (b↦δ↦v ...))
;;   (b↦δ↦v      ::= (b δ↦v))
;;   (δ↦v        ::= (δ v))
;;   (κ          ::= int8signed
;;                   int8unsigned
;;                   int16signed
;;                   int16unsigned
;;                   int32
;;                   float32
;;                   float64)
;;   (io-v       ::= (int n)
;;                   (float f))
;;   (io-e       ::= (id io-v ... io-v))
;;   (t          ::= ε
;;                   (io-e t))
;;   (T          ::= ε
;;                   (io-e T))
;;   (B          ::= (terminates t n)
;;                   (diverges T))
;; )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFINE LANGUAGE SYNTAX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-language Clighter
  ;; Types
  (n          ::= integer)
  (id         ::= variable-not-otherwise-mentioned)
  (τ          ::= int
                  void
                  array
                  pointer
                  function
                  struct
                  union)
  (φ          ::= (id τ))

  ;; Expressions
  (a          ::= id
                  n
                  (uop a)
                  (bop a a)
                  (* a)
                  (@ a id)
                  (& a)
                  (? a a a))
  (uop        ::= - ~ !)
  (bop        ::= + - * / %
                  << >> & \| ^
                  < <= > >= == !=)

  ;; Statements
  (s          ::= skip
                  (= a a)
                  (= a (a a ...))
                  (a a ...)
                  (s s)
                  (if a s1 s2)
                  (while a s)
                  (for s a s s)
                  break
                  continue
                  return
                  (return a))

  ;; Functions and Programs
  (dcl        ::= (τ id))
  (F          ::= (τ id dcl ... dcl ... s))
  (Fe         ::= (extern τ id dcl ...))
  (Fd         ::= F Fe)
  (P          ::= (dcl ... Fd ...)) ; main = id

  ;; Semantic Elements
  (b          ::= natural)
  (δ          ::= natural)
  (l          ::= (b δ))
  (v          ::= (int n)
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
  (io-v       ::= (int n))
  (io-e       ::= (id io-v ... io-v))
  (t          ::= hole
                  (io-e t))
  (T          ::= hole
                  (io-e T))
  (B          ::= (terminates t n)
                  (diverges T))
)
(default-language Clighter)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : EXPRESSIONS IN L-VALUE POSITION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (lval I I I I O)
  #:contract (lval G E M a l)

  [
   --------------------------------------------- "1a"
   (lval G (id↦b ... (id b) id↦b ...) M id
         (b 0))]

  [(side-condition ,(not (term (in-domain? E id))))
   --------------------------------------------- "1b"
   (lval (id↦b ... (id b) id↦b ... b↦Fd ...) E M id
         (b 0))]

  [(rval G E M a (ptr l))
   --------------------------------------------- "2"
   (lval G E M (* a) l)]

  [(lval G E M a (b δ))
   (side-condition ,(equal? (term struct) (term (type a)))) ; detect type?
   --------------------------------------------- "3"
   (lval G E M (@ a id) (b ,(+ (term δ) (term (field-offset id a)))))]

  [(lval G E M a l)
   (side-condition ,(equal? (term union) (term (type a)))) ; detect type?
   --------------------------------------------- "4"
   (lval G E M (@ a id) l)])

(define-metafunction Clighter
  in-domain? : E id -> boolean
  [(in-domain? (id↦b ... (id b) id↦b ...) id) ,#t]
  [(in-domain? (id↦b ...) id) ,#f])

; TODO
(define-metafunction Clighter
  type : a -> τ
  [(type a) struct]) ; return type?

; TODO
(define-metafunction Clighter
  field-offset : id a -> δ
  [(field-offset id a) 0])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : EXPRESSIONS IN R-VALUE POSITION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (rval I I I I O)
  #:contract (rval G E M a v)

  [
   --------------------------------------------- "5"
   (rval G E M n (int n))]

  [(lval G E M a l)
   --------------------------------------------- "8"
   (rval G E M a (loadval (typa a) M l))]
  
  [(lval G E M a l)
   --------------------------------------------- "9"
   (rval G E M (& a) (ptr l))]

  [(lval G E M a v)
   --------------------------------------------- "10"
   (rval G E M (uop a) (eval-unop uop v (type a)))]

  [(lval G E M a_1 v_1) (lval G E M a_2 v_2)
   --------------------------------------------- "11"
   (rval G E M (bop a_1 a_2) (eval-binop bop v_1 (type a_1) v_2 (type a_2)))]

  [(lval G E M a_1 v_1)
   (side-condition (is_true v_1 (type a_1)))
   (lval G E M a_2 v_2)
   --------------------------------------------- "12"
   (rval G E M (? a_1 a_2 a_3) v_2)]

  [(lval G E M a_1 v_1)
   (side-condition (is_false v_1 (type a_1)))
   (lval G E M a_3 v_3)
   --------------------------------------------- "13"
   (rval G E M (? a_1 a_2 a_3) v_3)])

(define-metafunction Clighter
  loadval : τ M l -> v
  [(loadval int (b↦δ↦v ... (b (δ v)) b↦δ↦v ...) (b δ)) v]
  [(loadval void (b↦δ↦v ...) (b δ)) ,(raise "attempted loadval with void")]
  [(loadval array (b↦δ↦v ...) (b δ)) (ptr (b δ))]
  [(loadval pointer (b↦δ↦v ... (b (δ v)) b↦δ↦v ...) (b δ)) v]
  [(loadval function (b↦δ↦v ...) (b δ)) (ptr (b δ))]
  [(loadval struct (b↦δ↦v ...) (b δ)) ,(raise "attempted loadval with struct")]
  [(loadval union (b↦δ↦v ...) (b δ)) ,(raise "attempted loadval with union")])

(define-metafunction Clighter
  eval-unop : uop v τ -> v
  ; int
  [(eval-unop - (int n) int) (int ,(- (term n)))]
  [(eval-unop ~ (int n) int) (int ,(bitwise-not (term n)))]
  [(eval-unop ! (int n) int) (int ,(if (equal? 0 (term n)) 1 0))]
  ; else
  [(eval-unop uop v τ) ,(raise "attempted illegal unary operation")])

(define-metafunction Clighter
  eval-binop : bop v τ v τ -> v
  ; int
  [(eval-binop + (int n_1) int (int n_2) int) (int ,(+ (term n_1) (term n_2)))]
  [(eval-binop - (int n_1) int (int n_2) int) (int ,(- (term n_1) (term n_2)))]
  [(eval-binop * (int n_1) int (int n_2) int) (int ,(* (term n_1) (term n_2)))]
  [(eval-binop / (int n_1) int (int n_2) int) (int ,(quotient (term n_1) (term n_2)))]
  [(eval-binop % (int n_1) int (int n_2) int) (int ,(remainder (term n_1) (term n_2)))]
  [(eval-binop << (int n_1) int (int n_2) int) (int ,(arithmetic-shift (term n_1) (term n_2)))]
  [(eval-binop >> (int n_1) int (int n_2) int) (int ,(arithmetic-shift (term n_1) (- (term n_2))))]
  [(eval-binop & (int n_1) int (int n_2) int) (int ,(bitwise-and (term n_1) (term n_2)))]
  [(eval-binop \| (int n_1) int (int n_2) int) (int ,(bitwise-ior (term n_1) (term n_2)))]
  [(eval-binop ^ (int n_1) int (int n_2) int) (int ,(bitwise-xor (term n_1) (term n_2)))]
  [(eval-binop < (int n_1) int (int n_2) int) (int ,(< (term n_1) (term n_2)))]
  [(eval-binop <= (int n_1) int (int n_2) int) (int ,(<= (term n_1) (term n_2)))]
  [(eval-binop > (int n_1) int (int n_2) int) (int ,(> (term n_1) (term n_2)))]
  [(eval-binop >= (int n_1) int (int n_2) int) (int ,(>= (term n_1) (term n_2)))]
  [(eval-binop == (int n_1) int (int n_2) int) (int ,(equal? (term n_1) (term n_2)))]
  [(eval-binop != (int n_1) int (int n_2) int) (int ,(not (equal? (term n_1) (term n_2))))]
  ; pointer
  [(eval-binop + (ptr (b δ)) pointer (int n) int) (pointer (b ,(+ (term δ) (term n))))]
  [(eval-binop - (ptr (b δ)) pointer (int n) int) (pointer (b ,(- (term δ) (term n))))]
  ; else
  [(eval-binop bop v_1 τ_1 v_2 τ_2) ,(raise "attempted illegal binary operation")])

(define-metafunction Clighter
  is_true : v τ -> boolean
  [(is_true v pointer) ,#t]
  [(is_true (int n) int) ,(not (equal? (term n) 0))])

(define-metafunction Clighter
  is_false : v τ -> boolean
  [(is_false v pointer) ,#f]
  [(is_false (int n) int) ,(equal? (term n) 0)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : NON-LOOP NON-SWITCH STATEMENTS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (stmt I I I I O O O)
  #:contract (stmt G E M s t out M)

  [
   --------------------------------------------- "15"
   (stmt G E M skip hole Normal M)]

  [
   --------------------------------------------- "16"
   (stmt G E M break hole Break M)]

  [
   --------------------------------------------- "17"
   (stmt G E M continue hole Continue M)]

  [
   --------------------------------------------- "18"
   (stmt G E M return hole Return M)]

  [(rval G E M a v)
   --------------------------------------------- "19"
   (stmt G E M (return a) hole (Return v) M)]

  [(lval G E M a_1 l)
   (rval G E M a_2 v)
   --------------------------------------------- "20" ; a_1, a_2 types assumed to match
   (stmt G E M (= a_1 a_2) hole Normal (storeval (type a_1) M l v))]

  [(stmt G E M s_1 t_1 Normal M_1)
   (stmt G E M_1 s_2 t_2 out M_2) 
   --------------------------------------------- "21"
   (stmt G E M (s_1 s_2) (in-hole t_1 t_2) out M_2)]

  [(stmt G E M s_1 t out M_1)
   (side-condition (is-not-normal? out))
   --------------------------------------------- "22"
   (stmt G E M (s_1 s_2) t out M_1)])

(define-metafunction Clighter
  storeval : τ M l v -> M
  [(storeval int (b↦δ↦v ... (b (δ v_1)) b↦δ↦v ...) (b δ) v_2) (b↦δ↦v ... (b (δ v_2)) b↦δ↦v ...)]
  [(storeval pointer (b↦δ↦v ... (b (δ v_1)) b↦δ↦v ...) (b δ) v_2) (b↦δ↦v ... (b (δ v_2)) b↦δ↦v ...)]
  [(storeval τ M l v) ,(raise "attempted illegal storeval")])

(define-metafunction Clighter
  is-not-normal? : out -> boolean
  [(is-not-normal? Normal) ,#f]
  [(is-not-normal? out) #,t])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : WHILE AND FOR LOOPS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (loop I I I I O O O)
  #:contract (loop G E M s t out M)

  [(rval G E M a v)
   (side-condition (is_false v (type a)))
   --------------------------------------------- "23"
   (loop G E M (while a s) hole Normal M)]

  [(rval G E M a v)
   (side-condition (is_true v (type a)))
   (stmt G E M s t out M_1)
   --------------------------------------------- "24" ; break or return
   (loop G E M (while a s) t (outcome-update out) M_1)]

  [(rval G E M a v)
   (side-condition (is_true v (type a)))
   (stmt G E M s t_1 Normal M_1)
   (loop G E (while a s) M_1 t_2 out M_2)
   --------------------------------------------- "25a"
   (loop G E M (while a s) (in-hole t_1 t_2) out M_2)]

  [(rval G E M a v)
   (side-condition (is_true v (type a)))
   (stmt G E M s t_1 Continue M_1)
   (loop G E (while a s) M_1 t_2 out M_2)
   --------------------------------------------- "25b"
   (loop G E M (while a s) (in-hole t_1 t_2) out M_2)]

  [(stmt G E M s_1 t_1 Normal M_1)
   (side-condition (is-not-skip? s_1))
   (loop G E M_1 (for skip a s_2 s_3) t_2 out M_2)
   --------------------------------------------- "26"
   (loop G E M (for s_1 a s_2 s_3) (in-hole t_1 t_2) out M_2)]

  [(rval G E M a v)
   (side-condition (is_false v (type a)))
   --------------------------------------------- "27"
   (loop G E M (for skip a s_2 s_3) hole Normal M)]

  [(rval G E M a v)
   (side-condition (is_true v (type a)))
   (stmt G E M s_3 t out M_1)
   --------------------------------------------- "28" ; break or return
   (loop G E M (for skip a s_2 s_3) t (outcome-update out) M_1)]

  [(rval G E M a v)
   (side-condition (is_true v (type a)))
   (stmt G E M s_3 t_1 Normal M_1)
   (stmt G E M_1 s_2 t_2 Normal M_2)
   (loop G E M_2 (for skip a s_2 s_3) t_3 out M_3)
   --------------------------------------------- "29a"
   (loop G E M (for skip a s_2 s_3) (in-hole t_1 (in-hole t_2 t_3)) out M_3)]

  [(rval G E M a v)
   (side-condition (is_true v (type a)))
   (stmt G E M s_3 t_1 Continue M_1)
   (stmt G E M_1 s_2 t_2 Normal M_2)
   (loop G E M_2 (for skip a s_2 s_3) t_3 out M_3)
   --------------------------------------------- "29b"
   (loop G E M (for skip a s_2 s_3) (in-hole t_1 (in-hole t_2 t_3)) out M_3)])

(define-metafunction Clighter
  outcome-update : out -> out
  [(outcome-update Break) Normal]
  [(outcome-update Return) Return]
  [(outcome-update (Return v)) (Return v)]
  [(outcome-update out) ,(raise "invalid loop outcome update")])

(define-metafunction Clighter
  is-not-skip? : s -> boolean
  [(is-not-skip? skip) ,#f]
  [(is-not-skip? s) ,#t])