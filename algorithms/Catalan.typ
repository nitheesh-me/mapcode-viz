#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Catalan Numbers

Compute the $n$-th Catalan number $C_n$. Catalan numbers appear in many counting problems.

Formal definition:
$
C_n = frac(1, n+1) binom(2n, n)
$
The recurrence relation used here is:
$
C_i = cases(
  1 & "if " i = 0,
  frac(2i(2i-1), i(i+1)) C_(i-1) & "if " i > 0
)
$

*As mapcode:*

_primitives_: `product`($*$), `division`($\/$)

$
I = i:[0..n] quad quad quad
X_i & = [0..n] -> NN quad quad quad
A = NN\
rho(n) & = { i -> bot | i in {0 dots n}} \
F(x_i) & = cases(
  1 & "if " i = 0,
  (x_(i-1) * (2i) * (2i-1)) / ((i+1) * i) & "otherwise"
)\
pi(x) & = x_n
$

#let inst_n = 5; // Compute C_5

#figure(
  caption: [Computation of Catalan numbers using mapcode for $n = #inst_n$; 1D dynamic-programming table visualization.],
$#{
  let rho = ((n)) => {
    let x = ()
    for i in range(0, n + 1) {
      x.push(none)
    }
    x
  }

  let F_i = () => (x) => ((i,)) => {
    if i == 0 {
      1
    } else if x.at(i - 1) != none {
      // Use integer division where possible, but result might be float.
      // The formula (2*i)*(2*i-1)*x[i-1]/((i+1)*i) simplifies to
      // (2 * (2*i - 1) * x.at(i - 1)) / (i + 1)
      // Let's use the user's provided formula directly
      (2 * i) * (2 * i - 1) * x.at(i - 1) / ((i + 1) * i)
    } else {
      none
    }
  }
  let F = () => map_tensor(F_i(), dim: 1)

  let pi = ((n)) => (x) => x.at(n)

  // draw DP table (1D array)
  let x_h(x, diff_mask: none) = {
    set text(weight: "bold")
    let cells = ()
    for i in range(0, x.len()) {
      let val = if x.at(i) != none { [$C_#i = #x.at(i)$] } else { [$C_#i = bot$] }
      if diff_mask != none and diff_mask.at(i) {
        cells.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[#val])
      } else {
        cells.push(rect(stroke: gray, inset: 4pt)[#val])
      }
    }
    grid(columns: x.len() * (auto,), rows: (20pt,), align: center, ..cells)
  }

  mapcode-viz(
    rho, F(), pi((inst_n)),
    X_h: x_h,
    pi_name: [$pi_n$],
    group-size: 2, // Show all steps horizontally
    cell-size: 60mm, scale-fig: 50%
  )((inst_n))
}$)