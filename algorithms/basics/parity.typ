#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Parity
#set math.equation(numbering: none)

Decide whether a non-negative integer $n$ is even or odd, via the mutually recursive
functions
$
  "even"(0) & = "T", quad & "odd"(0) & = "F", \
  "even"(n) & = "odd"(n-1), quad & "odd"(n) & = "even"(n-1) quad "for " n >= 1
$

Examples:
- $"parity"(0) -> ("T", "F")$
- $"parity"(3) -> ("F", "T")$
- $"parity"(6) -> ("T", "F")$

*As mapcode:*

#mc-spec(
  state: [The two functions are folded into one table: for a fixed $n$, cell $i$ of $x$ holds
    the pair $("even"(i), "odd"(i))$ once it is defined and $bot$ before that.],
  I: $I = NN$,
  X: $X = X_n = [0..n] -> (BB times BB)_bot$,
  A: $A = BB times BB$,
  rho: $rho(n) = {i |-> bot | i in [0..n]}$,
  F: $F(x)_i = cases(("T", "F") & "if " i = 0, "swap"(x_(i-1)) & "if " i >= 1)$,
  pi: $pi = pi_n = x |-> x_n$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = ("even"(i), "odd"(i))$,
)
where $"swap"(e, o) = (o, e)$ is strict. Cell $i$ becomes defined one step after cell $i-1$
and never changes afterwards, so every non-fixed step defines a new cell and $sigma$ drops by
one; by the mutual recursion $"swap"$ maps the pair for $i-1$ to the pair for $i$, so $"Inv"$
is preserved, and at the fixed point ($sigma = 0$) $pi_n (x) = ("even"(n), "odd"(n))$.

#let parity-mc(n) = {
  let rho = n => range(n + 1).map(_ => none)
  let F_i = x => ((i,)) => {
    if i == 0 { (true, false) } else if x.at(i - 1) != none {
      let (e, o) = x.at(i - 1)
      (o, e)
    } else { none }
  }
  let F = map_tensor(F_i, dim: 1)
  let pi = x => x.at(n)
  let fmt-pair = v => if v == none { show-val(none) } else { [#show-val(v.at(0))#show-val(v.at(1))] }
  mapcode-viz(
    rho,
    F,
    pi,
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, fmt: fmt-pair, width: 2.3em, vertical: true),
    A_h: a => [(#show-val(a.at(0)), #show-val(a.at(1)))],
    pi_name: [$mpi_#n$],
    group-size: 4,
    spacing: (8mm, 10mm),
  )(n)
}

#let inst = 5
#figure(
  caption: [Parity via mapcode for $n = #inst$; each cell shows (even, odd).],
  parity-mc(inst),
)
