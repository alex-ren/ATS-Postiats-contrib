ATS-extsolve: External Constraint-Solving for ATS2
==================================================

This is an alternative constraint solver for ATS2. The goal of this
project is to move type checking out of the ATS2 compiler so that we
may incorporate industrial strength decision tools into the constraint
solving process. These tools are developed for specific domains of
program verification. In this project we offer a way to incorporate
them into typechecking so that users could use them to verify a
program under a formal specification in a domain understood by the
tools. Put simply, we envision this project as a way to put automated
and interactive deduction tools directly to work in verifying
properties of programs.

The statics of ATS are, by their nature, very extendable to domains
covered by first order theories. Of course, we are bounded by the
decidability of the segments of first order logic we express and by
the power of the tool we use to decide satisfiability. Our issue is
that the default constraint solver can only decide the satisfiability
of formulas in linear integer arithmetic, and so the statics in ATS
have so far been confined to this theory.

Modern day SMT solvers solve formulas in many more advanced theories
that are of interest to software verification. Some examples include
extensional arrays for modeling memory, bit vectors for checking
machine arithmetic, and even a proposed theory of IEEE floats. We can
leverage these advanced tools by declaring abstract sorts in ATS and
then discharging constraints with these sorts directly to an SMT
solver.

Installation
============

This project provides a program called `patsolve` that reads constraints
in JSON format from standard input and attempts to prove that all
propositions given in the constraints are valid. It uses the Z3 SMT
solver internally for making all decisions and embeds a Python
interpreter so that users can extend the solver with python scripts
using the Z3py library.

## Dependencies

  - python 2.7.x
  - json-c
  - Z3 4.3.1 (should include Z3py)

## Instructions

Make sure you install the latest Postiats compiler and all three of
the above dependencies. In this folder, you should just be able to run

  make

And `patsolve` will be generated in the current directory. To make it
available in your shell, copy it to the `$PATSHOME` bin folder.

  cp patsolve $PATSHOME/bin/

Usage
=====

Normally, constraints will be generated by the ATS2 compiler, `patsopt`,
and piped into `patsolve` for solving. If any constraint is unsolved,
`patsolve` will report an error on stdout. You can use `patsolve` on
just about any ATS2 program with some exceptions (unification sorts).

Let's say you have an ATS file called `test.dats` that you want to
typecheck. You could use `patsolve` by doing the following.

    patsopt --constraint-export -tc -d test.dats | patsolve 

If all is well, you will get a message saying "typechecked successfully!"

If you have used sorts that the default typechecker does not understand,
you will run into problems when you want actually compile your code to C.
_After_ you do typechecking like above, you can run `patsopt` to get a C
file.

    patsopt --constraint-ignore -d test.dats -o test_dats.c

Alternatively, you can use `patscc` to get an actual running file.

    patscc -CSignore -o test test.dats

Scripting patsolve
==================

We embed a python interpreter into `patsolve` so that users can
interact with the SMT solver directly. Users can then provide
interpretations of static functions or define their own macros like
`define-fun` provides in SMT-LIB2. These extensions can be written in
a stand alone python file and then given to `patsolve` during
constraint solving.

Macros
======

As an example, let's say we want to write a function that determines
whether a 32 bit unsigned integer is a power of two. Using bitwise
arithmetic, we can determine this fairly easily, but we want to verify
that the computation does, in fact, determine if a number is a power
of two for _all_ possible inputs. Let's say we have an unsigned
integer type indexed by a static bitvector of length 32.

    abst@ype uint (b:bv32) = uint

Any unsigned integer of this type is restricted to hold the value of
`b`, a bit vector in the ATS statics. Now, we need a predicate to
determine if a bitvector is a power of two.

    stacst power_of_two_bv32: (bv32) -> bool
    stadef power_of_two = power_of_two_bv32 // overloading

By default, `patsolve` will turn this function into an uninterpreted
function in the SMT solver. Using the scripting capability in
`patsolve`, we can turn `power_of_two` into a macro that is true iff
the static bit vector given to it is a power of two. In the Z3py
library, an expression that captures this meaning is build by the
following python function. Note, there is no need to import Z3py into
the code, `patsolve` will do that automatically.

    def power_of_two_bv32 (b):
      """
      A 32 bitvector x is a power of two.
      """
      return reduce(Or, (x == (1 << i) for i in range(32)))

When we pass a python file that defines this function to `patsolve`,
it will replace the static function call with the expression returned
by the python function. This is useful because it allows us to extend
constraint solver's capabilities by simply writing some python code.

We can put these pieces together into the following function that
determines whether an unsigned int is a power of two. Our constraint
solver checks that the result we return is in fact equal to the
straightforward definition we gave in the python file.

    fun
    power_of_two {x:bv32} (
      x: uint (x)
    ): bool (power_of_2 (x)) =
      if x = 0u then
        false
      else
        ((x land (x - 1u)) = 0u)

To check this, you would do the following.

    patsopt --constraint-export -tc -d power.dats | patsolve -s power.py


The ATS2 compiler will extract the constraints and send them to
`patsolve`. In this small function, the constraint is that the boolean
value is equal to the boolean value of the static function call
`power_of_2 (x)`. Note, the `dynamic` type `uint(x)` that isgiven to
the parameter `x` is a singleton type. This means the value of `x` is
restricted to the value of the `static` bit vector `x`. The type we
give to this function's return value is a singleton type as well whose
value must is equal to the static function `power_of_2(x)`.

Interpreted Functions
=====================

Sometimes the functions we want in a domain cannot easily be expressed
by using just a macro. Instead, we would like to provide an interpretation
for a function to the SMT solver. This requires adding assertions to the
internal SMT solver that `patsolve` uses. Since we embed python into
our constraint solver, we provide a module called `patsolve` to python
scripts so that users can add assertions with the familiar Z3 library.

Suppose we want to use a new static type in the ATS statics that represents
an infinite stream of identifiers, which we call stamps. We could call this 
new sort `stampseq` with the following.
  
    sortdef stamp = int

    datasort stampseq = (* abstract *)

We will need some way to construct static sequences. Suppose we want the
following operators.
  
    stacst stampseq_nil : () -> stampseq                 // empty sequence
    stacst stampseq_sing : (stamp) -> stampseq           // single sequence
    stacst stampseq_cons : (stamp, stampseq) -> stampseq // add to front
    stacst stampseq_head : stampseq -> stamp             // get first stamp
    stacst stampseq_tail : stampseq -> stampseq          // skip first stamp

Using these constructors, we are free to index ATS types with `stampseq`, but
the constraints generated with these functions will always be invalid for anything
but the simplest expression. The reason is because we have not given the SMT 
solver any _interpretation_ of these functions. To do this, we could add some
assertions about their behavior to the constraint solver using the following
python code. Suppose we represent a stamp sequence as an array of integers
mapping to integers in the underlying SMT solver.

    import patsolve

    # Get our solver
    s = patsolve.solver

    A = Array("A", IntSort(), IntSort())
    i, j, x = Int("i"), Int("j"), Int("x")

    StampSeqSort = lambda : ArraySort (IntSort(), IntSort())

    # Undefined Section of an Array

    s.add (
        ForAll ([A, i], Implies (i < 0, A[i] == 0))
    )

    # The "nil" sequence

    nil = Function ('stampseq_nil', StampSeqSort())

    s.add (
        ForAll (i, nil()[i] == 0)
    )

    # Sing

    sing = Function ('stampseq_sing', IntSort(), StampSeqSort())

    s.add (
        ForAll ([x, i], Select (sing(x), i) == Select(Store (nil(), 0, x), i))
    )
