#lang racket

(require redex)
(provide (all-defined-out))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFINE LANGUAGE SYNTAX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-language Clighter
  ; Types
  (n          ::= integer)
  (id         ::= variable-not-otherwise-mentioned)
  (τ          ::= int
                  void
                  (array τ n)
                  (pointer τ)
                  (struct id φ ...)
                  (union id φ ...))
  (φ          ::= (id τ))

  ; Expressions
  (a+τ        ::= (a τ))
  (a          ::= id
                  n
                  (sizeof a+τ)
                  (uop a+τ)
                  (bop a+τ a+τ)
                  (* a+τ)
                  (@ a+τ id)
                  (& a+τ)
                  (? a+τ a+τ a+τ))
  (uop        ::= - ~ !)
  (bop        ::= + - * / %
                  << >> & \| ^
                  < <= > >= == !=)

  ; Statements
  (s          ::= skip
                  (= a+τ a+τ)
                  (s s)
                  (if a+τ s s)
                  (while a+τ s)
                  (for s a+τ s s)
                  break
                  continue
                  return
                  (return a+τ))

  ; Programs
  (dcl        ::= (τ id))
  (P          ::= (dcl ... s))

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

  ; Global Environment
  (G          ::= (id↦b ...))
  (id↦b       ::= (id b))

  ; Memory State
  (M          ::= (b↦δ↦v ...))
  (b↦δ↦v      ::= (b δ↦v ...))
  (δ↦v        ::= (δ v)))
(default-language Clighter)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFINE META-FUNCTION HELPERS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; size-of : τ -> natural
; Returns the size of the type "τ"
(define-metafunction Clighter
  size-of : τ -> natural
  [(size-of int) ,4]
  [(size-of void) ,(raise "attempted to get size of void type")]
  [(size-of (array τ n)) ,(* (term (size-of τ)) (term n))]
  [(size-of (pointer τ)) ,8]
  [(size-of (struct id_struct (id_field τ) φ ...)) ,(+ (term (size-of τ)) (term (size-of (struct id_struct φ ...))))]
  [(size-of (struct id_struct)) ,0]
  [(size-of (union id_union (id_field τ) φ ...)) ,(max (term (size-of τ)) (term (size-of (union id_union φ ...))))]
  [(size-of (union id_union)) ,0])

; field-offset : id (φ ...) δ -> δ
; Returns the field offset of field "id" in the struct at block "b" in memory state "M"
(define-metafunction Clighter
  field-offset : id (φ ...) δ -> δ
  [(field-offset id_target ((id_field τ) φ ...) δ)
   (field-offset id_target (φ ...) (term ,(+ (term δ) (term (size-of τ)))))]
  [(field-offset id_target ((id_target τ) φ ...) δ)
   δ]
  [(field-offset id_target () δ)
   ,(raise "attempted to find field offset of non-existent struct field")])

; get-last-block : M -> b
; Returns the next block unallocated in the memory state "M"
(define-metafunction Clighter
  get-last-block : M -> b
  [(get-last-block ())
   0]
  [(get-last-block ((b δ↦v) b↦δ↦v ...))
   ,(max (term b) (term (get-next-block (b↦δ↦v ...))))])

; init-struct-fields : b↦δ↦v δ (φ ...) -> b↦δ↦v
(define-metafunction Clighter
  init-struct-fields : b↦δ↦v δ (φ ...) -> b↦δ↦v
  [(init-struct-fields (b δ↦v ...) δ ((id τ) φ ...))
   (init-struct-fields (b (δ undef) δ↦v ...) ,(+ (term δ) (term (size-of τ))) (φ ...))]
  [(init-struct-fields b↦δ↦v δ ())
   b↦δ↦v])

; init : G M (dcl ...) -> (G M)
; Returns the initial variable environment "G" and memory state "M" provided program declarations "dcl ..."
(define-metafunction Clighter
  init : G M (dcl ...) -> (G M)
  [(init (id↦b ...) (b↦δ↦v ...) ((id (struct id_struct φ ...)) dcl ...))
   (init ((id (term ,(+ 1 (term (get-last-block (b↦δ↦v ...)))))) id↦b ...) ((init-struct-fields ((term ,(+ 1 (term (get-last-block (b↦δ↦v ...)))))) 0 (φ ...)) b↦δ↦v ...) (dcl ...))]
  [(init (id↦b ...) (b↦δ↦v ...) ((id τ) dcl ...))
   (init ((id (term ,(+ 1 (term (get-last-block (b↦δ↦v ...)))))) id↦b ...) (((term ,(+ 1 (term (get-last-block (b↦δ↦v ...))))) (0 undef)) b↦δ↦v ...) (dcl ...))]
  [(init G M ())
   (G M)])

