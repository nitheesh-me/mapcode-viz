#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

#show link: underline

== House Robber #link("https://leetcode.com/problems/house-robber/")[LeetCode P.198]
#set math.equation(numbering: none)

A robber plans to rob houses along a street; house $i$ holds an amount $h_i$ of money. Adjacent
houses share an alarm system, so robbing two neighbouring houses on the same night alerts the
police. Return the maximum amount that can be robbed without robbing two adjacent houses.

Formal definition, for $h in NN^n$ and $"rob"(i)$ the best amount from houses $0, dots, i$:
$
  "rob"(i) = cases(
    0 & "if " i < 0,
    max("rob"(i-1), h_i + "rob"(i-2)) & "if " i >= 0
  ) quad quad "answer" = "rob"(n-1)
$

Examples:
- $h = [1, 2, 3, 1] -> 4$ (rob houses $0$ and $2$)
- $h = [2, 7, 9, 3, 1] -> 12$ (rob houses $0, 2, 4$: $2 + 9 + 1$)

Constraints: $1 <= n <= 100$ and $0 <= h_i <= 400$.

*As mapcode:*

_primitives_: `max` and `add`($+$) are strict, i.e. they return $bot$ if any argument is $bot$.

#mc-spec(
  state: [The state is a table $x$ indexed by house: cell $x_i$ holds the best amount
    $"rob"(i)$ from houses $0, dots, i$, or $bot$ while it is not yet known.],
  I: $I = h : NN^n$,
  X: $X = X_n = [0..n) -> NN_bot$,
  A: $A = NN$,
  rho: $rho(h) = {i |-> bot | i in [0..n)}$,
  F: $F = F_h, quad F_h (x)_i = cases(
    h_0 & "if " i = 0,
    max(x_0, h_1) & "if " i = 1,
    max(x_(i-1), h_i + x_(i-2)) & "if " i >= 2
  )$,
  pi: $pi(x) = x_(n-1)$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = "rob"(i)$,
)
Cell $x_i$ chooses between skipping house $i$ (keep $x_(i-1)$) and robbing it (add $h_i$ to
$x_(i-2)$); it becomes defined, with exactly $"rob"(i)$, one step after $x_(i-1)$ and never
changes, so each changing step lowers $sigma$ and keeps $"Inv"$, and after $n$ steps
$pi(x) = "rob"(n-1)$.

#let robber-mc(houses) = {
  let n = houses.len()
  let rho = h => range(h.len()).map(_ => none)
  let F_i = h => x => ((i,)) => {
    if i == 0 { h.at(0) } else if i == 1 {
      if x.at(0) == none { none } else { calc.max(x.at(0), h.at(1)) }
    } else if x.at(i - 1) == none or x.at(i - 2) == none { none } else {
      calc.max(x.at(i - 1), h.at(i) + x.at(i - 2))
    }
  }
  let F = h => map_tensor(F_i(h), dim: 1)
  let pi = x => x.at(n - 1)
  let labels = houses.map(v => [#v])
  mapcode-viz(
    rho,
    F(houses),
    pi,
    I_h: h => vec-view(h, none),
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, labels: labels, width: 2.2em),
    F_name: [$F_h$],
    pi_name: [$mpi$],
    group-size: 3,
    spacing: (8mm, 10mm),
  )(houses)
}

#let inst = (2, 7, 9, 3, 1)
#figure(
  caption: [House robber via mapcode for $h = [2, 7, 9, 3, 1]$. The grey label above cell $x_i$ is
    the money $h_i$ in house $i$.],
  robber-mc(inst),
)
