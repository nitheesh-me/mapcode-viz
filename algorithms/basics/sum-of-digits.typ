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

#mc-spec(
  state: [The state $(m, s)$ holds the number $m$ whose digits are still to be read and the
    running sum $s$ of the digits already read; each step moves the last digit of $m$ into $s$.],
  I: $I = NN$,
  X: $X = NN times NN$,
  A: $A = NN$,
  rho: $rho(n) = (n, 0)$,
  F: $F(m, s) = cases((m "div" 10, s + m mod 10) & "if " m > 0, (m, s) & "if " m = 0)$,
  pi: $pi(m, s) = s$,
  sigma: $sigma(m, s) = m$,
  theta: $theta(m, s) = s + "digitsum"(m)$,
)
For $m > 0$ we have $m "div" 10 < m$, so $sigma$ strictly decreases; $theta(rho(n)) =
"digitsum"(n)$, the defining equation $"digitsum"(m) = m mod 10 + "digitsum"(m "div" 10)$ makes
$theta$ unchanged by $F$, and once $m = 0$ (one step per digit) $theta(0, s) = s = pi(0, s)$.

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
