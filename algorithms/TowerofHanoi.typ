#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Tower of Hanoi
#set math.equation(numbering: none)

Solve the Tower of Hanoi puzzle with $n$ disks.
Algorithm:
1. Move $n-1$ disks from source to auxiliary.
2. Move the largest disk from source to destination.
3. Move $n-1$ disks from auxiliary to destination.

*As mapcode (Dynamic Programming Model):*
We model the state `X` as a 2D table `X[k][p]`, where $k$ is the number of disks and $p$ is an index for one of the 6 rod permutations.
$  X[k, p] = "solution for hanoi(k, ...)" $

$
  I = n:NN \
  X = [0..n] times [0..5] -> [text("Move")]_bot \
  A = [text("Move")] \
  rho(n) & = { (k,p) -> bot | k in {0..n}, p in {0..5}} \
  F(x)_(k,p) & = cases(
      [] & "if " k = 0,
      x[k-1, p_1] + [(s,d)] + x[k-1, p_2] & "if deps " x[k-1, ..] != bot,
      bot & "otherwise"
    ) \
  pi(n)(x) & = x[n, 0] // p=0 is the main problem "A->C (B)"
$

// --- 1. Global Definitions (Helper Data) ---

// Define all 6 permutations (src, dst, aux)
#let perms = (
  (src: "A", dst: "C", aux: "B"), // p=0 (Main Problem)
  (src: "A", dst: "B", aux: "C"), // p=1
  (src: "B", dst: "C", aux: "A"), // p=2
  (src: "B", dst: "A", aux: "C"), // p=3
  (src: "C", dst: "B", aux: "A"), // p=4
  (src: "C", dst: "A", aux: "B")  // p=5
)

// Pre-calculate the dependency indices for each permutation `p`
// dep_logic[p] = (p_dep1, p_dep2)
// Example: p=0 (A->C, B) depends on:
// 1. h(k-1, A, B, C) -> p=1
// 2. h(k-1, B, C, A) -> p=2
#let dep_logic = (
  (1, 2), // p=0
  (0, 5), // p=1
  (3, 0), // p=2
  (2, 4), // p=3
  (5, 2), // p=4
  (4, 3)  // p=5
)

#let inst_n = 2; // Example for 2 disks

// --- 2. Mapcode Functions (rho, F, pi) ---

// rho: Initialize (n+1) x 6 table with `none`
#let rho = n => {
  let x = ()
  for k in range(0, n + 1) {
    let row = ()
    for p in range(6) {
      row.push(none) // bot
    }
    x.push(row)
  }
  x
}

// F_i: Logic for a single cell X[k][p]
#let F_i = x => ((k_idx, p_idx)) => {
  // Base case: 0 disks requires no moves
  if k_idx == 0 {
    ()
  } else {
    // 1. Get info for this permutation
    let p_info = perms.at(p_idx)
    let move_mid = ( (p_info.src, p_info.dst), )
    
    // 2. Find the dependency indices from our pre-calculated map
    let (p1_idx, p2_idx) = dep_logic.at(p_idx)

    // 3. Look up solutions for sub-problems in the *previous* state `x`
    let moves1 = x.at(k_idx - 1).at(p1_idx)
    let moves2 = x.at(k_idx - 1).at(p2_idx)

    // 4. Check if dependencies are met (i.e., not none)
    if moves1 != none and moves2 != none {
      // 5. Dependencies met. Compute the result using array concatenation.
      moves1 + move_mid + moves2
    } else {
      // Dependencies not met. Stay ⊥ (none).
      none
    }
  }
}

// F: Applies F_i to the entire 2D state array
#let F = map_tensor(F_i, dim: 2)

// pi: Extract final result (solution for n disks, main permutation p=0)
#let pi = n => x => x.at(n).at(0)

// --- 3. Visualization Helpers (X_h, A_h) ---

// X_h: Renders the state X
#let X_h = (x, diff_mask: none) => {
  // Show the status of the main problem (p=0) for each k
  let cells = ()
  for k in range(0, x.len()) {
    let row = x.at(k)
    let val = row.at(0) // Get the p=0 (main) permutation
    
    let cell_val_str = if val != none and type(val) == array {
      let moves = val
      if moves.len() > 0 {
        let move_str = moves.slice(0, calc.min(moves.len(), 3)).map(m => {
          if type(m) == array and m.len() >= 2 {
            str(m.at(0)) + "->" + str(m.at(1))
          } else { "?" }
        }).join(", ")
        if moves.len() > 3 { move_str + "..." } else { move_str }
      } else { "()" } // Empty moves
    } else {
      [$bot$] // This can be math, it's just content
    }

    let cell_changed = false
    if diff_mask != none and k < diff_mask.len() {
      let row_mask = diff_mask.at(k)
      if row_mask != none and type(row_mask) == array and 0 < row_mask.len() {
        cell_changed = row_mask.at(0)
      }
    }

    // This creates content, which can include math
    let cell_content = [$k=#k: #cell_val_str$]
    
    if cell_changed {
      // CORRECTED: Added %
      cells.push(rect(fill: yellow.transparentize(70%), inset: 2pt)[#cell_content])
    } else {
      cells.push(cell_content)
    }
  }
  
  // Return a `table` (a content-mode function), not `$mat`
  table(
    columns: 1,
    align: center,
    ..cells
  )
}


// A_h: Renders the final answer
#let A_h = a => {
  if a != none and type(a) == array {
    let moves_items = a.map(m => "(" + str(m.at(0)) + "," + str(m.at(1)) + ")")
    let moves_str = moves_items.join(", ")
    [$(#moves_str)$]
  } else {
    [$bot$]
  }
}

// --- 4. Visualization Execution ---
#figure(
  caption: [Tower of Hanoi computation using mapcode for $#inst_n$ disks],
  $
    #{
      mapcode-viz(
        rho,
        F,
        pi(inst_n),
        X_h: X_h,
        A_h: A_h,
        pi_name: [$pi$],
        group-size: inst_n + 1, // Show all k steps
        cell-size: 40mm,
        scale-fig: 90%
      )(inst_n)
    }
  $,
)