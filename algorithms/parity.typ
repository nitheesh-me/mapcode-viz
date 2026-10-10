#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Parity

Determine whether a non-negative integer $n$ is even or odd using mutually recursive functions.

Formal definition:
$
"is_even"(0) &= "true",\
"is_odd"(0) &= "false",\
"is_even"(n) &= "is_odd"(n-1) quad "for " n > 0,\
"is_odd"(n) &= "is_even"(n-1) quad "for " n > 0
$

Examples:
- $"parity"(0) -> ("T", "F")$
- $"parity"(1) -> ("F", "T")$
- $"parity"(3) -> ("F", "T")$

*As mapcode:*

$ I = n : NN quad X_n = [0..n] -> (BB times BB)_bot quad A = BB times BB $

$ rho(n) = {i |-> bot | i in {0 dots n}} $

$ F(x_n) = cases(
  ("T", "F") & "if " n = 0,
  (x_(n-1)[1], x_(n-1)[0]) & "if " n > 0 "and" x_(n-1) != bot,
  bot & "otherwise"
) $

$ pi(x) = x_(|x| - 1) $

#let inst = 3;
#figure(
  caption: [Parity computation using mapcode for $n = #inst$],
$
#{
  let rho = (inst) => {
    let x = ()
    for i in range(0, inst + 1) {
      x.push(none)
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    if i == 0 {
      (true, false)
    } else if x.at(i - 1) != none {
      let (even_prev, odd_prev) = x.at(i - 1)
      (odd_prev, even_prev)
    } else {
      none
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (i) => (x) => x.at(i)

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {
        let (e, o) = x_i
        let e_str = if e { "T" } else { "F" }
        let o_str = if o { "T" } else { "F" }
        $#e_str#o_str$
      } else {
        $bot$
      }
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 1pt)[$#val$]
      } else {
        rect(stroke: none, inset: 1pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F, pi(inst),
    X_h: X_h,
    pi_name: [$pi(#inst)$],
    group-size: 4,
    cell-size: 8mm,
    scale-fig: 75%
  )(inst)
}
$
)
