#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Binomial Coefficients
#set math.equation(numbering: none)

Compute the binomial coefficient $binom(n, k)$, the number of ways to choose $k$ elements from a
set of $n$ elements, for $0 <= k <= n$.

Formal definition:
$
  binom(n, k) = frac(n!, k! (n-k)!)
$
Equivalently, by Pascal's rule:
$
  binom(n, k) = cases(
    1 & "if " k = 0 "or" k = n,
    binom(n-1, k-1) + binom(n-1, k) & "if " 0 < k < n
  )
$

Examples:
- $binom(5, 0) -> 1$
- $binom(5, 2) -> 10$
- $binom(6, 3) -> 20$
- $binom(10, 3) -> 120$

*As mapcode:*

_primitives_: `sum`($+$) is strict, i.e. $bot + v = v + bot = bot$.

The state is the top-left corner of Pascal's triangle: rows $0..n$ and columns $0..k$. Cells
with $j > i$ lie outside the triangle and stay $bot$ (shaded in the figure).

$
  I = {(n, k) in NN times NN | k <= n} quad quad X_(n,k) = [0..n] times [0..k] -> NN_bot
  quad quad A = NN \
  rho(n, k) = {(i, j) -> bot | i in [0..n], j in [0..k]} \
  F(x)_(i,j) = cases(
    1 & "if " j = 0 "or" j = i,
    x_(i-1,j-1) + x_(i-1,j) & "if " 0 < j < i,
    bot & "if " j > i
  ) \
  pi_(n,k) (x) = x_(n,k)
$

The first step fills the left edge and the diagonal of the triangle. An interior cell needs
both cells above it, so row $i$ is completed at step $i$ and the fixed point is reached after
$n$ steps.

#let binom-mc(inst) = {
  let (n, k) = inst
  let rho = ((n, k)) => range(n + 1).map(_ => range(k + 1).map(_ => none))
  let F_i = x => ((i, j)) => {
    if j == 0 or j == i { 1 } else if j < i {
      let (a, b) = (x.at(i - 1).at(j - 1), x.at(i - 1).at(j))
      if a != none and b != none { a + b } else { none }
    } else { none }
  }
  let F = map_tensor(F_i, dim: 2)
  let pi = x => x.at(n).at(k)
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((n, k)) => [$binom(#[#n], #[#k])$],
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: range(n + 1).map(i => [$#i$]),
      col-labels: range(k + 1).map(j => [$#j$]),
      corner: [$i slash j$],
      shade: (i, j) => j > i,
    ),
    pi_name: [$mpi_(#n,#k)$],
    group-size: 3,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(inst)
}

#let inst = (6, 3)
#figure(
  caption: [Binomial coefficient via mapcode for $binom(#[#inst.at(0)], #[#inst.at(1)])$, laid out as
    Pascal's triangle (row $i$, column $j$); shaded cells $j > i$ are outside the triangle.],
  binom-mc(inst),
)
