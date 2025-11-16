#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Longest Increasing Subsequence (LIS)
#set math.equation(numbering: none)

Compute the length of the longest increasing subsequence (LIS) of a vector of integers.

Formal definition:
$
I = "nums" in "vec"[ZZ] \
X_n = [0..n-1] -> NN_bot " where " n = |"nums"| \
A = NN
$

$
rho("nums") = { i -> bot | i in [0..n-1] } \
\
F(x)_i = 1 + max( {0} union { x_j | j in [0..i-1] " and " "nums"_i > "nums"_j } ) \
\
pi(x) = max( {0} union { x_i | i in [0..n-1] } )
$
(The $F$ function is strict: if any $x_j$ it depends on is $bot$, $F(x)_i$ remains $bot$.)

*As mapcode:*

#let inst = (10, 9, 2, 5, 3, 7, 101, 18);
#figure(
  caption: [LIS computation using mapcode for $n = #inst$],
$
#{
  let rho = (inst) => {
    // x_0 = [bot, bot, ..., bot]
    let x = ()
    for i in range(0, inst.len()) {
      x.push(none)
    }
    x
  }

  // F_i_gen creates the function for a single element F(x)_i
  // It needs the `inst` (nums) to compare values.
  let F_i_gen = (inst) => (x) => ((i,)) => {
    let max_len = 0
    let all_deps_met = true
    
    // Loop j from 0 to i-1
    for j in range(0, i) {
      if inst.at(i) > inst.at(j) {
        // This is a potential predecessor
        if x.at(j) == none {
          // Dependency not met, this cell remains bot
          all_deps_met = false
          break
        } else if x.at(j) > max_len {
          max_len = x.at(j)
        }
      }
    }
    
    if all_deps_met {
      1 + max_len
    } else {
      none
    }
  }

  // F_gen creates the parallel map F(x)
  let F = (inst) => map_tensor(F_i_gen(inst), dim: 1)

  // pi finds the maximum value in the final dp array
  let pi = (inst) => (x) => {
    if x.len() == 0 {
      0
    } else {
      let max_val = 0
      for i in range(0, x.len()) {
        if x.at(i) != none and x.at(i) > max_val {
          max_val = x.at(i)
        }
      }
      max_val
    }
  }

  // X_h is the helper to visualize the state vector x
  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        // changed element: highlight
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
    pi_name: [$mpi$],
    group-size: calc.min(8, inst.len()),
    cell-size: 8mm,
    scale-fig: 75%
  )(inst)
}
$
)