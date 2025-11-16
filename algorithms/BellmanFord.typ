#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Bellman-Ford Shortest Path Algorithm

Compute shortest paths from a source vertex to all other vertices in a weighted graph, handling negative edge weights (assuming no negative cycle).

Formal definition:
$
"dist"^((k))(v) = cases(
  0 & "if " v = s and k = 0,
  infinity & "if " v != s and k = 0,
  min("dist"^((k-1))(v), min_(u,v,w in E)("dist"^((k-1))(u) + w)) & "otherwise"
)
$

*As mapcode:*

_primitives_: `min`(min), `add`($+$)

$
I = n:NN times "edges": ("Vertex" times "Vertex" times ZZ)^* times s:"Vertex" quad quad\
X & = ([0..n-1] -> (NN union {infinity})_bot) times "edges" quad quad\
A = [0..n-1] -> (NN union {infinity})_bot\

rho(n, "edges", s) & = ("dist", "edges") "where" "dist" = cases(
  0 & "if" v = s,
  bot & "if" v != s
) \

F("dist", "edges") & = ("dist"', "edges") "where for each edge" (u,v,w) in "edges":\
& "dist"'[v] = cases(
    "dist"[v] & "if" "dist"[u] = bot,
    "dist"[u] + w & "if" "dist"[v] = bot,
    min("dist"[v], "dist"[u] + w) & "if" "dist"[u] != bot and "dist"[v] != bot
)\

pi("dist", "edges") & = "dist"
$

#let inst_n = 5;
#let inst_edges = (
  (0, 1, 6), (0, 3, 7), (1, 2, 5),
  (1, 3, 8), (1, 4, -4), (2, 1, -2),
  (3, 2, -3), (3, 4, 9), (4, 2, 7)
);
#let inst_src = 0;

#figure(
  caption: [Bellman-Ford shortest path computation from vertex #inst_src],
$#{
  // Implement rho function
  let rho = ((n, edges, src)) => {
    // Initialize distance array with all BOTTOM (none) except source
    let dist = ()
    for i in range(0, n) {
      if i == src {
        dist.push(0)
      } else {
        dist.push(none)
      }
    }
    (dist, edges) // State is (distance array, edges)
  }
  
  // Implement F_i function - edge relaxation
  let F_i = (edges) => (dist) => ((v,)) => {
    let current = dist.at(v)
    
    // Try to relax edges ending at vertex v
    for edge in edges {
      let (u, vtx, w) = edge
      if vtx == v and dist.at(u) != none {
        let new_cost = dist.at(u) + w
        if current == none or new_cost < current {
          current = new_cost
        }
      }
    }
    current
  }
  
  let F = (edges) => (state) => {
    let (dist, e) = state
    let new_dist = map_tensor(F_i(edges), dim: 1)(dist)
    (new_dist, e)
  }

  let pi = (state) => {
    // Return final distances
    let (dist, edges) = state
    dist
  }

  // Visualization helper
  let x_h(state, diff_mask:none) = {
    let (dist, edges) = state
    let cells = dist.enumerate().map(((i, d)) => {
      let val = if d != none {[$#d$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(0).at(i) {
        // changed element: highlight
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$v_#i: #val$]
      } else {
        rect(stroke: none, inset: 2pt)[$v_#i: #val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F(inst_edges), pi,
    X_h: x_h,
    pi_name: [$mpi$],
    dim: 2, // Explicitly set dimension: tuple of (array, edges)
    group-size: calc.min(4, inst_n + 1),
    cell-size: 30mm, scale-fig: 75%
  )((inst_n, inst_edges, inst_src))
}$)