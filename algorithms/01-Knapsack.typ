#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== 0-1 Knapsack (dynamic programming, mapcode)

Compute the maximum value that can be obtained by selecting a subset of items (each at most once) with given weights and values, not exceeding capacity W.

Formal definition:
$
"K"(i, w) = cases(
  0 & "if " i = 0,
  "K"(i-1, w) & "if " "weight"_i > w,
  max("K"(i-1, w), "K"(i-1, w - "weight"_i) + "value"_i) & "otherwise"
)
$
*As mapcode:*
_primitives_: `max`, `sub`($-$), `leq`($<=$), `add`($+$)
$
k = NN\
I = w:[NN]^k times v:[NN]^k times C:NN quad quad quad
X_(m,C) & = [0..m] times [0..C] -> NN_bot quad quad quad
A = NN\
rho(w, v, C) & = { (i,w) -> bot | i in {0 dots m}, w in {0 dots C}} \
F_(w,v)(x_(i,c)) & = cases(
    0 & "if " i = 0,
    x_(i-1,c) & "if " w_i > c,
    max(x_(i-1,c), x_(i-1,c - w_i) + v_i) & "otherwise"
  )\
pi_(w,v,C) (x) & = x_(m,C) quad quad quad "where" m = |w|\
$

#let inst_weights = (2, 3, 4, 5);
#let inst_values  = (3, 4, 5, 6);
#let inst_m = inst_weights.len();
#let inst_C = 5;

#figure(
  caption: [0-1 Knapsack DP table for weights = #inst_weights, values = #inst_values, capacity $W = #inst_C$.],
$#{
  let rho = ((inst_weights, inst_values, inst_C)) => {
    let x = ()
    for i in range(0, inst_weights.len() + 1) {
      let row = ()
      for w in range(0, inst_C + 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i = ((weights, values)) => (x) => ((i,w)) => {
    if i == 0 {
      0
    } else {
      let wi = weights.at(i - 1)
      let vi = values.at(i - 1)
      // If weight too large: inherit previous row
      if wi > w {
        if x.at(i - 1).at(w) != none {
          x.at(i - 1).at(w)
        } else {
          none
        }
      } else {
        // both options must be available to compute
        let without = x.at(i - 1).at(w)
        let with = x.at(i - 1).at(w - wi)
        if without != none and with != none {
          calc.max(without, with + vi)
        } else {
          none
        }
      }
    }
  }

  let F = ((weights, values)) => map_tensor(F_i((weights, values)), dim: 2)

  let pi = ((weights, values, C)) => (x) => {
    let m = weights.len()
    x.at(m).at(C)
  }

  // (2, 3, 4, 5), (3, 4, 5, 6), 5)
  let I_h((inst_weights, inst_values, inst_C)) = {
    [
      $w: vec(..#inst_weights.map(i => [#i]), delim: "[")_(#inst_weights.len())$,
      $v: vec(..#inst_values.map(i => [#i]), delim: "[")_(#inst_values.len())$,
      $C: #inst_C$,
    ]
  }

  // visualization: items on rows, capacities (0..W) as columns
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()

    // header row: capacities (with initial empty corner)
    let header_cells = ()
    header_cells.push(rect(fill: green.transparentize(70%), inset: 4pt)[$id$])
    header_cells.push(rect(fill: green.transparentize(70%), inset: 4pt)[$w$])
    header_cells.push(rect(fill: green.transparentize(70%), inset: 4pt)[$v$])

    for w in range(0, x.at(0).len()) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#w$])
    }
    rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

    for i in range(0, x.len()) {
      let row = ()
      // left label: empty for i=0, otherwise item label "i: wi/vi"
      if i == 0 {
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$0$])
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$emptyset$])
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$emptyset$])
      } else {
        let wi = inst_weights.at(i - 1)
        let vi = inst_values.at(i - 1)
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#i$])
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#wi$])
        row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#vi$])
      }

      for w in range(0, x.at(i).len()) {
        let val = if x.at(i).at(w) != none {[$#x.at(i).at(w)$]} else {[$bot$]}
        if diff_mask != none and diff_mask.at(i).at(w) {
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
    rho, F((inst_weights, inst_values)), pi((inst_weights, inst_values, inst_C)),
    I_h: I_h,
    X_h: x_h,
    F_name: [$F_(w,v)$],
    pi_name: [$\pi_(w,v,C)$],
    group-size: calc.min(3, inst_weights.len()),
    cell-size: 60mm, scale-fig: 75%
  )((inst_weights, inst_values, inst_C))
}$)

