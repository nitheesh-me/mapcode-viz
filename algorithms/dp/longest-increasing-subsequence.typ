#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Longest Increasing Subsequence
#set math.equation(numbering: none)

Compute the length of the longest strictly increasing subsequence (LIS) of a sequence of
numbers $"nums" = ("nums"_0, dots, "nums"_(n-1))$.

Formal definition: let $L(i)$ be the length of the longest increasing subsequence that ends
at position $i$. Then
$
  L(i) = 1 + max({L(j) | j < i, "nums"_j < "nums"_i} union {0})
$
and the answer is $max_i L(i)$ (or $0$ for the empty sequence).

Examples:
- $"nums" = (3, 1, 2) -> 2$ (e.g. $(1, 2)$)
- $"nums" = (10, 9, 2, 5, 3, 7, 101, 18) -> 4$ (e.g. $(2, 3, 7, 18)$)

*As mapcode:*

_primitives_: `sum`($+$) and `max` are strict, i.e. they return $bot$ if any argument is $bot$.

#mc-spec(
  state: [With $n = |"nums"|$, the state is an array $x$ with one cell per position; cell $i$
    holds the length of the longest increasing subsequence ending at position $i$ once it is
    known, and $bot$ before that.],
  I: $I = NN^*$,
  X: $X = X_"nums" = [0..n-1] -> NN_bot$,
  A: $A = NN$,
  rho: $rho("nums") = {i |-> bot}$,
  F: $F = F_"nums", quad F_"nums" (x)_i = 1 + max(P_i union {0})$,
  pi: $pi = pi_"nums" = x |-> max({0} union {x_i})$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = L(i)$,
)
where $P_i = {x_j | j < i, "nums"_j < "nums"_i}$ holds the values of the earlier, smaller cells.
Cell $i$ is defined only once every earlier cell with a smaller value is defined, and by
$"Inv"$ those cells already hold $L(j)$, so defined cells never change and every step that
changes $x$ defines a new cell and lowers $sigma$; cell $i$ is defined after $L(i)$ steps, so at
the fixed point $x_i = L(i)$ everywhere and $pi_"nums" (x) = max_i L(i)$ (or $0$ when $n = 0$).

#let lis-mc(nums) = {
  let n = nums.len()
  let rho = nums => nums.map(_ => none)
  let F_nums = x => ((i,)) => {
    let deps = range(i).filter(j => nums.at(j) < nums.at(i)).map(j => x.at(j))
    if deps.any(v => v == none) { none } else { 1 + calc.max(0, ..deps) }
  }
  let F = map_tensor(F_nums, dim: 1)
  let pi = x => calc.max(0, ..x)
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: nums => [$"nums" = (#nums.map(str).join(", "))$],
    // Two-row view: the input value nums_i above the current x_i.
    X_h: (x, diff_mask: none) => table-view(
      (x,),
      (diff_mask,),
      row-labels: ([$x$],),
      col-labels: nums.map(v => [#v]),
      corner: [nums],
    ),
    F_name: [$F_"nums"$],
    pi_name: [$mpi_"nums"$],
    group-size: 2,
    spacing: (8mm, 10mm),
    node-shape: rect,
  )(nums)
}

#let inst = (10, 9, 2, 5, 3, 7, 101, 18)
#figure(
  caption: [LIS via mapcode for $"nums" = (#inst.map(str).join(", "))$. The header row shows
    $"nums"_i$, the row below it the current $x_i$.],
  lis-mc(inst),
)
