#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Closest Pair of Points
#set math.equation(numbering: none)

Compute the minimum Euclidean distance between any two of $n >= 2$ points in the plane.

Formal definition (divide and conquer): let $P_x$ be the points sorted by $x$-coordinate and let
$f(i, j)$ be the minimum _squared_ distance between two points of the slice $P_x [i..j]$, $i < j$.
$
  f(i, j) = cases(
    min_(i <= p < q <= j) d^2(P_x [p], P_x [q]) & "if " j - i + 1 <= 3,
    min(f(i, k), f(k+1, j), delta^2_"strip") & "if " j - i + 1 > 3
  )
$
where $k = floor((i + j) / 2)$, $delta^2 = min(f(i, k), f(k+1, j))$ and $delta^2_"strip"$ is the
smallest squared distance between two points of $P_x [i..j]$ whose $x$-coordinates lie within
$delta$ of the split line $x = P_x [k].x$. The answer is $sqrt(f(0, n-1))$.

Example:
- $P = {(2, 3), (5, 1), (3, 4)} -> sqrt(2) approx 1.414$, between $(2, 3)$ and $(3, 4)$

*As mapcode:*

_primitives_: `min`, squared distance $d^2$ (strict), and `sqrt` in $pi$ only.

$
  I = "List"[ZZ^2] quad quad X_n = {(i, j) | 0 <= i < j < n} -> NN_bot quad quad A = RR \
  rho(P) = {(i, j) -> bot | 0 <= i < j < n} \
  F_(P_x)(x)_(i,j) = cases(
    min_(i <= p < q <= j) d^2(P_x [p], P_x [q]) & "if " j - i + 1 <= 3,
    min(x_(i,k), x_(k+1,j), delta^2_"strip") & "if " j - i + 1 > 3 and x_(i,k) != bot and x_(k+1,j) != bot,
    bot & "otherwise"
  ) \
  pi(x) = sqrt(x_(0, n-1))
$

The table stores squared distances, so $F$ stays in the integers; only $pi$ takes the square
root. Slices of length $<= 3$ are filled in the first step, and a slice of length $L$ one step
after its halves, so the fixed point is reached after about $log_2 (n \/ 3) + 2$ steps.

#let dist2 = (p, q) => (p.at(0) - q.at(0)) * (p.at(0) - q.at(0)) + (p.at(1) - q.at(1)) * (p.at(1) - q.at(1))

// (rho, F, pi) for a point list P; shared by the mapcode figure and the plot.
#let closest-parts(P) = {
  let Px = P.sorted(key: p => p.at(0))
  let n = P.len()
  let brute = pts => {
    let best = calc.inf
    for a in range(pts.len()) {
      for b in range(a + 1, pts.len()) { best = calc.min(best, dist2(pts.at(a), pts.at(b))) }
    }
    best
  }
  let strip-min = (pts, mid-x, d2) => {
    let strip = pts.filter(p => (p.at(0) - mid-x) * (p.at(0) - mid-x) < d2).sorted(key: p => p.at(1))
    let best = d2
    for a in range(strip.len()) {
      for b in range(a + 1, strip.len()) {
        let dy = strip.at(b).at(1) - strip.at(a).at(1)
        if dy * dy >= best { break }
        best = calc.min(best, dist2(strip.at(a), strip.at(b)))
      }
    }
    best
  }
  let rho = P => range(n).map(_ => range(n).map(_ => none))
  let F_S = Px => x => ((i, j)) => {
    if j <= i { return none }
    let slice = Px.slice(i, j + 1)
    if slice.len() <= 3 { return brute(slice) }
    let k = calc.div-euclid(i + j, 2)
    let (dl, dr) = (x.at(i).at(k), x.at(k + 1).at(j))
    if dl == none or dr == none { return none }
    let d2 = calc.min(dl, dr)
    calc.min(d2, strip-min(slice, Px.at(k).at(0), d2))
  }
  let F = map_tensor(F_S(Px), dim: 2)
  let pi = x => if n < 2 { calc.inf } else { calc.sqrt(x.at(0).at(n - 1)) }
  (rho, F, pi, Px)
}

#let closest-mc(P) = {
  let (rho, F, pi, Px) = closest-parts(P)
  let n = P.len()
  let pt(p) = [(#p.at(0),#p.at(1))]
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: P => block(width: 9em, align(center)[$P_x = $ #Px.map(pt).join(", ")]),
    X_h: (x, diff_mask: none) => table-view(
      x,
      diff_mask,
      row-labels: range(n).map(i => [$#i$]),
      col-labels: range(n).map(j => [$#j$]),
      corner: [$i \/ j$],
      shade: (i, j) => j <= i,
    ),
    A_h: a => [$sqrt(#[#int(calc.round(a * a))]) approx #calc.round(a, digits: 3)$],
    pi_name: [$mpi$],
    dim: 2,
    group-size: 2,
    spacing: (10mm, 8mm),
    node-shape: rect,
  )(P)
}

#let inst = ((9, 4), (3, 12), (13, 2), (6, 10), (2, 3), (11, 8), (4, 6), (7, 9))
#figure(
  caption: [Closest pair via mapcode for $n = 8$ points. Cell $(i, j)$ holds the minimum
    _squared_ distance in the slice $P_x [i..j]$; the answer is its square root at $(0, 7)$.],
  closest-mc(inst),
)
#legend

The split of the full set happens at $x = P_x [3].x$. The two halves have closest squared
distances $x_(0,3)$ and $x_(4,7)$; the overall closest pair straddles the split and is only found
in the strip of half-width $delta = sqrt(min(x_(0,3), x_(4,7)))$.

#figure(
  caption: [The instance: split line (solid), strip of half-width $delta$ around it (dashed), and
    the closest pair (red).],
  {
    let (rho, F, pi, Px) = closest-parts(inst)
    let n = inst.len()
    let x = limit-map(F)(rho(inst)) // fixed point of the same F
    let k = calc.div-euclid(n - 1, 2)
    let mid-x = Px.at(k).at(0)
    let delta = calc.sqrt(calc.min(x.at(0).at(k), x.at(k + 1).at(n - 1)))
    let best = x.at(0).at(n - 1)
    let pairs = ()
    for a in range(n) {
      for b in range(a + 1, n) { pairs.push((Px.at(a), Px.at(b))) }
    }
    let (p, q) = pairs.find(((p, q)) => dist2(p, q) == best)
    lq.diagram(
      width: 8cm,
      height: 5.5cm,
      xlabel: $x$,
      ylabel: $y$,
      lq.vlines(mid-x, stroke: 1pt + c-accent),
      lq.vlines(mid-x - delta, mid-x + delta, stroke: (paint: c-accent, dash: "dashed", thickness: 0.6pt)),
      lq.scatter(Px.map(p => p.at(0)), Px.map(p => p.at(1)), size: Px.map(_ => 80), color: luma(80)),
      lq.plot((p.at(0), q.at(0)), (p.at(1), q.at(1)), color: c-bad, stroke: 1.2pt + c-bad, mark-size: 6pt),
    )
  },
)
