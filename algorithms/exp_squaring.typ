#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Exponentiation by Squaring
#set math.equation(numbering: none)

Compute $b^n$ for base $b in NN$ and exponent $n in NN_0$ using binary exponentiation.

Formal definition:
$
b^n = cases(
  1 & "if " n = 0,
  b & "if " n = 1,
  (b^(n/2))^2 & "if " n "is even",
  b dot (b^(floor(n/2)))^2 & "if " n "is odd"
)
$

Examples:
- $"exp"(3, 5) -> 243$
- $"exp"(2, 10) -> 1024$

*As mapcode:*

_primitives_: `multiply`($*$) and `floor-divide`($div$) are strict. i.e operations on $bot$ are undefined.

$ I = (b, n) : NN times NN_0 quad quad quad X_((b,n)) &= [0..n] -> NN_bot quad quad quad A = NN\
rho((b,n)) & = {i -> bot | i in [0..n]}\
F(x_k) & = cases(
  1 & "if " k = 0,
  x_(floor(k/2))^2 & "if " k > 0 "and " k "is even and" x_(floor(k/2)) != bot,
  b dot x_(floor(k/2))^2 & "if " k > 0 "and " k "is odd and" x_(floor(k/2)) != bot,
  bot & "otherwise"
 )\
 pi(x) & = x_n
$

#let base = 3;
#let exp = 5;
#figure(
  caption: [Exponentiation by squaring computation using mapcode for $#base^#exp$],
$
#{
  let rho = (inst) => {
    let (b, n) = inst
    let x = ()
    for i in range(0, n + 1) {
      x.push(none)
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    if i == 0 {
      1
    } else {
      let half_idx = calc.floor(i / 2)
      if x.at(half_idx) != none {
        let half_val = x.at(half_idx)
        let squared = half_val * half_val
        if calc.rem(i, 2) == 0 {
          // even: x[i/2]^2
          squared
        } else {
          // odd: b * x[(i-1)/2]^2
          base * squared
        }
      } else {
        none
      }
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (i) => (x) => x.at(i)

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
    rho, F, pi(exp),
    X_h: X_h,
    I_h: (inst) => {
      let (b, n) = inst
      $((#b, #n))$
    },
    pi_name: [$pi(#exp)$],
    group-size: calc.min(7, exp + 1),
    cell-size: 10mm, scale-fig: 85%
  )((base, exp))
}
$
)