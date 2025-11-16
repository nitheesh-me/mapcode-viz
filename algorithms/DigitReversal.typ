#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Digit Reversal

Compute the digit reversal of a non-negative integer $n$.
i.e $n in NN_0, n >= 0$

Formal definition:
$
f(n) = h(n, 0)
$
$
h(n, a) = cases(
  a & "if " n = 0,
  h(n " div " 10, a * 10 + n " mod " 10) & "otherwise"
)
$

Examples:
- $"rev"(123) -> 321$
- $"rev"(90) -> 9$

*As mapcode:*

_primitives_: `div`, `mod`, `+`, `*`

// Put all definitions in one math block.
// Use '&=' to align and '\' for newlines.
$
I & = (n: NN_0, d: NN) \
X_d & = [0..d] -> (NN_0 times NN_0)_bot \
A & = NN_0 \
rho(n, d) & = { i -> bot | i in [0..d] }
$

// Define F(x_i) in its own math block
$
F(x_i) = cases(
  (n, 0) & "if " i = 0,
  
  // Use line breaks (\\) to wrap long conditions
  (n_p " div " 10, a_p * 10 + n_p " mod " 10) & "if " i > 0 and n_p > 0 \\
  & and x_(i-1) != bot,
  
  (0, a_p) & "if " i > 0 and n_p = 0 \\
  & and x_(i-1) != bot,
  
  bot & "otherwise"
)
$
(where $(n_p, a_p) = x_(i-1)$)
$
pi(x) = x_d.2 quad // Accumulator of the last state
$

// --- Implementation ---

// The number to reverse
#let inst_n = 123;
// The number of steps (digits + 1 for the '0' state)
#let num_steps = 4;
// The instance (n, d), where d is the max index
#let inst = (inst_n, num_steps - 1);

#figure(
  caption: [Digit Reversal computation using mapcode for $n = #inst_n$],
$
#{
  // inst = (n, d)
  let (n_val, d_val) = inst;

  let rho = (inst) => {
    let (n, d) = inst;
    let x = ()
    for i in range(0, d + 1) {
      x.push(none) // `none` is bot
    }
    x
  }

  // F_i defines the logic for one element x[i]
  let F_i = (x) => ((i,)) => {
    if i == 0 {
      // Base case: (input_n, 0_accumulator)
      (n_val, 0) 
    } else {
      let prev_state = x.at(i - 1);
      if prev_state == none {
        none // Dependency not met
      } else {
        let (prev_n, prev_acc) = prev_state;
        if prev_n == 0 {
          // Fixed point reached, propagate this state
          (0, prev_acc) 
        } else {
          // Compute the next state
          let next_n = calc.floor(prev_n / 10);
          let next_acc = prev_acc * 10 + calc.rem(prev_n, 10);
          (next_n, next_acc)
        }
      }
    }
  }
  
  // Create the tensor-wide operator
  let F = map_tensor(F_i, dim: 1)

  // pi extracts the final answer
  let pi = (i) => (x) => {
     let (n, acc) = x.at(i);
     acc // Return the accumulator part of the last state
  }

  // X_h visualizes the state (an array of tuples)
  // --- THIS BLOCK IS NOW FIXED ---
  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {
        let (n, acc) = x_i;
        // Format the (n, acc) tuple
        [$n: #n, acc: #acc$] 
      } else {
        [$bot$]
      }
      
      if diff_mask != none and diff_mask.at(i) {
        // changed element: highlight (style from factorial.typ)
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        // (style from factorial.typ)
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    
    $vec(delim: "[", ..cells)$
  }
  // --- END OF FIX ---

  mapcode-viz(
    rho, F, pi(d_val),
    X_h: X_h,
    pi_name: [$mpi(#repr(inst_n))$],
    group-size: calc.min(7, d_val + 1),
    cell-size: 30mm, // Wider to fit the tuple
    scale-fig: 85%
  )(inst)
}
$
)