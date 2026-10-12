#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Integer Partitions
#set math.equation(numbering: none)

A _partition_ of $n in NN$ is a way of writing $n$ as a sum of positive integers where order
does not matter, i.e. a sequence $p_1 >= p_2 >= dots >= p_m >= 1$ with
$p_1 + dots + p_m = n$. Compute $p(n, k)$, the number of partitions of $n$ whose parts are all
at most $k$.

Formal definition: splitting on whether a part equal to $k$ is used,
$
  p(n, k) = cases(
    1 & "if " n = 0,
    0 & "if " n > 0 "and" k = 0,
    p(n, k-1) & "if " 0 < n < k,
    p(n, k-1) + p(n-k, k) & "if " n >= k > 0
  )
$
The first term counts partitions with no part equal to $k$; the second removes one part $k$.

Examples:
- $p(4, 4) -> 5$: $4, space 3+1, space 2+2, space 2+1+1, space 1+1+1+1$
- $p(6, 4) -> 9$
- $p(7, 7) -> 15$

Taking $k = n$ gives the partition numbers $p(n) = p(n, n)$, OEIS sequence A000041 @oeisA000041:
$1, 1, 2, 3, 5, 7, 11, 15, 22, 30, dots$ for $n = 0, 1, 2, dots$

*As mapcode:*

_primitives_: `sum`($+$) is strict, i.e. $bot + v = v + bot = bot$.

#mc-spec(
  state: [For fixed $(n, k)$, cell $(i, j)$ of the table holds the number $p(i, j)$ of partitions
    of $i$ into parts at most $j$ once it is known, and $bot$ before.],
  I: $I = NN times NN$,
  X: $X = X_(n,k) = [0..n] times [0..k] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(n, k)_(i,j) = bot$,
  F: $F(x)_(i,j) = cases(
    1 & "if " i = 0,
    0 & "if " i > 0 "and" j = 0,
    x_(i, j-1) & "if " 0 < i < j,
    x_(i, j-1) + x_(i-j, j) & "if " i >= j > 0
  )$,
  pi: $pi = pi_(n,k) = x |-> x_(n,k)$,
  sigma: $sigma(x) = |{(i, j) | x_(i,j) = bot}|$,
  inv: $"Inv"(x) <=> forall i, j . x_(i,j) != bot => x_(i,j) = p(i, j)$,
)
The first step fills row $0$ and column $0$; cell $(i, j)$ then waits for its left neighbour and,
when $i >= j$, for the cell $j$ rows above, both on an earlier anti-diagonal, so the table fills
diagonal by diagonal in at most $n + k$ steps. Defined cells never change, so every changing step
defines new cells and $sigma$ drops; $F$ is the recurrence for $p$, so $"Inv"$ is preserved, and
at the fixed point $pi$ returns $x_(n,k) = p(n, k)$.

#let partitions-mc(inst) = {
  let (n, k) = inst
  let rho = ((n, k)) => range(n + 1).map(_ => range(k + 1).map(_ => none))
  let F_i = x => ((i, j)) => {
    if i == 0 { 1 } else if j == 0 { 0 } else {
      let left = x.at(i).at(j - 1)
      if i < j { left } else {
        let up = x.at(i - j).at(j)
        if left != none and up != none { left + up } else { none }
      }
    }
  }
  let F = map_tensor(F_i, dim: 2)
  let pi = x => x.at(n).at(k)
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((n, k)) => [$p(#n, #k)$],
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: range(n + 1).map(i => [$#i$]),
      col-labels: range(k + 1).map(j => [$#j$]),
      corner: [$i slash j$],
    ),
    pi_name: [$mpi_(#n,#k)$],
    group-size: 3,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(inst)
}

// All partitions of n with parts <= k, largest part first (only used to list them in the text).
#let partitions(n, k) = {
  if n == 0 { return ((),) }
  let out = ()
  for m in range(calc.min(n, k), 0, step: -1) {
    for rest in partitions(n - m, m) { out.push((m,) + rest) }
  }
  out
}

#let inst = (5, 3)
#figure(
  caption: [Partition count via mapcode for $p(#inst.at(0), #inst.at(1))$; row $i$ is the
    number being partitioned, column $j$ the largest part allowed.],
  partitions-mc(inst),
)

#let ps = partitions(..inst)
The #ps.len() partitions counted by $p(#inst.at(0), #inst.at(1))$ are
#ps.map(p => $#p.map(str).join(" + ")$).join([, ], last: [ and ]).
