#lang racket

(require redex)
(require "clighter.rkt")
(require "utils.rkt")







































;;;;;;;;;;;;
;; TRACES ;;
;;;;;;;;;;;;

#| Collatz Conjecture |#
#;(traces run (term ((int start)                                                                         ; int start;
                   (int count)                                                                         ; int count;
                   ,(stmts->seq+term [
                       (= (start int) (19 int))                                                        ; start = 19;
                       (= (count int) (0 int))                                                         ; count = 0;
                       (while ((!= (start int) (1 int)) int)                                           ; while (start != 1)
                              ,(stmts->seq+term [                                                      ; {
                                  (= (count int) ((+ (1 int) (count int)) int))                        ;   count += 1;
                                  (if ((== (1 int) ((% (start int) (2 int)) int)) int)                 ;   if (1 == start % 2)
                                      (= (start int) ((+ (1 int) ((* (3 int) (start int)) int)) int))  ;     start = 3 * start + 1;
                                      (= (start int) ((/ (start int) (2 int)) int)))                   ;   else start /= 2;
                                  ]))                                                                  ; }
                       (return (count int))                                                            ; return count;
                       ]))))



































#| Maximum Array Element |#
#;(traces run (term ((int max)                                                                           ; int max;
                   (int i)                                                                             ; int i;
                   (int j)                                                                             ; int j;
                   ((array (array int 3) 3) arr)                                                       ; int arr[3][3];
                   ((pointer int) arrij)                                                               ; int* arrij;
                   ,(stmts->seq+term [
                       (= (max int) (-1 int))                                                          ; max = -1;
                       (= (arrij (pointer int)) ((& (arr (array (array int 3) 3))) (pointer int)))     ; arrij = &arr;
                       ; initialize array
                       (for (= (i int) (0 int))                                                        ; for (i = 0;
                            ((< (i int) (3 int)) int)                                                  ;      i < 3;
                            (= (i int) ((+ (i int) (1 int)) int))                                      ;      i++)
                            (for (= (j int) (0 int))                                                   ;   for (j = 0;
                                 ((< (j int) (3 int)) int)                                             ;        j < 3;
                                 (= (j int) ((+ (j int) (1 int)) int))                                 ;        j++)
                                 (= ((* ((+ (arrij (pointer int))                                      ;     *(arrij + i * 3 + j) = i * j;  // arrij[i][j] = i * j;
                                            ((+ (j int) ((* (i int) (3 int)) int)) int))
                                         (pointer int))) int)
                                    ((* (i int) (j int)) int))))
                       ; find maximum
                       (for (= (i int) (0 int))                                                        ; for (i = 0;
                            ((< (i int) (3 int)) int)                                                  ;      i < 3;
                            (= (i int) ((+ (i int) (1 int)) int))                                      ;      i++)
                            (for (= (j int) (0 int))                                                   ;   for (j = 0;
                                 ((< (j int) (3 int)) int)                                             ;        j < 3;
                                 (= (j int) ((+ (j int) (1 int)) int))                                 ;        j++)
                                 (if ((> ((* ((+ (arrij (pointer int))                                 ;     if (*(arrij + i * 3 + j) > max)
                                                 ((+ (j int) ((* (i int) (3 int)) int)) int))
                                              (pointer int))) int)
                                         (max int)) int)
                                     (= (max int)                                                      ;        max = *(arrij + i * 3 + j);
                                        ((* ((+ (arrij (pointer int))
                                                ((+ (j int) ((* (i int) (3 int)) int)) int))
                                             (pointer int))) int))
                                     skip)))
                       (return (max int))]))))                                                         ; return max;

































