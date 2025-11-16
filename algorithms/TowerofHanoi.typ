#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Tower of Hanoi
#set math.equation(numbering: none)

Solve the Tower of Hanoi puzzle with $n$ disks, moving all disks from source rod to destination rod using auxiliary rod, following the rules:
1. Only one disk can be moved at a time
2. Each move consists of taking the upper disk from one stack and placing it on top of another stack
3. No larger disk may be placed on top of a smaller disk

Formal definition:
$
  "hanoi": (n, "src", "dst", "aux") -> "sequence of moves"
$
where $n$ is the number of disks, and the function returns the sequence of moves to transfer $n$ disks.

Algorithm:
1. Move $n-1$ disks from source to auxiliary, using destination as the auxiliary rod
2. Move the largest disk from source to destination
3. Move $n-1$ disks from auxiliary to destination, using source as the auxiliary rod

Examples:
- $"hanoi"(0, "A", "C", "B") -> []$ (no moves needed)
- $"hanoi"(1, "A", "C", "B") -> [(A, C)]$ (direct move)
- $"hanoi"(2, "A", "C", "B") -> [(A, B), (A, C), (B, C)]$

*As mapcode:*

_primitives_: `move` transfers a disk from one rod to another, `concat` combines move sequences.

For Tower of Hanoi, we model the problem using a DP table where each cell corresponds to a subproblem (k disks with specific rod configuration). The state `X` is a 2D table where `X[k][p]` stores the solution for `hanoi(k, src, dst, aux)` in permutation `p`.

$
  I = n:NN quad quad quad X & = [0..n] times [0..5] -> [text("Move")]_bot quad quad quad A = [text("Move")] \
                          rho(n) & = {(k,p) -> bot | k in [0..n], p in [0..5]} \
                              F(x) & = cases(
                                         () & "if " k = 0, "base case"\\
                                         "concat"(x_{k-1, p_1}, [("src", "dst")], x_{k-1, p_2}) & "if " k > 0 " and dependencies solved"\\
                                         bot & "otherwise"
                                       ) \
                               pi(x) & = x_{n,0}
$

// Example showing the solution for 2 disks
#let example_moves = (("A", "B"), ("A", "C"), ("B", "C"))
#let inst_n = 2;
#h(3em)
For 2 disks from A to C using B as auxiliary, the moves are: $A -> B$, $A -> C$, $B -> C$

