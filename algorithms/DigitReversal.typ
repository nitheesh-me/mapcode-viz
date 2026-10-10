#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Digit Reversal

Reverse the digits of a non-negative integer $n$ using tail-recursive computation. This algorithm demonstrates efficient fixed-point computation with a 2-element state pair $(n_p, a_p)$ representing remaining digits and accumulator.

Formal definition:
$
"reverse"(n) = cases(
  0 & "if " n = 0,
  10 dot "reverse"(n div 10) + (n mod 10) & "otherwise"
)
$

Examples:
- $"reverse"(123) = 321$
- $"reverse"(1000) = 1$
- $"reverse"(12345) = 54321$

*As mapcode (2-state pair):*

$ I = n : NN quad X = NN times NN quad A = NN $

$ rho(n) = (n, 0) $

$ F((n_p, a_p)) = cases(
  (n_p div 10, a_p dot 10 + n_p mod 10) & "if " n_p > 0,
  (0, a_p) & "if " n_p = 0
) $

$ pi((n_p, a_p)) = a_p $

#let inst = 123;
#figure(
  caption: [Digit reversal using mapcode for reverse(#inst) = 321],
$
#{
  let rho = (inst) => {
    (inst, 0)
  }

  let F = (x) => {
    let (n_p, a_p) = x
    if n_p == 0 {
      (0, a_p)
    } else {
      let n_i = int(n_p / 10)
      let a_i = a_p * 10 + int(n_p) - n_i * 10
      (n_i, a_i)
    }
  }

  let pi = (x) => {
    x.at(1)
  }

  let X_h = (x, diff_mask: none) => {
    let (n_p, a_p) = x
    let n_box = if diff_mask != none and diff_mask.at(0) {
      rect(fill: yellow.transparentize(70%), inset: 1pt)[$ #n_p $]
    } else {
      rect(stroke: none, inset: 1pt)[$ #n_p $]
    }
    let a_box = if diff_mask != none and diff_mask.at(1) {
      rect(fill: yellow.transparentize(70%), inset: 1pt)[$ #a_p $]
    } else {
      rect(stroke: none, inset: 1pt)[$ #a_p $]
    }
    $lr((#n_box, #a_box))$
  }

  // Build history
  let x0 = rho(inst)
  let xs = (x0,)
  let xn = x0
  let prev = none
  let iters = 0
  while prev != xn and iters < 10 {
    prev = xn
    xn = F(xn)
    if xn != xs.at(-1) {
      xs.push(xn)
    }
    iters += 1
  }
  let ans = pi(xn)

  // Compute diffs
  let get_diff = (a, b) => {
    let (n_a, a_a) = a
    let (n_b, a_b) = b
    (n_a != n_b, a_a != a_b)
  }
  
  let diffs = xs.windows(2).map(((prev, next)) => {
    get_diff(prev, next)
  })
  diffs.insert(0, (false, false))

  // Format trace
  let trace_items = xs.enumerate().map(((idx, x_i)) => {
    let label = if idx == 0 { $rho$ } else { $F$ }
    let state = X_h(x_i, diff_mask: diffs.at(idx))
    $(#label): #state$
  })

  box(inset: 5pt)[
    Trace:
    #h(1em)
    #trace_items.join([ $arrow.r$ ])
    #h(1em)
    $pi = #ans$
  ]
}
$
)
