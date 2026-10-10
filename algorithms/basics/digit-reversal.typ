#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Digit Reversal
#set math.equation(numbering: none)

Reverse the decimal digits of a non-negative integer $n$ (leading zeros of the result are
dropped).

Formal definition, with an accumulator $r$:
$
  "rev"(n) & = "rev"'(n, 0), \
  "rev"'(n, r) & = cases(
    r & "if " n = 0,
    "rev"'(n "div" 10, 10 r + n mod 10) & "if " n > 0
  )
$

Examples:
- $"rev"(123) -> 321$
- $"rev"(1000) -> 1$
- $"rev"(12345) -> 54321$

*As mapcode:*

_primitives_: integer division `div`, remainder `mod`, $+$ and $dot$.

$
  I = NN quad quad X = NN times NN quad quad A = NN \
  rho(n) = (n, 0) \
  F(n, r) = cases(
    (n "div" 10, 10 r + n mod 10) & "if " n > 0,
    (n, r) & "if " n = 0
  ) \
  pi(n, r) = r
$

Each step pops the last digit of $n$ and pushes it onto $r$. When $n = 0$ the state is a
fixed point, reached after one step per digit.

#let rev-mc(n) = {
  let rho = n => (n, 0)
  let F = ((n, r)) => if n > 0 { (calc.quo(n, 10), 10 * r + calc.rem(n, 10)) } else { (n, r) }
  let pi = ((n, r)) => r
  mapcode-viz(
    rho,
    F,
    pi,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, labels: ([$n$], [$r$]), width: 5.4em, vertical: true),
    group-size: 3,
    spacing: (8mm, 10mm),
  )(n)
}

#let inst = 1234567809
#figure(
  caption: [Digit reversal via mapcode for the 10-digit $n = #inst$.],
  rev-mc(inst),
)
#legend
