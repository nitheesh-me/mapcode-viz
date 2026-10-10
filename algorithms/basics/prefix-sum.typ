#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Prefix Sum
#set math.equation(numbering: none)

Given an array $a = [a_0, ..., a_(n-1)]$ of integers, compute its prefix sums: the sum of
the first $i$ elements for every $i in [0..n]$.

Formal definition:
$
  S(0) & = 0, \
  S(i) & = S(i-1) + a_(i-1) quad "for " 1 <= i <= n
$

Examples:
- $[1, 2, 3, 4] -> [0, 1, 3, 6, 10]$
- $[5, -2, 3] -> [0, 5, 3, 6]$
- $[] -> [0]$

*As mapcode:*

_primitives_: `add`($+$) is strict, i.e. $bot + v = v + bot = bot$.

The input array is instance data: it lives in $I$ and reaches $F$ through the closure $F_a$;
the state holds only the prefix sums.

$
  I = ZZ^* quad quad X_n = [0..n] -> ZZ_bot quad quad A = ZZ^(n+1) \
  rho(a) = {i -> bot | i in [0..n]} quad "where" n = |a| \
  F_a (x)_i = cases(
    0 & "if " i = 0,
    x_(i-1) + a_(i-1) & "if " i >= 1
  ) \
  pi(x) = [x_0, ..., x_n]
$

Cell $i$ becomes defined one step after cell $i-1$, so the table fills left to right and the
fixed point is reached after $n+1$ steps.

#let prefix-mc(a) = {
  let n = a.len()
  let rho = a => range(a.len() + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { 0 } else if x.at(i - 1) != none { x.at(i - 1) + a.at(i - 1) } else { none }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => x
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: a => stack(dir: ttb, spacing: 3pt, align(left, text(size: 0.8em)[$a =$]), array-view(a)),
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, vertical: true),
    A_h: x => [$[#x.map(str).join(", ")]$],
    pi_name: [$mpi$],
    F_name: [$F_a$],
    group-size: 4,
    spacing: (8mm, 10mm),
  )(a)
}

#let inst = (3, 1, 4, 1, 5)
#figure(
  caption: [Prefix sums via mapcode for $a = (#inst.map(str).join(", "))$.],
  prefix-mc(inst),
)
#legend
