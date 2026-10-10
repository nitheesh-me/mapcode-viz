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

$
  I = NN quad quad X_n = [0..n] -> NN_bot quad quad A = NN \
  rho(n) = {i -> bot | i in [0..n]} \
  F(x)_i = cases(
    0 & "if " i = 0,
    1 & "if " i = 1,
    x_(i-1) + x_(i-2) & "if " i >= 2
  ) \
  pi_n (x) = x_n
$

Each step of $F$ recomputes every cell from the previous state. Cell $i$ becomes defined one
step after cells $i-1$ and $i-2$, so the table fills left to right and reaches its fixed point
after $n$ steps; a pre-filled cell never changes again.

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
