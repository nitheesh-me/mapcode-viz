#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *


== Leetcode:62. #link("https://leetcode.com/problems/unique-paths/")[Unique Paths]

There is a robot on an $m times n$ grid. The robot is initially located at the top-left corner (i.e., `grid[0][0]`). The robot tries to move to the bottom-right corner (i.e., `grid[m - 1][n - 1]`). The robot can only move either down or right at any point in time.

Given the two integers $m$ and $n$, return the number of possible unique paths that the robot can take to reach the bottom-right corner.

=== Recurrence Relation

$
"Paths"(i, j) = cases(
  1 & "if" i = 0 or j = 0,
  "Paths"(i-1, j) + "Paths"(i, j-1) & "otherwise"
)
$

*Example:* $3 times 7$ grid → $28$ unique paths

*Constraints:*
- $1 <= m, n <= 100$

=== Recursion Analysis

This exhibits non-trivial recursion through:
1. *Two recursive branches*: Each cell reachable from top or left
2. *Two-dimensional state space*: Grid-based DP problem
3. *Combinatorial counting*: Summing paths from multiple directions
4. *Pascal's triangle structure*: Relates to binomial coefficients

=== Mapcode Formalization

*Primitives:* $+$

$
I &= (m: NN, n: NN) \
X &= [0..m-1] times [0..n-1] -> NN_bot \
A &= NN \
rho(m, n) &= {(i,j) |-> bot | i in {0 dots m-1}, j in {0 dots n-1}} \
F(x)(i,j) &= cases(
  1 & "if" i = 0 or j = 0,
  x[i-1,j] + x[i,j-1] & "if" x[i-1,j] != bot and x[i,j-1] != bot,
  bot & "otherwise"
) \
pi(x) &= x[m-1, n-1]
$

=== Complexity Analysis
- *Time Complexity*: $O(m times n)$ where $m$ and $n$ are grid dimensions
- *Space Complexity*: $O(m times n)$ for storing intermediate results

#let inst_m = 4;
#let inst_n = 5;

#figure(
  caption: [Unique Paths computation for $#inst_m times #inst_n$ grid showing path counts.],
  $#{
    let rho = ((m, n)) => {
      let x = ()
      for i in range(0, m) {
        let row = ()
        for j in range(0, n) {
          row.push(none)
        }
        x.push(row)
      }
      x
    }

    let F_i = (x) => ((i, j)) => {
      if i == 0 or j == 0 {
        1
      } else {
        let from_top = x.at(i - 1).at(j)
        let from_left = x.at(i).at(j - 1)
        
        if from_top != none and from_left != none {
          from_top + from_left
        } else {
          none
        }
      }
    }

    let F = map_tensor(F_i, dim: 2)

    let pi = ((m, n)) => (x) => {
      x.at(m - 1).at(n - 1)
    }

    let x_h(x, diff_mask: none) = {
      set text(size: 8pt)
      let rows = ()
      
      // Header row
      let header_cells = ()
      header_cells.push(rect(stroke: none, inset: 3pt)[])
      for j in range(0, x.at(0).len()) {
        header_cells.push(rect(fill: orange.transparentize(80%), inset: 3pt, stroke: 0.5pt)[*#j*])
      }
      rows.push(grid(columns: header_cells.len() * (16pt,), rows: 14pt, align: center + horizon, ..header_cells))

      for i in range(0, x.len()) {
        let row = ()
        row.push(rect(fill: green.transparentize(80%), inset: 3pt, stroke: 0.5pt)[*#i*])
        
        for j in range(0, x.at(i).len()) {
          let val = x.at(i).at(j)
          let display = if val == none { $bot$ } else { str(val) }
          
          let cell_fill = if diff_mask != none and diff_mask.at(i).at(j) {
            yellow.transparentize(60%)
          } else if i == 0 or j == 0 {
            blue.transparentize(85%)
          } else {
            none
          }
          
          row.push(rect(stroke: 0.5pt + gray, fill: cell_fill, inset: 3pt)[#display])
        }
        rows.push(grid(columns: row.len() * (16pt,), rows: 14pt, align: center + horizon, ..row))
      }
      grid(align: center, row-gutter: 0pt, ..rows)
    }

    let I_h = ((m, n)) => {
      diagram(
        node((0, 0), [*Start*], stroke: 2pt + green, shape: rect),
        node((3, 2), [*End*], stroke: 2pt + red, shape: rect),
        edge((0, 0), (3, 0), "->", bend: 20deg),
        edge((0, 0), (0, 2), "->", bend: -20deg),
        edge((3, 0), (3, 2), "->"),
        edge((0, 2), (3, 2), "->"),
        node((1.5, 1), [$#m times #n$ grid])
      )
    }

    let A_h = (a) => {
      box(fill: green.transparentize(70%), inset: 8pt, radius: 4pt)[
        *Unique Paths:* $#a$
      ]
    }

    mapcode-viz(
      rho, F, pi((inst_m, inst_n)),
      I_h: I_h,
      X_h: x_h,
      A_h: A_h,
      F_name: [$F$],
      pi_name: [$mpi ((#(inst_m - 1), #(inst_n - 1)))$],
      group-size: 3,
      cell-size: 60mm,
      scale-fig: 70%
    )((inst_m, inst_n))
  }$
)

=== Trace Analysis

The table shows:
1. *First row/column*: All $1$s (only one way to reach any cell on edge)
2. *Interior cells*: Sum of paths from above and left
3. *Pattern*: Resembles Pascal's triangle rotated

For $4 times 5$ grid: $35$ unique paths to reach bottom-right corner.

This can be verified combinatorially: to reach $(m-1, n-1)$ from $(0,0)$, we need exactly $m-1$ down moves and $n-1$ right moves. Total ways = $binom(m+n-2, m-1) = binom(7, 3) = 35$ which is correct.