; get-G : (G M) -> G
; Extracts G from the return of the init meta-function
(define-metafunction Clighter
  get-G : (G M) -> G
  [(get-G (G M)) G])

; get-M : (G M) -> M
; Extracts M from the return of the init meta-function
(define-metafunction Clighter
  get-M : (G M) -> M
  [(get-M (G M)) M])

; loadval : τ M l -> v
; Returns the value at location "l" in the memory state "M"
; The type "τ" is used to determine the form the returned value (by value, by reference, or illegal)
(define-metafunction Clighter
  loadval : τ M l -> v
  [(loadval int (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ))
   v]
  [(loadval void (b↦δ↦v ...) (b δ))
   ,(raise "attempted loadval with void")]
  [(loadval (array τ n) (b↦δ↦v ...) (b δ))
   (ptr (b δ))]
  [(loadval (pointer τ) (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ))
   v]
  [(loadval (struct id φ ...) (b↦δ↦v ...) (b δ))
   ,(raise "attempted loadval with struct")]
  [(loadval (union id φ ...) (b↦δ↦v ...) (b δ))
   ,(raise "attempted loadval with union")])

; storeval : τ M l v -> M
; Returns ; The type "τ" is used tthe memory state "M" after placing value "v" at location "l"
; The type "τ" is used to determine if the value is legal to store
(define-metafunction Clighter
  storeval : τ M l v -> M
  [(storeval int (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ) v_new)
   (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v_new) δ↦v_2 ...) b↦δ↦v_2 ...)]
  [(storeval (pointer τ) (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ) v_new)
   (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v_new) δ↦v_2 ...) b↦δ↦v_2 ...)]
  [(storeval τ M l v)
   ,(raise "attempted illegal storeval")])

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
  [(eval-binop + (ptr (b δ)) (pointer τ) (int n) int) (ptr (b ,(+ (term δ) (term n))))]
  [(eval-binop - (ptr (b δ)) (pointer τ) (int n) int) (ptr (b ,(- (term δ) (term n))))]
  ; else
  [(eval-binop bop v_1 τ_1 v_2 τ_2) ,(raise "attempted illegal binary operation")])

