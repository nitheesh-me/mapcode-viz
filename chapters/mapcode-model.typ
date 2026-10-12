#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

// Numbered environments (Definition 1.1, Theorem 1.2, ...).
#let env-counter = counter("mc-env")
#let env(kind, title, body) = block(above: 1em, below: 1em, {
  env-counter.step()
  [*#kind #context [1.#env-counter.display()]*]
  if title != none [ (#title)]
  [*.* ]
  if kind in ("Theorem", "Corollary") { emph(body) } else { body }
})
#let definition(title: none, body) = env("Definition", title, body)
#let theorem(title: none, body) = env("Theorem", title, body)
#let corollary(title: none, body) = env("Corollary", title, body)
#let remark(title: none, body) = env("Remark", title, body)
#let example(title: none, body) = env("Example", title, body)
#let proof(body) = block(above: 0.6em, below: 1em, [_Proof._ #body #h(1fr) $square$])

= The Mapcode Model <mapcode-model>

Notation follows #link(<notation>)[Appendix A]. The definitions below are adapted from
#cite(<viswanath2008>, form: "prose").

#definition(title: "Mapcode")[
  Let $f : I -> A$ be a function, the _specification_. A _mapcode_ for $f$ consists of a set $X$, the
  _state space_, together with three maps
  $
    rho : I -> X quad "(initialisation)," quad quad F : X -> X quad "(transformation)," quad quad
    pi : X -> A quad "(projection)."
  $
]

#definition(title: "Fixed and convergent points")[
  The set of _fixed points_ of $F$ is $"fix"(F) = {x in X | F(x) = x}$. A state $x in X$ is
  _convergent_ if $F^k (x) in "fix"(F)$ for some $k in NN$; the set of convergent states is denoted
  $"con"(F)$. For $x in "con"(F)$ the _limit_ of $x$ is $F^infinity (x) = F^k (x)$, where $k$ is the
  least such index. This defines the _limit map_ $F^infinity : "con"(F) -> "fix"(F)$.
]

#definition(title: "Run")[
  The _run_ of the mapcode is the partial function $"run" = pi compose F^infinity compose rho$ from $I$
  to $A$, defined at $i$ if and only if $rho(i) in "con"(F)$. The mapcode _computes_ $f$ if $"run"(i)$ is
  defined and equal to $f(i)$ for every $i in I$, that is, if the square in @fig-mapcode-symbolic
  commutes.
]

#figure(
  caption: [A mapcode. *Left:* the mapcode computes $f$ if and only if this square commutes.
    *Right:* a run on an instance $i$: the initial state $x_0 = rho(i)$, the iterates $x_(k+1) = F(x_k)$,
    the limit $x^* = F^infinity (x_0)$ with its $F$ loop, and the answer $pi(x^*)$. Each figure in this book
    shows the right-hand diagram for a concrete instance.],
  {
    let lab(body) = text(size: 0.75em, fill: luma(100), style: "italic", body)
    let square = diagram(
      spacing: (13mm, 14mm),
      node((0, 0), $I$, name: <sI>),
      node((1, 0), $A$, name: <sA>),
      node((0, 1), $"con"(F)$, name: <sC>),
      node((1, 1), $"fix"(F)$, name: <sF>),
      edge(<sI>, <sA>, $f$, "-->"),
      edge(<sI>, <sC>, $rho$, "->", label-side: right),
      edge(<sC>, <sF>, $F^infinity$, "->", label-side: right),
      edge(<sF>, <sA>, $pi$, "->", label-side: right),
    )
    let run = diagram(
      spacing: (8.5mm, 11mm),
      node((0, 0), $i$, name: <ri>),
      node((5, 0), $f(i)$, name: <ra>),
      node((0, 1.4), $x_0$, name: <r0>),
      node((1.25, 1.4), $x_1$, name: <r1>),
      node((2.5, 1.4), $x_2$, name: <r2>),
      node((3.75, 1.4), $dots.h.c$, name: <rd>),
      node((5, 1.4), $x^*$, name: <rs>),
      edge(<ri>, <ra>, $f$, "-->"),
      edge(<ri>, <r0>, $rho$, "->", label-side: right),
      edge(<r0>, <r1>, $F$, "->", label-side: right),
      edge(<r1>, <r2>, $F$, "->", label-side: right),
      edge(<r2>, <rd>, $F$, "->", label-side: right),
      edge(<rd>, <rs>, $F$, "->", label-side: right),
      edge(<rs>, <rs>, $F$, "->", bend: -120deg, loop-angle: 90deg),
      edge(<r0>, <rs>, $F^infinity$, "->", bend: 28deg),
      edge(<rs>, <ra>, $pi$, "->", label-side: right),
      // callouts
      node((-0.9, -0.45), lab[instance], stroke: none, name: <ci>),
      node((5.75, -0.45), lab[answer], stroke: none, name: <ca>),
      node((-0.95, 2.15), lab[initial state], stroke: none, name: <c0>),
      node((1.9, 2.4), lab[state], stroke: none, name: <c2>),
      node((5.85, 2.35), lab[fixed point], stroke: none, name: <cs>),
      edge(<ci>, <ri>, stroke: 0.4pt + c-accent),
      edge(<ca>, <ra>, stroke: 0.4pt + c-accent),
      edge(<c0>, <r0>, stroke: 0.4pt + c-accent),
      edge(<c2>, <r2>, stroke: 0.4pt + c-accent),
      edge(<cs>, <rs>, stroke: 0.4pt + c-accent),
    )
    grid(columns: (auto, auto), column-gutter: 0.9cm, align: horizon, square, run)
  },
) <fig-mapcode-symbolic>

