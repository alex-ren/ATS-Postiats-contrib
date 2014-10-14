(**
  Some examples of playing with uninterpreted functions.
*)

// Factorial

stacst fact_int: (int) -> int
stadef fact = fact_int

fun 
fact {n:nat} (
  n: int n
): int (fact (n)) = 
  if n = 0 then
    1
  else
    n * fact (pred (n))
    
fun 
fact1 {n:nat} (
  n: int n
): int (fact (n)) = let
  fun loop {i:nat} (
    i: int i, r: int (fact (i))
  ): int (fact (n)) =
    if i = n then
      r
    else let
      val i' = succ (i)
    in
      loop (i', i' * r)
    end
in
  loop (0, 1)
end

// Fibonacci

stacst fib_int: (int) -> int
stadef fib = fib_int

fun 
fib {n:nat} (
  n: int n
): int (fib(n)) = 
  if n < 2 then
    n
  else
    fib (n-1) + fib (n-2)
    
fun 
fib1 {n:nat} (
  n: int n
): int (fib (n)) = let
  //
  fun loop {i:nat | i > 0} (
      i: int i,
      r: int (fib (i)), s: int (fib (i-1))
  ): int (fib (n)) =
    if i = n then
      r
    else
      loop (succ (i), r + s, r)
  //
in
  loop (1, 1, 0)
end

// Euclid's Algorithm

stacst gcd_int: (int, int) -> int
stadef gcd = gcd_int

(**
  Something like mod1 isn't included
  in the prelude.
*)

infix mod1

%{^
#define mod1_int(a, b) (a % b)
%}

extern
fun mod1_int {a,b:nat | b > 0} (
  a: int (a), b: int (b)
): int (a % b) = "mac#"

overload mod1 with mod1_int

fun
gcd {a,b:nat | a > 0} (
  a: int a, b: int b
): int (gcd (a, b)) =
  if b = 0 then
    a
  else
    gcd (b, a mod1 b)
