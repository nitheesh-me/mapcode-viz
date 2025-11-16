#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Longest Increasing Subsequence (LIS)
#set math.equation(numbering: none)

Compute the length of the longest increasing subsequence in an array.

Formal definition:
$
"LIS"(i) = cases(
  1 & "if" i = 0,
  1 + max_(j < i, A[j] < A[i]) "LIS"(j) & "if" i > 0 "and valid j exists",
  1 & "otherwise"
)
$

Example: A = [10, 9, 2, 5, 3, 7, 101]  
LIS length = 4 (subsequence: [2, 3, 7, 101] or [2, 5, 7, 101])

*As mapcode:*

_primitives_: `max` and `add`($+$) are strict. i.e max and add on $bot$ is undefined.

$ 
I = (n: NN, A: "array") quad quad quad X &= [0..n-1] -> NN_bot quad quad quad A = NN\
rho(n, A) &= {i -> 1 | i in [0..n-1]}\
F(x)[i] &= cases(
  1 & "if" i = 0,
  1 + max_(j < i, A[j] < A[i]) {x[j]} & "if valid j and deps defined",
  1 & "otherwise"
)\
pi(x) &= max_(i) x[i]
$

#let arr = (10, 9, 2, 5, 3, 7, 101);
#let n = arr.len();
#figure(
  caption: [LIS computation using mapcode for array = #arr],
$
#{
  let rho = (n) => {
    let x = ()
    for i in range(0, n) {
      x.push(1)
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    if i == 0 {
      1
    } else {
      let max_len = 1
      for j in range(0, i) {
        if arr.at(j) < arr.at(i) and x.at(j) != none {
          max_len = calc.max(max_len, x.at(j) + 1)
        }
      }
      max_len
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (n) => (x) => {
    let max_val = 0
    for val in x {
      if val != none {
        max_val = calc.max(max_val, val)
      }
    }
    max_val
  }

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      let arr_val = arr.at(i)
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[
          $#arr_val: #val$
        ]
      } else {
        rect(stroke: none, inset: 2pt)[
          $#arr_val: #val$
        ]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F, pi(n),
    X_h: X_h,
    pi_name: [$max_i x[i]$],
    group-size: calc.min(7, n),
    cell-size: 12mm, scale-fig: 80%
  )(n)
}
$
)
