#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Rod Cutting
#set math.equation(numbering: none)

Given a rod of length $n$ and a price table $P = (P_1, dots, P_m)$, where $P_j$ is the price of a
piece of length $j$, determine the maximum revenue obtainable by cutting the rod into pieces
(of length at most $m$) and selling them.

Formal definition: let $r_i$ be the maximum revenue for a rod of length $i$.
$
  r_i = cases(
    0 & "if " i = 0,
    max_(1 <= j <= min(i, m)) (P_j + r_(i-j)) & "if " i > 0
  )
$

Examples (with $P = (1, 5, 8, 9)$):
- $r_2 -> 5$ (one piece of length 2)
- $r_4 -> 10$ (two pieces of length 2)
- $r_6 -> 16$ (lengths $2 + 2 + 2$, or $3 + 3$)

*As mapcode:*

_primitives_: `max` and `sum`($+$) are strict, i.e. $bot + v = bot$ and $max$ is $bot$ as soon as
one argument is $bot$.

$
  I = P : NN^m times n : NN quad quad X_n = [0..n] -> NN_bot quad quad A = NN \
  rho(P, n) = {i -> bot | i in [0..n]} quad "(the prices are not needed to initialise)" \
  F_P (x)_i = cases(
    0 & "if " i = 0,
    max_(1 <= j <= min(i, m)) (P_j + x_(i-j)) & "if " i > 0
  ) \
  pi_n (x) = x_n
$

Cell $i$ depends on the $min(i, m)$ cells to its left, so it becomes defined one step after
cell $i - 1$: the table fills left to right and reaches its fixed point after $n + 1$ steps.

#let rod-mc(P, n) = {
  let m = P.len()
  let rho = ((P, n)) => range(n + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { return 0 }
    let deps = range(1, calc.min(i, m) + 1).map(j => (j, x.at(i - j)))
    if deps.any(((j, r)) => r == none) { none } else {
      calc.max(..deps.map(((j, r)) => P.at(j - 1) + r))
    }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => x.at(n)
  let I_h = ((P, n)) => stack(
    dir: ttb,
    spacing: 4pt,
    [$P$ (price by length):],
    vec-view(P, none, labels: range(1, m + 1).map(j => [#j])),
    [$n = #n$],
  )
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: I_h,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask),
    F_name: [$F_P$],
    pi_name: [$mpi_#n$],
    group-size: 3,
    spacing: (8mm, 10mm),
  )((P, n))
}

#let inst-P = (1, 5, 8, 9)
#let inst-n = 6
#figure(
  caption: [Rod cutting via mapcode for $P = (#inst-P.map(str).join(", "))$ and $n = #inst-n$.],
  rod-mc(inst-P, inst-n),
)
