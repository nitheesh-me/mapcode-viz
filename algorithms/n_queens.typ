
#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== N-Queens
#set math.equation(numbering: none)

Compute the number of solutions to the N-Queens problem: placing $N$ queens on an $N times N$ chessboard so that no two queens attack each other.

Formal definition:
Let $f(k)$ be the set of all valid partial queen placements in rows $0$ to $k-1$.
$
f(k) = cases(
  { () } & "if " k = 0,
  union_("sol" in f(k-1)) { "sol" + (c,) | c in [0..N-1], "is_safe"("sol", c) } & "if " k > 0
)
$
The total number of solutions for an $N times N$ board, denoted $"nqueens"(N)$, is the size of the set of full solutions, i.e., $|f(N)|$.

Examples:
- $"nqueens"(1) -> |f(1)| = 1$
- $"nqueens"(4) -> |f(4)| = 2$
- $"nqueens"(8) -> |f(8)| = 92$

*As mapcode:*

_primitives_: `union`, `iteration`

$ 
I &= n:NN quad quad quad
// X[k] = f(k), the set of partial solutions for rows 0..k-1
X_n = [0..n] -> "Set"["Tuple"]bot quad quad quad A = NN\

rho(n) & = {k -> bot | k in [0..n]}\

F(x_k) & = cases( { () } & "if " k = 0, union_("sol" in x_(k-1)) { "sol" + (c,) | c in [0..n-1], "is_safe"("sol", c) } & "if " k > 0 " and " x_(k-1) != bot )\

pi(x) & = |x_n| = |x_(|x| - 1)| 
$

#let inst = 4;
#figure(
  caption: [N-Queens computation using mapcode for $n = #inst$. The state vector $X[k]$ shows the valid partial solutions using $k$ queens (in rows $0..k-1$).],
$
#{
  let rho = (inst) => {
    let x = ()
    for i in range(0, inst + 1) {
      x.push(none) 
    }
    x
  }

  let is_safe = (partial_solution, new_col) => {
    let new_row = partial_solution.len()
    
    // column conflict
    if partial_solution.find(c => c == new_col) != none {
      return false
    }
    
    // diagonal conflicts
    for (prev_row, prev_col) in partial_solution.enumerate() {
      if (new_row - prev_row == new_col - prev_col or new_row - prev_row == prev_col - new_col) {
        return false
      }
    }
    return true
  }

  let F_i = (n) => (x) => ((i,)) => {
    if i == 0 {
      ( (), )
    } else if x.at(i - 1) != none {
      let prev_solutions = x.at(i - 1)
      let new_solutions_for_i = () 

      for partial_sol in prev_solutions {
        for new_col in range(n) {
          if is_safe(partial_sol, new_col) {
            // add (partial_sol + (new_col,))
            new_solutions_for_i.push(partial_sol + (new_col,))
          }
        }
      }
      new_solutions_for_i
    } else {
      none 
    }
  }
  let F = (n) => map_tensor(F_i(n), dim: 1)

  let pi = (i) => (x) => {
    if x.at(i) != none {
      x.at(i).len()
    } else {
      none
    }
  }

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {
        // display the count of partial solutions
        [$#x_i$] 
        // [$#x_i.len()$] 
      } else {
        [$bot$]
      }
      if diff_mask != none and diff_mask.at(i) {
        // changed element: highlight
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho,
    F(inst), 
    pi(inst),
    X_h: X_h,
    pi_name: [$mpi (inst)$],
    group-size: calc.min(1, inst + 1),
    cell-size: 10mm, scale-fig: 85%
  )(inst)
}
$
)