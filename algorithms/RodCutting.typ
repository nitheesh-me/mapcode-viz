#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Rod Cutting Problem

Given a rod of length $n$ and a table of prices $P$ for different lengths,
determine the maximum revenue $r_n$ obtainable by cutting up the rod and
selling the pieces.

Formal definition:
Let $r_i$ be the maximum revenue for a rod of length $i$.
$
r_n = cases(
  0 & "if " n = 0,
  max_(1 <= i <= n) (P_i + r_(n-i)) & "if " n > 0
)
$

*As mapcode:*

Here, $NN$ is the set of non-negative integers $\{0, 1, ...\}$,
and $NN_bot = NN union {bot}$.

_primitives_: `max`, `sum`($+$)

$
I &= P:vec(NN) times n:NN quad quad quad "where" m = |P| \
X_n &= [0..n] -> NN_bot quad quad quad \
A &= NN \
rho(n) &= { i -> bot | i in {0 dots n}} \
F_P(x_i) &= cases(
    0 & "if " i = 0,
    max_(1 <= j <= i) (P_(j-1) + x_(i-j)) & "if " i > 0 " and " j-1 < m
)\
pi_n(x) &= x_n
$

// Price table: P[0] = price for length 1, P[1] = price for length 2, etc.
// So for this example: length 1 costs 1, length 2 costs 5, length 3 costs 8, length 4 costs 9
#let inst_P = (1, 5, 8, 9);
// Target length
#let inst_n = 4;

#figure(
  caption: [Rod Cutting DP table for $n = #inst_n$ and prices $P = #inst_P$.],
$
#{
  let rho = (inst) => {
    let x = ()
    for i in range(0, inst + 1) {
      x.push(none)
    }
    x
  }

  let F_i = (P) => (x) => ((i,)) => {
    if i == 0 {
      0
    } else if x.at(i) != none {
      // Already computed, keep the value
      x.at(i)
    } else {
      // Check if all dependencies are computed
      let all_deps_ready = true
      for j in range(1, i + 1) {
        if j - 1 < P.len() and x.at(i - j) == none {
          all_deps_ready = false
          break
        }
      }
      
      if not all_deps_ready {
        none
      } else {
        let max_rev = 0
        // j is the length of the first cut
        for j in range(1, i + 1) {
          // Check if we have a price for this cut
          if j - 1 < P.len() {
            let p_j = P.at(j - 1)
            let r_remaining = x.at(i - j)
            max_rev = calc.max(max_rev, p_j + r_remaining)
          }
        }
        max_rev
      }
    }
  }
  let F = map_tensor(F_i(inst_P), dim: 1)

  let pi = (i) => (x) => x.at(i)

  // X_h visualizer from fibonacci.typ
  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        // changed element: highlight
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F, pi(inst_n),
    X_h: X_h,
    pi_name: [$mpi (#inst_n)$],
    group-size: inst_n + 1, // Show all steps in one row
    cell-size: 10mm,
    scale-fig: 95%
  )(inst_n)
}
$
)