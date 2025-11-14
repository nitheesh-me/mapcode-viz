#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Edit Distance (Levenshtein Distance)

Compute the edit distance (also known as Levenshtein distance) between two strings $S$ and $T$. The edit distance is the minimum number of single-character edits (insertions, deletions, or substitutions) required to change one string into the other.

Formal definition:
$
"ED"(i, j) = cases(
  i & "if " j = 0,
  j & "if " i = 0,
  "ED"(i-1, j-1) & "if " S_i = T_j,
  1 + min("ED"(i-1, j), "ED"(i, j-1), "ED"(i-1, j-1)) & "otherwise"
)
$

where:
- $"ED"(i-1, j)$ represents deletion from $S$
- $"ED"(i, j-1)$ represents insertion into $S$
- $"ED"(i-1, j-1)$ represents substitution

Examples:
- $"ED"("kitten", "sitting") = 3$ (substitute k→s, substitute e→i, insert g)
- $"ED"("horse", "ros") = 3$ (delete h, delete r, substitute s→r)
- $"ED"("intention", "execution") = 5$

*As mapcode:*

_primitives_: `sum`($+$), `min`(min)

$
I = S times T quad "where" S, T in Sigma^* quad quad "(strings over an alphabet Sigma)"
$

$
X_(S,T) & = [0..|S|] times [0..|T|] -> NN_bot quad quad quad
A = NN\
rho(S,T) & = { (i,j) -> bot | i in {0 dots |S|}, j in {0 dots |T|}} \
F_(S, T)(x_(i,j)) & = cases(
    i & "if " j = 0,
    j & "if " i = 0,
    x_(i-1,j-1) & "if " S_i = T_j,
    1 + min(x_(i-1,j), x_(i,j-1), x_(i-1,j-1)) & "otherwise"
)\
pi_(S,T) (x) & = x_(|S|,|T|)
$

#let inst_S = "horse";
#let inst_T = "ros";
#let inst_m = inst_S.len();
#let inst_n = inst_T.len();

#figure(
  caption: [Edit Distance computation using mapcode for $S = "horse"$ and $T = "ros"$; dynamic-programming table visualization.],
$#{
  let rho = ((inst_m, inst_n)) => {
    let x = ()
    for i in range(0, inst_m + 1) {
      let row = ()
      for j in range(0, inst_n + 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i = ((S, T)) => (x) => ((i,j)) => {
    if j == 0 {
      i
    } else if i == 0 {
      j
    } else if S.at(i - 1) == T.at(j - 1) {
      if x.at(i - 1).at(j - 1) != none {
        x.at(i - 1).at(j - 1)
      } else {
        none
      }
    } else {
      if x.at(i - 1).at(j) != none and x.at(i).at(j - 1) != none and x.at(i - 1).at(j - 1) != none {
        1 + calc.min(x.at(i - 1).at(j), x.at(i).at(j - 1), x.at(i - 1).at(j - 1))
      } else {
        none
      }
    }
  }
  let F = ((S, T)) => map_tensor(F_i((S, T)), dim: 2)

  let pi = ((S, T)) => (x) => {
    let m = S.len()
    let n = T.len()
    x.at(m).at(n)
  }

  // draw DP table with sequence labels
  let x_h(x, diff_mask:none) = {
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
      if i == 0 {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$emptyset$])
      } else {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#inst_S.at(i - 1)$])
      }

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
    rho,F((inst_S, inst_T)), pi((inst_S, inst_T)),
    I_h: (i) => [$S=#inst_S$, $T=#inst_T $],
    X_h: x_h,
    pi_name: [$pi_(S,T) (x) & = x_(|S|,|T|)
$],
    group-size: calc.min(3, inst_m),
    cell-size: 60mm, scale-fig: 75%
  )((inst_m, inst_n))
}$)