#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Fibonacci
#set math.equation(numbering: none)

Compute the $n$-th Fibonacci number, where $n$ is a non-negative integer.

Formal definition:
$
  "fib"(0) & = 0, \
  "fib"(1) & = 1, \
  "fib"(n) & = "fib"(n-1) + "fib"(n-2) quad "for " n >= 2
$

Examples:
- $"fib"(0) -> 0$
- $"fib"(1) -> 1$
- $"fib"(4) -> 3$
- $"fib"(8) -> 21$

*As mapcode:*

_primitives_: `sum`($+$) is strict, i.e. $bot + v = v + bot = bot$.

#mc-spec(
  state: [For a fixed $n$, cell $i$ of the table $x$ holds $"fib"(i)$ once it is defined and
    $bot$ before that.],
  I: $I = NN$,
  X: $X = X_n = [0..n] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(n) = {i |-> bot | i in [0..n]}$,
  F: $F(x)_i = cases(0 & "if " i = 0, 1 & "if " i = 1, x_(i-1) + x_(i-2) & "if " i >= 2)$,
  pi: $pi = pi_n = x |-> x_n$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = "fib"(i)$,
)
Each step recomputes every cell, but a cell becomes defined only once cells $i-1$ and $i-2$
are, and then gets the value $"fib"(i-1) + "fib"(i-2) = "fib"(i)$ again on every later step;
so defined cells never change, every non-fixed step defines a new cell and $sigma$ decreases,
$"Inv"$ is preserved, and at the fixed point ($sigma = 0$) $pi_n (x) = "fib"(n)$.

#let fib-mc(n) = {
  let rho = n => range(n + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { 0 } else if i == 1 { 1 } else if x.at(i - 1) != none and x.at(i - 2) != none {
      x.at(i - 1) + x.at(i - 2)
    } else { none }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => x.at(n)
  mapcode-viz(
    rho,
    F,
    pi,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask),
    pi_name: [$mpi_#n$],
    group-size: 3,
    spacing: (8mm, 10mm),
  )(n)
}

#let inst = 6
#figure(
  caption: [Fibonacci via mapcode for $n = #inst$.],
  fib-mc(inst),
)
