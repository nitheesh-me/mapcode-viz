#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Bellman–Ford Shortest Paths <sec-bellman-ford>
#set math.equation(numbering: none)

Given a directed graph $G = (V, E)$ with integer edge weights (possibly negative) and a source
$s in V$, compute the shortest-path distance $delta(s, v)$ from $s$ to every vertex $v$. We assume
there is no negative cycle reachable from $s$; otherwise shortest paths are not defined.
The recurrence below is due to #cite(<bellman1958>, form: "prose")\; the example graph is
Figure 24.4 of #cite(<clrs2009>, form: "prose").

Formal definition, with $d^((k))(v)$ the length of a shortest path from $s$ to $v$ using at most $k$ edges:
$
  d^((0))(v) & = cases(0 & "if " v = s, infinity & "otherwise"), \
  d^((k))(v) & = min(d^((k-1))(v), min_((u, v, w) in E) d^((k-1))(u) + w), \
  delta(s, v) & = d^((|V|-1))(v)
$

Examples:
- a single edge $(s, t, 3)$ gives $delta(s, t) = 3$
- edges $(s, t, 4)$, $(s, u, 1)$, $(u, t, -2)$: the detour through $u$ wins, $delta(s, t) = -1$, $delta(s, u) = 1$

*As mapcode:*

_primitives_: `min` and `add`($+$) on $ZZ union {infinity}$ with $infinity + w = infinity$.

#mc-spec(
  state: [Cell $x_v$ of the state holds the length of the shortest walk from $s$ to $v$ found so
    far, or $infinity$ if $v$ has not been reached yet.],
  I: $I = (V, E, s)$,
  X: $X = V -> ZZ union {infinity}$,
  A: $A = V -> ZZ union {infinity}$,
  rho: $rho(V, E, s) = {v |-> d^((0))(v) | v in V}$,
  F: $F = F_E, quad F_E (x)_v = min(x_v, min_((u, v, w) in E) x_u + w)$,
  pi: $pi(x) = x$,
  sigma: $sigma(x) = sum_(v in V) phi_v (x_v)$,
  inv: $"Inv"(x) <=> exists k in NN . x = d^((k))$,
)
where $E subset.eq V times V times ZZ$ and, with $W = sum_((u, v, w) in E) |w|$,
$ phi_v (d) = cases(d - delta(s, v) & "if" d < infinity, 2W + 1 & "if" d = infinity.) $

Here $infinity$ means "not reached yet"; it is a genuine value, not $bot$, because
$infinity + w = infinity$ and $min(infinity, d) = d$ are well defined, so no state cell is ever
undefined. The edge set $E$ is part of the instance and reaches $F_E$ by closure.
The invariant holds because $rho$ builds $d^((0))$ and $F_E$ is exactly the recurrence, so
$F_E (d^((k))) = d^((k+1))$; at the fixed point $x = d^((|V|-1))$, so $pi(x)_v = delta(s, v)$.
With no negative cycle, a finite $d^((k))(v)$ is the length of a simple path, so
$-W <= delta(s, v) <= x_v <= W$ and $sigma$ takes values in $NN$; $F_E$ never raises a cell, and a step
that changes the state lowers some integer $x_v$ by at least $1$ or turns an $infinity$ (worth
$2W + 1$) into a finite value (worth at most $2W$), so $sigma$ strictly decreases. Since a shortest
path uses at most $|V| - 1$ edges, the fixed point is reached within $|V|$ steps.

If a negative cycle is reachable from $s$, the distances around it decrease forever: $F_E$ has
no fixed point, so the mapcode does not terminate; this is why the instance must be free of
negative cycles.

#let bellman-ford-mc(inst, pos, names) = {
  let (n, edges, src) = inst
  let rho = ((n, E, s)) => range(n).map(v => if v == s { 0 } else { calc.inf })
  let F_v = E => x => ((v,)) => {
    let best = x.at(v)
    for (u, t, w) in E {
      if t == v and x.at(u) != calc.inf { best = calc.min(best, x.at(u) + w) }
    }
    best
  }
  let F = E => map_tensor(F_v(E), dim: 1)
  let pi = x => x
  // Look up the previous state to see which edges produced the new distances.
  let (_, hist, _) = mapcode-hist(rho, F(edges), pi)(inst)
  let prev-of = x => {
    let k = hist.position(y => y == x)
    if k == none or k == 0 { none } else { hist.at(k - 1) }
  }
  let bend = ((u, v, w)) => if (u, v) in ((1, 2), (2, 1)) { 20deg } else if (u, v) == (4, 0) { 50deg } else if (
    (u, v) in ((1, 4), (3, 2))
  ) { 28deg } else { 0deg }
  let X_h = (x, diff_mask: none) => {
    let p = prev-of(x)
    graph-view(
      pos,
      edges,
      label: v => text(size: 0.8em)[#names.at(v): #show-val(x.at(v))],
      node-fill: v => if mask-at(diff_mask, v) { c-changed } else if x.at(v) != calc.inf { c-done } else { white },
      edge-active: ((u, v, w)) => (
        p != none and mask-at(diff_mask, v) and p.at(u) != calc.inf and p.at(u) + w == x.at(v)
      ),
      bend: bend,
    )
  }
  mapcode-viz(
    rho,
    F(edges),
    pi,
    I_h: ((n, E, s)) => graph-view(
      pos,
      E,
      label: v => text(size: 0.8em)[#names.at(v)],
      bend: bend,
    ),
    X_h: X_h,
    A_h: a => vec-view(a, none, labels: names.map(v => [#v])),
    F_name: [$F_E$],
    pi_name: [$mpi$],
    group-size: 2,
    spacing: (12mm, 10mm),
    node-shape: rect,
  )(inst)
}

// The graph of CLRS Figure 24.4: vertices s, t, x, y, z.
#let names = ("s", "t", "x", "y", "z")
#let pos = ((0, 1), (1, 0), (2, 0), (1, 2), (2, 2))
#let inst = (
  5,
  (
    (0, 1, 6),
    (0, 3, 7),
    (1, 2, 5),
    (1, 3, 8),
    (1, 4, -4),
    (2, 1, -2),
    (3, 2, -3),
    (3, 4, 9),
    (4, 0, 2),
    (4, 2, 7),
  ),
  0,
)
#figure(
  caption: [Bellman-Ford via mapcode on the CLRS graph from $s$. Nodes show $v: x_v$; thick
    blue edges are the relaxations that lowered a distance in the last step.],
  bellman-ford-mc(inst, pos, names),
)
