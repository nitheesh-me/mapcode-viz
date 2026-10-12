#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Edit Distance (Levenshtein)
#set math.equation(numbering: none)

Compute the edit distance between two strings $S$ and $T$: the minimum number of
single-character insertions, deletions and substitutions that turn $S$ into $T$.

Formal definition: let $"ED"(i, j)$ be the edit distance between the prefixes $S_1 dots S_i$
and $T_1 dots T_j$. Then
$
  "ED"(i, j) = cases(
    i & "if " j = 0,
    j & "if " i = 0,
    "ED"(i-1, j-1) & "if " S_i = T_j,
    1 + min("ED"(i-1, j), "ED"(i, j-1), "ED"(i-1, j-1)) & "otherwise"
  )
$
where the three terms of the minimum correspond to deleting $S_i$, inserting $T_j$ and
substituting $S_i -> T_j$. The answer is $"ED"(|S|, |T|)$.

Examples:
- $"ED"("cat", "cut") = 1$ (substitute a → u)
- $"ED"("horse", "ros") = 3$ (substitute h → r, delete r, delete e)
- $"ED"("kitten", "sitting") = 3$ (substitute k → s, substitute e → i, insert g)

*As mapcode:*

_primitives_: `sum`($+$) and `min` are strict, i.e. they return $bot$ if any argument is $bot$.

#mc-spec(
  state: [With $m = |S|$ and $n = |T|$, the state is a table $x$ with one cell for every pair of
    prefix lengths; cell $(i, j)$ holds the edit distance between $S_1 dots S_i$ and
    $T_1 dots T_j$ once it is known, and $bot$ before that.],
  I: $I = Sigma^* times Sigma^*$,
  X: $X = X_(S,T) = [0..m] times [0..n] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(S, T) = {(i, j) |-> bot}$,
  F: $F = F_(S,T), quad F_(S,T)(x)_(i,j) = cases(
    i & "if " j = 0,
    j & "if " i = 0,
    x_(i-1,j-1) & "if " S_i = T_j,
    1 + mu_(i,j) & "otherwise"
  )$,
  pi: $pi = pi_(S,T) = x |-> x_(m,n)$,
  sigma: $sigma(x) = |{(i, j) | x_(i,j) = bot}|$,
  inv: $"Inv"(x) <=> forall (i, j) . x_(i,j) != bot => x_(i,j) = "ED"(i, j)$,
)
where $mu_(i,j) = min(x_(i-1,j), x_(i,j-1), x_(i-1,j-1))$ (strict, so $bot$ if any neighbour is $bot$).
A cell is defined only from defined neighbours, which by $"Inv"$ already hold their final
$"ED"$ values, so defined cells never change and every step that changes $x$ defines a new cell
and lowers $sigma$; the first step fills row and column $0$, the rest fills along
anti-diagonals, and at the fixed point every cell is defined, so $pi_(S,T)(x) = "ED"(m, n)$.

#let ed-mc(inst) = {
  let (S, T) = inst
  let (m, n) = (S.len(), T.len())
  let rho = ((S, T)) => range(S.len() + 1).map(_ => range(T.len() + 1).map(_ => none))
  let F_ST = x => ((i, j)) => {
    if j == 0 { i } else if i == 0 { j } else if S.at(i - 1) == T.at(j - 1) {
      x.at(i - 1).at(j - 1)
    } else {
      let (u, l, d) = (x.at(i - 1).at(j), x.at(i).at(j - 1), x.at(i - 1).at(j - 1))
      if u != none and l != none and d != none { 1 + calc.min(u, l, d) } else { none }
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

#let inst = ("kitten", "sitting")
#figure(
  caption: [Edit distance via mapcode for $S = #raw(inst.at(0))$, $T = #raw(inst.at(1))$. Rows
    are indexed by characters of $S$, columns by characters of $T$; $epsilon$ is the empty prefix.],
  ed-mc(inst),
)
