#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Longest Common Subsequence
#set math.equation(numbering: none)

Compute the length of the longest common subsequence (LCS) of two strings $S$ and $T$. A
subsequence is obtained by deleting some characters without changing the order of the rest.

Formal definition: let $"L"(i, j)$ be the LCS length of the prefixes $S_1 dots S_i$ and
$T_1 dots T_j$. Then
$
  "L"(i, j) = cases(
    0 & "if " i = 0 or j = 0,
    "L"(i-1, j-1) + 1 & "if " S_i = T_j,
    max("L"(i-1, j), "L"(i, j-1)) & "otherwise"
  )
$
and the answer is $"L"(|S|, |T|)$.

Examples:
- $S = "ABC", T = "AC" -> 2$ ("AC")
- $S = "AGGTAB", T = "GXTXAYB" -> 4$ ("GTAB")

*As mapcode:*

_primitives_: `sum`($+$) and `max` are strict, i.e. they return $bot$ if any argument is $bot$.

#mc-spec(
  state: [With $m = |S|$ and $n = |T|$, the state is a table $x$ with one cell for every pair of
    prefix lengths; cell $(i, j)$ holds the LCS length of the prefixes $S_1 dots S_i$ and
    $T_1 dots T_j$ once it is known, and $bot$ before that.],
  I: $I = Sigma^* times Sigma^*$,
  X: $X = X_(S,T) = [0..m] times [0..n] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(S, T) = {(i, j) |-> bot}$,
  F: $F = F_(S,T), quad F_(S,T)(x)_(i,j) = cases(
    0 & "if " i = 0 or j = 0,
    x_(i-1,j-1) + 1 & "if " S_i = T_j,
    max(x_(i-1,j), x_(i,j-1)) & "otherwise"
  )$,
  pi: $pi = pi_(S,T) = x |-> x_(m,n)$,
  sigma: $sigma(x) = |{(i, j) | x_(i,j) = bot}|$,
  inv: $"Inv"(x) <=> forall (i, j) . x_(i,j) != bot => x_(i,j) = "L"(i, j)$,
)
Since $+$ and $max$ are strict, $F$ defines a cell only from defined neighbours, which by
$"Inv"$ hold their final $"L"$ values, so a defined cell is recomputed to the same value and
never changes; every step that changes $x$ therefore defines a new cell and lowers $sigma$, and
at the fixed point every cell is defined (the table fills along anti-diagonals), so
$pi_(S,T)(x) = "L"(m, n)$.

#let lcs-mc(inst) = {
  let (S, T) = inst
  let (m, n) = (S.len(), T.len())
  let rho = ((S, T)) => range(S.len() + 1).map(_ => range(T.len() + 1).map(_ => none))
  let F_ST = x => ((i, j)) => {
    if i == 0 or j == 0 { 0 } else if S.at(i - 1) == T.at(j - 1) {
      let d = x.at(i - 1).at(j - 1)
      if d != none { d + 1 } else { none }
    } else {
      let (u, l) = (x.at(i - 1).at(j), x.at(i).at(j - 1))
      if u != none and l != none { calc.max(u, l) } else { none }
    }
  }
  let F = map_tensor(F_ST, dim: 2)
  let pi = x => x.at(m).at(n)
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((S, T)) => [$S = #raw(S)$ \ $T = #raw(T)$],
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: ([$epsilon$],) + S.clusters().map(raw),
      col-labels: ([$epsilon$],) + T.clusters().map(raw),
      corner: [$S slash T$],
      width: 1.6em,
      height: 1.4em,
    ),
    F_name: [$F_(S,T)$],
    pi_name: [$mpi_(S,T)$],
    group-size: 3,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(inst)
}

#let inst = ("AGGTAB", "GXTXAYB")
#figure(
  caption: [LCS via mapcode for $S = #raw(inst.at(0))$, $T = #raw(inst.at(1))$. Rows are
    indexed by characters of $S$, columns by characters of $T$; $epsilon$ is the empty prefix.],
  lcs-mc(inst),
)
