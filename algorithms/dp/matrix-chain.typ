#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Optimal Matrix Chain Multiplication
#set math.equation(numbering: none)

Given a chain of matrices $M_1 M_2 dots M_n$, where $M_i$ has dimensions $p_(i-1) times p_i$,
compute the minimum number of scalar multiplications needed to evaluate the product. The input is
the dimension vector $p = (p_0, p_1, dots, p_n)$.

Formal definition: let $m(i, j)$ be the cheapest cost of computing $M_i dots M_j$ for
$1 <= i <= j <= n$. Splitting after $M_k$ costs $m(i, k) + m(k+1, j)$ plus
$p_(i-1) p_k p_j$ for the final product.
$
  m(i, j) = cases(
    0 & "if " i = j,
    min_(i <= k < j) (m(i, k) + m(k+1, j) + p_(i-1) p_k p_j) & "if " i < j
  ) \
  "mcm"(p) = m(1, n)
$

Examples:
- $"mcm"(10, 20, 30, 40, 50) -> 38000$, from $((M_1 M_2) M_3) M_4$
- $"mcm"(13, 5, 89, 3, 34) -> 2856$, from $(M_1 (M_2 M_3)) M_4$
- $"mcm"(10, 30, 5, 60) -> 4500$, from $(M_1 M_2) M_3$

*As mapcode:*

_primitives_: `min`, `sum`($+$) and `mul`($dot$) are strict: $4 + bot = bot$ and
$min {3, 2, bot} = bot$.

#mc-spec(
  state: [The state is an upper-triangular table $x$: cell $x_(i,j)$ holds the cheapest cost
    $m(i, j)$ of computing $M_i dots M_j$, or $bot$ while it is not yet known.],
  I: $I = p : NN^(n+1)$,
  X: $X = X_n = {(i, j) | 1 <= i <= j <= n} -> NN_bot$,
  A: $A = NN$,
  rho: $rho(p) = {(i, j) |-> bot | 1 <= i <= j <= n}$,
  F: $F = F_p, quad F_p (x)_(i,j) = cases(0 & "if " i = j, min_(i <= k < j) s_k & "if " i < j)$,
  pi: $pi = pi_n = x |-> x_(1,n)$,
  sigma: $sigma(x) = |{(i, j) | x_(i,j) = bot}|$,
  inv: $"Inv"(x) <=> forall (i, j) . x_(i,j) != bot => x_(i,j) = m(i, j)$,
)
where $s_k = x_(i,k) + x_(k+1,j) + p_(i-1) p_k p_j$ is the cost of splitting $M_i dots M_j$
after $M_k$. Because $min$ is strict, cell $(i, j)$ stays $bot$ until all of its splits are known and then gets
exactly $m(i, j)$, never to change again; so each changing step defines new cells ($sigma$ drops)
and keeps $"Inv"$. The table fills one diagonal per step, the chains of length $ell$ being settled
by step $ell$, so after $n$ steps $pi_n (x) = m(1, n)$. The lower triangle ($i > j$) lies outside
the domain.

#let mcm-mc(p) = {
  let n = p.len() - 1
  // x.at(i - 1).at(j - 1) holds x_(i,j); cells with i > j are outside the domain and stay ⊥.
  let rho = p => range(n).map(_ => range(n).map(_ => none))
  let F_i = x => ((r, c)) => {
    let (i, j) = (r + 1, c + 1)
    if i > j { return none }
    if i == j { return 0 }
    let splits = range(i, j).map(k => {
      let (a, b) = (x.at(i - 1).at(k - 1), x.at(k).at(j - 1))
      if a == none or b == none { none } else { a + b + p.at(i - 1) * p.at(k) * p.at(j) }
    })
    if splits.any(s => s == none) { none } else { calc.min(..splits) }
  }
  let F = map_tensor(F_i, dim: 2)
  let pi = x => x.at(0).at(n - 1)
  let labels = range(1, n + 1).map(i => [#i])
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: p => [$p = (#p.map(str).join(", "))$],
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: labels,
      col-labels: labels,
      corner: [$i backslash j$],
      shade: (r, c) => r > c,
      width: 3.2em,
    ),
    F_name: [$F_p$],
    pi_name: [$mpi_#n$],
    group-size: 2,
    spacing: (8mm, 10mm),
  )(p)
}

#let inst = (10, 20, 30, 40, 50)
#figure(
  caption: [Matrix chain multiplication via mapcode for $p = (#inst.map(str).join(", "))$.],
  mcm-mc(inst),
)
