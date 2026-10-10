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

$
  I = NN quad quad X_n = [0..n] -> NN_bot quad quad A = NN \
  rho(n) = {i -> bot | i in [0..n]} \
  F(x)_i = cases(
    1 & "if " i = 0,
    i dot x_(i-1) & "if " i >= 1
  ) \
  pi_n (x) = x_n
$

Cell $i$ becomes defined one step after cell $i-1$, so the table fills left to right. The
number of undefined cells, $sigma(x) = |{i | x_i = bot}|$, drops by one per step and the
fixed point is reached after $n+1$ steps, when $sigma = 0$.

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
#legend
