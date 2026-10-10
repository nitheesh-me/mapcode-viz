#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Sum of Digits
#set math.equation(numbering: none)

Compute the sum of the decimal digits of a non-negative integer $n$.

Formal definition:
$
  "digitsum"(n) = cases(
    0 & "if " n = 0,
    (n mod 10) + "digitsum"(n "div" 10) & "if " n > 0
  )
$

Examples:
- $"digitsum"(0) -> 0$
- $"digitsum"(5) -> 5$
- $"digitsum"(123) -> 6$
- $"digitsum"(8296) -> 25$

*As mapcode:*

_primitives_: integer division `div`, remainder `mod` and `add`($+$).

The state is a pair $(m, s)$: the digits $m$ still to be read and the running sum $s$ of the
digits already read.

$
  I = NN quad quad X = NN times NN quad quad A = NN \
  rho(n) = (n, 0) \
  F(m, s) = cases(
    (m "div" 10, s + m mod 10) & "if " m > 0,
    (m, s) & "if " m = 0
  ) \
  pi(m, s) = s
$

Each step moves the last digit of $m$ into $s$, so $s + "digitsum"(m)$ stays equal to
$"digitsum"(n)$. Once $m = 0$ the state is a fixed point and $s$ is the answer; this takes
one step per digit.

#let digitsum-mc(n) = {
  let rho = n => (n, 0)
  let F = ((m, s)) => if m > 0 { (calc.quo(m, 10), s + calc.rem(m, 10)) } else { (m, s) }
  let pi = ((m, s)) => s
  mapcode-viz(
    rho,
    F,
    pi,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, labels: ([$m$], [$s$]), width: 3em),
    group-size: 3,
    spacing: (10mm, 10mm),
  )(n)
}

#let inst = 8296
#figure(
  caption: [Sum of digits via mapcode for $n = #inst$.],
  digitsum-mc(inst),
)
#legend
