#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Subset Sum Problem

Given a set of non-negative integers $S$ and a target sum $T$, determine
if there is a subset of $S$ whose elements sum to $T$.

Formal definition:
Let $D(i, j)$ be true if a sum of $j$ can be made using the first $i$ items.
$
D(i, j) = cases(
  "true" & "if " j = 0,
  "false" & "if " i = 0 " and " j > 0,
  D(i-1, j) & "if " S_i > j,
  D(i-1, j) or D(i-1, j - S_i) & "otherwise"
)
$

*As mapcode:*

_primitives_: `or`

$
I &= S:bb(N)^* times T:bb(N) quad quad quad "where" m = |S| \
X_(m,T) &= [0..m] times [0..T] -> {bot, "true", "false"} \
A &= {"true", "false"} \
rho(m,T) &= { (i,j) |-> bot | i in {0 dots m}, j in {0 dots T}} \
F_S(x_(i,j)) &= cases(
    "true" & "if " j = 0,
    "false" & "if " i = 0 " and " j > 0,
    x_(i-1, j) & "if " S_(i-1) > j,
    x_(i-1, j) or x_(i-1, j - S_(i-1)) & "otherwise"
) \
pi_(S,T) (x) &= x_(m,T)
$

#let inst_S = (3, 5, 8);
#let inst_T = 11;
#let inst_m = inst_S.len();

#figure(
  caption: [Subset Sum DP table for $S = #inst_S$ and $T = #inst_T$.],
$#{
  let rho = ((inst_m, inst_T)) => {
    let x = ()
    for i in range(0, inst_m + 1) {
      let row = ()
      for j in range(0, inst_T + 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }
  let F_i = (S) => (x) => ((i,j)) => {
    if j == 0 {
      true
    } else if i == 0 and j > 0 {
      false
    } else {
      let item = S.at(i - 1)
      if item > j {
        // Item is too large, 'without' case
        let without = x.at(i - 1).at(j)
        if without != none {
          without
        } else {
          none
        }
      } else {
        // 'with' or 'without'
        let without = x.at(i - 1).at(j)
        let with = x.at(i - 1).at(j - item)
        if without != none and with != none {
          without or with
        } else {
          none
        }
      }
    }
  }
  let F = (S) => map_tensor(F_i(S), dim: 2)

  let pi = ((S, T)) => (x) => {
    let m = S.len()
    x.at(m).at(T)
  }

  // draw DP table
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()

    // header row: Target Sum
    let header_cells = ()
    header_cells.push(rect(fill: green.transparentize(70%), inset: 4pt)[$i slash j$])
    for j in range(0, inst_T + 1) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#j$])
    }
    rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

    for i in range(0, x.len()) {
      let row = ()
      // left label: Item from S
      if i == 0 {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$0$])
      } else {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#inst_S.at(i - 1)$])
      }

      for j in range(0, x.at(i).len()) {
        let val = if x.at(i).at(j) == true {
          $checkmark$
        } else if x.at(i).at(j) == false {
          $times$
        } else {
          $bot$
        }
        
        if diff_mask != none and diff_mask.at(i).at(j) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[#val])
        } else {
          row.push(rect(stroke: gray, inset: 4pt)[#val])
        }
      }
      rows.push(grid(columns: row.len() * (14pt,), rows: 14pt, align: center + horizon, ..row))
    }
    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho, F(inst_S), pi((inst_S, inst_T)),
    X_h: x_h,
    pi_name: [$pi ((#inst_m, #inst_T))$],
    group-size: calc.min(3, inst_m),
    cell-size: 55mm, scale-fig: 65%
  )((inst_m, inst_T))
}$)