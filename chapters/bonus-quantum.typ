#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *
#import "@preview/cetz:0.5.2"
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/quill:0.7.3" as quill

= Bonus: Quantum Algorithms as Mapcodes

Nothing in the mapcode model is specific to classical data. A quantum algorithm evolves a state
vector by unitary maps, step after step, and reads the answer off by a measurement at the end.
This is exactly a mapcode: $rho$ prepares the initial quantum state, $F$ is one round of the
circuit, and $pi$ is the measurement. As specified below, the mapcode is entirely deterministic:
$pi$ returns the exact _distribution_ of measurement outcomes. A real device returns one sample from
that distribution; that sampling is the only source of randomness. (Algorithms that measure part
way through, or restart until they succeed, need a more elaborate state; we keep to two clean
examples.)

In general gates are unitary maps on complex vectors $CC^(2^n)$. Both algorithms below happen to need
only real amplitudes, so here every state is a real unit vector and every gate a real orthogonal
map.

#let c-neg = rgb("#f97316") // negative amplitudes

// Signed amplitude bars around a zero line. The `marked` input is blue; other negative amplitudes
// are orange. `mean` draws the average amplitude as a dashed line; `labels` go under the bars.
#let amp-bars(amp, marked: none, unit: 1.15cm, bar: 0.26cm, gap: 1.5pt, label: none, labels: none, mean: none) = {
  let depth = calc.max(0.08, ..amp.map(a => -a)) * unit + 1pt
  let bars = amp
    .enumerate()
    .map(((x, a)) => {
      let h = calc.abs(a) * unit
      let col = if x == marked { c-accent.transparentize(15%) } else if a < 0 { c-neg.transparentize(15%) } else {
        luma(165)
      }
      let up = box(width: bar, height: unit, {
        align(bottom, box(width: bar, height: if a > 0 { h } else { 0pt }, fill: col))
        if mean != none and mean > 0 {
          place(bottom + left, dy: -mean * unit, line(length: bar + gap, stroke: (paint: black, thickness: 0.6pt, dash: "dashed")))
        }
      })
      let down = box(width: bar, height: depth, align(top, box(width: bar, height: if a < 0 { h } else { 0pt }, fill: col)))
      let parts = (up, line(length: bar, stroke: 0.4pt + luma(90)), down)
      if labels != none {
        parts.push(box(width: bar, align(center, text(size: 0.5em, fill: luma(90), labels.at(x)))))
      }
      stack(dir: ttb, ..parts)
    })
  stack(
    dir: ttb,
    spacing: 3pt,
    stack(dir: ltr, spacing: gap, ..bars),
    if label != none { align(center, text(size: 0.75em, fill: luma(90), label)) },
  )
}

// Probabilities: outlined bars of height p on a [0, 1] axis (visually distinct from amplitudes).
#let prob-bars(p, marked: none, unit: 1.15cm, bar: 0.26cm, gap: 1.5pt, label: none, labels: none) = {
  let axis = box(height: unit, width: 1.4em, {
    place(top + right, dx: -2pt, dy: -0.4em, text(size: 0.5em, fill: luma(90))[1])
    place(bottom + right, dx: -2pt, dy: 0.35em, text(size: 0.5em, fill: luma(90))[0])
    place(top + right, line(start: (0pt, 0pt), end: (0pt, unit), stroke: 0.5pt + luma(90)))
  })
  let bars = p
    .enumerate()
    .map(((x, q)) => {
      let col = if x == marked { c-accent } else { luma(110) }
      let parts = (
        box(width: bar, height: unit, align(bottom, box(width: bar, height: q * unit, stroke: 0.8pt + col, fill: col.transparentize(80%)))),
        line(length: bar, stroke: 0.4pt + luma(90)),
      )
      if labels != none {
        parts.push(box(width: bar, align(center, text(size: 0.5em, fill: luma(90), labels.at(x)))))
      }
      stack(dir: ttb, ..parts)
    })
  stack(
    dir: ttb,
    spacing: 3pt,
    stack(dir: ltr, spacing: gap, axis, ..bars),
    if label != none { align(center, text(size: 0.75em, fill: luma(90), label)) },
  )
}