#| Binary Search |#
#;(traces run (term ((int lo)                                                                            ; int lo;
                   (int hi)                                                                            ; int hi;
                   (int mi)                                                                            ; int mi;
                   (int target)                                                                        ; int target;
                   ((array int 10) arr)                                                                ; int arr[10];
                   ((pointer int) arrp)                                                                ; int* arrp;
                   ,(stmts->seq+term [
                       ; initialize array
                       (= (arrp (pointer int)) ((& (arr (array int 10))) (pointer int)))               ; arrp = &arr;
                       (= ((* ((+ (arrp (pointer int)) (0 int)) (pointer int))) int) (20 int))         ; arrp[0] = 20;
                       (= ((* ((+ (arrp (pointer int)) (1 int)) (pointer int))) int) (24 int))         ; arrp[1] = 24;
                       (= ((* ((+ (arrp (pointer int)) (2 int)) (pointer int))) int) (50 int))         ; arrp[2] = 50;
                       (= ((* ((+ (arrp (pointer int)) (3 int)) (pointer int))) int) (58 int))         ; arrp[3] = 58;
                       (= ((* ((+ (arrp (pointer int)) (4 int)) (pointer int))) int) (95 int))         ; arrp[4] = 95;
                       (= ((* ((+ (arrp (pointer int)) (5 int)) (pointer int))) int) (128 int))        ; arrp[5] = 128;
                       (= ((* ((+ (arrp (pointer int)) (6 int)) (pointer int))) int) (572 int))        ; arrp[6] = 572;
                       (= ((* ((+ (arrp (pointer int)) (7 int)) (pointer int))) int) (683 int))        ; arrp[7] = 683;
                       (= ((* ((+ (arrp (pointer int)) (8 int)) (pointer int))) int) (934 int))        ; arrp[8] = 934;
                       (= ((* ((+ (arrp (pointer int)) (9 int)) (pointer int))) int) (1024 int))       ; arrp[9] = 1024;
                       ; binsearch
                       (= (target int) (1024 int))                                                     ; target = 1024;
                       (= (lo int) (0 int))                                                            ; lo = 0;
                       (= (hi int) ((- ((/ ((sizeof (arr (array int 10))) int)                         ; hi = sizeof(arr) / sizeof(int) - 1
                                           ((sizeof (target int)) int)) int)
                                       (1 int)) int))
                       (while ((<= (lo int) (hi int)) int)                                             ; while (lo <= hi)
                              ,(stmts->seq+term [                                                      ; {
                                  (= (mi int) ((/ ((+ (lo int) (hi int)) int) (2 int)) int))           ;   mi = (lo + hi) / 2;
                                  (if ((< ((* ((+ (arrp (pointer int)) (mi int)) (pointer int))) int)  ;   if (arrp[mi] < target)
                                          (target int)) int)
                                      (= (lo int) ((+ (mi int) (1 int)) int))                          ;     lo = mi + 1;
                                      (if ((> ((* ((+ (arrp (pointer int))                             ;   else if (arrp[mi] > target)
                                                      (mi int)) (pointer int))) int)
                                              (target int)) int)
                                          (= (hi int) ((- (mi int) (1 int)) int))                      ;     hi = mi - 1;
                                          (return (mi int))))]))                                       ;   else return mi;
                       (return (-1 int))]))))                                                          ; } return -1;









































