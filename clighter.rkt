#lang racket

(require redex)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFINE LANGUAGE SYNTAX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-language Clighter
  ; Types
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

  ; Expressions
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

  ; Statements
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

  ; Functions and Programs
  (dcl        ::= (τ id))
  (F          ::= (τ id dcl ... dcl ... s))
  (Fe         ::= (extern τ id dcl ...))
  (Fd         ::= F Fe)
  (P          ::= (dcl ... Fd ...)) ; main = id

  ; Locations
  (b          ::= natural)
  (δ          ::= natural)
  (l          ::= (b δ))

  ; Values
  (v          ::= (int n)
                  (ptr l)
                  undef)

  ; Outcomes
  (out        ::= Normal
                  Continue
                  Break
                  Return
                  (Return v))

  ; Environments
  (G          ::= (id↦b ... b↦Fd ...))
  (E          ::= (id↦b ...))
  (id↦b       ::= (id b))
  (b↦Fd       ::= (b Fd))
  (M          ::= (b↦δ↦v ...))
  (b↦δ↦v      ::= (b δ↦v))
  (δ↦v        ::= (δ v))

  ; Traces and Program Results
  (io-v       ::= (int n))
  (io-e       ::= (id io-v ... io-v))
  (t          ::= (io-e ...))
  (B          ::= (terminates t n)
                  (diverges t))
)
(default-language Clighter)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFINE META-FUNCTION HELPERS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; in-E-domain? : E id -> boolean
; Returns true if identifier "id" is in local environment "E"
(define-metafunction Clighter
  in-E-domain? : E id -> boolean
  [(in-E-domain? (id↦b ... (id b) id↦b ...) id) ,#t]
  [(in-E-domain? (id↦b ...) id) ,#f])

; TODO
; type : a -> τ
; Returns the type of the evaluation of expression "a"
(define-metafunction Clighter
  type : a -> τ
  [(type a) struct])

; TODO
; field-offset : id a -> δ
; Returns the natural "δ" field offset of field "id" in expression "a"
; Expression "a" is expected to have type "struct" or "union"
(define-metafunction Clighter
  field-offset : id a -> δ
  [(field-offset id a) 0])

; loadval : τ M l -> v
; Returns the value at location "l" in the memory state "M"
; The type "τ" is used to determine the form the returned value (by value, by reference, or illegal)
(define-metafunction Clighter
  loadval : τ M l -> v
  [(loadval int (b↦δ↦v ... (b (δ v)) b↦δ↦v ...) (b δ)) v]
  [(loadval void (b↦δ↦v ...) (b δ)) ,(raise "attempted loadval with void")]
  [(loadval array (b↦δ↦v ...) (b δ)) (ptr (b δ))]
  [(loadval pointer (b↦δ↦v ... (b (δ v)) b↦δ↦v ...) (b δ)) v]
  [(loadval function (b↦δ↦v ...) (b δ)) (ptr (b δ))]
  [(loadval struct (b↦δ↦v ...) (b δ)) ,(raise "attempted loadval with struct")]
  [(loadval union (b↦δ↦v ...) (b δ)) ,(raise "attempted loadval with union")])

; storeval : τ M l v -> M
; Returns ; The type "τ" is used tthe memory state "M" after placing value "v" at location "l"
; The type "τ" is used to determine if the value is legal to store
(define-metafunction Clighter
  storeval : τ M l v -> M
  [(storeval int (b↦δ↦v ... (b (δ v_1)) b↦δ↦v ...) (b δ) v_2) (b↦δ↦v ... (b (δ v_2)) b↦δ↦v ...)]
  [(storeval pointer (b↦δ↦v ... (b (δ v_1)) b↦δ↦v ...) (b δ) v_2) (b↦δ↦v ... (b (δ v_2)) b↦δ↦v ...)]
  [(storeval τ M l v) ,(raise "attempted illegal storeval")])

; eval-unop : uop v τ -> v
; Returns the evaluation of the unary operation "uop" on input "v"
; The type "τ" is used to determine the legality of the operation
(define-metafunction Clighter
  eval-unop : uop v τ -> v
  ; int
  [(eval-unop - (int n) int) (int ,(- (term n)))]
  [(eval-unop ~ (int n) int) (int ,(bitwise-not (term n)))]
  [(eval-unop ! (int n) int) (int ,(if (equal? 0 (term n)) 1 0))]
  ; else
  [(eval-unop uop v τ) ,(raise "attempted illegal unary operation")])

; eval-binop : bop v τ v τ -> v
; Returns the evaluation of the binary operation "bop" on inputs "v"
; The types "τ" are used to determine the legality of the operation
(define-metafunction Clighter
  eval-binop : bop v τ v τ -> v
  ; int - arithmetic
  [(eval-binop + (int n_1) int (int n_2) int) (int ,(+ (term n_1) (term n_2)))]
  [(eval-binop - (int n_1) int (int n_2) int) (int ,(- (term n_1) (term n_2)))]
  [(eval-binop * (int n_1) int (int n_2) int) (int ,(* (term n_1) (term n_2)))]
  [(eval-binop / (int n_1) int (int n_2) int) (int ,(quotient (term n_1) (term n_2)))]
  [(eval-binop % (int n_1) int (int n_2) int) (int ,(remainder (term n_1) (term n_2)))]
  ; int - bitwise
  [(eval-binop << (int n_1) int (int n_2) int) (int ,(arithmetic-shift (term n_1) (term n_2)))]
  [(eval-binop >> (int n_1) int (int n_2) int) (int ,(arithmetic-shift (term n_1) (- (term n_2))))]
  [(eval-binop & (int n_1) int (int n_2) int) (int ,(bitwise-and (term n_1) (term n_2)))]
  [(eval-binop \| (int n_1) int (int n_2) int) (int ,(bitwise-ior (term n_1) (term n_2)))]
  [(eval-binop ^ (int n_1) int (int n_2) int) (int ,(bitwise-xor (term n_1) (term n_2)))]
  ; itn - relational
  [(eval-binop < (int n_1) int (int n_2) int) (int ,(< (term n_1) (term n_2)))]
  [(eval-binop <= (int n_1) int (int n_2) int) (int ,(<= (term n_1) (term n_2)))]
  [(eval-binop > (int n_1) int (int n_2) int) (int ,(> (term n_1) (term n_2)))]
  [(eval-binop >= (int n_1) int (int n_2) int) (int ,(>= (term n_1) (term n_2)))]
  [(eval-binop == (int n_1) int (int n_2) int) (int ,(equal? (term n_1) (term n_2)))]
  [(eval-binop != (int n_1) int (int n_2) int) (int ,(not (equal? (term n_1) (term n_2))))]
  ; pointer - arithmetic
  [(eval-binop + (ptr (b δ)) pointer (int n) int) (pointer (b ,(+ (term δ) (term n))))]
  [(eval-binop - (ptr (b δ)) pointer (int n) int) (pointer (b ,(- (term δ) (term n))))]
  ; else
  [(eval-binop bop v_1 τ_1 v_2 τ_2) ,(raise "attempted illegal binary operation")])

; is_true : v τ -> boolean
; Returns the logical "truthiness" of input "v" based on its type "τ"
(define-metafunction Clighter
  is_true : v τ -> boolean
  [(is_true v pointer) ,#t]
  [(is_true (int n) int) ,(not (equal? (term n) 0))])

; is_false : v τ -> boolean
; Returns the logical "falsiness" of input "v" based on its type "τ"
(define-metafunction Clighter
  is_false : v τ -> boolean
  [(is_false v pointer) ,#f]
  [(is_false (int n) int) ,(equal? (term n) 0)])

; loop-exit-out-update : out -> out
; Returns the updated outcome "out" post exit of a loop
(define-metafunction Clighter
  loop-exit-out-update : out -> out
  [(loop-exit-out-update Break) Normal]
  [(loop-exit-out-update Return) Return]
  [(loop-exit-out-update (Return v)) (Return v)]
  [(loop-exit-out-update out) ,(raise "encountered invalid outcome update on loop exit")])

; is-not-normal? : out -> boolean
; Returns true if the outcome "out" is not "Normal"
(define-metafunction Clighter
  is-not-normal? : out -> boolean
  [(is-not-normal? Normal) ,#f]
  [(is-not-normal? out) #,t])

; is-not-skip? : s -> boolean
; Returns true if the statement "s" is not "skip"
(define-metafunction Clighter
  is-not-skip? : s -> boolean
  [(is-not-skip? skip) ,#f]
  [(is-not-skip? s) ,#t])

; convert-out-to-return : out τ -> v
; Returns the return value associated with the outcome "out"
(define-metafunction Clighter
  convert-out-to-return : out τ -> v
  [(convert-out-to-return Normal void) undef]
  [(convert-out-to-return Return void) undef]
  [(convert-out-to-return Return(v) void) ,(raise "attempted to return value from void function")]
  [(convert-out-to-return Return(v) τ) v]
  [(convert-out-to-return out τ) ,(raise "attempted illegal function return")])

; concat-trace : t t -> t
; Returns the concatenation of two traces, with "t_1" before "t_2"
(define-metafunction Clighter
  concat-trace : t t -> t
  [(concat-trace (io-e io-e_1 ...) (io-e_2 ...))
   (concat-trace (io-e_1 ...) (io-e io-e_2 ...))]
  [(concat-trace () (io-e_2 ...))
   (io-e_2 ...)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : EXPRESSIONS IN L-VALUE POSITION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (lval I I I I O)
  #:contract (lval G E M a l)

  ; fetch location of variable "id" in local environment "E"
  [
   --------------------------------------------- "1a"
   (lval G (id↦b_1 ... (id b) id↦b_2 ...) M id
         (b 0))]

  ; fetch location of variable "id" in global environment "G"
  [(side-condition ,(not (term (in-E-domain? E id))))
   --------------------------------------------- "1b"
   (lval (id↦b_1 ... (id b) id↦b_2 ... b↦Fd ...) E M id
         (b 0))]

  ; extract location from a pointer expression "a"
  ; (NOTE: for the purposes of assignment to a dereferenced pointer)
  [(rval G E M a (ptr l))
   --------------------------------------------- "2"
   (lval G E M (* a)
         l)]

  ; TODO
  ; fetch location of field "id" in struct expression "a"
  ; (NOTE: struct fields have offsets from overall struct location)
  [(lval G E M a
         (b δ))
   (side-condition ,(equal? (term struct)
                            (term (type a)))) ; detect type?
   --------------------------------------------- "3"
   (lval G E M (@ a id)
         (b ,(+ (term δ) (term (field-offset id a)))))]

  ; TODO
  ; fetch location of field "id" in union expression "a"
  ; (NOTE: union fields do not have offsets)
  [(lval G E M a
         l)
   (side-condition ,(equal? (term union)
                            (term (type a)))) ; detect type?
   --------------------------------------------- "4"
   (lval G E M (@ a id)
         l)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : EXPRESSIONS IN R-VALUE POSITION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (rval I I I I O)
  #:contract (rval G E M a v)

  ; wrap integer constant inside of value
  ; (NOTE: integer constant expression "n" gets converted to value "(int n)")
  [
   --------------------------------------------- "5"
   (rval G E M n
         (int n))]

  ; inference rule 6 removed - no floating point values

  ; inference rule 7 removed - no differing type sizes

  ; fetch value from location of expression "a"
  [(lval G E M a
         l)
   --------------------------------------------- "8"
   (rval G E M a
         (loadval (typa a) M l))]

  ; fetch location of expression "a"
  [(lval G E M a
         l)
   --------------------------------------------- "9"
   (rval G E M (& a)
         (ptr l))]

  ; evaluate unary operation "uop" with evaluation of "a"
  [(rval G E M a
         v)
   --------------------------------------------- "10"
   (rval G E M (uop a)
         (eval-unop uop v (type a)))]

  ; evaluate binary operation "bop" with evaluation of "a_1" and "a_2"
  [(rval G E M a_1
         v_1)
   (rval G E M a_2
         v_2)
   --------------------------------------------- "11"
   (rval G E M (bop a_1 a_2)
         (eval-binop bop v_1 (type a_1) v_2 (type a_2)))]

  ; evaluate ternary conditional operator in "a_cond" true case
  [(rval G E M a_cond
         v_cond)
   (side-condition (is_true v_cond (type a_cond)))
   (rval G E M a_true
         v_true)
   --------------------------------------------- "12"
   (rval G E M (? a_cond a_true a_false)
         v_true)]

  ; evaluate ternary conditional operator in "a_cond" false case
  [(rval G E M a_cond
         v_cond)
   (side-condition (is_false v_cond (type a_cond)))
   (rval G E M a_false
         v_false)
   --------------------------------------------- "13"
   (rval G E M (? a_cond a_true a_false)
         v_false)])

   ; inference rule 14 removed - no type casts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : NON-LOOP NON-SWITCH STATEMENTS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (stmt I I I I O O O)
  #:contract (stmt G E M s t out M)

  ; evaluate "skip" statement
  ; (NOTE: "skip" (do-nothing statement) exists for evaluation of for loops)
  [
   --------------------------------------------- "15"
   (stmt G E M skip
         () Normal M)]

  ; evaluate "break" statement
  ; (NOTE: continuation behavior handled by enclosing loop)
  [
   --------------------------------------------- "16"
   (stmt G E M break
         () Break M)]

  ; evaluate "continue" statement
  ; (NOTE: continuation behavior handled by enclosing loop)
  [
   --------------------------------------------- "17"
   (stmt G E M continue
         () Continue M)]

  ; evaluate empty "return" statement
  ; (NOTE: continuation behavior handled by enclosing loop and function)
  [
   --------------------------------------------- "18"
   (stmt G E M return
         () Return M)]

  ; evaluate valued "(return a)" statement
  ; (NOTE: continuation behavior handled by enclosing loop and function)
  [(rval G E M a
         v)
   --------------------------------------------- "19"
   (stmt G E M (return a)
         () (Return v) M)]

  ; evaluate assignment between expressions
  ; (NOTE: types of expressions "a_1" and "a_2" are assumed to match)
  [(lval G E M a_1
         l)
   (rval G E M a_2
         v)
   --------------------------------------------- "20"
   (stmt G E M (= a_1 a_2)
         () Normal (storeval (type a_1) M l v))]

  ; evaluate sequence of expressions where statement one finishes "Normal"
  [(stmt G E M s_1
         t_1 Normal M_1)
   (stmt G E M_1 s_2
         t_2 out M_2) 
   --------------------------------------------- "21"
   (stmt G E M (s_1 s_2)
         (concat-trace t_1 t_2) out M_2)]

   ; evaluate sequence of expressions where statement one finishes non-"Normal"
  [(stmt G E M s_1
         t out M_1)
   (side-condition (is-not-normal? out))
   --------------------------------------------- "22"
   (stmt G E M (s_1 s_2)
         t out M_1)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : WHILE AND FOR LOOPS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (loop I I I I O O O)
  #:contract (loop G E M s t out M)

  ; exit while loop when condition "a" is false
  [(rval G E M a
         v)
   (side-condition (is_false v (type a)))
   --------------------------------------------- "23"
   (loop G E M (while a s)
         () Normal M)]

  ; exit while loop when "break" or "return" statement encountered
  ; (NOTE: continue and normal not checked here - handled in following two rules)
  [(rval G E M a
         v)
   (side-condition (is_true v (type a)))
   (stmt G E M s
         t out M_1)
   --------------------------------------------- "24"
   (loop G E M (while a s)
         t (loop-exit-out-update out) M_1)]

  ; continue to next while loop iteration under "Normal" behavior
  [(rval G E M a
         v)
   (side-condition (is_true v (type a)))
   (stmt G E M s
         t_1 Normal M_1)
   (loop G E M_1 (while a s)
         t_2 out M_2)
   --------------------------------------------- "25a"
   (loop G E M (while a s)
         (concat-trace t_1 t_2) out M_2)]

  ; continue to next while loop iteration when "continue" statement encountered
  [(rval G E M a
         v)
   (side-condition (is_true v (type a)))
   (stmt G E M s
         t_1 Continue M_1)
   (loop G E M_1 (while a s)
         t_2 out M_2)
   --------------------------------------------- "25b"
   (loop G E M (while a s)
         (concat-trace t_1 t_2) out M_2)]

  ; continue to first for loop iteration after evaluation of loop initializer
  [(stmt G E M s_init
         t_1 Normal M_1)
   (side-condition (is-not-skip? s_init))
   (loop G E M_1 (for skip a s_incr s_body)
         t_2 out M_2)
   --------------------------------------------- "26"
   (loop G E M (for s_init a s_incr s_body)
         (concat-trace t_1 t_2) out M_2)]

  ; exit for loop when condition "a" is false
  [(rval G E M a
         v)
   (side-condition (is_false v (type a)))
   --------------------------------------------- "27"
   (loop G E M (for skip a s_incr s_body)
         () Normal M)]

  ; exit for loop when "break" or "return" statement encountered
  ; (NOTE: continue and normal not checked here - handled in following two rules)
  [(rval G E M a
         v)
   (side-condition (is_true v (type a)))
   (stmt G E M s_body
         t out M_1)
   --------------------------------------------- "28"
   (loop G E M (for skip a s_incr s_body)
         t (loop-exit-out-update out) M_1)]

  ; continue to next for loop iteration under "Normal" behavior
  [(rval G E M a
         v)
   (side-condition (is_true v (type a)))
   (stmt G E M s_body
         t_1 Normal M_1)
   (stmt G E M_1 s_incr
         t_2 Normal M_2)
   (loop G E M_2 (for skip a s_incr s_body)
         t_3 out M_3)
   --------------------------------------------- "29a"
   (loop G E M (for skip a s_incr s_body)
         (concat-trace t_1 (concat-trace t_2 t_3)) out M_3)]

  ; continue to next for loop iteration when "continue" statement encountered
  [(rval G E M a
         v)
   (side-condition (is_true v (type a)))
   (stmt G E M s_3
         t_1 Continue M_1)
   (stmt G E M_1 s_2
         t_2 Normal M_2)
   (loop G E M_2 (for skip a s_2 s_3)
         t_3 out M_3)
   --------------------------------------------- "29b"
   (loop G E M (for skip a s_2 s_3)
         (concat-trace t_1 (concat-trace t_2 t_3)) out M_3)])

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; JUDGEMENT : FUNCTION CALLS ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (define-judgment-form Clighter
;;   #:mode (call I I I I O O O)
;;   #:contract (call G E M s t v M)
;; 
;;   ; TODO
;;   [(rval (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M a_1 (ptr (b 0)))
;;    (rval-> (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M a ... v ...) ; rval evaluate multiple args?
;;    ; type_of_fundef ???
;;    (invo (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) Fd v ... M t v_1 M_1)
;;    --------------------------------------------- "30"
;;    (call (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M (a_1 a ...) t v_1 M_1)]
;; 
;;   ; TODO
;;   [(lval (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M a_2 l)
;;    (rval (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M a_1 (ptr (b 0)))
;;    (rval-> (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M a ... v ...) ; rval evaluate multiple args?
;;    ; type_of_fundef ???
;;    (invo (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) Fd v ... M t v_1 M_1)
;;    --------------------------------------------- "31"
;;    (call (id↦b ... b↦Fd_1 ... (b Fd) b↦Fd_2 ...) E M (= a_2 (a_1 a ...)) t v_1 (storeval (type a_2) M_1 l v_1))])
;; 
;; (define-judgment-form Clighter
;;   #:mode (rval-> I I I I I O O)
;;   #:contract (rval-> G E M a ... v ...)
;; 
;;   [(rval G E M a_1 v_1)
;;    (rval-> G E M a ... v ...)
;;    --------------------------------------------- "rval->"
;;    (rval-> G E M a_1 a ... v_1 v ...)])
;; 
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; JUDGEMENT : FUNCTION INVOCATIONS ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (define-judgment-form Clighter
;;   #:mode (invo I I I I I O O O)
;;   #:contract (invo G M Fd v ... t v M)
;; 
;;   [()
;;    --------------------------------------------- "32"
;;    (invo G M F v ... t v_1 (free M_3 b ...))]
;; 
;;   [()
;;    --------------------------------------------- "33"
;;    (invo G M Fe v ... t v_1 M)])