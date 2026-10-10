#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Bellman-Ford Shortest Paths
#set math.equation(numbering: none)

Given a directed graph $G = (V, E)$ with integer edge weights (possibly negative) and a source
$s in V$, compute the shortest-path distance $delta(s, v)$ from $s$ to every vertex $v$. We assume
there is no negative cycle reachable from $s$; otherwise shortest paths are not defined.

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

$
  I = (V, E, s), quad E subset.eq V times V times ZZ quad quad X = V -> ZZ union {infinity} quad quad A = V -> ZZ union {infinity} \
  rho(V, E, s) = {v -> (0 "if " v = s "else" infinity) | v in V} \
  F_E (x)_v = min(x_v, min_((u, v, w) in E) x_u + w) \
  pi(x) = x
$

Here $infinity$ means "not reached yet"; it is a genuine value, not $bot$, because $infinity + w = infinity$
and $min(infinity, d) = d$ are well defined, so no state cell is ever undefined. The edge set $E$ is
part of the instance and reaches $F_E$ by closure. After $k$ steps $x_v <= d^((k))(v)$, and since a
shortest path uses at most $|V| - 1$ edges, $F_E$ reaches its fixed point within $|V|$ steps.

If a negative cycle is reachable from $s$, the distances around it decrease forever: $F_E$ has
no fixed point, and `mapcode-viz` stops with its max-iteration guard instead of looping.

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
#legend