#| Removing Node from a Linked List |#
(define NodeT (term (struct Node (val int) (next (pointer void)))))                                    ; typedef struct Node { int val; void* next; } NodeT;
#;(traces run (term ((,NodeT dummy)                                                                      ; NodeT dummy;
                   (,NodeT n0)                                                                         ; NodeT n0;
                   (,NodeT n1)                                                                         ; NodeT n1;
                   (,NodeT n2)                                                                         ; NodeT n2;
                   (,NodeT n3)                                                                         ; NodeT n3;
                   (int toRemove)                                                                      ; int   toRemove;
                   ((pointer void) prev)                                                               ; void* prev;
                   ((pointer void) curr)                                                               ; void* curr;
                   ((pointer void) nullptr)                                                            ; void* nullptr;
                   ,(stmts->seq+term [
                       (= (nullptr (pointer void))                                                     ; nullptr = &nullptr;
                          ((& (nullptr (pointer void))) (pointer (pointer void))))
                       ; Linked List initialization
                       (= ((@ (dummy ,NodeT) next) (pointer void)) ((& (n0 ,NodeT)) (pointer void)))   ; dummy.next = (void*)&n0;
                       (= ((@ (n0 ,NodeT) val) int) (1 int))                                           ; n0.val  = 1;
                       (= ((@ (n0 ,NodeT) next) (pointer void)) ((& (n1 ,NodeT)) (pointer void)))      ; n0.next = (void*)&n1;
                       (= ((@ (n1 ,NodeT) val) int) (2 int))                                           ; n1.val  = 2;
                       (= ((@ (n1 ,NodeT) next) (pointer void)) ((& (n2 ,NodeT)) (pointer void)))      ; n1.next = (void*)&n2;
                       (= ((@ (n2 ,NodeT) val) int) (3 int))                                           ; n2.val  = 3;
                       (= ((@ (n2 ,NodeT) next) (pointer void)) ((& (n3 ,NodeT)) (pointer void)))      ; n2.next = (void*)&n3;
                       (= ((@ (n3 ,NodeT) val) int) (4 int))                                           ; n3.val  = 4;
                       (= ((@ (n3 ,NodeT) next) (pointer void)) (nullptr (pointer void)))              ; n3.next = nullptr;
                       ; Setup remove node
                       (= (toRemove int) (3 int))                                                      ; toRemove = 3;
                       (= (prev (pointer void)) ((& (dummy ,NodeT)) (pointer void)))                   ; prev = (void*)&dummy;
                       (= (curr (pointer void)) ((& (n0 ,NodeT)) (pointer void)))                      ; curr = (void*)&n0;
                       ; Remove Node
                       (while ((!= (curr (pointer void)) (nullptr (pointer void))) int)                ; while (curr != nullptr)
                              ,(stmts->seq+term [                                                      ; {
                                  (if ((== (toRemove int)                                              ;   if (toRemove == ((NodeT*)curr)->val)
                                           ((@ ((* (curr (pointer ,NodeT))) ,NodeT) val) int)) int)
                                      (= ((@ ((* (prev (pointer ,NodeT))),NodeT) next)(pointer void))  ;     ((NodeT*)prev)->next = ((NodeT*)curr)->next;
                                         ((@ ((* (curr (pointer ,NodeT))),NodeT) next)(pointer void)))
                                      (= (prev (pointer void)) (curr (pointer void))))                 ;   else prev = curr;
                                  (= (curr (pointer void))                                             ;   curr = ((NodeT*)curr)->next;
                                     ((@ ((* (curr (pointer ,NodeT))) ,NodeT) next) (pointer void)))
                                  ]))                                                                  ; }
                       (return ((@ (dummy ,NodeT) next) (pointer void)))]))))                          ; return dummy.next;





































;;;;;;;;;;;;;;;;;
;; DERIVATIONS ;;
;;;;;;;;;;;;;;;;;

#| Simple Addition |#
#;(show-derivations (build-derivations (run ((int aaa)                                                   ; int aaa;
                                           (int bbb)                                                   ; int bbb;
                                           (((= (aaa int) (4 int))                                     ; aaa = 4;
                                             (= (bbb int) (5 int)))                                    ; bbb = 5;
                                            (return ((+ (aaa int) (bbb int)) int))))                   ; return aaa + bbb;
                                          ((int 9)                                                     ; // should return 9
                                           ((0 (0 (int 4))) (1 (0 (int 5))))))))                       ; // with mem block 0+0 is a, blk 1+0 is 5
































#| Collatz Conjecture |#
#;(show-derivations (build-derivations (run ((int start)                                                 ; int start;
                                           (int count)                                                 ; int count;
                                           ,(stmts->seq+term [
                                               (= (start int) (2 int))                                 ; start = 2;
                                               (= (count int) (0 int))                                 ; count = 0;
                                               (while ((!= (start int) (1 int)) int)                   ; while (start != 1)
                                                      ,(stmts->seq+term [                              ; {
                                                          (= (count int)                               ;   count += 1;
                                                             ((+ (1 int) (count int)) int))
                                                          (if ((== (1 int)                             ;   if (1 == start % 2)
                                                                   ((% (start int) (2 int)) int)) int)
                                                              (= (start int)                           ;     start = 3 * start + 1;
                                                                 ((+ (1 int)
                                                                     ((* (3 int) (start int)) int))
                                                                  int))
                                                              (= (start int)                           ;   else start /= 2;
                                                                 ((/ (start int) (2 int)) int)))
                                                          ]))
                                               (return (count int))                                    ; return count
                                               ]))
                                          ((int 1)                                                     ; // should return 1
                                           ((0 (0 (int 1))) (1 (0 (int 1))))))))                       ; // with mem block 0+0 is start, 1+0 is count