== Grover's search

Given an oracle for a function $g : [0..N) -> {0, 1}$ with exactly one _marked_ input $w$
($g(w) = 1$), find $w$ @grover1996. Classically this needs $Theta(N)$ queries to $g$ in the worst
case. Grover's algorithm needs $O(sqrt(N))$ queries, and no quantum algorithm can do better
@bbbv1997; what is compared is the number of queries, not running time.

Write $|x chevron.r$ for the basis state of input $x$, $|s chevron.r = 1/sqrt(N) sum_x |x chevron.r$ for
the uniform superposition, and $|s' chevron.r$ for the normalised uniform superposition of the
unmarked inputs. For $N = 16$ and $w = 11$, every amplitude of $|s chevron.r$ is $1/4$, and
$|s' chevron.r$ has amplitude $1 / sqrt(15) approx 0.258$ on every $x != 11$ and $0$ on $11$.
Measuring $|s chevron.r$ gives a uniformly random $x$: the superposition does not "contain the answer".
The work is done by _interference_ of signed amplitudes. One _Grover iteration_ applies

- the *oracle* $O_g$, which flips the sign of the marked amplitude, $psi_w |-> -psi_w$. It is a
  circuit computing $g$; the usual form $|x, y chevron.r |-> |x, y xor g(x) chevron.r$ with the extra
  qubit $y$ in state $(|0 chevron.r - |1 chevron.r) / sqrt(2)$ acts exactly as this sign flip ("phase
  kickback"). The algorithm learns about $w$ _only_ through these queries;
- the *diffusion* $D = 2|s chevron.r chevron.l s| - 1$, an inversion about the mean:
  $psi_x |-> 2 macron(psi) - psi_x$ with $macron(psi) = 1/N sum_y psi_y$.

*Why the state stays in a plane.* Both maps are _reflections_: $O_g = 1 - 2|w chevron.r chevron.l w|$
reflects across the hyperplane orthogonal to $|w chevron.r$, which meets the plane
$"span"{|w chevron.r, |s' chevron.r}$ in the line through $|s' chevron.r$, and $D$ reflects across the line through
$|s chevron.r$. Both mirrors lie in that plane, so the state never leaves it, and the product of two
reflections is a rotation by twice the angle between the mirrors. That angle is $alpha$, with
$sin alpha = 1 / sqrt(N)$, so each iteration rotates the state by $2 alpha$ towards $|w chevron.r$.

*As mapcode:*

_primitives_: real arithmetic on amplitudes and the oracle $O_g$; no $bot$ is needed, since every
state is a fully defined vector. $S^(N-1)$ denotes the unit vectors of $RR^N$.

#mc-spec(
  state: [The state $(k, psi)$ holds the number $k$ of Grover iterations performed so far and the
    unit vector $psi$ of amplitudes; each step performs one iteration $D O_g$ until $K$ have been
    done.],
  I: $I = (N, g)$,
  X: $X = X_N = [0..K] times S^(N-1)$,
  A: $A = [0..N) -> [0, 1]$,
  rho: $rho(N, g) = (0, |s chevron.r)$,
  F: $F = F_(N,g) = (k, psi) |-> cases((k + 1, D O_g psi) & "if" k < K, (k, psi) & "if" k = K)$,
  pi: $pi(k, psi) = x |-> psi_x^2$,
  sigma: $sigma(k, psi) = K - k$,
  inv: $"Inv"(k, psi) <=> psi = sin((2k + 1) alpha) |w chevron.r + cos((2k + 1) alpha) |s' chevron.r$,
)
where $K = floor(pi / (4 alpha))$. Each step increases $k$, so $sigma$ drops by one until $k = K$. The
invariant holds initially because $|s chevron.r = sin alpha |w chevron.r + cos alpha |s' chevron.r$, and
$D O_g$ is the rotation by $2 alpha$, so it is preserved. It even determines $psi$ from $k$ alone: the
real state is a single angle, $(2k + 1) alpha$. At the fixed point the marked input is measured with
probability $sin^2((2K + 1) alpha) >= 1 - 1/N$. Indeed $pi/(4 alpha) - 1 < K <= pi/(4 alpha)$ gives
$(2K + 1) alpha in (pi/2 - alpha, pi/2 + alpha]$, so $sin^2((2K + 1) alpha) >= cos^2 alpha = 1 - 1/N$.

#let grover-parts(N, w) = {
  let al = calc.asin(1 / calc.sqrt(N))
  let K = calc.floor(calc.pi / (4 * al.rad()))
  let rho = ((N, g)) => (0, range(N).map(_ => 1 / calc.sqrt(N)))
  let oracle(amp) = amp.enumerate().map(((x, a)) => if x == w { -a } else { a })
  let diffuse(amp) = {
    let mean = amp.sum() / amp.len()
    amp.map(a => 2 * mean - a)
  }
  let F = ((k, amp)) => if k < K { (k + 1, diffuse(oracle(amp))) } else { (k, amp) }
  let proj = ((k, amp)) => amp.map(a => a * a)
  (al, K, rho, F, proj, oracle, diffuse)
}

