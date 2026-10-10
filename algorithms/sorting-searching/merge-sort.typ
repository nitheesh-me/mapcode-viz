#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Mergesort
#set math.equation(numbering: none)

Sort an array of integers with bottom-up mergesort: start from sorted runs of length 1 and
repeatedly merge adjacent runs, doubling the run length each round.

Formal definition: given $a = [a_0, ..., a_(n-1)]$, produce a permutation $a'$ of $a$ with
$
  a'_i <= a'_j quad "for all " i < j.
$

Examples:
- $"mergesort"([5, 2, 8, 1]) -> [1, 2, 5, 8]$
- $"mergesort"([9, 3, 7, 5, 6]) -> [3, 5, 6, 7, 9]$
- $"mergesort"([]) -> []$

*As mapcode:*

_primitives_: `merge`, which combines two sorted sequences into one sorted sequence.
$"merge_pairs"(a, s)$ merges the runs $a[2k s .. (2k+1)s)$ and $a[(2k+1)s .. (2k+2)s)$ for every
$k$ (a trailing run without a partner is copied unchanged).

The state is the current run width $s$ together with the array, in which every block
$a[k s .. (k+1)s)$ is sorted.

$
  I = "Seq"[ZZ] quad quad X = NN times "Seq"[ZZ] quad quad A = "Seq"[ZZ] \
  rho(a) = (1, a) \
  F_n (s, a) = cases(
    (s, a) & "if " s >= n,
    (2s, "merge_pairs"(a, s)) & "if " s < n
  ) quad "where " n = |a| \
  pi(s, a) = a
$

Each step doubles $s$, so $F$ reaches its fixed point after $ceil(log_2 n)$ steps (immediately
for $n <= 1$, including the empty array). The invariant "every block of width $s$ is sorted"
holds in every state; at the fixed point $s >= n$, so the whole array is one sorted block.

#pseudo[
  + $s <- 1$
  + *while* $s < n$
    + *for* $k = 0, 2s, 4s, ...$ *while* $k < n$
      + $a[k .. k+2s) <- "merge"(a[k .. k+s), a[k+s .. k+2s))$
    + $s <- 2s$
  + *return* $a$
]

#let merge-mc(inst) = {
  // Merge two sorted sequences.
  let merge = (xs, ys) => {
    let out = ()
    let (p, q) = (0, 0)
    while p < xs.len() and q < ys.len() {
      if xs.at(p) <= ys.at(q) {
        out.push(xs.at(p))
        p += 1
      } else {
        out.push(ys.at(q))
        q += 1
      }
    }
    out + xs.slice(p) + ys.slice(q)
  }
  // Merge adjacent runs of width s.
  let merge-pairs = (a, s) => {
    let n = a.len()
    let out = ()
    for k in range(0, n, step: 2 * s) {
      let mid = calc.min(k + s, n)
      let end = calc.min(k + 2 * s, n)
      out += merge(a.slice(k, mid), a.slice(mid, end))
    }
    out
  }
  let n = inst.len()
  let rho = a => (1, a)
  let F_S = n => ((s, a)) => if s >= n { (s, a) } else { (2 * s, merge-pairs(a, s)) }
  let pi = ((s, a)) => a
  let X_h = ((s, a), diff_mask: none) => {
    let runs = range(0, a.len(), step: s)
      .enumerate()
      .map(((k, lo)) => (lo, calc.min(lo + s, a.len()) - 1, if calc.even(k) { c-done } else { c-active }))
    stack(
      dir: ttb,
      spacing: 4pt,
      align(center, box(baseline: 30%, text(size: 0.85em)[$s =$]) + cell(s, changed: mask-at(diff_mask, 0))),
      // run strip above the array: keeps the runs visible where the change highlight covers their colour
      grid(columns: calc.max(a.len(), 1), ..runs
          .map(((lo, hi, col)) => range(lo, hi + 1).map(i => box(
            width: 1.9em,
            height: 4pt,
            inset: (left: if i == lo { 1pt } else { 0pt }, right: if i == hi { 1pt } else { 0pt }),
            box(width: 100%, height: 100%, fill: col.opacify(30%)),
          )))
          .flatten()),
      array-view(a, mask: if type(diff_mask) == array { diff_mask.at(1) } else { diff_mask }, runs: runs),
    )
  }
  mapcode-viz(
    rho,
    F_S(n),
    pi,
    I_h: a => [$a = (#a.map(str).join(", "))$],
    X_h: X_h,
    A_h: a => [$(#a.map(str).join(", "))$],
    pi_name: [$mpi$],
    dim: 2,
    group-size: 2,
    spacing: (10mm, 8mm),
    node-shape: rect,
  )(inst)
}

#let inst = (5, 2, 8, 1, 6, 3, 7)
#figure(
  caption: [Bottom-up mergesort via mapcode for $a = (5, 2, 8, 1, 6, 3, 7)$. Alternating colours
    mark the sorted runs of width $s$; highlighted cells changed in the last merge round.],
  merge-mc(inst),
)
#legend

*Analysis:* $ceil(log_2 n)$ steps of $F$, each doing $O(n)$ work in `merge_pairs`, for
$O(n log n)$ time in total.
