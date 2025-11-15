#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Optimal Matrix Chain Multiplication
#set math.equation(numbering: none)

Given a sequence of matrices $A_(n_1 times n_2),A_(n_2 times n_3),..,A_(n_(q-1) times q_i)$, Compute the minimum number of scalar multiplication required to multiply all of them.  
The algorithm takes in vector $d = (n_1,..,n_q)$ and returns an integer.

Formal definition: $"num_mul"(d) := T_d (0,|d|-2)$ where

$
  T_d (i, j) = min_{k|i<=k<j} T_d (i,k)+T_d (k+1,j)+d(i) dot d(j+1) dot d(k+1)
$  
This is a classic dynamic programming algorithm where we build up by solving subproblems. $T_d$ is a matrix whose (i,j)th represents the subproblem instance (n_i,...,n_j+1)

Examples:
- $"num_mul"(10, 20, 30, 40, 50) -> 38000 $
- $"num_mul"(13, 5, 89, 3, 34) -> 2856$

*As mapcode:*

_primitives_: `mod`($mod$) is strict. i.e operation on $bot$ is undefined.

$
  I = "vec"[NN] quad quad quad X & = NN times NN -> NN_bot quad quad quad
  A = NN \
    rho(d) & = {(i,j) -> bot | i,j in NN} \
        F_d (x) & = cases(
                  0 & "if " i = j,
                  min { x(i,k)+ x(k+1,j)+d(i) dot d(j+1) dot d(k+1) |i<=k<j} & "else"
                ) \
        pi_d (x) & = x(0,|d|-2)
$




#let inst_dimvecs  = (10, 20, 30, 40, 50);
#let inst_dm = inst_dimvecs.len();


#figure(
  caption: [Optimal Matrix Chain Multiplication for dimensions = #inst_dimvecs.],
$#{
  let rho = (inst_dimvecs) => {
    let x = ()
    for i in range(0, inst_dimvecs.len() - 1) {
      let row = ()
      for w in range(0, inst_dimvecs.len() - 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i(d) = (x) => ((i, j)) => {
    if i == j {
      0
    } else {
      let mut = none
      let min_val = none
      for k in range(i, j) {
        let term1 = x.at(i).at(k)
        let term2 = x.at(k+1).at(j)
        let product = d.at(i) * d.at(j+1) * d.at(k+1)
        
        // If any component is none, the result is none
        if term1 == none or term2 == none {
          // Continue to check other k values, but min_val becomes none
          min_val = none
        } else if min_val != none {
          let current = term1 + term2 + product
          if current < min_val {
            min_val = current
          }
        }
      }
      min_val
    }
  }
  

  let F = (inst_dimvecs) => map_tensor(F_i(inst_dimvecs), dim: 2)

  let pi = ((dimvec)) => (x) => {
    let m = dimvec.len()
    x.at(0).at(m - 2)
  }

  // (2, 3, 4, 5), (3, 4, 5, 6), 5)
  let I_h(inst_dimvecs) = {
    [
      $d: vec(..#inst_dimvecs.map(i => [#i]), delim: "[")_(#inst_dimvecs.len())$
    ]
  }

  
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()

    
    let header_cells = ()
    header_cells.push(rect(fill: green.transparentize(70%), inset: 14pt)[$id$])
    

    for w in range(0, x.at(0).len()) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 14pt)[$#w$])
    }
    rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

    for i in range(0, x.len()) {
      let row = ()
      
      if i == 0 {
        row.push(rect(fill: green.transparentize(70%), inset: 14pt)[$0$])
      }else{
        row.push(rect(fill: green.transparentize(70%), inset: 14pt)[$#i$])
      }

      for w in range(0, x.at(i).len()) {
        let val = if x.at(i).at(w) != none {[$#x.at(i).at(w)$]} else {[$bot$]}
        if diff_mask != none and diff_mask.at(i).at(w) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 14pt)[$#val$])
        } else {
          row.push(rect(stroke: gray, inset: 14pt)[$#val$])
        }
      }

      rows.push(grid(columns: row.len() * (30pt,), rows: 14pt, align: center + horizon, ..row))
    }

    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho, F(inst_dimvecs), pi(inst_dimvecs),
    I_h: I_h,
    X_h: x_h,
    F_name: [$F_(w,v)$],
    pi_name: [$\pi_(w,v,C)$],
    group-size: calc.min(3, inst_dimvecs.len()),
    cell-size: 60mm, scale-fig: 75%
  )(inst_dimvecs)
}$)