#let grover-mc(N, w) = {
  let (al, K, rho, F, proj, ..) = grover-parts(N, w)
  let labels = range(N).map(str)
  mapcode-viz(
    rho,
    F,
    proj,
    I_h: ((N, g)) => [$N = #N$, $g$ marks $w = #w$],
    X_h: ((k, amp), diff_mask: none) => amp-bars(
      amp,
      marked: w,
      labels: labels,
      label: [$k = #k$, #h(0.3em) $(2k+1) alpha = #calc.round(((2 * k + 1) * al).deg(), digits: 1) degree$,
        #h(0.3em) $P(w) = #calc.round(amp.at(w) * amp.at(w), digits: 4)$],
    ),
    A_h: p => prob-bars(p, marked: w, labels: labels, label: [outcome distribution $pi$]),
    F_name: [$F_(#N,g)$],
    sigma: ((k, amp)) => K - k,
    dim: 0,
    group-size: 2,
    spacing: (10mm, 10mm),
  )((N, "g"))
}

#figure(
  caption: [Grover's search via mapcode for $N = 16$ with $g$ marking $w = 11$, so $K = 3$. Filled bars are
    amplitudes (marked input blue, negative ones orange); the outlined bars at the top right are
    probabilities. $P(w)$ runs through exactly $1/16$, $121/256$, $3721/4096$ and $63001/65536 approx
    0.9613$. At $k = 3$ the state has turned slightly past $|w chevron.r$ (to $101.4 degree$), so the
    unmarked amplitudes have become negative ($approx -0.051$).],
  grover-mc(16, 11),
)

The two halves of one iteration are easiest to see on the first step. The oracle flips the marked
bar below the axis; this lowers the mean amplitude slightly. The diffusion then reflects every bar
about the mean: bars just above the mean drop a little, while the marked bar, far below it, jumps
far above it.

#figure(
  caption: [One Grover iteration split into its two reflections ($N = 16$, $w = 11$, from $k = 0$ to
    $k = 1$). The dashed line is the mean amplitude $macron(psi) = 7/32$ of $O_g psi$, about which $D$
    reflects every bar: unmarked bars go from $1/4$ to $3/16$, and the marked bar from $-1/4$ to $11/16$.],
  {
    let (al, K, rho, F, proj, oracle, diffuse) = grover-parts(16, 11)
    let x0 = rho((16, "g")).at(1)
    let x1 = oracle(x0)
    let x2 = diffuse(x1)
    let m = x1.sum() / 16
    let labels = range(16).map(str)
    let arrow(name) = align(horizon, stack(dir: ttb, spacing: 2pt, text(size: 0.85em, name), sym.arrow.r.long))
    grid(
      columns: 5,
      column-gutter: 6pt,
      align: bottom,
      amp-bars(x0, marked: 11, unit: 1.3cm, bar: 0.21cm, gap: 1pt, labels: labels, label: [$psi = |s chevron.r$]),
      arrow($O_g$),
      amp-bars(x1, marked: 11, unit: 1.3cm, bar: 0.21cm, gap: 1pt, labels: labels, mean: m, label: [$O_g psi$, mean dashed]),
      arrow($D$),
      amp-bars(x2, marked: 11, unit: 1.3cm, bar: 0.21cm, gap: 1pt, labels: labels, label: [$D O_g psi$]),
    )
  },
)

#figure(
  caption: [The same run in the plane spanned by $|s' chevron.r$ and $|w chevron.r$. The first step is drawn
    as its two reflections: $O_g$ reflects $x_0$ (at angle $alpha$) across the $|s' chevron.r$ axis to $-alpha$
    (orange), and $D$ reflects that across the dashed mirror through $|s chevron.r$ to $3 alpha$. The later
    states (grey) follow by the same rotation by $2 alpha$; $x_3$ lies at $7 alpha approx 101.4 degree$, just
    past $|w chevron.r$.],
  {
    let (al, K, ..) = grover-parts(16, 11)
    cetz.canvas(length: 3.2cm, {
      import cetz.draw: *
      arc((1, 0), start: 0deg, stop: 110deg, radius: 1, stroke: 0.4pt + luma(190))
      line((-0.3, 0), (1.18, 0), mark: (end: "stealth"), stroke: 0.6pt + luma(90))
      line((0, -0.35), (0, 1.18), mark: (end: "stealth"), stroke: 0.6pt + luma(90))
      content((1.24, 0), $|s' chevron.r$, anchor: "west")
      content((0, 1.24), $|w chevron.r$, anchor: "south")
      // mirror of D: the line through |s>
      line(
        (-0.25 * calc.cos(al), -0.25 * calc.sin(al)),
        (1.25 * calc.cos(al), 1.25 * calc.sin(al)),
        stroke: (paint: luma(60), thickness: 0.6pt, dash: "dashed"),
      )
      content((1.27 * calc.cos(al), 1.27 * calc.sin(al) - 0.02), text(size: 0.7em, fill: luma(60))[mirror of $D$ (through $|s chevron.r$)], anchor: "north-west")
      // later states
      for k in range(2, K + 1) {
        let t = (2 * k + 1) * al
        line((0, 0), (calc.cos(t), calc.sin(t)), mark: (end: "stealth"), stroke: 0.5pt + luma(150))
        content((1.07 * calc.cos(t), 1.07 * calc.sin(t)), text(size: 0.75em, fill: luma(110))[$x_#k$], anchor: "south")
      }
      // first step: x0 -> O x0 -> D O x0 = x1
      let p0 = (calc.cos(al), calc.sin(al))
      let po = (calc.cos(al), -calc.sin(al))
      let p1 = (calc.cos(3 * al), calc.sin(3 * al))
      line((0, 0), p0, mark: (end: "stealth"), stroke: 0.9pt + black)
      content((0.62 * p0.at(0), 0.62 * p0.at(1) + 0.03), text(size: 0.75em)[$x_0$], anchor: "south")
      line((0, 0), po, mark: (end: "stealth"), stroke: 0.9pt + c-neg)
      content((po.at(0) + 0.04, po.at(1)), text(size: 0.75em, fill: c-neg)[$O_g x_0$], anchor: "west")
      line((0, 0), p1, mark: (end: "stealth"), stroke: 1pt + c-accent)
      content((1.07 * p1.at(0), 1.07 * p1.at(1)), text(size: 0.75em, fill: c-accent)[$x_1 = D O_g x_0$], anchor: "south-west")
      line(p0, po, stroke: (paint: c-neg, thickness: 0.4pt, dash: "dotted"))
      line(po, p1, stroke: (paint: c-accent, thickness: 0.4pt, dash: "dotted"))
      arc((0.28, 0), start: 0deg, stop: al, radius: 0.28, stroke: 0.4pt + luma(90))
      content((0.34 * calc.cos(al / 2), 0.34 * calc.sin(al / 2)), text(size: 0.7em)[$alpha$], anchor: "west")
    })
  },
)

The fixed number of iterations matters. Stopping later does not help: the state keeps rotating, and
the success probability falls again.

#figure(
  caption: [Success probability $P(w) = sin^2((2k + 1) alpha)$ after $k$ iterations, $N = 16$. It
    oscillates with period $pi / (2 alpha) approx 6.2$ iterations; the mapcode stops at its fixed point
    $k = K = 3$ (blue), the first peak.],
  {
    let (al, K, ..) = grover-parts(16, 11)
    let ks = range(13)
    let ps = ks.map(k => calc.pow(calc.sin((2 * k + 1) * al), 2))
    lq.diagram(
      width: 9cm,
      height: 4cm,
      xlabel: [iterations $k$],
      ylabel: [$P(w)$],
      ylim: (0, 1.05),
      lq.plot(ks, ps, mark-size: 4pt, color: luma(110)),
      lq.plot((K, K), (0, 1.05), mark: none, stroke: (paint: c-accent, dash: "dashed")),
      lq.scatter((K,), (ps.at(K),), color: c-accent, size: 8pt),
    )
  },
)

Amplitude amplification is this same mapcode with an arbitrary initial state in place of
$|s chevron.r$, and quantum walks iterate a walk unitary in place of $D O_g$.

== Bernstein–Vazirani: a circuit as a mapcode

Any quantum circuit is a mapcode: a circuit is a list of gates $G_1, dots, G_L$, and the state is
the quantum state together with a program counter. As an example, take a hidden string
$s in {0, 1}^n$ and the function $f(x) = s dot x mod 2$, given as the phase oracle
$U_f |x chevron.r = (-1)^(s dot x) |x chevron.r$ @bv1997. Classically, $n$ queries to $f$ are needed to
learn $s$ (one per bit); the Bernstein–Vazirani circuit needs a single query. Qubit $q_0$ is the top
wire and the leftmost (most significant) bit of $x$; $H_q$ is a Hadamard gate on qubit $q$.

#figure(
  caption: [The Bernstein–Vazirani circuit for $n = 3$, with the gates in the order the mapcode applies
    them: $G_1, dots, G_7 = H_0, H_1, H_2, U_f, H_0, H_1, H_2$. The dashed slices mark the program
    counter: $c$ gates have been applied at slice $c$. Measurement is not a gate; it is $pi$.],
  {
    let H = $H$
    quill.quantum-circuit(
      quill.lstick($q_0: |0 chevron.r$), H, 1, 1, quill.mqgate($U_f$, n: 3), H, 1, 1, quill.meter(), [\ ],
      quill.lstick($q_1: |0 chevron.r$), 1, H, 1, 1, 1, H, 1, quill.meter(), [\ ],
      quill.lstick($q_2: |0 chevron.r$), 1, 1, H, 1, 1, 1, H, quill.meter(),
      ..range(8).map(c => quill.slice(
        x: c + 1,
        y: 0,
        n: 3,
        stroke: (paint: c-accent, thickness: 0.6pt, dash: "dashed"),
        label: text(size: 0.7em, fill: c-accent)[$c = #c$],
      )),
    )
  },
)

*As mapcode:*

_primitives_: the gates $G_c$ (Hadamards and one query to $U_f$), each a real orthogonal map on
$RR^(2^n)$; $S^(2^n - 1)$ denotes the unit vectors.

#mc-spec(
  state: [The state $(c, psi)$ holds the number $c$ of gates applied so far and the unit vector
    $psi$ of amplitudes; each step applies the next gate $G_(c+1)$.],
  I: $I = (n, f)$,
  X: $X = X_L = [0..L] times S^(2^n - 1)$,
  A: $A = {0, 1}^n -> [0, 1]$,
  rho: $rho(n, f) = (0, |0 dots 0 chevron.r)$,
  F: $F = F_f = (c, psi) |-> cases((c + 1, G_(c+1) psi) & "if" c < L, (c, psi) & "if" c = L)$,
  pi: $pi(c, psi) = x |-> psi_x^2$,
  sigma: $sigma(c, psi) = L - c$,
  inv: $"Inv"(c, psi) <=> psi = phi.alt_0 (c) times.o phi.alt_1 (c) times.o dots.c times.o phi.alt_(n-1) (c)$,
)
where $L = 2n + 1$ and the state of qubit $q$ after $c$ gates is
$
  phi.alt_q (c) = cases(
    |0 chevron.r & "if" c <= q quad "(before its first" H")",
    |+ chevron.r & "if" q < c <= n quad "(after it, before the query)",
    H |s_q chevron.r & "if" n < c <= n + 1 + q quad "(after the query)",
    |s_q chevron.r & "if" c > n + 1 + q quad "(after its second" H")",
  )
$
with $|plus.minus chevron.r = (|0 chevron.r plus.minus |1 chevron.r) / sqrt(2)$, so $H |s_q chevron.r$ is
$|+ chevron.r$ if $s_q = 0$ and $|- chevron.r$ if $s_q = 1$. The bound function drops by one per gate. The
invariant holds initially, a Hadamard on qubit $q$ changes only $phi.alt_q$, and the query turns
$|+ chevron.r^(times.o n)$ into $times.o_q (|0 chevron.r + (-1)^(s_q) |1 chevron.r) / sqrt(2)$, because
$(-1)^(s dot x) = product_q (-1)^(s_q x_q)$. So _every state is a product state_: each qubit learns its
own bit of $s$ independently, there is no entanglement, and the advantage comes entirely from the
query model (one query to $U_f$ instead of $n$ to $f$). At the fixed point $psi = |s chevron.r$, so
$pi$ is the point mass at $s$. The invariant value $theta(c, psi)$ = "outcome distribution of running the
rest of the circuit" is also preserved, but it holds for every circuit; the product-state invariant is
what explains this one.

#let bv-parts(n, s) = {
  let N = calc.pow(2, n)
  let sv = s.clusters().fold(0, (acc, ch) => acc * 2 + int(ch))
  let gates = range(n).map(q => ("H", q)) + (("U", none),) + range(n).map(q => ("H", q))
  let L = gates.len()
  let parity(x) = calc.rem(range(n).filter(b => calc.rem(calc.quo(x.bit-and(sv), calc.pow(2, b)), 2) == 1).len(), 2)
  let apply((kind, q), v) = if kind == "U" {
    v.enumerate().map(((x, a)) => if parity(x) == 1 { -a } else { a })
  } else {
    let b = calc.pow(2, n - 1 - q)
    range(N).map(x => if x.bit-and(b) == 0 {
      (v.at(x) + v.at(x.bit-or(b))) / calc.sqrt(2)
    } else { (v.at(x.bit-xor(b)) - v.at(x)) / calc.sqrt(2) })
  }
  let rho = ((n, f)) => (0, range(N).map(x => if x == 0 { 1.0 } else { 0.0 }))
  let F = ((c, v)) => if c < L { (c + 1, apply(gates.at(c), v)) } else { (c, v) }
  let proj = ((c, v)) => v.map(a => a * a)
  let names = gates.map(((kind, q)) => if kind == "U" { $U_f$ } else { $H_#q$ })
  let bits(x) = range(n).map(i => str(calc.rem(calc.quo(x, calc.pow(2, n - 1 - i)), 2))).join()
  (N, sv, L, names, rho, F, proj, parity, bits)
}

#let bv-mc(n, s) = {
  let (N, sv, L, names, rho, F, proj, parity, bits) = bv-parts(n, s)
  let labels = range(N).map(x => raw(bits(x)))
  mapcode-viz(
    rho,
    F,
    proj,
    I_h: ((n, f)) => [$n = #n$, $f(x) = s dot x$ with $s = #raw(s)$],
    X_h: ((c, v), diff_mask: none) => amp-bars(
      v,
      unit: 0.9cm,
      bar: 0.42cm,
      gap: 2pt,
      labels: labels,
      label: [$c = #c$#if c < L [, next $#names.at(c)$]],
    ),
    A_h: p => prob-bars(p, marked: sv, unit: 0.9cm, bar: 0.42cm, gap: 2pt, labels: labels, label: [outcome distribution $pi$]),
    F_name: [$F_f$],
    sigma: ((c, v)) => L - c,
    dim: 0,
    group-size: 3,
    spacing: (8mm, 9mm),
  )((n, "f"))
}

#figure(
  caption: [Bernstein–Vazirani via mapcode for $n = 3$ and $s = 101$; $c$ is the slice of the circuit
    above. Filled bars are amplitudes (negative ones orange). Only the outcome distribution (outlined, top
    right) singles out $|101 chevron.r$: before the last three Hadamards no basis state is special. The
    first Hadamards spread the amplitude uniformly, the query flips the signs of the $x$ with $s dot x$
    odd, and the last Hadamards make the amplitudes interfere onto $|101 chevron.r$.],
  bv-mc(3, "101"),
)

The product-state invariant can be read off qubit by qubit:

#figure(
  caption: [The invariant $phi.alt_q (c)$ for $s = 101$: the state of each qubit after $c$ gates. Each qubit
    changes only at its own two Hadamards and at the query (highlighted); after the last gate the
    qubits read $1, 0, 1$.],
  {
    let (N, sv, L, names, rho, F, proj, parity, bits) = bv-parts(3, "101")
    let n = 3
    let sb = "101".clusters().map(int)
    let phi(q, c) = if c <= q { "0" } else if c <= n { "+" } else if c <= n + 1 + q { if sb.at(q) == 0 { "+" } else { "-" } } else { str(sb.at(q)) }
    let ket(t) = $|#t chevron.r$
    let cells = (label-cell([]),)
    for c in range(L + 1) { cells.push(label-cell([$c = #c$], fill: c-header, width: 3em)) }
    for q in range(n) {
      cells.push(label-cell([$q_#q$], fill: c-side))
      for c in range(L + 1) {
        let changed = c > 0 and phi(q, c) != phi(q, c - 1)
        cells.push(cell(ket(phi(q, c)), changed: changed, width: 3em))
      }
    }
    grid(columns: L + 2, gutter: 0pt, ..cells)
  },
)

Why do the last Hadamards produce exactly $|s chevron.r$? The state after the query is
$H^(times.o n) |s chevron.r = 2^(-n/2) sum_x (-1)^(s dot x) |x chevron.r$: its signs are row $s$ of the
matrix $((-1)^(x dot y))_(x,y)$. This matrix (scaled by $2^(-n/2)$) is $H^(times.o n)$ itself, the
Fourier transform over ${0, 1}^n$, and it is its own inverse, so one more application returns
$|s chevron.r$.

#figure(
  kind: image,
  caption: [The sign matrix $(-1)^(x dot y)$ of $H^(times.o 3)$ (up to the factor $2^(-3/2)$). Row $y = 101$
    (blue) is exactly the sign pattern of the state at $c = 4$ above; since $H^(times.o n)$ is its own
    inverse, applying it again maps that row back to $|101 chevron.r$.],
  {
    let (N, sv, L, names, rho, F, proj, parity, bits) = bv-parts(3, "101")
    let dot(x, y) = calc.rem(range(3).filter(b => calc.rem(calc.quo(x.bit-and(y), calc.pow(2, b)), 2) == 1).len(), 2)
    let cells = (label-cell([$y backslash x$]),)
    for x in range(N) { cells.push(label-cell(raw(bits(x)), fill: c-header)) }
    for y in range(N) {
      cells.push(label-cell(raw(bits(y)), fill: c-side))
      for x in range(N) {
        let neg = dot(x, y) == 1
        cells.push(cell(
          if neg { text(fill: c-neg, weight: "bold")[$-$] } else { [$+$] },
          fill: if y == sv { c-active } else { none },
          fmt: v => v,
        ))
      }
    }
    grid(columns: N + 1, gutter: 0pt, ..cells)
  },
)
