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

#mc-spec(
  state: [The state $(n, r)$ holds the number $n$ whose digits are still to be reversed and the
    accumulator $r$ holding the digits already popped, in reverse order.],
  I: $I = NN$,
  X: $X = NN times NN$,
  A: $A = NN$,
  rho: $rho(n) = (n, 0)$,
  F: $F(n, r) = cases((n "div" 10, 10 r + n mod 10) & "if " n > 0, (n, r) & "if " n = 0)$,
  pi: $pi(n, r) = r$,
  sigma: $sigma(n, r) = n$,
  theta: $theta(n, r) = "rev"'(n, r)$,
)
For $n > 0$ we have $n "div" 10 < n$, so $sigma$ strictly decreases; $theta(rho(n)) =
"rev"'(n, 0) = "rev"(n)$, one step of $F$ is exactly one unfolding of $"rev"'$ so $theta$ is
unchanged, and once $n = 0$ (one step per digit) $theta(0, r) = r = pi(0, r)$.

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
