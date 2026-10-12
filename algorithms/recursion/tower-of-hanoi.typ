#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Tower of Hanoi
#set math.equation(numbering: none)

Move a tower of $n$ discs from a source peg $s$ to a destination peg $d$, using the third peg
$a$ as auxiliary, one disc at a time and never placing a larger disc on a smaller one. Output the
shortest sequence of moves.

Formal definition: writing $p q$ for "move the top disc of peg $p$ to peg $q$" and $plus.double$ for list
concatenation,
$
  "hanoi"(0, s, d, a) & = [] \
  "hanoi"(k, s, d, a) & = "hanoi"(k-1, s, a, d) plus.double [s d] plus.double "hanoi"(k-1, a, d, s) quad "for " k >= 1
$
The list has $T_k = 2 T_(k-1) + 1 = 2^k - 1$ moves.

Examples:
- $"hanoi"(1, A, C, B) -> [A C]$
- $"hanoi"(2, A, C, B) -> [A B, A C, B C]$
- $"hanoi"(3, A, C, B)$ has $7$ moves

*As mapcode:*

_primitives_: list concatenation $plus.double$ and peg relabelling $tau_(p q)$ (swap the peg names
$p$ and $q$ in every move of a list); both are strict, e.g. $bot plus.double ell = ell plus.double bot = bot$.

A tower of $k-1$ discs moved from $s$ to $a$ is the same move list as one moved from $s$ to $d$
with the names $d$ and $a$ swapped. So the instance pegs $(s, d, a)$ can stay fixed and the state
needs only a single list per disc count.

#mc-spec(
  state: [The state $x$ is a table indexed by the disc count $k in [0..n]$; cell $x_k$ holds the
    move list $"hanoi"(k, s, d, a)$ for the fixed pegs, or $bot$ while it is not yet computed.],
  I: $I = NN times "Perm"{A, B, C}$,
  X: $X = X_n = [0..n] -> "Move"^*_bot$,
  A: $A = "Move"^*$,
  rho: $rho(n, s, d, a) = {k |-> bot | k in [0..n]}$,
  F: $F = F_(s,d,a), quad F_(s,d,a)(x)_k = cases(
    [] & "if " k = 0,
    "lift"(x_(k-1)) & "if " k >= 1
  )$,
  pi: $pi = pi_(n, s, d, a) = x |-> x_n$,
  sigma: $sigma(x) = |{k | x_k = bot}|$,
  inv: $"Inv"(x) <=> forall k . x_k != bot => x_k = "hanoi"(k, s, d, a)$,
)
where $"lift"(ell) = tau_(d a)(ell) plus.double [s d] plus.double tau_(s a)(ell)$. By strictness
$F(x)_k = bot$ while $x_(k-1) = bot$, and once $x_(k-1) = "hanoi"(k-1, s, d, a)$ the
relabelled copies are exactly the two recursive calls, so a defined cell always equals
$"hanoi"(k, s, d, a)$ and never changes again; hence $"Inv"$ is preserved and every step that
changes the state defines at least one new cell, decreasing $sigma$. Cell $k$ becomes defined one
step after cell $k-1$, so the fixed point is reached after $n + 1$ steps with every cell defined,
and $pi$ returns $x_n = "hanoi"(n, s, d, a)$ with $2^n - 1$ moves.

#let pegs = "ABC"

// (rho, F, pi) for an instance (n, "sda"); shared by the mapcode figure and the replay.
#let hanoi-parts(inst) = {
  let (n, sda) = inst
  let (s, d, a) = sda.clusters()
  // swap the peg names p and q in every move
  let swap(p, q) = ms => ms.map(m => m.clusters().map(c => if c == p { q } else if c == q { p } else { c }).join())
  let rho = ((n, sda)) => range(n + 1).map(_ => none)
  let F_S = ((s, d, a)) => x => ((k,)) => {
    if k == 0 { () } else if x.at(k - 1) == none { none } else {
      swap(d, a)(x.at(k - 1)) + (s + d,) + swap(s, a)(x.at(k - 1))
    }
  }
  let F = map_tensor(F_S((s, d, a)), dim: 1)
  let pi = x => x.at(n)
  (rho, F, pi)
}

#let show-moves(ms) = if ms == none { botc } else if ms.len() == 0 { $[thin]$ } else {
  text(size: 0.85em, ms.map(raw).join(h(0.3em)))
}
// fixed-width cell content, so `vec-view(width: auto)` keeps narrow index labels
#let move-cell(ms) = box(width: 8em, align(center, show-moves(ms)))

#let hanoi-mc(inst) = {
  let (n, sda) = inst
  let (rho, F, pi) = hanoi-parts(inst)
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((n, sda)) => [$n = #n$ \ $(s, d, a) = (#sda.clusters().join(", "))$],
    X_h: (x, diff_mask: none) => vec-view(x, diff_mask, vertical: true, fmt: move-cell, width: auto),
    A_h: show-moves,
    F_name: [$F_(#sda.clusters().join(", "))$],
    pi_name: [$mpi_(#n, #sda.clusters().join(", "))$],
    dim: 1,
    group-size: 3,
    spacing: (8mm, 8mm),
    node-shape: rect,
  )(inst)
}

#let inst = (3, "ACB")
#figure(
  caption: [Tower of Hanoi via mapcode for $n = 3$ discs from $A$ to $C$ via $B$. Cell $k$ is the
    move list for $k$ discs; $p q$ moves the top disc of peg $p$ to peg $q$.],
  hanoi-mc(inst),
)

The answer $x_3$ can be replayed on the pegs. Each snapshot shows the pegs after one move; the
disc that has just been moved is highlighted.

#let hanoi-replay(n, moves) = {
  let state = (range(n, 0, step: -1), (), ())
  let snaps = ((state, none, [start]),)
  for (i, mv) in moves.enumerate() {
    let (p, q) = mv.clusters().map(c => pegs.position(c))
    let disc = state.at(p).last()
    state.at(p) = state.at(p).slice(0, -1)
    state.at(q).push(disc)
    snaps.push((state, q, [#(i + 1): #raw(mv)]))
  }
  grid(
    columns: 4,
    column-gutter: 6mm,
    row-gutter: 4mm,
    ..snaps.map(((st, q, lab)) => stack(
      dir: ttb,
      spacing: 2mm,
      pegs-view(st, n, moved: q, unit: 0.13, height: 0.2),
      align(center, text(size: 0.8em, lab)),
    )),
  )
}

#figure(
  kind: image,
  caption: [Replay of the $7$ moves in the answer $x_3$, computed by the same $rho$, $F$, $pi$.],
  {
    let (rho, F, pi) = hanoi-parts(inst)
    hanoi-replay(inst.at(0), mapcode(rho, F, pi)(inst))
  },
)
