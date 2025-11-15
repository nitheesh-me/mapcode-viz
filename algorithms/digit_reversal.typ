#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Digit Reversal
#set math.equation(numbering: none)

Reverse the digits of a non-negative integer $N in NN_0$ using accumulator-based recursion.

Formal definition using helper function $R(n, a)$ where $n$ is the remaining number and $a$ is the accumulator:

Main function:
$
"reverse"(N) = R(N, 0)
$

Recursive helper:
$
R(n, a) = cases(
  a & "if " n = 0,
  R(floor(n/10), (a times 10) + (n mod 10)) & "if " n > 0
)
$

Examples:
- $"reverse"(123) -> 321$
- $"reverse"(5040) -> 405$

*As mapcode:*

_primitives_: `floor-divide`($div$) and `modulo`($mod$) are strict. i.e operations on $bot$ are undefined.

$ I = (n_"in", a_"in") : NN times NN quad quad quad X &= (NN times NN) -> NN_bot quad quad quad A = NN\
rho(n_"in", a_"in") & = {(n, a) -> bot | n, a in NN}\
F(m)(n, a) & = cases(
  a & "if " n = 0,
  m[floor(n/10), (a times 10) + (n mod 10)] & "if " n > 0 "and" m[...] != bot,
  bot & "otherwise"
 )\
 pi(n_"in", a_"in")(m) & = m[n_"in", a_"in"]
$

#let number = 123;
#figure(
  caption: [Digit reversal computation using mapcode for $"reverse"(#number)$],
$
#{
  // Generate the chain of (n, a) pairs
  let generate_chain = (num) => {
    let chain = ((num, 0),)
    let n = num
    let a = 0
    while n > 0 {
      let digit = calc.rem(n, 10)
      n = calc.floor(n / 10)
      a = a * 10 + digit
      chain.push((n, a))
    }
    chain
  }

  let chain = generate_chain(number)
  let len = chain.len()

  let rho = (inst) => {
    let x = ()
    for i in range(0, len) {
      x.push(none)
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    let (n, a) = chain.at(i)
    if n == 0 {
      a
    } else if i < len - 1 and x.at(i + 1) != none {
      x.at(i + 1)
    } else {
      none
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (i) => (x) => x.at(i)

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let (n, a) = chain.at(i)
      let key_str = $((#n, #a))$
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      let entry = $#key_str -> #val$
      
      if diff_mask != none and diff_mask.at(i) {
        // changed element: highlight
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#entry$]
      } else {
        rect(stroke: none, inset: 2pt)[$#entry$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F, pi(0),
    X_h: X_h,
    I_h: (inst) => {
      $((#number, 0))$
    },
    pi_name: [$pi((#number, 0))$],
    group-size: calc.min(7, len),
    cell-size: 20mm, scale-fig: 80%
  )(number)
}
$
)