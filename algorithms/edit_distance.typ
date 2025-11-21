#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Edit Distance
#set math.equation(numbering: none)

Compute the Edit Distance (Levenshtein distance) between two strings, S and T. This is the minimum number of single-character edits (insertions, deletions, or substitutions) required to change S into T.

Formal definition:
Let $"ED"(i, j)$ be the edit distance between the first $i$ characters of $S$ and the first $j$ characters of $T$.
$
"ED"(i, j) = cases(
  i & "if " j = 0,
  j & "if " i = 0,
  min(
    "ED"(i-1, j) + 1,
    "ED"(i, j-1) + 1,
    "ED"(i-1, j-1) + "cost"
  ) & "otherwise"
)
$
where "cost" is 0 if $S_i = T_j$ and 1 otherwise.

Example:
- $S = "kitten", T = "sitting" -> "ED" = 3$

*As mapcode:*

_primitives_: `min`, `sum`($+$)

$
I &= S:"Str" times T:"Str" quad quad "let" m = |S|, n = |T| \
X_(i,j) & = [0..m] times [0..n] -> NN_bot quad quad
A = NN\
rho(m,n) & = { (i,j) -> bot |
i in {0 dots m}, j in {0 dots n}} \
F_(S, T)(x_(i,j)) & = cases(
    i & "if " j = 0,
    j & "if " i = 0,
    min(
      x_(i-1, j) + 1,
      x_(i, j-1) + 1,
      x_(i-1, j-1) + "cost"
    ) & "otherwise"
)\
pi_(S,T) (x) & = x_(m,n) quad quad "where" m = |S|, n = |T|
$

#let inst_S = "kitten";
#let inst_T = "sitting";
#let inst_m = inst_S.len();
#let inst_n = inst_T.len();

#figure(
  caption: [Edit Distance computation using mapcode for $S = #inst_S$ and $T = #inst_T$; dynamic-programming table visualization.],
$#{
  let rho = ((m, n)) => {
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

  let F_i = ((S, T)) => (x) => ((i,j)) => {
    if i == 0 {
      j // Base case: ED(0, j) = j
    } else if j == 0 {
      i // Base case: ED(i, 0) = i
    } else {
      // Check dependencies
      let val_del = x.at(i - 1).at(j)
      let val_ins = x.at(i).at(j - 1)
      let val_sub = x.at(i - 1).at(j - 1)
      
      if val_del == none or val_ins == none or val_sub == none {
        none
      } else {
        // S.at(i - 1) corresponds to S_i
        let cost = if S.at(i - 1) == T.at(j - 1) { 0 } else { 1 }
        
        calc.min(
          val_del + 1,    // Deletion
          val_ins + 1,    // Insertion
          val_sub + cost  // Substitution
        )
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
    X_h: x_h,
    pi_name: [$mpi ((#inst_m, #inst_n))$],
    group-size: calc.min(4, inst_m),
    cell-size: 60mm, scale-fig: 60%
  )((inst_m, inst_n))
}$)