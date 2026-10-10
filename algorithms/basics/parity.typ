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

The two functions are folded into one table whose cell $i$ holds the pair
$("even"(i), "odd"(i))$; the swap is strict.

$
  I = NN quad quad X_n = [0..n] -> (BB times BB)_bot quad quad A = BB times BB \
  rho(n) = {i -> bot | i in [0..n]} \
  F(x)_i = cases(
    ("T", "F") & "if " i = 0,
    (o, e) "where" (e, o) = x_(i-1) & "if " i >= 1
  ) \
  pi_n (x) = x_n
$

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
