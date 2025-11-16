#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Recursive Height of a Binary Tree
#set math.equation(numbering: none)

Compute the recursive height of a binary tree.
Formal definition:
$
  "Height"(n) = cases(
    -1 & "if " n = "None",
    1 + max("Height"("n.left"), "Height"("n.right")) & "otherwise"
  )
$

*As mapcode:*

_primitives_: `max` function, `addition`($+$).

In the mapcode framework, we model tree height computation as a DP table where each node's height depends on its children's heights:

$
  I = "TreeDef" \
  X = [0..N-1] -> NN_bot \
  A = NN \
  rho("tree") & = {i -> bot | i in [0..N-1]} \
  F(x)_i & = cases(
               -1 & "if node" i "is terminal"\\
               1 + max(x_{l(i)}, x_{r(i)}) & "if both children solved"\\
               bot & "otherwise"
             ) \
  pi(x) & = x_{root}
$

// --- Input Instance ---
// We define the tree structure with node indices instead of string IDs
#let inst_tree = (
  nodes: (
    (id: 0, val: 10, left: 1, right: 2),  // node 0: root with value 10, left child 1, right child 2
    (id: 1, val: 5,  left: 3, right: 4),  // node 1: value 5, left child 3, right child 4
    (id: 2, val: 15, left: -1, right: -1), // node 2: value 15, left None (-1), right None (-1)
    (id: 3, val: 2,  left: -1, right: -1), // node 3: value 2, left None, right None
    (id: 4, val: 7,  left: -1, right: -1), // node 4: value 7, left None, right None
  ),
  root: 0,
  size: 5
)

// --- Mapcode Functions (rho, F, pi) ---

// rho: Initialize with all values as undefined (bot)
#let rho = tree_data => {
  let x = ()
  for i in range(0, tree_data.size) {
    x.push(none)  // Represents bot
  }
  x
}

// F_i: Compute height for a specific node based on current state
// Returns the new height for node at index `node_idx` given the previous state
#let F_i = (tree_data) => (prev_state) => ((node_idx,)) => {
  let node = tree_data.nodes.at(node_idx)

  // Base case: if node is None (-1) we return -1, but since we index nodes differently,
  // we handle terminal nodes specially
  if node_idx >= tree_data.nodes.len() or node_idx < 0 {
    return -1  // Not a valid node
  }

  // Check if this is a leaf node (no valid children)
  let left_idx = node.left
  let right_idx = node.right

  // Terminal case: both children are None (-1)
  if left_idx == -1 and right_idx == -1 {
    return 0  // Height of leaf node is 0
  }

  // Get children heights from previous state
  let left_height = if left_idx >= 0 and left_idx < prev_state.len() {
    prev_state.at(left_idx)
  } else {
    if left_idx == -1 { -1 } else { none }  // -1 represents None
  }

  let right_height = if right_idx >= 0 and right_idx < prev_state.len() {
    prev_state.at(right_idx)
  } else {
    if right_idx == -1 { -1 } else { none }  // -1 represents None
  }

  // Check if dependencies are satisfied
  let left_ok = (left_idx == -1 or (left_idx >= 0 and left_height != none))
  let right_ok = (right_idx == -1 or (right_idx >= 0 and right_height != none))

  if left_ok and right_ok {
    // Calculate height based on children
    let actual_left_height = if left_idx == -1 { -1 } else { left_height }
    let actual_right_height = if right_idx == -1 { -1 } else { right_height }

    1 + calc.max(actual_left_height, actual_right_height)
  } else {
    none  // Dependencies not met yet
  }
}

// F: Apply F_i to all nodes using map_tensor
#let F = tree_data => map_tensor(F_i(tree_data), dim: 1)

// pi: Extract the height of the root node
#let pi = tree_data => x => x.at(tree_data.root)

// --- Visualization Helpers ---
// X_h: Render the state as a vector of heights
#let X_h = (x, diff_mask: none) => {
  let cells = ()
  for i in range(0, calc.min(x.len(), 10)) {  // Limit display
    let height = x.at(i)
    let val = if height != none {
      $h_#i = #height$
    } else {
      $h_#i = bot$
    }

    let is_changed = if diff_mask != none and i < diff_mask.len() {
      if type(diff_mask.at(i)) == bool { diff_mask.at(i) } else { false }
    } else {
      false
    }

    if is_changed {
      cells.push(rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$])
    } else {
      cells.push(val)
    }
  }
  $vec(delim: "[", ..cells)$
}

// A_h: Render the final answer
#let A_h = a => {
  if a != none {
    [$"height = " #a$]
  } else {
    [$bot$]
  }
}

// --- Visualization Execution ---
#figure(
  caption: [Recursive Tree Height computation using mapcode.],
  $
    #{
      mapcode-viz(
        rho,
        F(inst_tree),
        pi(inst_tree),
        X_h: X_h,
        A_h: A_h,
        pi_name: [$pi$],
        group-size: 3,
        cell-size: 10mm,
        scale-fig: 85%
      )(inst_tree)
    }
  $,
)