#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

#show link: underline

== Add Two Numbers #link("https://leetcode.com/problems/add-two-numbers")[LeetCode P.2]
#set math.equation(numbering: none)

You are given two non-empty linked lists representing two non-negative integers. The digits are
stored in reverse order (least significant digit first), and each node holds a single digit. Add
the two numbers and return the sum as a linked list in the same format. Neither number has a
leading zero, except the number $0$ itself.

Formal definition, for digit lists $a = [a_0, dots, a_(m-1)]$ and $b = [b_0, dots, b_(n-1)]$ with
$L = max(m, n)$ and $a_k = 0$ for $k >= m$, $b_k = 0$ for $k >= n$:
$
  c_(-1) & = 0, \
  s_k & = a_k + b_k + c_(k-1), quad d_k = s_k mod 10, quad c_k = s_k "div" 10 quad "for " 0 <= k < L, \
  "add"(a, b) & = [d_0, dots, d_(L-1)] + ([1] "if " c_(L-1) = 1 "else" [])
$

Examples:
- $[2,4,3] + [5,6,4] -> [7,0,8]$, since $342 + 465 = 807$
- $[0] + [0] -> [0]$
- $[9,9,9,9,9,9,9] + [9,9,9,9] -> [8,9,9,9,0,0,0,1]$

Constraints: each list has $1$ to $100$ nodes, and every digit is in $[0..9]$.

*As mapcode:*

_primitives_: `add`($+$), `mod` and `div` by $10$ are strict, i.e. they return $bot$ if any argument is $bot$.

Cell $k$ of the state holds the pair (digit, carry-out) of column $k$.

$
  I = [0..9]^+ times [0..9]^+ quad quad X_(a,b) = [0..L) -> ([0..9] times {0, 1})_bot quad quad A = [0..9]^+ \
  rho(a, b) = {k -> bot | k in [0..L)} \
  F_(a,b) (x)_k = (s mod 10, s "div" 10) quad "where" s = a_k + b_k + cases(0 & "if " k = 0, c_(k-1) & "otherwise") quad "and" x_(k-1) = (d_(k-1), c_(k-1)) \
  pi(x) = [d_0, dots, d_(L-1)] + ([1] "if " c_(L-1) = 1 "else" [])
$

Column $k$ needs the carry of column $k-1$, so the carry ripples one column per step and the fixed
point is reached after $L$ steps.

#let add-two-mc(inst) = {
  let (l1, l2) = inst
  let L = calc.max(l1.len(), l2.len())
  let digit = (l, k) => l.at(k, default: 0)
  let rho = ((a, b)) => range(calc.max(a.len(), b.len())).map(_ => none)
  let F_k = ((a, b)) => x => ((k,)) => {
    let c = if k == 0 { 0 } else if x.at(k - 1) == none { none } else { x.at(k - 1).at(1) }
    if c == none { none } else {
      let s = digit(a, k) + digit(b, k) + c
      (calc.rem(s, 10), calc.div-euclid(s, 10))
    }
  }
  let F = I => map_tensor(F_k(I), dim: 1)
  let pi = x => {
    let ds = x.map(p => p.at(0))
    if x.at(-1).at(1) == 1 { ds + (1,) } else { ds }
  }
  let pad = l => range(L).map(k => if k < l.len() { l.at(k) } else { none })
  let shade = (i, j) => (i == 0 and j >= l1.len()) or (i == 1 and j >= l2.len())
  let rows = ($a$, $b$, [carry], [digit])
  let I_h = ((a, b)) => table-view((pad(a), pad(b)), none, row-labels: rows.slice(0, 2), shade: shade)
  let X_h = (x, diff_mask: none) => {
    let get = (k, i) => if x.at(k) == none { none } else { x.at(k).at(i) }
    table-view(
      (pad(l1), pad(l2), range(L).map(k => get(k, 1)), range(L).map(k => get(k, 0))),
      (
        range(L).map(_ => false),
        range(L).map(_ => false),
        range(L).map(k => mask-at(diff_mask, k, 1)),
        range(L).map(k => mask-at(diff_mask, k, 0)),
      ),
      row-labels: rows,
      col-labels: range(L).map(k => [#k]),
      corner: $k$,
      shade: shade,
      width: 2.4em,
    )
  }
  mapcode-viz(
    rho,
    F(inst),
    pi,
    I_h: I_h,
    X_h: X_h,
    A_h: a => vec-view(a, none),
    pi_name: [$mpi$],
    group-size: 3,
    spacing: (8mm, 10mm),
    node-shape: rect,
  )(inst)
}

#let inst = ((2, 4, 9), (5, 6, 4, 9))
#figure(
  caption: [Add Two Numbers via mapcode for $a = [2, 4, 9]$, $b = [5, 6, 4, 9]$, i.e. $942 + 9465 = 10407$.
    Grey cells are missing digits (read as $0$).],
  add-two-mc(inst),
)
#legend
