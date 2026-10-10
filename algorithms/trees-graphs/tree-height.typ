#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Tree Height
#set math.equation(numbering: none)

Compute the height of a rooted tree: the number of edges on the longest path from the root down
to a leaf.

Formal definition:
$
  "height"(v) = cases(
    0 & "if " v "is a leaf",
    1 + max_(c in "children"(v)) "height"(c) & "otherwise"
  )
$

Examples:
- a single node has height $0$
- a root with two leaf children has height $1$
- a path of $k$ nodes has height $k - 1$

*As mapcode:*

_primitives_: `max` and `add`($+$) are strict, i.e. they return $bot$ if any argument is $bot$.

The tree on nodes $[0..n)$ is given by its children lists $C_v$, and $0$ is the root.

$
  I = [0..n) -> [0..n)^* quad quad X_C = [0..n) -> NN_bot quad quad A = NN \
  rho(C) = {v -> bot | v in [0..n)} \
  F_C (x)_v = cases(
    0 & "if " C_v = emptyset,
    1 + max_(c in C_v) x_c & "otherwise"
  ) \
  pi(x) = x_0
$

A leaf is defined after the first step. An inner node $v$ becomes defined one step after the last
of its children, so after $k$ steps exactly the nodes of height $< k$ are known and the fixed point
is reached after $"height"(0) + 1$ steps.

#let tree-height-mc(children) = {
  let rho = C => range(C.len()).map(_ => none)
  let F_v = C => x => ((v,)) => {
    let cs = C.at(v)
    if cs.len() == 0 { 0 } else {
      let hs = cs.map(c => x.at(c))
      if hs.any(h => h == none) { none } else { 1 + calc.max(..hs) }
    }
  }
  let F = C => map_tensor(F_v(C), dim: 1)
  let pi = x => x.at(0)
  let X_h = C => (x, diff_mask: none) => tree-view(
    C,
    root: 0,
    radius: 0.45,
    label: v => [#v: #show-val(x.at(v))],
    node-fill: v => if mask-at(diff_mask, v) { c-changed } else if x.at(v) != none { c-done } else { white },
  )
  mapcode-viz(
    rho,
    F(children),
    pi,
    I_h: C => tree-view(C, root: 0, radius: 0.45),
    X_h: X_h(children),
    pi_name: [$mpi$],
    group-size: 3,
    spacing: (8mm, 10mm),
    node-shape: rect,
  )(children)
}

#let inst = (
  (1, 2), // 0: root
  (3,), // 1
  (4, 5), // 2
  (), // 3: leaf
  (6,), // 4
  (), // 5: leaf
  (), // 6: leaf
)
#figure(
  caption: [Tree height via mapcode; node labels are "$v$: $x_v$". Green nodes are already
    resolved.],
  tree-height-mc(inst),
)
#legend
