
#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *


== Factorial
#set math.equation(numbering: none)

Compute the factorial of a non-negative integer $n$. i.e $n in NN_0, n >= 0$

Formal definition:
$
  n! = product_(k=1)^(n) k
$
Equivalently:
$
  0! & = 1 \
  n! & = n * (n - 1)! "for" n in NN, n ≥ 1
$

Examples:
- $"fact"(0) -> 1$
- $"fact"(5) -> 120$

*As mapcode:*

_primitives_: `product`($*$) and `subtract`($-$) are strict. i.e product and subtract on $bot$ is undefined.

$
  I = n:NN quad quad quad X_n & = [0..n] -> NN_bot quad quad quad A = NN \
                       rho(n) & = {i -> bot | i in [0..n]} \
                       F(x_n) & = cases(
                                  1 & "if " n = 0,
                                  n * x_(n-1) & "if " n > 0
                                ) \
                        pi(x) & = "last"(x) = x_(|x| - 1)
$



#let inst = 6;
#figure(
  caption: [Factorial computation using mapcode for $n = #inst$],
  $
    #{
      let rho = inst => {
        let x = ()
        for i in range(0, inst + 1) { x.push(none) }
        x
      }

      let F_i = x => ((i,)) => { if i == 0 { 1 } else if x.at(i - 1) != none { i * x.at(i - 1) } else { none } }
      let F = map_tensor(F_i, dim: 1)

      let pi = i => x => x.at(i)

      let X_h = (x, diff_mask: none) => {
        let cells = x.enumerate().map(((i, x_i)) => {
          let val = if x_i != none { [$#x_i$] } else { [$bot$] }
          if diff_mask != none and diff_mask.at(i) {
            // changed element: highlight
            rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
          } else { rect(stroke: none, inset: 2pt)[$#val$] }
        })
        $vec(delim: "[", ..cells)$
      }

      mapcode-viz(
        rho,
        F,
        pi(inst),
        X_h: X_h,
        pi_name: [$mpi (inst)$],
        group-size: calc.min(7, inst + 1),
        cell-size: 10mm,
        scale-fig: 85%,
      )(inst)
    }
  $,
)
