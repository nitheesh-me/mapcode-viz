#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Mergesort
#set math.equation(numbering: none)

Sort an array of integers using the bottom-up mergesort algorithm. Elements are progressively merged from smaller sorted segments into larger ones.

Formal definition:

Given array $a = [a_0, a_1, ..., a_(n-1)]$, produce sorted array $a' = [a'_0, a'_1, ..., a'_(n-1)]$ where:
$
forall i < j: a'_i <= a'_j quad "and" quad {a'_i} = {a_i}
$

Bottom-up approach:
- Start: treat each element as a sorted segment of length 1
- Iterate: merge pairs of adjacent sorted segments
- Double segment length each iteration
- Terminate: when segment length exceeds array size

Examples:
- $"mergesort"([5,2,8,1]) -> [1,2,5,8]$
- $"mergesort"([9,3,7,5,6]) -> [3,5,6,7,9]$

*As mapcode:*

_primitives_: Binary `merge` operator combines sorted sequences. Strict: returns $bot$ if either input is $bot$.

State: each iteration $i$ stores tuple $(w_i, a_i)$ where $w_i$ is merge width, $a_i$ is partially sorted array.

$ I = a: "Seq"[ZZ] quad quad X &= NN -> (NN times "Seq"[ZZ])_bot quad quad A = "Seq"[ZZ]\
rho(a) &= {0 -> (1, a), k -> bot | k > 0}\
F(x_k) &= cases(
  x_0 & "if " k = 0,
  (w', a') & "if " x_(k-1) != bot "and" w < n,
  x_(k-1) & "if " x_(k-1) != bot "and" w >= n
) \
& "where " (w, a) = x_(k-1) ", " w' = 2w ", " a' = "merge_pairs"(a, w) \
pi(x) &= a "where" (w, a) = "last"({x_k | x_k != bot "and" w >= n})
$

Iteration count: $ceil(log_2 n)$ steps until $w >= n$.

#let inst_arr = (5, 2, 8, 1, 6, 3);
#figure(
  caption: [Mergesort using mapcode for input $a = #inst_arr$],
$
#{
  // Combine two sorted sequences
  let combine_sorted = (left, right) => {
    let out = ()
    let (p, q) = (0, 0)
    
    while p < left.len() and q < right.len() {
      if left.at(p) <= right.at(q) {
        out.push(left.at(p))
        p += 1
      } else {
        out.push(right.at(q))
        q += 1
      }
    }
    
    // Append remaining
    while p < left.len() { out.push(left.at(p)); p += 1 }
    while q < right.len() { out.push(right.at(q)); q += 1 }
    
    out
  }

  // Merge adjacent pairs with given width
  let merge_pairs = (sequence, width) => {
    let merged = ()
    let pos = 0
    let total = sequence.len()
    
    while pos < total {
      let end_left = calc.min(pos + width, total)
      let end_right = calc.min(pos + 2 * width, total)
      
      let left_part = sequence.slice(pos, end_left)
      let right_part = if end_left < total {
        sequence.slice(end_left, end_right)
      } else { () }
      
      if right_part.len() > 0 {
        merged += combine_sorted(left_part, right_part)
      } else {
        merged += left_part
      }
      
      pos += 2 * width
    }
    
    merged
  }

  // ρ: Initial state with width=1
  let rho = sequence => {
    let capacity = calc.ceil(calc.log(sequence.len(), base: 2)) + 3
    let states = ()
    for _ in range(capacity) { states.push(none) }
    states.at(0) = (1, sequence)
    states
  }

  // F: Apply one merge iteration
  let F_i = states => ((index,)) => {
    if index == 0 { 
      return states.at(0) 
    }
    
    let prev = states.at(index - 1)
    if prev == none { return none }
    
    let (width, arr) = prev
    let n = arr.len()
    
    // Already complete
    if width >= n {
      return (width, arr)
    }
    
    // Perform merge with doubled width
    let next_arr = merge_pairs(arr, width)
    (width * 2, next_arr)
  }
  let F = map_tensor(F_i, dim: 1)

  // π: Extract final sorted array
  let pi = original => states => {
    let n = original.len()
    for idx in range(states.len() - 1, -1, step: -1) {
      let state = states.at(idx)
      if state != none {
        let (width, arr) = state
        if width >= n { return arr }
      }
    }
    original
  }

  // Display state as (width: [elements])
  let X_h = (states, diff_mask: none) => {
    let rendered = ()
    
    for idx in range(states.len()) {
      let state = states.at(idx)
      
      let content = if state != none {
        let (w, arr) = state
        let elements = arr.map(x => str(x)).join(",")
        $(w=#w: [#elements])$
      } else {
        $bot$
      }
      
      // Check if this state changed
      let changed = if diff_mask != none and idx < diff_mask.len() {
        let mask_val = diff_mask.at(idx)
        if type(mask_val) == array {
          mask_val.any(b => b)
        } else {
          mask_val
        }
      } else { false }
      
      if changed {
        rendered.push(rect(fill: yellow.transparentize(70%), inset: 3pt)[#content])
      } else {
        rendered.push(rect(stroke: none, inset: 3pt)[#content])
      }
    }
    
    $vec(delim: "[", ..rendered)$
  }

  let A_h = result => {
    if result != none {
      let vals = result.map(x => str(x)).join(",")
      $[#vals]$
    } else {
      $bot$
    }
  }

  mapcode-viz(
    rho,
    F,
    pi(inst_arr),
    X_h: X_h,
    A_h: A_h,
    pi_name: [$pi$],
    dim: 1,
    group-size: 4,
    cell-size: 22mm,
    scale-fig: 80%,
  )(inst_arr)
}
$
)

*Analysis:*
- Iterations: $O(log n)$ - width doubles each step
- Per iteration: $O(n)$ - scan entire array
- Total time: $O(n log n)$
- Space: $O(log n)$ - one state per iteration