#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== N-Queens
#set math.equation(numbering: none)

Place $n$ queens on an $n times n$ chessboard so that no two queens attack each other, and
return all such placements (their number is the classic N-Queens count).

Formal definition: a placement of queens in rows $0..k-1$ is a sequence
$q = (q_0, ..., q_(k-1))$ of columns. Column $c$ is _safe_ for $q$ if no queen of $q$ shares its
column or a diagonal with $(k, c)$:
$
  "safe"(q, c) <==> forall r < k: q_r != c and |q_r - c| != k - r
$
Let $f(k)$ be the set of safe placements in rows $0..k-1$:
$
  f(k) = cases(
    {()} & "if " k = 0,
    {q + (c) | q in f(k-1), c in [0..n-1], "safe"(q, c)} & "if " k > 0
  )
$
The solutions are $f(n)$.

Examples:
- $n = 1 -> 1$ solution
- $n = 4 -> 2$ solutions, $(1, 3, 0, 2)$ and $(2, 0, 3, 1)$
- $n = 8 -> 92$ solutions

*As mapcode:*

_primitives_: set union and the `safe` test.

$
  I = NN quad quad X_n = [0..n] -> "Set"("Seq"[0..n-1])_bot quad quad A = "Set"("Seq"[0..n-1]) \
  rho(n) = {k -> bot | k in [0..n]} \
  F_n (x)_k = cases(
    {()} & "if " k = 0,
    {q + (c) | q in x_(k-1), c in [0..n-1], "safe"(q, c)} & "if " k > 0 and x_(k-1) != bot,
    bot & "otherwise"
  ) \
  pi_n (x) = x_n
$

Row $k$ is filled one step after row $k-1$, so the fixed point is reached after $n + 1$ steps.
Partial placements that cannot be extended (dead ends) simply produce no children.

#let queens-mc(n) = {
  let safe = (q, c) => {
    let k = q.len()
    range(k).all(r => q.at(r) != c and calc.abs(q.at(r) - c) != k - r)
  }
  let rho = n => range(n + 1).map(_ => none)
  let F_S = n => x => ((k,)) => {
    if k == 0 { ((),) } else if x.at(k - 1) == none { none } else {
      let out = ()
      for q in x.at(k - 1) {
        for c in range(n) {
          if safe(q, c) { out.push(q + (c,)) }
        }
      }
      out
    }
  }
  let F = map_tensor(F_S(n), dim: 1)
  let pi = x => x.at(n)
  let boards(qs, per-row: 3) = if qs == none { botc } else if qs.len() == 0 { $emptyset$ } else {
    grid(
      columns: calc.min(qs.len(), per-row),
      gutter: 6pt,
      ..qs.map(q => box(stroke: 0.8pt + luma(60), board-view(n, q, square-size: 2.6mm))),
    )
  }
  let X_h = (x, diff_mask: none) => grid(
    columns: 2,
    column-gutter: 4pt,
    row-gutter: 3pt,
    align: (center + horizon, left + horizon),
    ..range(n + 1)
      .map(k => (
        label-cell([$#k$]),
        box(
          inset: 2pt,
          fill: if mask-at(diff_mask, k) { c-changed } else { none },
          stroke: 0.5pt + c-grid,
          boards(x.at(k)),
        ),
      ))
      .flatten(),
  )
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: n => [$n = #n$],
    X_h: X_h,
    A_h: sols => stack(
      dir: ttb,
      spacing: 3pt,
      boards(sols),
      align(center, text(size: 0.85em)[#sols.len() solutions]),
    ),
    pi_name: [$mpi_#n$],
    dim: 1,
    group-size: 3,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(n)
}

#let inst = 4
#figure(
  caption: [N-Queens via mapcode for $n = 4$. Row $k$ of each state lists the safe placements of
    queens in the first $k$ board rows, one mini board each.],
  queens-mc(inst),
)
