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
  [(size-of void) ,(raise-argument-error 'size-of "attempted to get size of void type" (term τ))]
  [(size-of (array τ n)) ,(* (term (size-of τ)) (term n))]
  [(size-of (pointer τ)) ,8]
  [(size-of (struct id_struct (id_field τ) φ ...)) ,(+ (term (size-of τ)) (term (size-of (struct id_struct φ ...))))]
  [(size-of (struct id_struct)) ,0]
  [(size-of (union id_union (id_field τ) φ ...)) ,(max (term (size-of τ)) (term (size-of (union id_union φ ...))))]
  [(size-of (union id_union)) ,0])

; field-offset : id (φ ...) δ -> δ
; Returns the "δ" offset of field "id" in the struct with fields "(φ ...)"
(define-metafunction Clighter
  field-offset : id (φ ...) δ -> δ
  [(field-offset id_target ((id_field τ) φ ...) δ)
   ,(if (equal? (term id_target) (term id_field))
       (term δ)
       (term (field-offset id_target (φ ...) ,(+ (term δ) (term (size-of τ))))))]
  [(field-offset id_target () δ)
   ,(raise-argument-error 'field-offset "field id that exists within the struct" (term id_target))])

; get-next-block : M -> b
; Returns the lowest-value unallocated block in the memory state "M"
(define-metafunction Clighter
  get-next-block : M -> b
  [(get-next-block ())
   0]
  [(get-next-block ((b δ↦v ...) b↦δ↦v ...))
   ,(max (term ,(+ 1 (term b))) (term (get-next-block (b↦δ↦v ...))))])

; init-struct-fields : b↦δ↦v δ (φ ...) -> b↦δ↦v
; Initializes a struct by creating δ↦v pairs in block "b" for each field of the struct
; (NOTE: handles nested arrays and structs in-place)
(define-metafunction Clighter
  init-struct-fields : b↦δ↦v δ (φ ...) -> b↦δ↦v
  ; done
  [(init-struct-fields b↦δ↦v δ ())
   b↦δ↦v]
  ; field is an array
  [(init-struct-fields (b δ↦v ...)
                       δ
                       ((id (array τ n)) φ ...))
   (init-struct-fields (init-array (b δ↦v ...) δ τ n)
                       ,(+ (term δ) (term (size-of (array τ n))))
                       (φ ...))]
  ; field is a struct
  [(init-struct-fields (b δ↦v ...)
                       δ
                       ((id (struct id_struct φ_field ...)) φ ...))
   (init-struct-fields (init-struct-fields (b δ↦v ...) δ (φ_field ...))
                       ,(+ (term δ) (term (size-of (struct id_struct φ_field ...))))
                       (φ ...))]
  ; field is something else
  [(init-struct-fields (b δ↦v ...)
                       δ
                       ((id τ) φ ...))
   (init-struct-fields (b δ↦v ... (δ undef))
                       ,(+ (term δ) (term (size-of τ)))
                       (φ ...))])

; init-array : b↦δ↦v δ τ n -> b↦δ↦v
; Initializes an array by creating "n" δ↦v pairs in block "b"
; (NOTE: handles nested arrays and structs in-place)
(define-metafunction Clighter
  init-array : b↦δ↦v δ τ n -> b↦δ↦v
  ; done
  [(init-array (b δ↦v ...) δ τ 0)
   (b δ↦v ...)]
  ; τ is a struct
  [(init-array (b δ↦v ...)
               δ
               (struct id_struct φ ...)
               n)
   (init-array (init-struct-fields (b δ↦v ...) δ (φ ...))
               ,(+ (term δ) (term (size-of (struct id_struct φ ...))))
               (struct id_struct φ ...)
               ,(- (term n) 1))]
  ; τ is an array
  [(init-array (b δ↦v ...)
               δ
               (array τ n_arr)
               n)
   (init-array (init-array (b δ↦v ...) δ τ n_arr)
               ,(+ (term δ) (term (size-of (array τ n_arr))))
               (array τ n_arr)
               ,(- (term n) 1))]
  ; τ is something else
  [(init-array (b δ↦v ...)
               δ
               τ
               n)
   (init-array (b δ↦v ... (δ undef))
               ,(+ (term δ) (term (size-of τ)))
               τ
               ,(- (term n) 1))])

; init : G M (dcl ...) -> (G M)
; Returns the initial variable environment "G" and memory state "M" provided program declarations "dcl ..."
(define-metafunction Clighter
  init : G M (dcl ...) -> (G M)
  ; done
  [(init G M ())
   (G M)]
  ; next dcl is a struct
  [(init (id↦b ...)
         (b↦δ↦v ...)
         (((struct id_struct φ ...) id) dcl ...))
   (init (id↦b ... (id (get-next-block (b↦δ↦v ...))))
         (b↦δ↦v ... (init-struct-fields ((get-next-block (b↦δ↦v ...))) 0 (φ ...)))
         (dcl ...))]
  ; next dcl is an array
  [(init (id↦b ...)
         (b↦δ↦v ...)
         (((array τ n) id) dcl ...))
   (init (id↦b ... (id (get-next-block (b↦δ↦v ...))))
         (b↦δ↦v ... (init-array ((get-next-block (b↦δ↦v ...))) 0 τ n))
         (dcl ...))]
  ; next dcl is something else
  [(init (id↦b ...)
         (b↦δ↦v ...)
         ((τ id) dcl ...))
   (init (id↦b ... (id (get-next-block (b↦δ↦v ...))))
         (b↦δ↦v ... ((get-next-block (b↦δ↦v ...)) (0 undef)))
         (dcl ...))])

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
   ,(raise-argument-error 'loadval "int, array, or pointer" (term void))]
  [(loadval (array τ n) (b↦δ↦v ...) (b δ))
   (ptr (b δ))]
  [(loadval (pointer τ) (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ))
   v]
  [(loadval (struct id φ ...) (b↦δ↦v ...) (b δ))
   ,(raise-argument-error 'loadval "int, array, or pointer" (term (struct id φ ...)))]
  [(loadval (union id φ ...) (b↦δ↦v ...) (b δ))
   ,(raise-argument-error 'loadval "int, array, or pointer" (term (union id φ ...)))]
  [(loadval τ M l)
   ,(raise-argument-error 'loadval "existing location in the memory (SEGFAULT)" (term l))])

; storeval : τ M l v -> M
; Returns the memory state "M" after storing the value "v" at location "l"
; The type "τ" is used to determine if the value is legal to store
(define-metafunction Clighter
  storeval : τ M l v -> M
  [(storeval int (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ) v_new)
   (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v_new) δ↦v_2 ...) b↦δ↦v_2 ...)]
  [(storeval (pointer τ) (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v) δ↦v_2 ...) b↦δ↦v_2 ...) (b δ) v_new)
   (b↦δ↦v_1 ... (b δ↦v_1 ... (δ v_new) δ↦v_2 ...) b↦δ↦v_2 ...)]
  [(storeval τ M l v)
   ,(raise-argument-error 'storeval "int or pointer" (term τ))])

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
  [(eval-unop uop v τ) ,(raise-argument-error 'eval-unop "(int n)" (term τ))])

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
  ; int - relational
  [(eval-binop < (int n_1) int (int n_2) int) (int ,(boolean-to-int (< (term n_1) (term n_2))))]
  [(eval-binop <= (int n_1) int (int n_2) int) (int ,(boolean-to-int (<= (term n_1) (term n_2))))]
  [(eval-binop > (int n_1) int (int n_2) int) (int ,(boolean-to-int (> (term n_1) (term n_2))))]
  [(eval-binop >= (int n_1) int (int n_2) int) (int ,(boolean-to-int (>= (term n_1) (term n_2))))]
  [(eval-binop == (int n_1) int (int n_2) int) (int ,(boolean-to-int (equal? (term n_1) (term n_2))))]
  [(eval-binop != (int n_1) int (int n_2) int) (int ,(boolean-to-int (not (equal? (term n_1) (term n_2)))))]
  ; pointer - arithmetic
  [(eval-binop + (ptr (b δ)) (pointer τ) (int n) int) (ptr (b ,(+ (term δ) (term n))))]
  [(eval-binop + (int n) int (ptr (b δ)) (pointer τ)) (ptr (b ,(+ (term δ) (term n))))]
  [(eval-binop - (ptr (b δ)) (pointer τ) (int n) int) (ptr (b ,(- (term δ) (term n))))]
  ; else
  [(eval-binop bop v_1 τ_1 v_2 τ_2) ,(raise-argument-error 'eval-binop "(int n) or (pointer τ)" (term τ_1))])

; boolean-to-int
; Returns the integer representation of a boolean value
(define (boolean-to-int b)
  (if (equal? #true b)
      1
      0))

; is-true : v τ -> boolean
; Returns the logical "truthiness" of input "v" based on its type "τ"
(define-metafunction Clighter
  is-true : v τ -> boolean
  [(is-true v (pointer τ)) ,#t]
  [(is-true (int n) int) ,(not (equal? (term n) 0))]
  [(is-true v τ) ,(raise-argument-error 'is-true "int or pointer value" (term v))])

; is-false : v τ -> boolean
; Returns the logical "falsiness" of input "v" based on its type "τ"
(define-metafunction Clighter
  is-false : v τ -> boolean
  [(is-false v (pointer τ)) ,#f]
  [(is-false (int n) int) ,(equal? (term n) 0)]
  [(is-false v τ) ,(raise-argument-error 'is-false "int or pointer value" (term v))])

; loop-exit-out-update : out -> out
; Returns the updated outcome "out" post exit of a loop
(define-metafunction Clighter
  loop-exit-out-update : out -> out
  [(loop-exit-out-update Break) Normal]
  [(loop-exit-out-update Return) Return]
  [(loop-exit-out-update (Return v)) (Return v)]
  [(loop-exit-out-update out) ,(raise-argument-error 'loop-exit-out-update "Break, Return, or (Return v)" (term out))])

; is-break-or-return? : out -> boolean
; Returns true if the outcome "out" is "Break", "Return", or "(Return v)"
(define-metafunction Clighter
  is-break-or-return? : out -> boolean
  [(is-break-or-return? Break) #t]
  [(is-break-or-return? Return) #t]
  [(is-break-or-return? (Return v)) #t]
  [(is-break-or-return? out) #f])

; is-not-normal? : out -> boolean
; Returns true if the outcome "out" is not "Normal"
(define-metafunction Clighter
  is-not-normal? : out -> boolean
  [(is-not-normal? Normal) ,#f]
  [(is-not-normal? out) ,#t])

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
   --------------------------------------------- "lval 1: variable"
   (lval (id↦b_1 ... (id b) id↦b_2 ... b↦Fd ...) M (id τ)
         (b 0))]

  ; extract location from a pointer expression "a"
  ; (NOTE: for the purposes of assignment to a dereferenced pointer)
  [(rval G M a+τ (ptr l))
   --------------------------------------------- "lval 2: pointer"
   (lval G M ((* a+τ) τ)
         l)]

  ; fetch location of field "id" in struct expression "a"
  ; (NOTE: struct fields have offsets from overall struct location)
  [(lval G M (a (struct id_struct φ_1 ... (id_field τ) φ_2 ...))
         (b δ))
   --------------------------------------------- "lval 3: struct field"
   (lval G M ((@ (a (struct id_struct φ_1 ... (id_field τ) φ_2 ...)) id_field) τ)
         (b (field-offset id_field (φ_1 ... (id_field τ) φ_2 ...) δ)))]

  ; fetch location of field "id" in union expression "a"
  ; (NOTE: union fields do not have offsets)
  [(lval G M (a (union id_union φ_1 ... (id_field τ) φ_2 ...))
         l)
   --------------------------------------------- "lval 4: union"
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
   --------------------------------------------- "rval 5: int constant"
   (rval G M (n int)
         (int n))]

  ; inference rule 6 removed - no floating point values

  ; compute size of the type "τ" of expression "a"
  [
   --------------------------------------------- "rval 7: sizeof type"
   (rval G M ((sizeof (a τ)) int)
         (int (size-of τ)))]

  ; fetch value from location of expression "a"
  [(lval G M (a τ)
         l)
   --------------------------------------------- "rval 8: load memory"
   (rval G M (a τ)
         (loadval τ M l))]

  ; fetch location of expression "a"
  [(lval G M a+τ
         l)
   --------------------------------------------- "rval 9: address of"
   (rval G M ((& a+τ) τ_outer)
         (ptr l))]

  ; evaluate unary operation "uop" with evaluation of "a"
  [(rval G M (a τ)
         v)
   --------------------------------------------- "rval 10: unary operation"
   (rval G M ((uop (a τ)) τ_outer)
         (eval-unop uop v τ))]

  ; evaluate binary operation "bop" with evaluation of "a_1" and "a_2"
  [(rval G M (a_1 τ_1)
         v_1)
   (rval G M (a_2 τ_2)
         v_2)
   --------------------------------------------- "rval 11: binary operation"
   (rval G M ((bop (a_1 τ_1) (a_2 τ_2)) τ_outer)
         (eval-binop bop v_1 τ_1 v_2 τ_2))]

  ; evaluate ternary conditional operator in "a_cond" true case
  [(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is-true v_cond τ_cond))
   (rval G M a+τ_true
         v_true)
   --------------------------------------------- "rval 12: ternary true"
   (rval G M ((? (a_cond τ_cond) a+τ_true a+τ_false) τ_outer)
         v_true)]

  ; evaluate ternary conditional operator in "a_cond" false case
  [(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is-false v_cond τ_cond))
   (rval G M a+τ_false
         v_false)
   --------------------------------------------- "rval 13: ternary false"
   (rval G M ((? (a_cond τ_cond) a+τ_true a+τ_false) τ_outer)
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
   --------------------------------------------- "stmt 15: skip"
   (stmt G M skip
         Normal M)]

  ; evaluate "break" statement
  ; (NOTE: continuation behavior handled by enclosing loop)
  [
   --------------------------------------------- " stmt16: break"
   (stmt G M break
         Break M)]

  ; evaluate "continue" statement
  ; (NOTE: continuation behavior handled by enclosing loop)
  [
   --------------------------------------------- "stmt 17: continue"
   (stmt G M continue
         Continue M)]

  ; evaluate empty "return" statement
  ; (NOTE: continuation behavior handled by enclosing loop and function)
  [
   --------------------------------------------- "stmt 18: return no value"
   (stmt G M return
         Return M)]

  ; evaluate valued "(return a+τ)" statement
  ; (NOTE: continuation behavior handled by enclosing loop and function)
  [(rval G M a+τ
         v)
   --------------------------------------------- "stmt 19: return with value"
   (stmt G M (return a+τ)
         (Return v) M)]

  ; evaluate assignment between expressions
  ; (NOTE: types of expressions "a_1" and "a_2" are assumed to match)
  [(lval G M (a_1 τ_1)
         l)
   (rval G M a+τ_2
         v)
   --------------------------------------------- "stmt 20: variable assignment"
   (stmt G M (= (a_1 τ_1) a+τ_2)
         Normal (storeval τ_1 M l v))]

  ; evaluate sequence of expressions where statement one finishes "Normal"
  [(stmt G M s_1
         Normal M_1)
   (stmt G M_1 s_2
         out M_2)
   --------------------------------------------- "stmt 21: sequence normal"
   (stmt G M (s_1 s_2)
         out M_2)]

   ; evaluate sequence of expressions where statement one finishes non-"Normal"
  [(stmt G M s_1
         out M_1)
   (side-condition (is-not-normal? out))
   --------------------------------------------- "stmt 22: sequence non-normal"
   (stmt G M (s_1 s_2)
         out M_1)]

  ; evaluate if statement in "a_cond" true case
  [(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is-true v_cond τ_cond))
   (stmt G M s_true
         out M_1)
   --------------------------------------------- "stmt __: if true"
   (stmt G M (if (a_cond τ_cond) s_true s_false)
         out M_1)]

  ; evaluate if statement in "a_cond" false case
  [(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is-false v_cond τ_cond))
   (stmt G M s_false
         out M_1)
   --------------------------------------------- "stmt __: if false"
   (stmt G M (if (a_cond τ_cond) s_true s_false)
         out M_1)]

  ; exit while loop when condition "a" is false
  [(rval G M (a τ)
         v)
   (side-condition (is-false v τ))
   --------------------------------------------- "stmt 23: while false condition"
   (stmt G M (while (a τ) s)
         Normal M)]

  ; exit while loop when "break" or "return" statement encountered
  ; (NOTE: continue and normal not checked here - handled in following two rules)
  [(rval G M (a τ)
         v)
   (side-condition (is-true v τ))
   (stmt G M s
         out M_1)
   (side-condition (is-break-or-return? out))
   --------------------------------------------- "stmt 24: while break or return"
   (stmt G M (while (a τ) s)
         (loop-exit-out-update out) M_1)]

  ; continue to next while loop iteration under "Normal" behavior
  [(rval G M (a τ)
         v)
   (side-condition (is-true v τ))
   (stmt G M s
         Normal M_1)
   (stmt G M_1 (while (a τ) s)
         out M_2)
   --------------------------------------------- "stmt 25a: while next iteration normal"
   (stmt G M (while (a τ) s)
         out M_2)]

  ; continue to next while loop iteration when "continue" statement encountered
  [(rval G M (a τ)
         v)
   (side-condition (is-true v τ))
   (stmt G M s
         Continue M_1)
   (stmt G M_1 (while (a τ) s)
         out M_2)
   --------------------------------------------- "stmt 25b: while next iteration continue"
   (stmt G M (while (a τ) s)
         out M_2)]

  ; continue to first for loop iteration after evaluation of loop initializer
  [(stmt G M s_init
         Normal M_1)
   (side-condition (is-not-skip? s_init))
   (stmt G M_1 (for skip a s_incr s_body)
         out M_2)
   --------------------------------------------- "stmt 26: enter for loop"
   (stmt G M (for s_init a s_incr s_body)
         out M_2)]

  ; exit for loop when condition "a" is false
  [(rval G M (a τ)
         v)
   (side-condition (is-false v τ))
   --------------------------------------------- "stmt 27: for false condition"
   (stmt G M (for skip (a τ) s_incr s_body)
         Normal M)]

  ; exit for loop when "break" or "return" statement encountered
  ; (NOTE: continue and normal not checked here - handled in following two rules)
  [(rval G M (a τ)
         v)
   (side-condition (is-true v τ))
   (stmt G M s_body
         out M_1)
   (side-condition (is-break-or-return? out))
   --------------------------------------------- "stmt 28: for break or return"
   (stmt G M (for skip (a τ) s_incr s_body)
         (loop-exit-out-update out) M_1)]

  ; continue to next for loop iteration under "Normal" behavior
  [(rval G M (a τ)
         v)
   (side-condition (is-true v τ))
   (stmt G M s_body
         Normal M_1)
   (stmt G M_1 s_incr
         Normal M_2)
   (stmt G M_2 (for skip (a τ) s_incr s_body)
         out M_3)
   --------------------------------------------- "stmt 29a: for next iteration normal"
   (stmt G M (for skip (a τ) s_incr s_body)
         out M_3)]

  ; continue to next for loop iteration when "continue" statement encountered
  [(rval G M (a τ)
         v)
   (side-condition (is-true v τ))
   (stmt G M s_3
         Continue M_1)
   (stmt G M_1 s_2
         Normal M_2)
   (stmt G M_2 (for skip (a τ) s_2 s_3)
         out M_3)
   --------------------------------------------- "stmt 29b: for next iteration continue"
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
   --------------------------------------------- "prog 40: evaluate program"
   (prog (dcl ... s)
         (convert-out-to-return out) M)])