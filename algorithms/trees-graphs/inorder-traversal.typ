#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Inorder Traversal of a Binary Tree
#set math.equation(numbering: none)

List the values of a binary tree in inorder: first the left subtree, then the root, then the
right subtree.

Formal definition, for a node $i$ with value $v_i$ and (possibly empty) subtrees $l_i$, $r_i$:
$
  "inorder"("nil") & = [], \
  "inorder"(i) & = "inorder"(l_i) + [v_i] + "inorder"(r_i)
$
where $+$ is list concatenation.

Examples:
- a single node $5$ gives $[5]$
- the complete binary search tree on $1, dots, 7$ (root $4$) gives $[1, 2, 3, 4, 5, 6, 7]$

*As mapcode:*

_primitives_: concatenation ($+$) is strict, i.e. $bot + ell = ell + bot = bot$.

The tree is an array of nodes $T_i = (v_i, l_i, r_i)$ with $l_i, r_i in [0..n) union {"nil"}$ and root $0$.
For readability write $x_"nil" = []$.

#mc-spec(
  state: [Cell $x_i$ of the state holds the inorder list of the subtree rooted at node $i$, or $bot$
    while some node of that subtree is still unresolved.],
  I: $I = (ZZ times [0..n)_"nil" times [0..n)_"nil")^n$,
  X: $X = X_T = [0..n) -> (ZZ^*)_bot$,
  A: $A = ZZ^*$,
  rho: $rho(T) = {i |-> bot | i in [0..n)}$,
  F: $F = F_T, quad F_T (x)_i = x_(l_i) + [v_i] + x_(r_i)$,
  pi: $pi(x) = x_0$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = "inorder"(i)$,
)
Since $+$ is strict, a node becomes defined only once both children are, and then with the value
$"inorder"(i)$; defined cells never change, so every non-fixed step defines a new node and decreases
$sigma$, and at the fixed point $pi(x) = "inorder"(0)$. A leaf is defined after one step and an inner
node one step after both of its children, so the root appears after (height $+ 1$) steps.

#let inorder-mc(tree) = {
  let sub = (x, c) => if c == none { () } else { x.at(c) }
  let rho = T => range(T.len()).map(_ => none)
  let F_i = T => x => ((i,)) => {
    let (v, l, r) = T.at(i)
    let (xl, xr) = (sub(x, l), sub(x, r))
    if xl == none or xr == none { none } else { xl + (v,) + xr }
  }
  let F = T => map_tensor(F_i(T), dim: 1)
  let pi = x => x.at(0)
  let children = tree.map(((v, l, r)) => (l, r).filter(c => c != none))
  let show-list = xs => if xs == none { botc } else { $[#xs.map(str).join(", ")]$ }
  let draw = (x, mask) => tree-view(
    children,
    root: 0,
    label: i => [#tree.at(i).at(0)],
    node-fill: i => if mask-at(mask, i) { c-changed } else if x != none and x.at(i) != none { c-done } else {
      white
    },
  )
  let X_h = (x, diff_mask: none) => grid(
    columns: 1,
    align: center,
    row-gutter: 4pt,
    draw(x, diff_mask),
    text(size: 0.8em)[$x_0 = #show-list(x.at(0))$],
  )
  mapcode-viz(
    rho,
    F(tree),
    pi,
    I_h: T => draw(none, none),
    X_h: X_h,
    A_h: show-list,
    F_name: [$F_T$],
    pi_name: [$mpi$],
    group-size: 2,
    spacing: (12mm, 8mm),
    node-shape: rect,
  )(tree)
}

#let inst = (
  (4, 1, 2), // node 0: value 4, children 1, 2
  (2, 3, 4), // node 1
  (6, 5, 6), // node 2
  (1, none, none), // node 3: leaf
  (3, none, none), // node 4: leaf
  (5, none, none), // node 5: leaf
  (7, none, none), // node 6: leaf
)
#figure(
  caption: [Inorder traversal via mapcode; nodes show their values $v_i$. A green node $i$ has
    its subtree list $x_i$ resolved; below each state is the root's list $x_0$.],
  inorder-mc(inst),
)
