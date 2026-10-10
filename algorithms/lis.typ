#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Longest Increasing Subsequence (LIS)
#set math.equation(numbering: none)

Compute the length of the LIS for a sequence $A$.
Formal definition:
$
L(i) = 1 + max(\{L(j) | j < i, A[j] < A[i]\} union \{0\})
$

Example:
- $A = [10, 9, 2, 5, 3, 7, 101, 18]$
- LIS Length: 4 (e.g., $[2, 3, 7, 18]$)

*As mapcode:*

_primitives_: `sum`($+$), `max`

$ I = A:NN^* quad quad quad X = NN -> NN_bot quad quad quad A = NN\
rho(A) & = {i -> bot | i in {0 dots |A|-1}}\
F(A)(x) & = cases(
  1 & "if no valid " j < i,
  max{x[j] + 1 | j < i and A[j] < A[i]} & "if deps satisfied",
  bot & "otherwise"
 )\
 pi(A)(x) & = max(x)
$

#let inst = (10, 9, 2, 5, 3, 7, 101, 18);
#figure(
  caption: [LIS computation using mapcode for $A = #inst$],
$
#{
  let rho = (inst) => {
    let x = ()
    for i in range(0, inst.len()) {
      x.push(none)
    }
    x
  }

  // F depends on the instance A
  let F_i = (A) => (x) => ((i,)) => {
    let max_lis = 1
    let possible = true
    
    for j in range(0, i) {
        if A.at(j) < A.at(i) {
            if x.at(j) == none {
                possible = false
                break
            }
            max_lis = calc.max(max_lis, x.at(j) + 1)
        }
    }

    if possible { max_lis } else { none }
  }
  // We bind the instance A to F
  let F = (A) => map_tensor(F_i(A), dim: 1)

  let pi = (A) => (x) => {
    let m = 0
    for val in x {
        if val != none { m = calc.max(m, val) }
    }
    m
  }

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F(inst), pi(inst),
    X_h: X_h,
    pi_name: [$mpi (A)$],
    group-size: calc.min(8, inst.len()),
    cell-size: 10mm, scale-fig: 85%
  )(inst)
}
$
)