
#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Integer Partitions
#set math.equation(numbering: none)

Compute $p(n, k)$, the number of partitions of an integer $n$ using parts less than or equal to $k$.

Formal definition:
$
p(n, k) = cases(
  1 & "if " n = 0,
  0 & "if " n > 0 " and " k = 0,
  p(n, k-1) + p(n-k, k) & "if " n > 0 " and " k > 0
)
$
(where $p(n-k, k)$ is 0 if $n-k < 0$)

Examples:
- $p(5, 3) = 5$
- $p(5, 5) = 7$
- $p(7, 5) = 15$

*As mapcode:*

_primitives_: `sum`($+$)

$
I = n:NN times k:NN quad quad quad
X_(n,k) & = [0..n] times [0..k] -> NN_bot quad quad quad
A = NN\
rho(n,k) & = { (i,j) -> bot | i in {0 dots n}, j in {0 dots k}} \
F(x_(i,j)) & = cases(
    1 & "if " i = 0,
    0 & "if " i > 0 " and " j = 0,
    x_(i, j-1) + x_(i-j, j) & "if " i > 0 " and " j > 0
  )\
pi_(n,k) (x) & = x_(n,k)
$

#let inst_n = 7;
#let inst_k = 5;
#figure(
  caption: [Integer Partition computation using mapcode for $n = #inst_n$ and $k = #inst_k$; dynamic-programming table visualization.],
$
#{
  let rho = ((inst_n, inst_k)) => {
    let x = ()
    for i in range(0, inst_n + 1) {
      let row = ()
      for j in range(0, inst_k + 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i = (x) => ((i,j)) => {
    if i == 0 {
      1 // p(0, k) = 1
    } else if j == 0 {
      0 // p(n, 0) = 0 (for n > 0)
    } else {
      let val1 = x.at(i).at(j - 1) // p(n, k-1)
      
      let val2 = none // p(n-k, k)
      if i - j == 0 {
        val2 = 1
      } else if i - j > 0 {
        val2 = x.at(i - j).at(j)
      } else {
        val2 = 0
      }

      if val1 != none and val2 != none {
        val1 + val2 // Recurrence: p(n, k-1) + p(n-k, k)
      } else {
        none
      }
    }
  }
  let F = map_tensor(F_i, dim: 2)

  let pi = ((n, k)) => (x) => x.at(n).at(k)

  // draw DP table with n and k labels
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()

    // header row: show k values
    let header_cells = ()
    header_cells.push(rect(stroke: none, inset: 4pt)[$bot$]) // Top-left empty corner
    for j in range(0, inst_k + 1) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#j$])
    }
    rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

    
    for i in range(0, x.len()) {
      let row = ()
      row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#i$])

      for j in range(0, x.at(i).len()) {
        let val = if x.at(i).at(j) != none {[$#x.at(i).at(j)$]} else {[$bot$]}
        if diff_mask != none and diff_mask.at(i).at(j) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[$#val$])
        } else {
          row.push(rect(stroke: gray, inset: 4pt)[$#val$])
        }
      }
      rows.push(grid(columns: row.len() * (14pt,), rows: 14pt, align: center + horizon, ..row))
    }
    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho,F, pi((inst_n, inst_k)),
    X_h: x_h,
    pi_name: [$mpi ((#inst_n, #inst_k))$],
    group-size: calc.min(3, inst_n),
    cell-size: 60mm, scale-fig: 65%
  )((inst_n, inst_k))
}
$
)