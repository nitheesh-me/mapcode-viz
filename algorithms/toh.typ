#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Tower of Hanoi
#set math.equation(numbering: none)

Compute the minimum moves to solve the Tower of Hanoi puzzle with $n$ disks.
Formal definition:
$
T_0 &= 0\
T_n &= 2 T_{n-1} + 1 quad "for " n >= 1
$

Example:
- $"Hanoi"(0) -> 0$
- $"Hanoi"(1) -> 1$
- $"Hanoi"(3) -> 7$

*As mapcode:*

_primitives_: `sum`($+$), `product`($*$)

$ I = n:NN quad quad quad X_n &= [0..n] -> NN_bot quad quad quad A = NN\
rho(n) & = {k -> bot | k in {0 dots n}}\
F(n)(x) & = cases(
  0 & "if " k = 0,
  2 dot x[k-1] + 1 & "if " k > 0 and x[k-1] != bot,
  bot & "otherwise"
 )\
 pi(n)(x) & = x[n]
$

#let inst = 4;
#figure(
  caption: [Tower of Hanoi computation using mapcode for $n = #inst$],
$
#{
  let rho = (inst) => {
    let x = ()
    for i in range(0, inst + 1) {
      x.push(none)
    }
    x
  }

  let F_i = (x) => ((k,)) => {
    if k == 0 { 0 }
    else if x.at(k - 1) != none { 2 * x.at(k - 1) + 1 }
    else { none }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (inst) => (x) => x.at(inst)

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F, pi(inst),
    X_h: X_h,
    pi_name: [$mpi (inst)$],
    group-size: calc.min(6, inst + 1),
    cell-size: 10mm, scale-fig: 90%
  )(inst)
}
$
)