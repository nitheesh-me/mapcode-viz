#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== 0-1 Knapsack
#set math.equation(numbering: none)

Given $m$ items with weights $w_1, dots, w_m$ and values $v_1, dots, v_m$, and a knapsack of
capacity $C$, compute the maximum total value of a subset of the items (each used at most
once) whose total weight is at most $C$.

Formal definition: let $K(i, c)$ be the best value achievable with the first $i$ items and
capacity $c$. Then
$
  K(i, c) = cases(
    0 & "if " i = 0,
    K(i-1, c) & "if " w_i > c,
    max(K(i-1, c), K(i-1, c - w_i) + v_i) & "otherwise"
  )
$
and the answer is $K(m, C)$.

Examples:
- $w = (1, 2), v = (5, 4), C = 2 -> 5$ (take item 1)
- $w = (2, 3, 4, 5), v = (3, 4, 5, 6), C = 5 -> 7$ (take items 1 and 2)

*As mapcode:*

_primitives_: `sum`($+$), `sub`($-$), `max` and `leq`($<=$); `sum` and `max` are strict.

$
  I = NN^* times NN^* times NN quad quad X_(w,v,C) = [0..m] times [0..C] -> NN_bot quad quad A = NN
  quad quad "where" m = |w| = |v| \
  rho(w, v, C) = {(i, c) -> bot | i in [0..m], c in [0..C]} \
  F_(w,v)(x)_(i,c) = cases(
    0 & "if " i = 0,
    x_(i-1,c) & "if " w_i > c,
    max(x_(i-1,c), x_(i-1,c - w_i) + v_i) & "otherwise"
  ) \
  pi_(w,v,C)(x) = x_(m,C)
$

Row $i$ depends only on row $i-1$, so each step of $F$ completes one more row and the fixed
point is reached after $m + 1$ steps.

#let knap-mc(inst) = {
  let (w, v, C) = inst
  let m = w.len()
  let rho = ((w, v, C)) => range(w.len() + 1).map(_ => range(C + 1).map(_ => none))
  let F_wv = x => ((i, c)) => {
    if i == 0 { 0 } else {
      let (wi, vi) = (w.at(i - 1), v.at(i - 1))
      let skip = x.at(i - 1).at(c)
      if wi > c { skip } else {
        let take = x.at(i - 1).at(c - wi)
        if skip != none and take != none { calc.max(skip, take + vi) } else { none }
      }
    }
  }
  let F = map_tensor(F_wv, dim: 2)
  let pi = x => x.at(m).at(C)
  let tup(a) = "(" + a.map(str).join(", ") + ")"
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((w, v, C)) => [$w = #tup(w)$ \ $v = #tup(v)$ \ $C = #C$],
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: ([$emptyset$],) + range(m).map(i => [$#w.at(i) slash #v.at(i)$]),
      col-labels: range(C + 1).map(c => [#c]),
      corner: [$w slash v$],
      width: 2.1em,
    ),
    F_name: [$F_(w,v)$],
    pi_name: [$mpi_(w,v,C)$],
    group-size: 2,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(inst)
}

#let inst = ((2, 3, 4, 5), (3, 4, 5, 6), 5)
#figure(
  caption: [0-1 knapsack via mapcode for $w = (2, 3, 4, 5)$, $v = (3, 4, 5, 6)$, $C = 5$.
    Row $i$ is labelled with item $i$'s weight/value, column $c$ is the capacity.],
  knap-mc(inst),
)
