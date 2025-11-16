#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Greatest Common Divisor (GCD)
#set math.equation(numbering: none)

Computes the greatest common divisor of two non-negative integers using the Euclidean algorithm.

Formal definition:
$
"gcd"(a, b) &= cases(
  a & "if " b = 0,
  "gcd"(b, a mod b) & "otherwise"
)
$

Examples:
- $`gcd`(48, 18) -> 6$
- $`gcd`(101, 103) -> 1$

*As mapcode:*

_primitives_: `mod` (modulo operator)

$
I = ("a", "b"): NN times NN \
X = "Map"(("a","b") -> NN_bot) \
A = NN\\
rho("a", "b") & = { ("x","y") -> bot | ("x","y") " is a pair in the GCD chain"}\
F(x) & = cases(
  "a" & "if " "b" = 0,
  x_("b", "a" " mod " "b") & "otherwise"
)\
pi(x) & = "last computed value"
$

#let inst_a = 48;
#let inst_b = 18;

#figure(
  caption: [GCD computation using mapcode for $`gcd`(#inst_a, #inst_b)$],
$
#{
  let get_pairs = (a_start, b_start) => {
    let pairs = ()
    let a = a_start
    let b = b_start
    while true {
      pairs.push((a, b))
      if b == 0 {
        break
      }
      let temp = b
      b = calc.rem(a, b)
      a = temp
    }
    pairs
  }

  let pairs = get_pairs(inst_a, inst_b)
  let num_steps = pairs.len()

  let rho = (inst) => {
    let x = ()
    for i in range(0, num_steps) {
      x.push(none)
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    if i == num_steps - 1 {
      // Base case: gcd(a, 0) = a
      let (a, b) = pairs.at(i)
      a
    } else if x.at(i + 1) != none {
      x.at(i + 1)
    } else {
      none
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (x) => x.at(0)

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let (a, b) = pairs.at(i)
      let val = if x_i != none {[#x_i]} else {[$bot$]}
      let cell_content = [$"gcd"(#a, #b) -> #val$]
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[#cell_content]
      } else {
        rect(stroke: none, inset: 2pt)[#cell_content]
      }
    })
    $vec(delim: "{", ..cells)$
  }

  mapcode-viz(
    rho, F, pi,
    I_h: ((a,b)) => [$"gcd"(#a, #b)$],
    X_h: X_h,
    pi_name: [$pi$],
    group-size: 2,
    cell-size: 40mm,
    scale-fig: 95%
  )((inst_a, inst_b))
}
$
)