As for loops @floyd1967 @hoare1969, the proof splits into _termination_ (@sec-termination) and
_partial correctness_ (@sec-partial), whose conjunction is _total correctness_ (@sec-total).

== Termination <sec-termination>

#definition(title: "Termination")[
  The mapcode _terminates on_ $i in I$ if $rho(i) in "con"(F)$, and it _terminates_ if
  $rho(I) subset.eq "con"(F)$.
]

#definition(title: "Bound function")[
  A map $sigma : X -> NN$ is a _bound function_ (or _variant_) for $F$ if
  $sigma(F(x)) < sigma(x)$ for every $x in X$ with $F(x) != x$.
]

#theorem(title: "Termination")[
  If $F$ admits a bound function $sigma$, then $"con"(F) = X$. In particular the mapcode terminates,
  and $F^infinity (rho(i))$ is obtained after at most $sigma(rho(i))$ applications of $F$.
]
#proof[
  Let $x in X$ and $x_k = F^k (x)$. If none of $x_0, dots, x_(k-1)$ is a fixed point, then
  $sigma(x_k) <= sigma(x_0) - k$ by induction on $k$. Since $sigma(x_k) >= 0$, this is possible only for
  $k <= sigma(x_0)$. Hence $x_k in "fix"(F)$ for some $k <= sigma(x_0)$.
]

#remark[
  The condition on $sigma$ concerns only state-changing steps and is independent of $pi$ and $f$.
  Typical bound functions are the number of undefined cells of a strict table (Appendix A.3), a step
  counter, and the length of a search interval.
]

#example[
  Without a bound function termination may fail: $F(n) = n + 1$ on $NN$ has no fixed point, and the
  Bellman–Ford map of @sec-bellman-ford has none on a graph with a negative cycle.
]

== Partial correctness <sec-partial>

#definition(title: "Partial correctness")[
  The mapcode is _partially correct_ for $f$ if $pi(F^infinity (rho(i))) = f(i)$ for every $i in I$ with
  $rho(i) in "con"(F)$.
]

#definition(title: "Invariant value")[
  A map $theta : X -> A$ is an _invariant value_ for the mapcode and $f$ if, for all $i in I$ and
  $x in X$,
  #align(center, table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 8pt, y: 3pt),
    [(i) #h(0.3em) $theta(rho(i)) = f(i)$], [(initialisation)],
    [(ii) #h(0.3em) $theta(F(x)) = theta(x)$], [(preservation)],
    [(iii) #h(0.3em) $F(x) = x ==> theta(x) = pi(x)$], [(exit).],
  ))
]

#theorem(title: "Partial correctness")[
  If the mapcode has an invariant value $theta$, then it is partially correct for $f$.
]
#proof[
  Let $i in I$ with $rho(i) in "con"(F)$, and let $x_k = F^k (rho(i))$. By (ii) and induction on $k$,
  $theta(x_k) = theta(x_0)$, and $theta(x_0) = f(i)$ by (i). For $x^* = F^infinity (rho(i))$, condition (iii)
  gives $pi(x^*) = theta(x^*) = f(i)$.
]

