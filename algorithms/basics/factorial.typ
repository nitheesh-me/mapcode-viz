#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Factorial
#set math.equation(numbering: none)

Compute the factorial $n!$ of a non-negative integer $n$.

Formal definition:
$
  0! & = 1, \
  n! & = n dot (n-1)! quad "for " n >= 1
$

Examples:
- $0! -> 1$
- $1! -> 1$
- $5! -> 120$
- $6! -> 720$

*As mapcode:*

_primitives_: `product`($dot$) is strict, i.e. $i dot bot = bot$.

#mc-spec(
  state: [For a fixed $n$, cell $i$ of the table $x$ holds $i!$ once it is defined and $bot$
    before that.],
  I: $I = NN$,
  X: $X = X_n = [0..n] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(n) = {i |-> bot | i in [0..n]}$,
  F: $F(x)_i = cases(1 & "if " i = 0, i dot x_(i-1) & "if " i >= 1)$,
  pi: $pi = pi_n = x |-> x_n$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = i!$,
)
Cell $i$ becomes defined one step after cell $i-1$ and, being recomputed from a correct
neighbour, never changes afterwards, so every non-fixed step defines a new cell and $sigma$
drops by one; $F$ only writes $1 = 0!$ or $i dot (i-1)! = i!$, so $"Inv"$ is preserved, and at
the fixed point ($sigma = 0$, after $n+1$ steps) $pi_n (x) = x_n = n!$.

#let fact-mc(n) = {
  let rho = n => range(n + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { 1 } else if x.at(i - 1) != none { i * x.at(i - 1) } else { none }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => x.at(n)
  mapcode-viz(
    rho,
    F,
    pi,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, width: 2.3em, vertical: true),
    pi_name: [$mpi_#n$],
    sigma: x => x.filter(v => v == none).len(),
    group-size: 4,
    spacing: (8mm, 10mm),
  )(n)
}

#let inst = 6
#figure(
  caption: [Factorial via mapcode for $n = #inst$; $sigma$ counts the undefined cells.],
  fact-mc(inst),
)
