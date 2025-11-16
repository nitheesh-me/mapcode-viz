#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Matrix Chain Multiplication

Compute the minimum number of scalar multiplications needed to multiply a chain of matrices. The input $p$ is an array of dimensions, where matrix $M_i$ has dimensions $p_i times p_(i+1)$.

Formal definition (0-indexed):
$
m[i, j] = cases(
  0 & "if " j = i+1,
  min_(i < k < j) (m[i, k] + m[k, j] + p_i p_k p_j) & "if " j > i+1
)
$

*As mapcode:*

_primitives_: `sum`($+$), `min`(min)

$
I = (i,j):[0..n-1] times [0..n-1] quad "where" n = |p| \
// X is now *only* the matrix
X_(i,j) & = [0..n-1] times [0..n-1] -> NN_bot \
A = NN\
// rho is parameterized by (p, n) and returns *only* mat
rho_((p, n)) & = { (i,j) -> bot | i,j in {0 dots n-1}} \
// F is parameterized by (p) and receives *only* mat
F_((p))(x_(i,j)) & = cases(
  0 & "if " j = i+1,
  min_(i < k < j) (x_(i,k) + x_(k,j) + p_i p_k p_j) & "if " j > i+1,
  bot & "otherwise"
)\
// pi is parameterized by (p, n) and receives *only* mat
pi_((p, n))(x) & = x_(0, n-1)
$

#let inst_p = (4,6,2,9,4,5,6); // 3 matrices: 10x30, 30x5, 5x60
#let inst_n = inst_p.len();

#figure(
  caption: [Matrix Chain Multiplication (MCM) computation using mapcode for $p = #inst_p$.],
$#{
  // rho is parameterized, returns *only* mat
  let rho = ((p, n)) => {
    let mat = ()
    for i in range(0, n) {
      let row = ()
      for j in range(0, n) { row.push(none) }
      mat.push(row)
    }
    mat // <-- CHANGED
  }

  // F_i is parameterized by (p).
  // It receives x_full which is *just* the matrix.
  let F_i = ((p)) => (x_full) => ((i, j)) => {
    let mat = x_full // <-- CHANGED: x_full *is* the mat
    
    if j <= i {
      return none // Lower triangle and diagonal
    } else if j == i + 1 {
      return 0 // Cost of a single matrix
    } else {
      // j > i+1. Compute min cost
      let costs = ()
      for k in range(i + 1, j) {
        let cost1 = mat.at(i).at(k)
        let cost2 = mat.at(k).at(j)
        
        // p comes from closure
        if cost1 != none and cost2 != none {
          let cost_split = cost1 + cost2 + p.at(i) * p.at(k) * p.at(j)
          costs.push(cost_split)
        }
      }
      
      if costs.len() > 0 {
        return calc.min(..costs)
      } else {
        return none // Prerequisites not met
      }
    }
  }
  
  // F is parameterized by (p). It returns a function that
  // map_tensor will apply to x_full (which is just mat).
  let F = ((p)) => map_tensor(F_i((p)), dim: 2)
  
  // No F_wrapped is needed anymore.

  // pi is parameterized by (p, n).
  // It receives x_full which is *just* the final matrix.
  let pi = ((p, n)) => (x_full) => {
    let mat = x_full // <-- CHANGED
    mat.at(0).at(n - 1) // Final cost m[0, n-1]
  }

  // x_h receives x_full which is *just* the matrix
  let x_h(x_full, diff_mask: none) = {
    let mat = x_full // <-- CHANGED
    let n = mat.len() // Get n from the matrix itself
    set text(weight: "bold")
    let rows = ()
    
    // Header row
    let header_cells = ()
    header_cells.push(rect(stroke: none, inset: 4pt)[$i/j$])
    for j in range(0, n) { header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#j$]) }
    rows.push(grid(columns: (n + 1) * (auto,), ..header_cells))

    for i in range(0, n) {
      let row = ()
      row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#i$]) // Row label
      
      for j in range(0, n) {
        let val = if mat.at(i).at(j) != none { [$#mat.at(i).at(j)$] } else { [$bot$] }
        let cell = rect(stroke: gray, inset: 4pt)[#val]
        if i >= j {
          cell = rect(stroke: gray, fill: gray.transparentize(80%), inset: 4pt)[#val]
        }
        
        if diff_mask != none and diff_mask.at(i).at(j) {
          cell = rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[#val]
        }
        row.push(cell)
      }
      rows.push(grid(columns: (n + 1) * (auto,), ..row))
    }
    grid(rows: (n + 1), ..rows)
  }

  mapcode-viz(
    rho, F((inst_p)), pi((inst_p, inst_n)), // <-- Call F, not F_wrapped
    X_h: x_h,
    pi_name: [$"pi_mcm"$],
    group-size: 2, // DP computation order is diagonal
    cell-size: 60mm, scale-fig: 75%
  )((inst_p, inst_n)) // Pass (p, n) to parameterize rho, pi
}$)