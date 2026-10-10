#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

= The Mapcode Model

A *mapcode* program for a specification $f : I -> A$ is a triple of maps
$
  rho : I -> X quad quad F : X -> X quad quad pi : X -> A
$
over a _state space_ $X$. The input is _initialised_ into a state by $rho$, the state is
_transformed_ by $F$ until it stops changing, and the answer is _read off_ by $pi$:
$
  "run" = pi compose F^infinity compose rho,
  quad quad F^infinity (x) = F^k (x) "for the least" k "with" F(F^k (x)) = F^k (x).
$
Each figure in this book draws exactly this pipeline: the instance $i$, the states
$x_0 = rho(i), x_1 = F(x_0), dots$ up to the fixed point $x^*$ (marked by the $F$ self-loop),
and the answer $pi(x^*)$. The dashed edge is the specification $f$ that the pipeline implements.
#legend

== Strictness and $bot$

Most examples take $X$ to be a table $[0..n] -> V_bot$: every cell starts _undefined_ ($bot$),
and $F$ fills a cell only when all the cells it depends on are already defined. Because the
primitives are _strict_ (an operation on $bot$ is $bot$), each step of $F$ defines at least one more
cell until none change, so the fixed point is reached after at most one step per cell, and it is
_the same table_ that the recursive definition would compute. The order in which cells become
defined is the dependency order of the recursion; the highlighted cells in each figure show
exactly which sub-problems became available in that step.

== Verified mapcode

The accompanying Lean file `Mapcode.lean` formalises the model. `MapCodeUnverified` is just the
triple $(rho, F, pi)$ with `run = π ∘ runTillFix ∘ ρ`. The verified structure `Mapcode` adds
the three ingredients of a classical loop proof:

#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  table.hline(stroke: 0.5pt),
  [*Field*], [*Meaning*],
  table.hline(stroke: 0.3pt),
  [$sigma : X -> NN$], [a _variant_: $F(x) != x => sigma(F(x)) < sigma(x)$, so iteration terminates],
  [$theta : X -> A$], [an _invariant value_: $theta(rho(i)) = f(i)$ and $theta(F(x)) = theta(x)$],
  [$theta$ at exit], [at a fixed point $F(x) = x$, $theta(x) = pi(x)$],
  table.hline(stroke: 0.5pt),
)

From these, `runWithProof` returns $pi(F^infinity (rho(i)))$ _together with_ a proof that it equals
$f(i)$: $theta$ starts at the specification, never changes, and coincides with the output at the
end. `MapcodeInv` further carries a predicate $"Inv"$ that holds initially and is preserved by
$F$ (it need not determine the answer).

`mapcode-viz` can display $sigma$ and $theta$ under every state (parameters `sigma:` and
`theta:`), which makes the proof obligations visible: $sigma$ must go down along every $F$ edge,
and $theta$ must stay constant.

== Example: factorial, counting down

State $(n, "acc")$; each step moves $n$ into the accumulator (`factorialMC` in Lean).
$
  I = NN quad X = NN times NN quad A = NN quad
  rho(n) = (n, 1) quad
  F(n, "acc") = cases((n - 1, "acc" dot n) & "if" n > 0, (0, "acc") & "if" n = 0) quad
  pi(n, "acc") = "acc"
$
with variant $sigma(n, "acc") = n$ and invariant $theta(n, "acc") = "acc" dot n!$.

#let fact(n) = range(1, n + 1).product(default: 1)
#figure(
  caption: [Factorial of 5 as a verified mapcode: $sigma$ decreases, $theta$ stays $5! = 120$.],
  mapcode-viz(
    n => (n, 1),
    ((n, acc)) => if n > 0 { (n - 1, acc * n) } else { (n, acc) },
    ((n, acc)) => acc,
    X_h: ((n, acc), diff_mask: none) => $(#n, #acc)$,
    sigma: ((n, acc)) => n,
    theta: ((n, acc)) => acc * fact(n),
    group-size: 3,
    spacing: (14mm, 12mm),
  )(5),
)

== Example: factorial, counting up

State $(k, "acc")$ with $k <= n$ (`factorialMC'`): the accumulator runs through $0!, 1!, 2!, dots$.
The variant is $sigma = n - k$, the invariant value $theta(k, "acc") = "acc" dot (k+1) dots.c n$, and
`MapcodeInv` adds the predicate $"Inv"(k, "acc") <=> "acc" = k!$.

#figure(
  caption: [Counting-up factorial of 5; every state satisfies $"acc" = k!$.],
  mapcode-viz(
    n => (0, 1),
    ((k, acc)) => if k < 5 { (k + 1, acc * (k + 1)) } else { (k, acc) },
    ((k, acc)) => acc,
    X_h: ((k, acc), diff_mask: none) => $(#k, #acc)$,
    sigma: ((k, acc)) => 5 - k,
    theta: ((k, acc)) => acc * range(k + 1, 6).product(default: 1),
    group-size: 3,
    spacing: (14mm, 12mm),
  )(5),
)

== Example: bubble sort

The Lean file also verifies bubble sort. One pass `bubble` swaps adjacent out-of-order pairs
left to right; the state $(k, l)$ counts the passes still to do.
$
  I = [NN] quad X = NN times [NN] quad A = [NN] quad
  rho(l) = (|l|, l) quad
  F(k, l) = cases((k - 1, "bubble"(l)) & "if" k > 0, (0, l) & "if" k = 0) quad
  pi(k, l) = l
$
with $sigma(k, l) = k$ and $theta(k, l) = "bubbleSortN"(k, l)$, the result of $k$ more passes, which
is preserved by $F$ by definition and equals $l$ when $k = 0$.

#let bubble(l) = {
  let l = l
  for i in range(l.len() - 1) {
    if l.at(i) > l.at(i + 1) {
      let t = l.at(i)
      l.at(i) = l.at(i + 1)
      l.at(i + 1) = t
    }
  }
  l
}
#figure(
  caption: [Bubble sort of $[5, 1, 4, 2, 8]$; highlighted cells moved in the last pass.],
  mapcode-viz(
    l => (l.len(), l),
    ((k, l)) => if k > 0 { (k - 1, bubble(l)) } else { (k, l) },
    ((k, l)) => l,
    X_h: ((k, l), diff_mask: none) => {
      let m = if type(diff_mask) == array { diff_mask.at(1) } else { none }
      stack(dir: ttb, spacing: 2pt, text(size: 0.8em, fill: c-muted)[$k = #k$], vec-view(l, m))
    },
    A_h: l => vec-view(l, none, labels: l.map(_ => [])),
    I_h: l => vec-view(l, none, labels: l.map(_ => [])),
    dim: 2,
    sigma: ((k, l)) => k,
    group-size: 3,
    spacing: (10mm, 12mm),
  )((5, 1, 4, 2, 8)),
)
