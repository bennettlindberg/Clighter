# Clighter

***A mechanized big-step operational semantics for a subset of the C programming language.***

- **Authors**: Bennett Lindberg and Jerry Lu
- **Additional Credits**: Sandrine Blazy, Xavier Leroy, and Professor Christos Dimoulas

## What is it?

Clight*er* is a programming language that is a subset of C*light*, the source-code language for the [CompCert](https://compcert.org/) verified C compiler headed by Xavier Leroy. CompCert is "verified" in the sense that the observable behavior of its source programs and output programs have been proven to be identical in all valid scenarios. CompCert uses a subset of C called Clight as its source language, which is implemented based on a formal big-step operational semantics. Clight removes several ambiguities of the C language, including the behavior of expressions with side effects.

As part of COMP_SCI 424, a graduate-level Programming Languages course, I developed Clighter alongside Master's Degree student [Jerry Lu](https://github.com/Viyerelu23333). Clighter is implemented as a mechanized big-step operational semantics written in [PLT Redex](https://redex.racket-lang.org/). PLT Redex is a language used for formally defining the syntax and mechanizing the evaluation of programming languages. The operational semantics mechanized by Clighter are sourced from the original Clight [paper](https://xavierleroy.org/publi/Clight.pdf) written by Sandrine Blazy and Xavier Leroy.

The goal of writing Clighter was to gain hands-on experience writing an operational semantics and using PLT Redex. More concretely, we sought to match the behavior of C with Clighter by transpiling the operational semantics for Clight to PLT Redex. Rigorous testing informally demonstrated that our implementation matches the expected C behavior for all our targeted scenarios, which included branching, loops, pointers, structs, and several other interesting C features.

## Repository Structure

This repository contains the following files:
- `clighter.rkt`: The main file that defines the syntax and big-step reduction rules.
- `clighter-tests.rkt`: A large test suite that tests the implementation of Clighter.
- `clighter-programs.rkt`: A collection of example programs written in Clighter (with equivalent Clight code).
- `docs/Background-Presentation.pdf`: A PDF presentation that provides background information on Clight.

## Implementation

The `clighter.rkt` file defines the syntax and big-step reduction rules for Clighter.

#### Example Syntax Definitions

```racket
(v          ::= (int n)
                  (ptr l)
                  undef)
```
*Values (v) may be integers, pointers to a location in memory, or undefined.*

```racket
(dcl        ::= (τ id))
(P          ::= (dcl ... s))
```
*Programs (P) consist of a variadic number of declarations and a single statement to execute. Declarations (dcl) each contain a type and an identifier.*

#### Example Reduction Rules

```racket
[(rval G M (a_cond τ_cond)
         v_cond)
   (side-condition (is-false v_cond τ_cond))
   (stmt G M s_false
         out M_1)
   --------------------------------------------- "stmt __: if false"
   (stmt G M (if (a_cond τ_cond) s_true s_false)
         out M_1)]
```
*This rule handles the case where an `if` statement is being evaluated and the condition's statement evaluates to `false`. In this case, the false branch's statement should be executed next.*

```racket
  [(rval G M (a_1 τ_1)
         v_1)
   (rval G M (a_2 τ_2)
         v_2)
   --------------------------------------------- "rval 11: binary operation"
   (rval G M ((bop (a_1 τ_1) (a_2 τ_2)) τ_outer)
         (eval-binop bop v_1 τ_1 v_2 τ_2))]
```
*This rule handles the care where a binary operation, such as `*` or `+`, is being evaluated. Here, the right and left operands are evaluated and the final result is the result of the binary operation executed against the evaluated operands.*

## Testing

A large test suite for Clighter's implementation can be found in the `clighter-tests.rkt` file.

#### Example Tests

```racket
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (while ((- (10 int) (11 int)) int)
                                  ((= (aaa int)
                                      (30 int))
                                   break))
                           Normal
                           ((0 (0 (int 30))))))
```
*This test checks that assigning a variable (here, `aaa` gets assigned to `30`) executes correctly when inside of a `while` loop, and that `while` loops exit when a `break` statement is encountered.*

```racket
(test-judgment-holds (stmt ((aaa 0))
                           ((0 (0 (int 4))))
                           (while ((- (10 int) (10 int)) int)
                                  (= (aaa int)
                                     (30 int)))
                           Normal
                           ((0 (0 (int 4))))))
```
*This test ensures that `while` loops exit when the loop condition evaluates to `0`. Here, `aaa` is never set to `30` because the body of the `while` loop never executes.*

## Examples

Example programs written in Clighter are provided in the `clighter-programs.rkt` file. In `clighter-programs.rkt`, the Clighter code is written on the left, and the corresponding C code is written on the right.

In the file, the following programs are given as examples:
- The Collatz Conjecture
- Maximum Array Element Identification
- Binary Search
- Linked List Node Removal
