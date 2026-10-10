#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Coin Change
#set math.equation(numbering: none)

Given a set $C$ of coin denominations (each usable any number of times) and an amount $a$, compute
the fewest coins that add up to $a$, or $-1$ if $a$ cannot be made at all
(#link("https://leetcode.com/problems/coin-change/")[LeetCode 322]).

Formal definition: let $"mc"(i)$ be the fewest coins making $i$, with $"mc"(i) = infinity$ when
$i$ is unreachable and $min emptyset = infinity$.
$
  "mc"(i) & = cases(
              0 & "if " i = 0,
              1 + min_(c in C, c <= i) "mc"(i - c) & "if " i > 0
            ) \
  "coins"(C, a) & = cases("mc"(a) & "if " "mc"(a) < infinity, -1 & "otherwise")
$

Examples:
- $"coins"({1, 2, 5}, 11) -> 3$ ($5 + 5 + 1$)
- $"coins"({3, 5}, 11) -> 3$ ($5 + 3 + 3$)
- $"coins"({3, 5}, 7) -> -1$
- $"coins"({2}, 0) -> 0$

*As mapcode:*

_primitives_: `min`, `sum`($+$) and `leq`($<=$) are strict; $1 + infinity = infinity$ and
$min emptyset = infinity$.

$
  I = C : 2^NN times a : NN quad quad X_a = [0..a] -> (NN union {infinity})_bot quad quad
  A = NN union {-1} \
  rho(C, a) = {i -> bot | i in [0..a]} \
  F_C (x)_i = cases(
    0 & "if " i = 0,
    bot & "if " i > 0 " and " x_(i-c) = bot " for some " c in C", " c <= i,
    1 + min_(c in C, c <= i) x_(i-c) & "otherwise"
  ) \
  pi_a (x) = cases(x_a & "if " x_a < infinity, -1 & "if " x_a = infinity)
$

Cells with no coin $c <= i$ (here $1$ and $2$) are settled to $infinity$ in the first step together
with cell $0$; every other cell is settled one step after the last cell it looks back to.

#let coin-mc(C, a, wrap: 6, group-size: 3) = {
  let rho = ((C, a)) => range(a + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { return 0 }
    let deps = C.filter(c => c <= i).map(c => x.at(i - c))
    if deps.any(d => d == none) { none } else { 1 + calc.min(calc.inf, ..deps) }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => if x.at(a) == calc.inf { -1 } else { x.at(a) }
  let I_h = ((C, a)) => [$C = {#C.map(str).join(", ")}, quad a = #a$]
  let A_h = v => text(fill: if v < 0 { c-bad } else { black })[$#v$]
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: I_h,
    A_h: A_h,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, wrap: wrap),
    F_name: [$F_C$],
    pi_name: [$mpi_#a$],
    group-size: group-size,
    spacing: (12mm, 10mm),
  )((C, a))
}

#figure(
  caption: [Coin change via mapcode for $C = {3, 5}$ and $a = 11$; $infinity$ marks unreachable amounts.],
  coin-mc((3, 5), 11),
)
#legend

The same coins cannot make $a = 7$: the table reaches its fixed point with $x_7 = infinity$, so
$pi$ returns $-1$.

#figure(
  caption: [Coin change via mapcode for $C = {3, 5}$ and $a = 7$ (unreachable).],
  coin-mc((3, 5), 7, wrap: 4),
)