#definition(title: "Invariant predicate")[
  A family $("Inv"_i)_(i in I)$ of predicates on $X$ is an _invariant_ if, for all $i in I$ and
  $x in X$, $"Inv"_i (rho(i))$ holds and $"Inv"_i (x)$ implies $"Inv"_i (F(x))$.
]

#corollary[
  If $("Inv"_i)$ is an invariant and $"Inv"_i (x) and F(x) = x$ implies $pi(x) = f(i)$ for all $i in I$
  and $x in X$, then the mapcode is partially correct for $f$.
]
#proof[
  As in the proof of Theorem 1.11, $"Inv"_i$ holds at every iterate of $rho(i)$, and hence at
  $F^infinity (rho(i))$ whenever the limit exists.
]

For the strict tables of Appendix A.3, $"Inv"_i (x)$ asserts that every defined cell of $x$ holds its
recursive value; the subscript $i$ is omitted when clear.

#remark[
  Partial correctness imposes no condition on inputs with $rho(i) in.not "con"(F)$; a mapcode that
  terminates on no input is partially correct for every $f$.
]

== Total correctness <sec-total>

#definition(title: "Total correctness")[
  The mapcode is _totally correct_ for $f$ if it terminates and is partially correct for $f$;
  equivalently, if it computes $f$.
]

#theorem(title: "Total correctness")[
  If $F$ admits a bound function $sigma$ and the mapcode has an invariant value $theta$ (or an invariant
  satisfying the hypothesis of Corollary 1.13), then the mapcode is totally correct for $f$, and
  $"run"(i)$ is obtained after at most $sigma(rho(i))$ applications of $F$.
]
#proof[
  Combine Theorem 1.6 with Theorem 1.11 (or Corollary 1.13).
]

Each specification block in the sequel therefore ends with $sigma$ and $theta$ (or $"Inv"$). In this
chapter their values are shown beneath each state.

== Reading the figures

Each figure shows one run, as in the right-hand diagram of @fig-mapcode-symbolic: the instance $i$
(upper left), the iterates $x_k$ in rows joined by $F$ edges, the limit $x^*$ with its $F$ loop, and the
answer $pi(x^*)$ (upper right); the dashed edge is $f$. Cells are coloured as follows (Appendix A.6):

#align(center, legend)

#pagebreak()
== Example: factorial, counting down

#mc-spec(
  state: [The state $(n, "acc")$ holds the factors $n$ still to multiply and the accumulated
    product $"acc"$; each step moves $n$ into the accumulator.],
  I: $I = NN$,
  X: $X = NN times NN$,
  A: $A = NN$,
  rho: $rho(n) = (n, 1)$,
  F: $F(n, "acc") = cases((n - 1, "acc" dot n) & "if" n > 0, (0, "acc") & "if" n = 0)$,
  pi: $pi(n, "acc") = "acc"$,
  sigma: $sigma(n, "acc") = n$,
  theta: $theta(n, "acc") = "acc" dot n!$,
)

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

#mc-spec(
  state: [For a fixed $n$, the state $(k, "acc")$ holds the number $k <= n$ of factors used so far
    and their product $"acc"$, which runs through $0!, 1!, 2!, dots$.],
  I: $I = NN$,
  X: $X = X'_n = {(k, "acc") in NN times NN | k <= n}$,
  A: $A = NN$,
  rho: $rho(n) = (0, 1)$,
  F: $F = F'_n = (k, "acc") |-> cases((k + 1, "acc" dot (k + 1)) & "if" k < n, (k, "acc") & "if" k = n)$,
  pi: $pi(k, "acc") = "acc"$,
  sigma: $sigma(k, "acc") = n - k$,
  theta: $theta(k, "acc") = "acc" dot (k+1) dots.c n$,
)
Moreover, $"Inv"(k, "acc") <=> "acc" = k!$ is an invariant.

