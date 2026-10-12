#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Binary Search
#set math.equation(numbering: none)

Search for a target value in a sorted array and return its index. If the target is not found,
return $-1$.

Formal definition: for a sorted array $a$ of length $n$, $"bs"(a, t) = "bs"(0, n-1)$ where
$
  "bs"(l, h) = cases(
    -1 & "if " l > h,
    m & "if " a[m] = t,
    "bs"(l, m-1) & "if " a[m] > t,
    "bs"(m+1, h) & "if " a[m] < t
  ) quad "where " m = floor((l + h) / 2)
$

Examples:
- $a = [1, 3, 5, 7, 9]$, $t = 5 -> 2$
- $a = [1, 3, 5, 7, 9]$, $t = 6 -> -1$

*As mapcode:*

_primitives_: comparison ($<$, $=$) and arithmetic ($+$, $-$, $floor(dot / 2)$) on integers.

#mc-spec(
  state: [The state $(l, h, r)$ holds the current search interval $[l, h]$ and the result slot
    $r$, which stays $bot$ until the search ends. The upper end $h$ can drop to $-1$ (and $l$ can
    reach $n$) when the target lies outside the array, so both live in $ZZ$.],
  I: $I = ZZ^n_"sorted" times ZZ$,
  X: $X = ZZ times ZZ times ({-1} union NN)_bot$,
  A: $A = {-1} union NN$,
  rho: $rho(a, t) = (0, n-1, bot)$,
  F: $F = F_(a,t) = (l, h, r) |-> cases(
    (l, h, r) & "if " r != bot,
    (l, h, -1) & "if " l > h,
    (l, h, m) & "if " a[m] = t,
    (l, m-1, bot) & "if " a[m] > t,
    (m+1, h, bot) & "otherwise"
  )$,
  pi: $pi(l, h, r) = r$,
  sigma: $sigma(l, h, r) = cases(|[l..h]| + 1 & "if " r = bot, 0 & "otherwise")$,
  theta: $theta(l, h, r) = cases("bs"(l, h) & "if " r = bot, r & "otherwise")$,
)
where $m = floor((l + h) / 2)$, the cases of $F$ are tried top to bottom,
$|[l..h]| = max(h - l + 1, 0)$ is the number of indices left, and $"bs"$ is the recursion of the formal definition for the fixed
$a$ and $t$. Each probe at least halves the interval, so $sigma$ drops strictly, and setting $r$
drops it from at least $1$ to $0$; $theta$ is $"bs"(0, n-1)$ initially, each case of $F$ is one
unfolding of $"bs"$ (so $theta$ is unchanged), and at the fixed point $r != bot$ gives
$theta = r = pi$. The fixed point is reached after at most $floor(log_2 n) + 2$ steps.

#pseudo[
  + $l <- 0$, $h <- n - 1$, $r <- bot$
  + *while* $r = bot$
    + *if* $l > h$ *then* $r <- -1$
    + *else* $m <- floor((l+h)/2)$
      + *if* $a[m] = t$ *then* $r <- m$
      + *else if* $a[m] > t$ *then* $h <- m - 1$
      + *else* $l <- m + 1$
  + *return* $r$
]

#let bs-mc(inst, group-size: 2) = {
  let (arr, target) = inst
  let n = arr.len()
  let rho = inst => (0, n - 1, none)
  let F_S = ((arr, target)) => ((l, h, r)) => {
    if r != none { (l, h, r) } else if l > h { (l, h, -1) } else {
      let m = calc.div-euclid(l + h, 2)
      if arr.at(m) == target { (l, h, m) } else if arr.at(m) > target { (l, m - 1, none) } else {
        (m + 1, h, none)
      }
    }
  }
  let pi = ((l, h, r)) => r
  let X_h = ((l, h, r), diff_mask: none) => {
    let ptrs = (l: l, h: h)
    if r == none and l <= h { ptrs.insert("m", calc.div-euclid(l + h, 2)) }
    let runs = if r != none and r >= 0 { ((r, r, c-done),) } else { () }
    stack(
      dir: ttb,
      spacing: 4pt,
      array-view(arr, pointers: ptrs, runs: runs, dim-outside: (l, h)),
      align(center, vec-view((l, h, r), diff_mask, labels: ([$l$], [$h$], [$r$]))),
    )
  }
  mapcode-viz(
    rho,
    F_S(inst),
    pi,
    I_h: ((arr, target)) => [$a = (#arr.map(str).join(", "))$ \ $t = #target$],
    X_h: X_h,
    A_h: a => [$#a$],
    F_name: [$F_(a,t)$],
    pi_name: [$mpi$],
    dim: 1,
    group-size: group-size,
    spacing: (8mm, 10mm),
    node-shape: rect,
  )(inst)
}

#let inst = ((2, 5, 8, 12, 16, 23, 38, 56), 38)
#figure(
  caption: [Binary search via mapcode for $a = (2, 5, 8, 12, 16, 23, 38, 56)$ and $t = 38$. Pointers show the
    interval $[l, h]$ and the probe $m$ for the next step; discarded cells are greyed.],
  bs-mc(inst),
)

#let inst2 = ((1, 3, 5, 7, 9), 0)
#figure(
  caption: [An unsuccessful search, $t = 0$: $h$ falls to $-1$, the interval becomes empty and
    $r = -1$.],
  bs-mc(inst2),
)
