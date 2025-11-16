#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *


== Leetcode::70. #link("https://leetcode.com/problems/climbing-stairs/")[Climbing Stairs]

You are climbing a staircase. It takes $n$ steps to reach the top.

Each time you can either climb $1$ or $2$ steps. In how many distinct ways can you climb to the top?

=== Recurrence Relation

$
"Ways"(n) = cases(
  1 & "if" n = 0,
  1 & "if" n = 1,
  "Ways"(n-1) + "Ways"(n-2) & "if" n > 1
)
$

*Example:* $n = 5$ → $8$ ways

*Constraints:*
- $1 <= n <= 45$



=== Recursion Analysis

This exhibits non-trivial recursion through:
1. *Two recursive calls*: Each step can be reached from previous two steps
2. *Fibonacci-like structure*: Classic combinatorial recursion
3. *Exponential without memoization*: Time complexity $O(2^n)$ naively, $O(n)$ with DP
4. *Counting problem*: Summing all possible paths

=== Mapcode Formalization

*Primitives:* $+$

$
I &= n: NN \
X &= [0..n] -> NN_bot \
A &= NN \
rho(n) &= {i |-> bot | i in {0 dots n}} \
F(x)(i) &= cases(
  1 & "if" i = 0 or i = 1,
  x[i-1] + x[i-2] & "if" x[i-1] != bot and x[i-2] != bot,
  bot & "otherwise"
) \
pi(x) &= x[n]
$

=== Complexity Analysis
- *Time Complexity*: $O(n)$ where $n$ is the number of steps
- *Space Complexity*: $O(n)$ for storing intermediate results

#pagebreak()

#let inst_stairs = 8;

#figure(
  caption: [Climbing Stairs computation for $n = #inst_stairs$ steps showing distinct ways.],
  $#{
    let rho = (n) => {
      let x = ()
      for i in range(0, n + 1) {
        x.push(none)
      }
      x
    }

    let F_i = (x) => ((i,)) => {
      if i == 0 or i == 1 {
        1
      } else {
        let way1 = x.at(i - 1)
        let way2 = x.at(i - 2)
        
        if way1 != none and way2 != none {
          way1 + way2
        } else {
          none
        }
      }
    }

    let F = map_tensor(F_i, dim: 1)

    let pi = (n) => (x) => {
      x.at(n)
    }

    let x_h(x, diff_mask: none) = {
      set text(size: 8pt)
      let rows = ()
      
      let header = ()
      let values = ()
      
      for i in range(0, x.len()) {
        header.push(rect(fill: blue.transparentize(85%), inset: 3pt, stroke: 0.5pt, width: 16pt)[*#i*])
        
        let val = x.at(i)
        let display = if val == none { $bot$ } else { str(val) }
        
        let cell_fill = if diff_mask != none and diff_mask.at(i) {
          yellow.transparentize(60%)
        } else if i <= 1 {
          green.transparentize(85%)
        } else {
          none
        }
        
        values.push(rect(stroke: 0.5pt + gray, fill: cell_fill, inset: 3pt, width: 16pt)[#display])
      }
      
      rows.push(grid(columns: x.len() * (16pt,), rows: 14pt, align: center + horizon, column-gutter: 1pt, ..header))
      rows.push(grid(columns: x.len() * (16pt,), rows: 14pt, align: center + horizon, column-gutter: 1pt, ..values))
      stack(dir: ttb, spacing: 2pt, ..rows)
    }

    let I_h = (n) => {
      box(inset: 5pt)[
        *Staircase:* $n = #n$ steps
      ]
    }

    let A_h = (a) => {
      box(fill: green.transparentize(70%), inset: 8pt, radius: 4pt)[
        *Distinct Ways:* $#a$
      ]
    }

    mapcode-viz(
      rho, F, pi(inst_stairs),
      I_h: I_h,
      X_h: x_h,
      A_h: A_h,
      F_name: [$F$],
      pi_name: [$mpi (#inst_stairs)$],
      group-size: 2,
      cell-size: 20mm,
      scale-fig: 90%
    )(inst_stairs)
  }$
)

=== Trace Analysis
At each step $i$, the number of ways to reach it is:
1. From step $i-1$ (taking 1 step)
2. From step $i-2$ (taking 2 steps)
Thus, total ways: = $"Ways"(i-1) + "Ways"(i-2)$

=== Correctness Verification

The sequence follows Fibonacci pattern starting from $1, 1$:
$
1, 1, 2, 3, 5, 8, 13, 21, 34, ...
$

For $n = 8$: $34$ ways which is correct.

This is because to reach step $n$, you can either:
- Come from step $n-1$ (taking 1 step)
- Come from step $n-2$ (taking 2 steps)