#figure(
  caption: [Counting-up factorial of 5; every state satisfies $"acc" = k!$.],
  mapcode-viz(
    n => (0, 1),
    ((k, acc)) => if k < 5 { (k + 1, acc * (k + 1)) } else { (k, acc) },
    ((k, acc)) => acc,
    X_h: ((k, acc), diff_mask: none) => $(#k, #acc)$,
    F_name: [$F'_5$],
    sigma: ((k, acc)) => 5 - k,
    theta: ((k, acc)) => acc * range(k + 1, 6).product(default: 1),
    group-size: 3,
    spacing: (14mm, 12mm),
  )(5),
)

== Example: bubble <ex-bubble>

A _bubble pass_ traverses a list once from left to right and exchanges every adjacent pair that is
out of order; consequently, a largest element is moved to the last position. It is defined
recursively by
$
  "bubble"([]) = [], quad "bubble"([x]) = [x], quad
  "bubble"(x :: y :: r) = cases(x :: "bubble"(y :: r) & "if" x <= y, y :: "bubble"(x :: r) & "otherwise.")
$
#mc-spec(
  state: [As a mapcode the pass is not a primitive. The state $(j, l)$ holds the position $j$ of
    the next comparison and the list $l$; one step of $F$ performs a single compare-and-swap
    $"cs"_j$, which exchanges $l_j$ and $l_(j+1)$ when $l_j > l_(j+1)$.],
  I: $I = NN^*$,
  X: $X = NN times NN^*$,
  A: $A = NN^*$,
  rho: $rho(l) = (0, l)$,
  F: $F(j, l) = cases((j + 1, "cs"_j (l)) & "if" j + 1 < |l|, (j, l) & "otherwise")$,
  pi: $pi(j, l) = l$,
  sigma: $sigma(j, l) = |l| - j$,
  theta: $theta(j, l) = l_([0..j)) plus.double "bubble"(l_([j..|l|)))$,
)
Here $theta(j, l)$ is the result of completing the pass from position $j$. Then
$theta(rho(l)) = "bubble"(l)$, $theta$ is preserved by a compare-and-swap, and $theta(j, l) = l = pi(j, l)$ when
$j + 1 >= |l|$.

#let cswap(j, l) = {
  let l = l
  if j + 1 < l.len() and l.at(j) > l.at(j + 1) {
    let t = l.at(j)
    l.at(j) = l.at(j + 1)
    l.at(j + 1) = t
  }
  l
}
#let plain-array(l) = array-view(l)
#figure(
  caption: [One bubble pass over $[5, 1, 4, 2, 8]$ as a mapcode. The pointer marks the next
    comparison; highlighted cells were swapped by the last step.],
  mapcode-viz(
    l => (0, l),
    ((j, l)) => if j + 1 < l.len() { (j + 1, cswap(j, l)) } else { (j, l) },
    ((j, l)) => l,
    I_h: plain-array,
    A_h: plain-array,
    X_h: ((j, l), diff_mask: none) => array-view(
      l,
      mask: if type(diff_mask) == array { diff_mask.at(1) } else { none },
      pointers: if j + 1 < l.len() { (j: j) } else { (:) },
    ),
    dim: 2,
    sigma: ((j, l)) => l.len() - j,
    group-size: 3,
    spacing: (10mm, 12mm),
  )((5, 1, 4, 2, 8)),
)

== Example: bubble sort <ex-bubble-sort>

Bubble sort applies the bubble pass repeatedly. After $p$ passes the $p$ largest elements occupy their
final positions at the end of the list, so $|l|$ passes suffice. The following mapcode treats the pass
of @ex-bubble as a primitive operation.

#mc-spec(
  state: [The state $(k, l)$ holds the number $k$ of passes still to do and the list $l$; each
    step applies one whole pass.],
  I: $I = NN^*$,
  X: $X = NN times NN^*$,
  A: $A = NN^*$,
  rho: $rho(l) = (|l|, l)$,
  F: $F(k, l) = cases((k - 1, "bubble"(l)) & "if" k > 0, (0, l) & "if" k = 0)$,
  pi: $pi(k, l) = l$,
  sigma: $sigma(k, l) = k$,
  theta: $theta(k, l) = "bubble"^k (l)$,
)
The bound function decreases by one at every step. The invariant value $theta(k, l) = "bubble"^k (l)$
satisfies $theta(rho(l)) = "bubble"^(|l|)(l)$, the sorted permutation of $l$; it is preserved by $F$, since
$"bubble"^k (l) = "bubble"^(k-1)("bubble"(l))$; and $theta(0, l) = l = pi(0, l)$.

