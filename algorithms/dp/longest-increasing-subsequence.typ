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

$
  I = NN^* quad quad X_"nums" = [0..n-1] -> NN_bot quad quad A = NN quad quad "where" n = |"nums"| \
  rho("nums") = {i -> bot | i in [0..n-1]} \
  F_"nums" (x)_i = 1 + max({x_j | j < i, "nums"_j < "nums"_i} union {0}) \
  pi_"nums" (x) = max_i x_i
$

Cell $i$ becomes defined as soon as every earlier cell with a smaller value is defined; cells
with no smaller predecessor are set to $1$ in the first step. Hence $x_i$ is fixed after
$L(i)$ steps and the fixed point is reached after $max_i L(i)$ steps.

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
