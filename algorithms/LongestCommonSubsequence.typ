#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Length of Longest Common Subsequence

Compute the length of the longest common subsequence (LCS) of two sequences S and T. A subsequence is a sequence that can be derived from another sequence by deleting some elements without changing the order of the remaining elements.

Formal definition:
$
  "LCS"(i, j) = cases(
    0 & "if " i = 0 or j = 0,
    "LCS"(i-1, j-1) + 1 & "if " S_i = T_j,
    max("LCS"(i-1, j), "LCS"(i, j-1)) & "otherwise"
  )
$

Example:
- $S = "AGGTAB", T = "GXTXAYB" -> "LCS length" = 4 ("GTAB")$

*As mapcode:*

_primitives_: `sum`($+$), `max`(max)

$
  I = i:[0..m] times j:[0..n] quad quad quad
  X_(i,j)           & = [0..m] times [0..n] -> NN_bot quad quad quad
                      A = NN \
          rho(m, n) & = { (i,j) -> bot | i in {0 dots m}, j in {0 dots n}} \
  F_(S, T)(x_(i,j)) & = cases(
                        0 & "if " i = 0 or j = 0,
                        x_(i-1,j-1) + 1 & "if " S_i = T_j,
                        max(x_(i-1,j), x_(i,j-1)) & "otherwise"
                      ) \
       pi_(S,T) (x) & = x_(m,n) quad quad "where" m = |S|, n = |T|
$

#let inst_S = "AGGTAB";
#let inst_T = "GXTXAYB";
#let inst_m = inst_S.len();
#let inst_n = inst_T.len();

#figure(
  caption: [Longest Common Subsequence (LCS) computation using mapcode for $S = "#inst_S"$ and $T = "#inst_T"$; dynamic-programming table visualization.],
  $#{
    let rho = ((inst_m, inst_n)) => {
      let x = ()
      for i in range(0, inst_m + 1) {
        let row = ()
        for j in range(0, inst_n + 1) { row.push(none) }
        x.push(row)
      }
      x
    }
    let F_i = ((S, T)) => x => ((i, j)) => {
      if i == 0 or j == 0 { 0 } else if S.at(i - 1) == T.at(j - 1) {
        if x.at(i - 1).at(j - 1) != none { x.at(i - 1).at(j - 1) + 1 } else { none }
      } else {
        if x.at(i - 1).at(j) != none and x.at(i).at(j - 1) != none {
          calc.max(x.at(i - 1).at(j), x.at(i).at(j - 1))
        } else { none }
      }
    }
    let F = ((S, T)) => map_tensor(F_i((S, T)), dim: 2)

    let pi = ((S, T)) => x => {
      let m = S.len()
      let n = T.len()
      x.at(m).at(n)
    }

    // draw DP table with sequence labels
    let x_h(x, diff_mask: none) = {
      set text(weight: "bold")
      let rows = ()

      // header row: show T characters (with an initial empty corner)
      let header_cells = ()
      header_cells.push(rect(stroke: none, inset: 4pt)[$bot$])
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$emptyset$])
      for j in range(0, inst_n) {
        header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#inst_T.at(j)$])
      }
      rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

      for i in range(0, x.len()) {
        let row = ()
        // left label: S character for i>0, empty for i=0
        if i == 0 { row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$emptyset$]) } else {
          row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#inst_S.at(i - 1)$])
        }

        for j in range(0, x.at(i).len()) {
          let val = if x.at(i).at(j) != none { [$#x.at(i).at(j)$] } else { [$bot$] }
          if diff_mask != none and diff_mask.at(i).at(j) {
            row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[$#val$])
          } else { row.push(rect(stroke: gray, inset: 4pt)[$#val$]) }
        }
        rows.push(grid(columns: row.len() * (14pt,), rows: 14pt, align: center + horizon, ..row))
      }
      grid(align: center, ..rows)
    }

    mapcode-viz(
      rho,
      F((inst_S, inst_T)),
      pi((inst_S, inst_T)),
      X_h: x_h,
      pi_name: [$mpi ((#inst_m, #inst_n))$],
      group-size: calc.min(3, inst_m),
      cell-size: 60mm,
      scale-fig: 75%,
    )((inst_m, inst_n))
  }$,
)
