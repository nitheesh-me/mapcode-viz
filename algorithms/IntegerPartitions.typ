#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Integer Partitions
#set math.equation(numbering: none)

Generate all integer partitions of a positive integer $n$. A partition of $n$ is a way of writing $n$ as a sum of positive integers, where order doesn't matter.

Formal definition:

For integer $n in NN$, find all sequences $[p_1, p_2, ..., p_k]$ where:
$
p_1 + p_2 + ... + p_k = n quad "and" quad p_1 >= p_2 >= ... >= p_k >= 1
$

Examples of partitions:
- $n = 4$: $[4], [3,1], [2,2], [2,1,1], [1,1,1,1]$ (5 partitions)
- $n = 5$: $[5], [4,1], [3,2], [3,1,1], [2,2,1], [2,1,1,1], [1,1,1,1,1]$ (7 partitions)

Recursive structure:
$
P(n, m) = "partitions of" n "using parts" <= m
$
$
P(0, m) &= {[]} quad "for all" m\
P(n, m) &= union.big_(k=1)^(min(n,m)) {[k] + p | p in P(n-k, k)}
$

*As mapcode:*

_primitives_: List concatenation and set union. Both strict on $bot$.

State: map $(s, m) -> "List"["Partition"]$ where $s$ is sum and $m$ is max part allowed.

$ I = n: NN quad quad X &= (NN times NN) -> "Set"["Partition"]_bot quad quad A = "Set"["Partition"]\
rho(n) &= {(0, m) -> {[]} | m in [0..n]} union {(s,m) -> bot | s > 0}\
F(x) &= cases(
  x((s,m)) & "if" (s,m) in "dom"(x),
  union.big_(k=1)^(min(s,m)) {[k] + p | p in x((s-k, k))} & "if all children defined",
  bot & "otherwise"
)\
pi(x) &= x((n, n))
$

Convergence: Fixed point reached when all reachable $(s,m)$ states are computed, typically in $O(n)$ iterations.

#let inst_n = 5;
#figure(
  caption: [Integer partitions computation using mapcode for $n = #inst_n$],
$
#{
  // Check if partition already exists in list
  let contains_partition = (partitions, target) => {
    for p in partitions {
      if p.len() != target.len() { continue }
      let match = true
      for i in range(p.len()) {
        if p.at(i) != target.at(i) {
          match = false
          break
        }
      }
      if match { return true }
    }
    false
  }

  // ρ: Initialize base cases (0, m) = [[]]
  let rho = n => {
    let state = ()
    for s in range(0, n + 1) {
      let row = ()
      for m in range(0, n + 1) {
        if s == 0 {
          // Empty partition represented as single element array with marker
          row.push(((-1,),))
        } else {
          row.push(none)
        }
      }
      state.push(row)
    }
    state
  }

  // F: Build partitions by prepending parts
  let F_i = x => ((s, m)) => {
    // Base case: sum is 0, return empty partition marker
    if s == 0 {
      return ((-1,),)
    }

    // Already computed - return as is
    let current = x.at(s).at(m)
    if current != none {
      return current
    }

    // Try to compute from children
    let result = ()
    let max_k = calc.min(s, m)
    
    for k in range(1, max_k + 1) {
      let child_s = s - k
      let child_m = k
      let child_parts = x.at(child_s).at(child_m)
      
      if child_parts == none {
        // Can't compute yet - child not ready
        return none
      }
      
      // For each partition in child, prepend k
      for child_part in child_parts {
        let new_part = if child_part.at(0) == -1 {
          // Child is empty partition, just return [k]
          (k,)
        } else {
          // Prepend k to child partition
          (k,) + child_part
        }
        
        if not contains_partition(result, new_part) {
          result.push(new_part)
        }
      }
    }
    
    if result.len() > 0 {
      result
    } else {
      none
    }
  }
  let F = map_tensor(F_i, dim: 2)

  // π: Extract partitions of (n, n)
  let pi = n => x => {
    let result = x.at(n).at(n)
    if result != none and result.len() > 0 and result.at(0).at(0) == -1 {
      // Return empty array if marked as empty
      return ((),)
    }
    result
  }

  // Display 2D state grid showing defined cells
  let X_h = (x, diff_mask: none) => {
    let n = inst_n
    let rows = ()
    
    for s in range(0, calc.min(n + 1, 6)) {
      let cells = ()
      for m in range(0, calc.min(n + 1, 6)) {
        let cell_val = x.at(s).at(m)
        
        let content = if cell_val != none {
          let count = cell_val.len()
          if s == 0 {
            text(size: 7pt, $emptyset$)
          } else if count <= 2 {
            let parts_str = cell_val.map(p => {
              "[" + p.map(str).join(",") + "]"
            }).join(",")
            text(size: 6pt, $#{parts_str}$)
          } else {
            text(size: 8pt, $#count$)
          }
        } else {
          $dot$
        }
        
        // Check if changed
        let is_new = if diff_mask != none and s < diff_mask.len() {
          let mask_row = diff_mask.at(s)
          if mask_row != none and m < mask_row.len() {
            mask_row.at(m)
          } else { false }
        } else { false }
        
        if is_new {
          cells.push(rect(fill: yellow.transparentize(70%), inset: 1.5pt, width: 11mm, height: 8mm)[#content])
        } else {
          cells.push(rect(stroke: 0.5pt, inset: 1.5pt, width: 11mm, height: 8mm)[#content])
        }
      }
      rows.push(cells)
    }
    
    // Build table manually
    table(
      columns: calc.min(n + 1, 6),
      rows: calc.min(n + 1, 6),
      stroke: none,
      ..rows.flatten()
    )
  }

  let A_h = partitions => {
    if partitions != none {
      let count = partitions.len()
      if count == 1 and partitions.at(0).len() == 0 {
        text(size: 9pt, $"1 partition: []"$)
      } else {
        let display = partitions.slice(0, calc.min(7, count)).map(p => {
          "[" + p.map(str).join(",") + "]"
        }).join(", ")
        if count > 7 {
          display = display + ", ..."
        }
        text(size: 8pt, [$#count "partitions:" #display$])
      }
    } else {
      $bot$
    }
  }

  mapcode-viz(
    rho,
    F,
    pi(inst_n),
    X_h: X_h,
    A_h: A_h,
    pi_name: [$pi$],
    dim: 2,
    group-size: 3,
    cell-size: 70mm,
    scale-fig: 65%,
  )(inst_n)
}
$
)

*Partition count (sequence A000041):*
$
p(0)=1, p(1)=1, p(2)=2, p(3)=3, p(4)=5, p(5)=7, p(6)=11, p(7)=15, ...
$

*Complexity:*
- States computed: $O(n^2)$ - all pairs $(s, m)$ where $0 <= s, m <= n$
- Per state: $O(p(s))$ - number of partitions to store
- Total: exponential in worst case, but tractable for moderate $n$