; is_true : v τ -> boolean
; Returns the logical "truthiness" of input "v" based on its type "τ"
(define-metafunction Clighter
  is_true : v τ -> boolean
  [(is_true v (pointer τ)) ,#t]
  [(is_true (int n) int) ,(not (equal? (term n) 0))])

; is_false : v τ -> boolean
; Returns the logical "falsiness" of input "v" based on its type "τ"
(define-metafunction Clighter
  is_false : v τ -> boolean
  [(is_false v (pointer τ)) ,#f]
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

; convert-out-to-return : out -> v
; Returns the return value associated with the outcome "out"
(define-metafunction Clighter
  convert-out-to-return : out -> v
  [(convert-out-to-return (Return v)) v]
  [(convert-out-to-return out) undef])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : EXPRESSIONS IN L-VALUE POSITION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (lval I I I O)
  #:contract (lval G M a+τ l)

  ; fetch location of variable "id" in global environment "G"
  [
   --------------------------------------------- "1"
   (lval (id↦b_1 ... (id b) id↦b_2 ... b↦Fd ...) M (id τ)
         (b 0))]

  ; extract location from a pointer expression "a"
  ; (NOTE: for the purposes of assignment to a dereferenced pointer)
  [(rval G M a+τ (ptr l))
   --------------------------------------------- "2"
   (lval G M ((* a+τ) τ)
         l)]

  ; fetch location of field "id" in struct expression "a"
  ; (NOTE: struct fields have offsets from overall struct location)
  [(lval G M ((@ (a (struct id_struct φ_1 ... (id_field τ) φ_2 ...)) id_field) τ)
         (b δ))
   --------------------------------------------- "3"
   (lval G M ((@ (a (struct id_struct φ_1 ... (id_field τ) φ_2 ...)) id_field) τ)
         (b (field-offset id_field (φ_1 ... (id_field τ) φ_2 ...) δ)))]

  ; fetch location of field "id" in union expression "a"
  ; (NOTE: union fields do not have offsets)
  [(lval G M ((@ (a (union id_union φ_1 ... (id_field τ) φ_2 ...)) id_field) τ)
         l)
   --------------------------------------------- "4"
   (lval G M ((@ (a (union id_union φ_1 ... (id_field τ) φ_2 ...)) id_field) τ)
         l)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : EXPRESSIONS IN R-VALUE POSITION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (rval I I I O)
  #:contract (rval G M a+τ v)

  ; wrap integer constant inside of value
  ; (NOTE: integer constant expression "n" gets converted to value "(int n)")
  [
   --------------------------------------------- "5"
   (rval G M (n int)
         (int n))]

  ; inference rule 6 removed - no floating point values

  ; compute size of the type "τ" of expression "a"
  [
   --------------------------------------------- "7"
   (rval G M (sizeof (a τ))
         (int (size-of τ)))]

  ; fetch value from location of expression "a"
  [(lval G M (a τ)
         l)
   --------------------------------------------- "8"
   (rval G M (a τ)
         (loadval τ M l))]

  ; fetch location of expression "a"
  [(lval G M a+τ
         l)
   --------------------------------------------- "9"
   (rval G M (& a+τ)
         (ptr l))]

  ; evaluate unary operation "uop" with evaluation of "a"
  [(rval G M (a τ)
         v)
   --------------------------------------------- "10"
   (rval G M (uop (a τ))
         (eval-unop uop v τ))]

  ; evaluate binary operation "bop" with evaluation of "a_1" and "a_2"
  [(rval G M (a_1 τ_1)
         v_1)
   (rval G M (a_2 τ_2)
         v_2)
   --------------------------------------------- "11"
   (rval G M (bop (a_1 τ_1) (a_2 τ_2))
         (eval-binop bop v_1 τ_1 v_2 τ_2))]

  ; evaluate ternary conditional operator in "a_cond" true case
  [(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is_true v_cond τ_cond))
   (rval G M a+τ_true
         v_true)
   --------------------------------------------- "12"
   (rval G M (? (a_cond τ_cond) a+τ_true a+τ_false)
         v_true)]

  ; evaluate ternary conditional operator in "a_cond" false case
  [(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is_false v_cond τ_cond))
   (rval G M a+τ_false
         v_false)
   --------------------------------------------- "13"
   (rval G M (? (a_cond τ_cond) a+τ_true a+τ_false)
         v_false)])

   ; inference rule 14 removed - no type casts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : STATEMENTS, FOR LOOPS, & WHILE LOOPS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (stmt I I I O O)
  #:contract (stmt G M s out M)

  ; evaluate "skip" statement
  ; (NOTE: "skip" (do-nothing statement) exists for evaluation of for loops)
  [
   --------------------------------------------- "15"
   (stmt G M skip
         Normal M)]

  ; evaluate "break" statement
  ; (NOTE: continuation behavior handled by enclosing loop)
  [
   --------------------------------------------- "16"
   (stmt G M break
         Break M)]

  ; evaluate "continue" statement
  ; (NOTE: continuation behavior handled by enclosing loop)
  [
   --------------------------------------------- "17"
   (stmt G M continue
         Continue M)]

  ; evaluate empty "return" statement
  ; (NOTE: continuation behavior handled by enclosing loop and function)
  [
   --------------------------------------------- "18"
   (stmt G M return
         Return M)]

  ; evaluate valued "(return a+τ)" statement
  ; (NOTE: continuation behavior handled by enclosing loop and function)
  [(rval G M a+τ
         v)
   --------------------------------------------- "19"
   (stmt G M (return a+τ)
         (Return v) M)]

  ; evaluate assignment between expressions
  ; (NOTE: types of expressions "a_1" and "a_2" are assumed to match)
  [(lval G M (a_1 τ_1)
         l)
   (rval G M a+τ_2
         v)
   --------------------------------------------- "20"
   (stmt G M (= (a_1 τ_1) a+τ_2)
         Normal (storeval τ_1 M l v))]

  ; evaluate sequence of expressions where statement one finishes "Normal"
  [(stmt G M s_1
         Normal M_1)
   (stmt G M_1 s_2
         out M_2)
   --------------------------------------------- "21"
   (stmt G M (s_1 s_2)
         out M_2)]

   ; evaluate sequence of expressions where statement one finishes non-"Normal"
  [(stmt G M s_1
         out M_1)
   (side-condition (is-not-normal? out))
   --------------------------------------------- "22"
   (stmt G M (s_1 s_2)
         out M_1)]

  ; exit while loop when condition "a" is false
  [(rval G M (a τ)
         v)
   (side-condition (is_false v τ))
   --------------------------------------------- "23"
   (stmt G M (while (a τ) s)
         Normal M)]

  ; exit while loop when "break" or "return" statement encountered
  ; (NOTE: continue and normal not checked here - handled in following two rules)
  [(rval G M (a τ)
         v)
   (side-condition (is_true v τ))
   (stmt G M s
         out M_1)
   --------------------------------------------- "24"
   (stmt G M (while (a τ) s)
         (loop-exit-out-update out) M_1)]

  ; continue to next while loop iteration under "Normal" behavior
  [(rval G M (a τ)
         v)
   (side-condition (is_true v τ))
   (stmt G M s
         Normal M_1)
   (stmt G M_1 (while (a τ) s)
         out M_2)
   --------------------------------------------- "25a"
   (stmt G M (while (a τ) s)
         out M_2)]

  ; continue to next while loop iteration when "continue" statement encountered
  [(rval G M (a τ)
         v)
   (side-condition (is_true v τ))
   (stmt G M s
         Continue M_1)
   (stmt G M_1 (while (a τ) s)
         out M_2)
   --------------------------------------------- "25b"
   (stmt G M (while (a τ) s)
         out M_2)]

  ; continue to first for loop iteration after evaluation of loop initializer
  [(stmt G M s_init
         Normal M_1)
   (side-condition (is-not-skip? s_init))
   (stmt G M_1 (for skip a s_incr s_body)
         out M_2)
   --------------------------------------------- "26"
   (stmt G M (for s_init a s_incr s_body)
         out M_2)]

  ; exit for loop when condition "a" is false
  [(rval G M (a τ)
         v)
   (side-condition (is_false v τ))
   --------------------------------------------- "27"
   (stmt G M (for skip (a τ) s_incr s_body)
         Normal M)]

  ; exit for loop when "break" or "return" statement encountered
  ; (NOTE: continue and normal not checked here - handled in following two rules)
  [(rval G M (a τ)
         v)
   (side-condition (is_true v τ))
   (stmt G M s_body
         out M_1)
   --------------------------------------------- "28"
   (stmt G M (for skip (a τ) s_incr s_body)
         (loop-exit-out-update out) M_1)]

  ; continue to next for loop iteration under "Normal" behavior
  [(rval G M (a τ)
         v)
   (side-condition (is_true v τ))
   (stmt G M s_body
         Normal M_1)
   (stmt G M_1 s_incr
         Normal M_2)
   (stmt G M_2 (for skip (a τ) s_incr s_body)
         out M_3)
   --------------------------------------------- "29a"
   (stmt G M (for skip (a τ) s_incr s_body)
         out M_3)]

  ; continue to next for loop iteration when "continue" statement encountered
  [(rval G M (a τ)
         v)
   (side-condition (is_true v τ))
   (stmt G M s_3
         Continue M_1)
   (stmt G M_1 s_2
         Normal M_2)
   (stmt G M_2 (for skip (a τ) s_2 s_3)
         out M_3)
   --------------------------------------------- "29b"
   (stmt G M (for skip (a τ) s_2 s_3)
         out M_3)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUDGEMENT : ENTIRE PROGRAMS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-judgment-form Clighter
  #:mode (prog I O O)
  #:contract (prog P v M)

  ; evaluate entire program
  [(stmt (get-G (init () () (dcl ...))) (get-M (init () () (dcl ...))) s
         out M)
   --------------------------------------------- "40"
   (prog (dcl ... s)
         (convert-out-to-return out) M)])