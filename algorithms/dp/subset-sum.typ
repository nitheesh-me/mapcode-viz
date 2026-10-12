#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Subset Sum
#set math.equation(numbering: none)

Given a list of non-negative integers $S = (s_1, dots, s_m)$ and a target $T$, decide whether
some subset of $S$ sums to exactly $T$.

Formal definition: let $D(i, j)$ be true iff some subset of the first $i$ items sums to $j$.
Then
$
  D(i, j) = cases(
    "true" & "if " j = 0,
    "false" & "if " i = 0 and j > 0,
    D(i-1, j) & "if " s_i > j,
    D(i-1, j) or D(i-1, j - s_i) & "otherwise"
  )
$
and the answer is $D(m, T)$.

Examples:
- $S = (2, 4), T = 5 -> "false"$
- $S = (3, 5, 8), T = 11 -> "true"$ ($3 + 8$)

*Remark (Partition).* The _partition-equal-subset_ problem asks whether $S$ can be split into
two parts of equal sum. It reduces to subset sum: answer false if $Sigma = sum_i s_i$ is odd,
and otherwise run subset sum with target $T = Sigma slash 2$.

*As mapcode:*

_primitives_: `or` is strict, i.e. $bot or b = b or bot = bot$; `leq`($<=$).

#mc-spec(
  state: [With $m = |S|$, the state is a table $x$ indexed by an item count and a partial target;
    cell $(i, j)$ records whether some subset of the first $i$ items sums to $j$ once it is
    known, and is $bot$ before that.],
  I: $I = NN^* times NN$,
  X: $X = X_(S,T) = [0..m] times [0..T] -> BB_bot$,
  A: $A = BB$,
  rho: $rho(S, T) = {(i, j) |-> bot}$,
  F: $F = F_S, quad F_S (x)_(i,j) = cases(
    "true" & "if " j = 0,
    "false" & "if " i = 0 and j > 0,
    x_(i-1,j) & "if " s_i > j,
    x_(i-1,j) or x_(i-1,j - s_i) & "otherwise"
  )$,
  pi: $pi = pi_(S,T) = x |-> x_(m,T)$,
  sigma: $sigma(x) = |{(i, j) | x_(i,j) = bot}|$,
  inv: $"Inv"(x) <=> forall (i, j) . x_(i,j) != bot => x_(i,j) = D(i, j)$,
)
Row $i$ is computed only from defined cells of row $i - 1$ (column $0$ is always true), which by
$"Inv"$ hold their final $D$ values, so defined cells never change and every step that changes
$x$ completes one more row and lowers $sigma$; after $m + 1$ steps every cell is defined and
$pi_(S,T)(x) = D(m, T)$.

#let subset-sum-mc(inst) = {
  let (S, T) = inst
  let m = S.len()
  let rho = ((S, T)) => range(S.len() + 1).map(_ => range(T + 1).map(_ => none))
  let F_S = x => ((i, j)) => {
    if j == 0 { true } else if i == 0 { false } else {
      let s = S.at(i - 1)
      let skip = x.at(i - 1).at(j)
      if s > j { skip } else {
        let take = x.at(i - 1).at(j - s)
        if skip != none and take != none { skip or take } else { none }
      }
    }
  }
  let F = map_tensor(F_S, dim: 2)
  let pi = x => x.at(m).at(T)
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((S, T)) => [$S = (#S.map(str).join(", "))$ \ $T = #T$],
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: ([$emptyset$],) + S.map(s => [#s]),
      col-labels: range(T + 1).map(j => [#j]),
      corner: [$s_i slash j$],
      width: 1.6em,
    ),
    A_h: show-val,
    F_name: [$F_((#S.map(str).join(", ")))$],
    pi_name: [$mpi_(((#S.map(str).join(", ")), #T))$],
    group-size: 2,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(inst)
}

#let inst = ((3, 5, 8), 11)
#figure(
  caption: [Subset sum via mapcode for $S = (3, 5, 8)$, $T = 11$. Row $i$ is labelled with item
    $s_i$, column $j$ is the partial target; T/F denote true/false.],
  subset-sum-mc(inst),
)