#let bubble(l) = {
  let l = l
  for j in range(calc.max(l.len() - 1, 0)) { l = cswap(j, l) }
  l
}
#figure(
  caption: [Bubble sort of $[5, 1, 4, 2, 8]$ with the pass as a primitive. Shaded cells are the
    sorted suffix: after $p = |l| - k$ passes the last $p$ elements are in place; highlighted cells
    moved in the last pass.],
  mapcode-viz(
    l => (l.len(), l),
    ((k, l)) => if k > 0 { (k - 1, bubble(l)) } else { (k, l) },
    ((k, l)) => l,
    I_h: plain-array,
    A_h: l => array-view(l, runs: ((0, l.len() - 1, c-done),)),
    X_h: ((k, l), diff_mask: none) => {
      let n = l.len()
      let p = n - k
      array-view(
        l,
        mask: if type(diff_mask) == array { diff_mask.at(1) } else { none },
        runs: if p > 0 { ((n - p, n - 1, c-done),) } else { () },
      )
    },
    dim: 2,
    sigma: ((k, l)) => k,
    group-size: 3,
    spacing: (10mm, 12mm),
  )((5, 1, 4, 2, 8)),
)

== Example: bubble sort with the full state

In the mapcode of @ex-bubble-sort the primitive $"bubble"$ itself contains a loop. In the following
mapcode every comparison is a separate application of $F$. Since each pass moves a largest remaining
element to its final position, each pass may stop one position before the previous one; recursively,
with $n = |l|$,
$
  "bs"_u (l) = cases(l & "if" u <= 1, "bs"_(u-1) ("bubble"(l_([0..u))) plus.double l_([u..n))) & "otherwise,")
  quad quad "sort"(l) = "bs"_n (l).
$
#mc-spec(
  state: [The mapcode keeps the entire computation in its state $(u, j, l)$: the prefix
    $l_([0..u))$ is still unsorted, the suffix $l_([u..n))$ is sorted and holds the largest
    elements, and $j$ is the position of the next comparison. One step of $F$ either performs a
    compare-and-swap or, at the end of a pass, moves the boundary $u$ one place to the left.],
  I: $I = NN^*$,
  X: $X = NN times NN times NN^*$,
  A: $A = NN^*$,
  rho: $rho(l) = (|l|, 0, l)$,
  F: $F(u, j, l) = cases(
    (u, j, l) & "if" u <= 1,
    (u, j + 1, "cs"_j (l)) & "if" j + 1 < u,
    (u - 1, 0, l) & "otherwise"
  )$,
  pi: $pi(u, j, l) = l$,
  sigma: $sigma(u, j, l) = u^2 + (u - j)$,
  theta: $theta(u, j, l) = cases(l & "if" u <= 1, "bs"_(u-1) (l_([0..j)) plus.double "bubble"(l_([j..u))) plus.double l_([u..n))) & "otherwise")$,
)
The bound function decreases by $1$ at every comparison and by at least $1$ at the end of each pass.
The invariant value completes the current pass and then applies $"bs"_(u-1)$; it satisfies
$theta(rho(l)) = "sort"(l)$, it is preserved by $F$, and $theta(u, j, l) = l = pi(u, j, l)$ whenever $u <= 1$.

#figure(
  caption: [Bubble sort of $[4, 3, 1, 2]$ with the full state. Shaded cells form the sorted
    suffix $l_([u..n))$; the pointers mark the next comparison $j$ and the boundary $u$.],
  mapcode-viz(
    l => (l.len(), 0, l),
    ((u, j, l)) => if u <= 1 { (u, j, l) } else if j + 1 < u { (u, j + 1, cswap(j, l)) } else {
      (u - 1, 0, l)
    },
    ((u, j, l)) => l,
    I_h: plain-array,
    A_h: l => array-view(l, runs: ((0, l.len() - 1, c-done),)),
    X_h: ((u, j, l), diff_mask: none) => {
      let n = l.len()
      let ptrs = (:)
      if u > 1 and j + 1 < u { ptrs.insert("j", j) }
      if u < n { ptrs.insert("u", u) }
      array-view(
        l,
        mask: if type(diff_mask) == array { diff_mask.at(2) } else { none },
        pointers: ptrs,
        runs: if u < n { ((u, n - 1, c-done),) } else { () },
      )
    },
    dim: 2,
    sigma: ((u, j, l)) => u * u + (u - j),
    group-size: 4,
    spacing: (8mm, 12mm),
  )((4, 3, 1, 2)),
)
