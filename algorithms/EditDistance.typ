#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Edit Distance (Levenshtein Distance, dynamic programming, mapcode)

Compute the minimum number of single-character edits (insertions, deletions, or substitutions) required to transform one string into another.

Formal definition:
$
"ED"(i, j) = cases(
  i & "if " j = 0,
  j & "if " i = 0,
  "ED"(i-1, j-1) & "if " s_1[i] = s_2[j],
  1 + min("ED"(i-1, j), "ED"(i, j-1), "ED"(i-1, j-1)) & "otherwise"
)
$

*As mapcode:*

_primitives_: `min`, `add`($+$)

$
I = s_1:[Sigma]^m times s_2:[Sigma]^n quad quad quad
X_(m,n) & = [0..m] times [0..n] -> NN_bot quad quad quad
A = NN\
rho(m, n) & = { (i,j) -> bot | i in {0 dots m}, j in {0 dots n}} \
F_(s_1, s_2)(x_(i,j)) & = cases(
    i & "if " j = 0,
    j & "if " i = 0,
    x_(i-1,j-1) & "if " s_1[i-1] = s_2[j-1],
    1 + min(x_(i-1,j), x_(i,j-1), x_(i-1,j-1)) & "otherwise"
  )\
pi_(m,n) (x) & = x_(m,n)
$

#let inst_s1 = "cat";
#let inst_s2 = "dog";
#let inst_m = inst_s1.len();
#let inst_n = inst_s2.len();

#figure(
  caption: [Edit Distance (Levenshtein) DP table for $s_1 =$ "#inst_s1" and $s_2 =$ "#inst_s2".],
$#{
  let rho = ((s1, s2)) => {
    let m = s1.len()
    let n = s2.len()
    let x = ()
    for i in range(0, m + 1) {
      let row = ()
      for j in range(0, n + 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i = ((s1, s2)) => (x) => ((i,j)) => {
    if j == 0 {
      i
    } else if i == 0 {
      j
    } else {
      // Check if all dependencies are met
      let dep1 = x.at(i - 1).at(j)      // deletion
      let dep2 = x.at(i).at(j - 1)      // insertion
      let dep3 = x.at(i - 1).at(j - 1)  // substitution/match

      if dep1 != none and dep2 != none and dep3 != none {
        if s1.at(i - 1) == s2.at(j - 1) {
          dep3
        } else {
          1 + calc.min(dep1, calc.min(dep2, dep3))
        }
      } else {
        none
      }
    }
  }

  let F = ((s1, s2)) => map_tensor(F_i((s1, s2)), dim: 2)

  let pi = ((s1, s2)) => (x) => {
    let m = s1.len()
    let n = s2.len()
    x.at(m).at(n)
  }

  let I_h((s1, s2)) = {
    [
      [$s_1:$ "#s1"],
      [$s_2:$ "#s2"],
    ]
  }

  // draw DP table with string character labels
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()

    // header row: show s2 characters (with an initial empty corner)
    let header_cells = ()
    header_cells.push(rect(stroke: none, inset: 4pt)[$bot$])
    header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$epsilon$])
    for j in range(0, inst_n) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#inst_s2.at(j)$])
    }
    rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

    for i in range(0, x.len()) {
      let row = ()
      // left label: s1 character for i>0, empty for i=0
      if i == 0 {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$epsilon$])
      } else {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#inst_s1.at(i - 1)$])
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
    rho, F((inst_s1, inst_s2)), pi((inst_s1, inst_s2)),
    I_h: I_h,
    X_h: x_h,
    F_name: [$F_(s_1, s_2)$],
    pi_name: [$\pi_(#inst_m, #inst_n)$],
    group-size: 3,
    cell-size: 40mm, scale-fig: 85%
  )((inst_s1, inst_s2))
}$)