#figure(
  caption: [Tower of Hanoi computation using mapcode for $#inst_n$ disks],
  $
    #{
      // Map rod permutations to indices:
      // 0: (A,B,C), 1: (A,C,B), 2: (B,A,C), 3: (B,C,A), 4: (C,A,B), 5: (C,B,A)

      // Initialize: 2D table with all undefined values
      let rho = n => {
        let x = ()
        for k in range(0, n + 1) {
          let row = ()
          for p in range(0, 6) {
            row.push(none)  // bot
          }
          x.push(row)
        }
        x  // (n+1) x 6 table
      }

      // Function to compute value at a specific index (k, p) based on previous state
      let F_i = (prev_state) => ((k_idx, p_idx)) => {
        // Base case: 0 disks requires no moves
        if k_idx == 0 {
          ()
        } else {
          // Map permutation index to rod configuration
          // Permutation 0: (src, dst, aux) = (A, C, B) - main case of interest
          // Permutation 1: (src, dst, aux) = (A, B, C)
          // Permutation 2: (src, dst, aux) = (B, C, A)
          // Permutation 3: (src, dst, aux) = (B, A, C)
          // Permutation 4: (src, dst, aux) = (C, B, A)
          // Permutation 5: (src, dst, aux) = (C, A, B)
          let rods = if p_idx == 0 { ("A", "C", "B") }  // hanoi(k, A, C, B) - main case
              else if p_idx == 1 { ("A", "B", "C") }   // hanoi(k, A, B, C)
              else if p_idx == 2 { ("B", "C", "A") }   // hanoi(k, B, C, A)
              else if p_idx == 3 { ("B", "A", "C") }   // hanoi(k, B, A, C)
              else if p_idx == 4 { ("C", "B", "A") }   // hanoi(k, C, B, A)
              else { ("C", "A", "B") }                 // hanoi(k, C, A, B)

          let (src, dst, aux) = rods

          // For hanoi(k, src, dst, aux), we need:
          // 1. hanoi(k-1, src, aux, dst) - move k-1 disks from src to aux using dst as aux
          // 2. hanoi(k-1, aux, dst, src) - move k-1 disks from aux to dst using src as aux

          // Find permutation indices for the dependencies based on the rod configuration
          // We need to map (src, aux, dst) to p1_idx and (aux, dst, src) to p2_idx

          // Helper function to map (src, dst, aux) to permutation index
          let get_perm_idx = (s, d, a) => {
            if s == "A" and d == "C" and a == "B" { 0 }  // (A, C, B)
            else if s == "A" and d == "B" and a == "C" { 1 }  // (A, B, C)
            else if s == "B" and d == "C" and a == "A" { 2 }  // (B, C, A)
            else if s == "B" and d == "A" and a == "C" { 3 }  // (B, A, C)
            else if s == "C" and d == "B" and a == "A" { 4 }  // (C, B, A)
            else { 5 }  // (C, A, B)
          }

          let (src, aux, dst_from_src) = (src, aux, dst)  // First dependency: (src, aux, dst)
          let (aux2, dst2, src2) = (aux, dst, src)        // Second dependency: (aux, dst, src)

          let p1_idx = get_perm_idx(src, aux, dst)  // hanoi(k-1, src, aux, dst)
          let p2_idx = get_perm_idx(aux, dst, src)  // hanoi(k-1, aux, dst, src)

          // Get solutions to subproblems from previous state
          let sub1_moves = if k_idx > 0 { prev_state.at(k_idx - 1).at(p1_idx) } else { none }
          let sub2_moves = if k_idx > 0 { prev_state.at(k_idx - 1).at(p2_idx) } else { none }

          // Only compute if both dependencies are solved
          if sub1_moves != none and sub2_moves != none {
            let result = ()
            // Add subproblem 1 moves
            for move in sub1_moves { result.push(move) }
            // Add the middle move (move largest disk)
            result.push((src, dst))
            // Add subproblem 2 moves
            for move in sub2_moves { result.push(move) }
            result
          } else {
            none  // Dependencies not ready yet
          }
        }
      }

      // Apply F_i to all positions in the table
      let F = map_tensor(F_i, dim: 2)

      // Extract final result: solution for n disks in the primary configuration
      let pi = n => x => x.at(n).at(0)

      // Visualize the state (show a flattened version or a specific row)
      let X_h = (x, diff_mask: none) => {
        // For simplicity, just show the main diagonal for small cases
        let cells = ()
        for k in range(0, calc.min(x.len(), 4)) {
          let row = x.at(k)
          let cell_val = if row.at(0) != none and type(row.at(0)) == array {
            let moves = row.at(0)
            if moves.len() > 0 {
              let move_str = moves.slice(0, calc.min(2, moves.len())).map(m => {
                if type(m) == array and m.len() >= 2 {
                  str(m.at(0)) + "->" + str(m.at(1))
                } else {
                  "?"
                }
              }).join(", ")
              if moves.len() > 2 { move_str + "..." } else { move_str }
            } else { "()" }  // Empty moves
          } else {
            [$bot$]
          }

          // Check if this cell changed in the diff
          let cell_changed = false
          if diff_mask != none and k < diff_mask.len() {
            let row_mask = diff_mask.at(k)
            if row_mask != none and type(row_mask) == array and 0 < row_mask.len() {
              cell_changed = row_mask.at(0)
            }
          }

          if cell_changed {
            cells.push(rect(fill: yellow.transparentize(70%), inset: 2pt)[$#cell_val$])
          } else {
            cells.push(cell_val)
          }
        }
        $vec(delim: "[", ..cells)$
      }

      mapcode-viz(
        rho,
        F,
        pi(inst_n),
        X_h: X_h,
        pi_name: [$pi$],
        group-size: 2,
        cell-size: 10mm,
        scale-fig: 85%
      )(inst_n)
    }
  $,
)