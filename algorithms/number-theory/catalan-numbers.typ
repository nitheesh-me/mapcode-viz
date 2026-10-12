#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Catalan Numbers
#set math.equation(numbering: none)

Compute the $n$-th Catalan number $C_n$. Catalan numbers count many combinatorial objects:
well-formed strings of $n$ pairs of parentheses, binary trees with $n$ internal nodes,
triangulations of a convex $(n+2)$-gon, monotone lattice paths that stay below the diagonal,
and so on.

Formal definition:
$
  C_n = frac(1, n+1) binom(2n, n) = frac((2n)!, (n+1)! n!)
$
Equivalently, by splitting off the first matched pair (or the root of the tree):
$
  C_n = cases(
    1 & "if " n = 0,
    sum_(k=0)^(n-1) C_k dot C_(n-1-k) & "if " n >= 1
  )
$

Examples:
- $C_0 -> 1$
- $C_3 -> 5$
- $C_4 -> 14$
- $C_5 -> 42$

*As mapcode:*

_primitives_: `sum`($+$) and `mul`($dot$) are strict, so a sum containing a $bot$ term is $bot$.

#mc-spec(
  state: [For fixed $n$, cell $i$ of the table holds the Catalan number $C_i$ once it is known
    and $bot$ before.],
  I: $I = NN$,
  X: $X = X_n = [0..n] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(n) = {i |-> bot | i in [0..n]}$,
  F: $F(x)_i = cases(
    1 & "if " i = 0,
    sum_(k=0)^(i-1) x_k dot x_(i-1-k) & "if " i >= 1
  )$,
  pi: $pi = pi_n = x |-> x_n$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = C_i$,
)
Cell $i$ depends on every earlier cell, so it becomes defined one step after $x_(i-1)$ does and
then never changes: the table fills in index order, each changing step defines one new cell and
$sigma$ drops, reaching $0$ after $n + 1$ steps. $F$ is the recurrence for $C_i$, so $"Inv"$ is
preserved, and at the fixed point $pi_n$ returns $x_n = C_n$.

#let catalan-mc(n) = {
  let rho = n => range(n + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { 1 } else if range(i).all(k => x.at(k) != none) {
      range(i).map(k => x.at(k) * x.at(i - 1 - k)).sum()
    } else { none }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => x.at(n)
  mapcode-viz(
    rho,
    F,
    pi,
    X_h: (x, diff_mask: none) => vec-view(
      x,
      diff_mask,
      labels: range(x.len()).map(i => [$C_#i$]),
      vertical: true,
      width: 2.2em,
    ),
    A_h: a => [$C_#n = #a$],
    pi_name: [$mpi_#n$],
    group-size: 4,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(n)
}

#let inst = 5
#figure(
  caption: [Catalan numbers via mapcode for $n = #inst$; the cell labelled $C_i$ holds the
    $i$-th Catalan number once defined.],
  catalan-mc(inst),
)
