#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Fibonacci
#set math.equation(numbering: none)

Compute the $n$-th Fibonacci number, where $n$ is a non-negative integer.

Formal definition:
$
  F(0) & = 0, \
  F(1) & = 1, \
  F(n) & = F(n-1) + F(n-2) quad "for " n ≥ 2
$

Examples:
- $"fib"(0) -> 0$
- $"fib"(1) -> 1$
- $"fib"(4) -> 5$
- $"fib"(8) -> 21$

*As mapcode:*

_primitives_: `sum`($+$) and `minus`($-$) are strict. i.e sum and minus on $bot$ is undefined.

$
  I = n:NN quad quad quad X_n & = [0..n] -> NN_bot quad quad quad A = NN \
                       rho(n) & = {i -> bot | i in {0 dots n}} \
                       F(x_n) & = cases(
                                  0 & "if " n = 0,
                                  1 & "if " n = 1,
                                  x_(n-1) + x_(n-2) & "if " n ≥ 2
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

      let F_i = x => ((i,)) => {
        if i <= 1 { 1 } else if x.at(i - 1) != none and x.at(i - 2) != none { x.at(i - 1) + x.at(i - 2) } else { none }
      }
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
        group-size: calc.min(6, inst),
        cell-size: 10mm,
        scale-fig: 95%,
      )(inst)
    }
  $,
)
