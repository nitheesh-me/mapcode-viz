#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Inorder Traversal of Binary Tree
#set math.equation(numbering: none)

Perform an inorder traversal of a binary tree, returning the sequence of node values visited in the order: left subtree, root, right subtree.

Formal definition:
$
"inorder"(i) = cases(
  [v_i] & "if " i "is leaf",
  "inorder"("left"(i)) + [v_i] + "inorder"("right"(i)) & "otherwise"
)
$

where $v_i$ is the value at node $i$, and $+$ denotes list concatenation.

Example:

```
       4
      / \
     2   6
    / \ / \
   1  3 5  7
```

Result: $[1, 2, 3, 4, 5, 6, 7]$

*As mapcode:*

_primitives_: `list concatenation` ($+$) is strict. i.e., concatenation with $bot$ is undefined.

$
I = "Tree represented as array" [(v_i, l_i, r_i)]_i quad quad quad
X &= NN -> (ZZ^* union {bot}) quad quad quad
A = ZZ^*\
rho("Tree") &= {i -> bot | i in {0 dots |"Tree"|-1}}\
F(x_i) &= cases(
  [v_i] & "if " l_i = "None" and r_i = "None",
  x_(l_i) + [v_i] + x_(r_i) & "otherwise"
)\
pi(x) &= x_0 quad "(" "root's inorder sequence" ")"
$

where each tree node $i$ has value $v_i$, left child index $l_i$, and right child index $r_i$ (None if no child).

#let inst_tree = (
  (4, 1, 2),        // Node 0: value=4, left=1, right=2
  (2, 3, 4),        // Node 1: value=2, left=3, right=4
  (6, 5, 6),        // Node 2: value=6, left=5, right=6
  (1, none, none),  // Node 3: value=1, leaf
  (3, none, none),  // Node 4: value=3, leaf
  (5, none, none),  // Node 5: value=5, leaf
  (7, none, none)   // Node 6: value=7, leaf
);

#figure(
  caption: [Inorder Traversal computation using mapcode for the binary tree shown above],
$
#{
  let rho = (tree) => {
    let x = ()
    for i in range(0, tree.len()) {
      x.push(none)
    }
    x
  }

  let F_i = (tree) => (x) => (i) => {
    let node = tree.at(i)
    let val = node.at(0)
    let left_idx = node.at(1)
    let right_idx = node.at(2)
    
    // Leaf node
    if left_idx == none and right_idx == none {
      (val,)
    } else {
      let left_list = if left_idx != none { x.at(left_idx) } else { () }
      let right_list = if right_idx != none { x.at(right_idx) } else { () }
      
      // Check if dependencies are resolved
      if left_idx != none and left_list == none {
        return none
      }
      if right_idx != none and right_list == none {
        return none
      }
      
      // Concatenate: left + [val] + right
      let result = ()
      if left_list != none {
        result = result + left_list
      }
      result = result + (val,)
      if right_list != none {
        result = result + right_list
      }
      result
    }
  }

  let F = (tree) => map_tensor(F_i(tree), dim: 1)

  let pi = (tree) => (x) => x.at(0)

  let X_h = (x, diff_mask: none) => {
    let cells = ()
    for i in range(0, x.len()) {
      let val = x.at(i)
      let node_val = inst_tree.at(i).at(0)
      
      let content = if val != none {
        $[#val.map(v => str(v)).join(", ")]$
      } else {
        $bot$
      }
      
      if diff_mask != none and diff_mask.at(i) {
        cells.push(rect(fill: yellow.transparentize(70%), inset: 3pt)[
          #text(size: 8pt)[$"node"_#node_val$]: #content
        ])
      } else {
        cells.push(rect(stroke: none, inset: 3pt)[
          #text(size: 8pt)[$"node"_#node_val$]: #content
        ])
      }
    }
    stack(dir: ttb, spacing: 3pt, ..cells)
  }

  mapcode-viz(
    rho, F(inst_tree), pi(inst_tree),
    X_h: X_h,
    pi_name: [$mpi$],
    group-size: 4,
    cell-size: 45mm, scale-fig: 85%
  )(inst_tree)
}
$
)

