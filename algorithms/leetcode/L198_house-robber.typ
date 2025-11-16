#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *


== Leetcode:198. #link("https://leetcode.com/problems/house-robber/")[House Robber]

You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed, the only constraint stopping you from robbing each of them is that adjacent houses have security systems connected and it will automatically contact the police if two adjacent houses were broken into on the same night.

Given an integer array `nums` representing the amount of money of each house, return the maximum amount of money you can rob tonight without alerting the police.

=== Recurrence Relation

$
"MaxRob"(i) = cases(
  0 & "if" i < 0,
  "money"[0] & "if" i = 0,
  max("MaxRob"(i-1), "money"[i] + "MaxRob"(i-2)) & "if" i > 0
)
$

*Example:* Houses = $[2, 7, 9, 3, 1]$ → Maximum: $12$ (rob houses $0, 2, 4$: $2+9+1$)

*Constraints:*
- $1 <= "nums"."length" <= 100$
- $0 <= "nums"[i] <= 400$

=== Recursion Analysis

This exhibits non-trivial recursion through:
1. *Two recursive branches*: Each decision depends on previous two states
2. *Optimization problem*: Finding maximum over multiple possibilities
3. *State dependency*: Current optimal depends on solutions to smaller subproblems
4. *Linear DP with choice*: Classic example of decision-making in dynamic programming

=== Mapcode Formalization

*Primitives:* $max$, $+$

$
I &= "houses": NN^n \
X &= [0..n-1] -> NN_bot \
A &= NN \
rho("houses") &= {i |-> bot | i in {0 dots n-1}} \
F_("houses")(x)(i) &= cases(
  "houses"[0] & "if" i = 0,
  max(x[i-1], "houses"[i] + (x[i-2] "if" i >= 2 "else" 0)) & "if" x[i-1] != bot and (i < 2 or x[i-2] != bot),
  bot & "otherwise"
) \
pi(x) &= x[n-1]
$

=== Complexity Analysis

- *Time Complexity*: $O(n)$ where $n$ is the number of houses
- *Space Complexity*: $O(n)$ for storing intermediate results

#let inst_houses = (2, 7, 9, 3, 1);

#figure(
  caption: [House Robber computation for houses $#inst_houses$ showing maximum robbery amount.],
  $#{
    let rho = (houses) => {
      let n = houses.len()
      let x = ()
      for i in range(0, n) {
        x.push(none)
      }
      x
    }

    let F_i = (houses) => (x) => ((i,)) => {
      let n = houses.len()
      
      if i == 0 {
        houses.at(0)
      } else {
        let skip = x.at(i - 1)
        let take_prev2 = if i >= 2 { x.at(i - 2) } else { 0 }
        
        if skip == none or (i >= 2 and take_prev2 == none) {
          none
        } else {
          let take = houses.at(i) + (if take_prev2 == none { 0 } else { take_prev2 })
          calc.max(skip, take)
        }
      }
    }

    let F = (houses) => map_tensor(F_i(houses), dim: 1)

    let pi = (houses) => (x) => {
      x.at(houses.len() - 1)
    }

    let x_h(x, diff_mask: none) = {
      set text(size: 9pt)
      let rows = ()
      
      let header = ()
      let values = ()
      
      for i in range(0, x.len()) {
        header.push(rect(fill: blue.transparentize(85%), inset: 4pt, stroke: 0.5pt)[*House #i*])
        
        let val = x.at(i)
        let display = if val == none { $bot$ } else { str(val) }
        
        let cell_fill = if diff_mask != none and diff_mask.at(i) {
          yellow.transparentize(60%)
        } else {
          none
        }
        
        values.push(rect(stroke: 0.5pt + gray, fill: cell_fill, inset: 4pt)[#display])
      }
      
      rows.push(grid(columns: x.len() * (auto,), rows: auto, align: center + horizon, column-gutter: 2pt, ..header))
      rows.push(grid(columns: x.len() * (auto,), rows: auto, align: center + horizon, column-gutter: 2pt, ..values))
      stack(dir: ttb, spacing: 2pt, ..rows)
    }

    let I_h = (houses) => {
      let house_display = houses.enumerate().map(((i, m)) => [House #i: $#m$])
      stack(
        dir: ttb,
        spacing: 2pt,
        [*Houses with money:*],
        ..house_display
      )
    }

    let A_h = (a) => {
      box(fill: green.transparentize(70%), inset: 8pt, radius: 4pt)[
        *Maximum Amount:* $#a$
      ]
    }

    mapcode-viz(
      rho, F(inst_houses), pi(inst_houses),
      I_h: I_h,
      X_h: x_h,
      A_h: A_h,
      F_name: [$F_("houses")$],
      pi_name: [$mpi (#(inst_houses.len() - 1))$],
      group-size: 1,
      cell-size: 10mm,
      scale-fig: 90%
    )(inst_houses)
  }$
)

=== Trace Analysis

At each house $i$, we decide:
1. *Skip house $i$*: Take maximum from previous house: $x[i-1]$
2. *Rob house $i$*: Add current money to maximum from $i-2$: $"houses"[i] + x[i-2]$
3. *Choose maximum*: $max("skip", "rob")$

For $[2, 7, 9, 3, 1]$:
- House 0: Rob = $2$
- House 1: Max(2, 7) = $7$
- House 2: Max(7, 9+2) = $11$
- House 3: Max(11, 3+7) = $11$
- House 4: Max(11, 1+11) = $12$ which is maximum and correct
