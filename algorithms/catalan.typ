#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Catalan Numbers
#set math.equation(numbering: none)

Compute the $n$-th Catalan number.
Formal definition:
$
C_0 &= 1\
C_{n+1} &= sum_(i=0)^n C_i C_{n-i} quad "for " n >= 0
$

Examples:
- $"Cat"(0) -> 1$
- $"Cat"(3) -> 5$
- $"Cat"(6) -> 132$

*As mapcode:*

_primitives_: `sum`($+$), `product`($*$)

$ I = n:NN quad quad quad X_n &= [0..n] -> NN_bot quad quad quad A = NN\
rho(n) & = {i -> bot | i in {0 dots n}}\
F(n)(x) & = cases(
  1 & "if " k = 0,
  sum_(i=0)^(k-1) x[i] dot x[k-1-i] & "if " k > 0 and forall i: x[i] != bot,
  bot & "otherwise"
 )\
 pi(n)(x) & = x[n]
$

#let inst = 6;
#figure(
  caption: [Catalan number computation using mapcode for $n = #inst$],
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
    if k == 0 {1}
    else {
        let sum = 0
        let possible = true
        for i in range(0, k) {
            let left = x.at(i)
            let right = x.at(k - 1 - i)
            if left != none and right != none {
                sum += left * right
            } else {
                possible = false
                break
            }
        }
        if possible { sum } else { none }
    }
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
    group-size: calc.min(7, inst + 1),
    cell-size: 10mm, scale-fig: 85%
  )(inst)
}
$
)