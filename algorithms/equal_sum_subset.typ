#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Partition Equal Subset Sum

Determine if an array can be partitioned into two subsets with equal sum.

Formal definition:
$
"dp"[i][s] = cases(
  "true" & "if " s = 0,
  "false" & "if " i = 0 and s > 0,
  "dp"[i-1][s] & "if " "nums"[i-1] > s,
  "dp"[i-1][s] or "dp"[i-1][s - "nums"[i-1]] & "otherwise"
)
$

Example:
- nums = [1, 2, 5, 2] → true (partitions: [1, 2, 2] and [5])
- nums = [1, 2, 5, 2] → false

*As mapcode:*

_primitives_: `or`($or$), `sum`, `div`($div$)

$ 
I = "nums":["NN"] quad quad quad
&"target" = sum("nums") div 2, n = |"nums"|\
X_("nums") &= [0..n] times [0.."target"] -> {"true", "false"}_bot quad quad quad
A = {"true", "false"}\
rho("nums") & = { (i,s) -> bot | i in {0 dots n}, s in {0 dots "target"}} \
F_("nums")(x_(i,s)) & = cases(
    "true" & "if " s = 0,
    "false" & "if " i = 0 and s > 0,
    x_(i-1,s) & "if " "nums"[i-1] > s,
    x_(i-1,s) or x_(i-1,s-"nums"[i-1]) & "otherwise"
  )\
pi_("nums") (x) & = x_(n,"target")
$

#let inst_nums = (1, 2, 5, 2);
#let total_sum = inst_nums.sum();
#let inst_target = 5;
#let n = inst_nums.len();

#figure(
  caption: [Partition Equal Subset Sum using mapcode for nums = $(#inst_nums.map(str).join(", "))$, target = $#inst_target$],
$#{
  if inst_target != -1 {
    let nums = inst_nums;     // <--- ADDED SEMICOLON
    let target = inst_target; // <--- ADDED SEMICOLON
    
    let rho = ((nums, target)) => {
      let x = ()
      for i in range(0, n + 1) {
        let row = ()
        for s in range(0, target + 1) {
          row.push(none)
        }
        x.push(row)
      }
      x
    }
    
    let F_i = ((nums)) => (x) => ((i, s)) => {
      // Base case: sum 0 is always achievable
      if s == 0 {
        true
      } else if i == 0 {
        // Base case: no items, sum > 0 is not achievable
        false
      } else {
        let num = nums.at(i - 1)
        
        // If current number is larger than target sum
        if num > s {
          // Can't include it, inherit from previous
          let prev = x.at(i - 1).at(s)
          if prev != none {
            prev
          } else {
            none
          }
        } else {
          // Can either include or exclude
          let exclude = x.at(i - 1).at(s)
          
          // Check bounds before accessing
          let include_val = none
          if s >= num and (s - num) >= 0 {
            include_val = x.at(i - 1).at(s - num)
          }
          
          if exclude != none and include_val != none {
            exclude or include_val
          } else {
            none
          }
        }
      }
    }
    
    let F = ((nums)) => map_tensor(F_i((nums)), dim: 2); // <--- ADDED SEMICOLON
    
    let pi = ((nums, target)) => (x) => {
      x.at(n).at(target)
    }
    
    // Visualization helper
    let x_h(x, diff_mask: none) = {
      set text(weight: "bold")
      let rows = ()
      
      // Header row
      let header_cells = ()
      header_cells.push(rect(fill: green.transparentize(70%), inset: 4pt)[$i$])
      header_cells.push(rect(fill: green.transparentize(70%), inset: 4pt)[$"num"$])
      
      for s in range(0, target + 1) {
        header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#s$])
      }
      rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))
      
      // Data rows
      for i in range(0, n + 1) {
        let row = ()
        
        // Row label
        if i == 0 {
          row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$0$])
          row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$emptyset$])
        } else {
          row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#i$])
          row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#nums.at(i - 1)$])
        }
        
        // DP values
        for s in range(0, target + 1) {
          let val = x.at(i).at(s)
          let display_val = if val == none {
            text(fill: purple)[$bot$]
          } else if val == true {
            text(fill: green.darken(20%))[T]
          } else {
            text(fill: red.darken(20%))[F]
          }
          
          let fill_color = if diff_mask != none and diff_mask.at(i).at(s) {
            yellow.transparentize(70%)
          } else {
            white
          }
          
          row.push(rect(stroke: gray, fill: fill_color, inset: 4pt)[$#display_val$])
        }
        
        rows.push(grid(columns: row.len() * (14pt,), rows: 14pt, align: center + horizon, ..row))
      }
      
      grid(align: center, ..rows)
    }
    
    mapcode-viz(
      rho, F((nums)), pi((nums, target)),
      X_h: x_h,
      F_name: [$F_("nums")$],
      pi_name: [$pi_("nums")$],
      group-size: calc.min(3, n + 1),
      cell-size: 60mm, scale-fig: 75%
    )((nums, target))
  } else {
    [Cannot partition: total sum is odd.]
  }
}
$
)

*Result:* The final value at $"dp"[#n][#inst_target]$ is `true`, meaning the array $#inst_nums$ can be partitioned into two equal-sum subsets: [1, 2, 2] and [5].