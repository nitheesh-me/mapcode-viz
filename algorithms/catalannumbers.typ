#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Catalan Numbers

Compute the $n$-th Catalan number, which appears in many combinatorial problems such as counting the number of valid parentheses expressions, binary search trees, paths in a grid, etc.

Formal definition:
$
"Cat"(n) = frac(1, n+1) binom(2n, n) = frac((2n)!, (n+1)!n!)
$

equivalently, as recursive definition:
$
"Cat"(n) = cases(
  1 & "if " n = 0,
  sum_(i=0)^(n-1) "Cat"(i) dot "Cat"(n-1-i) & "otherwise"
)
$

Examples:
- $"Cat"(0) = 1$
- $"Cat"(1) = 1$
- $"Cat"(2) = 2$
- $"Cat"(3) = 5$
- $"Cat"(4) = 14$
- $"Cat"(5) = 42$

*As mapcode:*

_primitives_: `sum`($+$), `mul`($dot$)

$
I = n:NN quad quad quad
X_n & = [0..n] -> NN_bot quad quad quad
A = NN\
rho(n) & = { i -> bot | i in {0 dots n}} \
F(x_i) & = cases(
    1 & "if " i = 0,
    sum_(k=0)^(i-1) x_k dot x_(i-1-k) & "otherwise"
)\
pi_n (x) & = x_n
$

#let inst = 5;
#figure(
  caption: [Catalan Numbers computation using mapcode for $n = #inst$],
$#{
  let rho = (inst) => {
    let x = ()
    for i in range(0, inst + 1) {
      x.push(none)
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    if i == 0 {
      1
    } else {
      // Check if all dependencies are ready
      let all_ready = true
      for k in range(0, i) {
        if x.at(k) == none {
          all_ready = false
          break
        }
      }
      
      if all_ready {
        let total = 0
        for k in range(0, i) {
          total += x.at(k) * x.at(i - 1 - k)
        }
        total
      } else {
        none
      }
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (n) => (x) => x.at(n)

  let X_h = (x, diff_mask: none) => {
    set text(weight: "bold")
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
    rho, F, pi(inst),
    X_h: X_h,
    pi_name: [$pi_#inst$],
    group-size: calc.min(6, inst),
    cell-size: 15mm, scale-fig: 95%
  )(inst)
}$
)
