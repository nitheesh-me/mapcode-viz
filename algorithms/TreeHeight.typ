#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Tree Height

Compute the height of a rooted tree. The height of a tree is the maximum distance from the root to any leaf node.

Formal definition:
$
"height"(v) = cases(
  0 & "if " v "is a leaf",
  1 + max_(c in "children"(v)) "height"(c) & "otherwise"
)
$

Example:
```
    0
   / \
  1   2
     / \
    3   4
```
- height(1) = 0 (leaf)
- height(3) = 0 (leaf)
- height(4) = 0 (leaf)
- height(2) = 1 + max(0, 0) = 1
- height(0) = 1 + max(0, 1) = 2

*As mapcode:*

_primitives_: `max`(max), `add`($+$)

Let:
- $"Node" = NN$ (node identifiers)
- $"Children" = "Node" -> "Node"^*$ (adjacency list)
- $"Heights" = "Node" -> NN_bot$ (height map)

$
I & = "Children" \
X & = "Heights" \
A & = NN\

rho("children") & = "heights" "where" "heights"[v] = bot quad forall v\

F("heights") & = "heights"' "where for each node" v:\
& "heights"'[v] = cases(
    0 & "if" "children"[v] = emptyset,
    1 + max_(c in "children"[v]) "heights"[c] & "if" forall c in "children"[v]: "heights"[c] != bot,
    "heights"[v] & "otherwise (preserve old value)"
)\

pi("heights") & = "heights"[0] quad "(root is node 0)"
$

#let inst_children = (
  (1, 2),    // 0: root
  (),        // 1: leaf
  (3, 4),    // 2: branch
  (),        // 3: leaf
  (),        // 4: leaf
);

#figure(
  caption: [Tree height computation using mapcode],
$
#{
  // rho: Initialize all heights to BOTTOM
  let rho = (children) => {
    let n = children.len()
    let heights = ()
    for i in range(0, n) {
      heights.push(none)
    }
    heights  // State is just the heights array
  }

  // F_i: Compute height for node i
  let F_i = (children) => (heights) => ((i,)) => {
    let current = heights.at(i)
    
    // If already computed, keep it
    if current != none {
      return current
    }
    
    // Get children of node i
    let node_children = children.at(i)
    
    // Leaf node: height = 0
    if node_children.len() == 0 {
      return 0
    }
    
    // Branch node: check if all children have known heights
    let child_heights = ()
    let all_known = true
    for child in node_children {
      let child_height = heights.at(child)
      if child_height == none {
        all_known = false
        break
      }
      child_heights.push(child_height)
    }
    
    // If all children heights are known, compute this node's height
    if all_known and child_heights.len() > 0 {
      return 1 + calc.max(..child_heights)
    }
    
    // Otherwise, keep as BOTTOM
    return none
  }

  let F = (children) => (heights) => {
    map_tensor(F_i(children), dim: 1)(heights)
  }

  let pi = (heights) => {
    heights.at(0)  // Return height of root (node 0)
  }

  // Visualization helper
  let X_h = (heights, diff_mask: none) => {
    let cells = heights.enumerate().map(((i, h)) => {
      let val = if h != none {[$#h$]} else {[$bot$]}
      let node_children = inst_children.at(i)
      let children_str = if node_children.len() == 0 {
        "(leaf)"
      } else {
        let child_list = node_children.map(c => str(c)).join(",")
        "→{" + child_list + "}"
      }
      
      if diff_mask != none and diff_mask.at(i) {
        // changed element: highlight
        rect(fill: yellow.transparentize(70%), inset: 2pt)[
          $v_#i#text(size: 8pt)[#children_str]: #val$
        ]
      } else {
        rect(stroke: none, inset: 2pt)[
          $v_#i#text(size: 8pt)[#children_str]: #val$
        ]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  // Tree visualization
  let I_h = (children) => {
    // Simple tree representation showing the structure
    let nodes = children.enumerate().map(((i, c)) => {
      if c.len() == 0 {
        [$v_#i$ (leaf)]
      } else {
        let child_list = c.map(ch => [$v_#ch$]).join([, ])
        [$v_#i -> {#child_list}$]
      }
    })
    table(
      columns: 1,
      align: left,
      stroke: none,
      ..nodes
    )
  }

  mapcode-viz(
    rho, F(inst_children), pi,
    I_h: I_h,
    X_h: X_h,
    pi_name: [$mpi$],
    group-size: calc.min(5, inst_children.len() + 1),
    cell-size: 35mm,
    scale-fig: 70%
  )(inst_children)
}
$
)
