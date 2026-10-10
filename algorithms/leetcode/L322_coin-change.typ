#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *

== Leetcode:322. #link("https://leetcode.com/problems/coin-change/")[Coin Change]

You are given an integer array `coins` representing coins of different denominations and an integer amount representing a total `amount` of money.

Return the fewest number of coins that you need to make up that amount. If that amount of money cannot be made up by any combination of the coins, return $-1$.

You may assume that you have an infinite number of each kind of coin.
=== Recurrence Relation

$
"MinCoins"(n) = cases(
  0 & "if" n = 0,
  min_(c in "coins", c <= n) {1 + "MinCoins"(n - c)} & "if" n > 0,
  infinity & "if no solution exists"
)
$

*Example:* Coins = $[1, 2, 4]$, Amount = $13$ → Minimum: $4$ coins $(4+4+4+1)$

*Constraints:*
- $1 <= "coins"."length" <= 12$
- $1 <= "coins"[i] <= 2^{31} - 1$
- $0 <= "amount" <= 10^4$

=== Recursion Analysis

This exhibits non-trivial recursion through:
1. *Multiple recursive branches*: For amount $n$, we explore $|"coins"|$ different branches
2. *Overlapping subproblems*: Same subproblem $"MinCoins"(k)$ computed via multiple paths
3. *Variable branching factor*: Number of branches depends on valid coins for each amount
4. *Optimal substructure*: Optimal solution contains optimal solutions to subproblems

=== Mapcode Formalization

*Primitives:* $min$, $+$, $infinity$ | $bot$, $<=$

$
I &= ("amount": NN, "coins": NN^k) \
X &= [0.."amount"] -> NN union {bot} \
A &= NN union {-1} \
rho("amount", "coins") &= {i |-> bot | i in {0 dots "amount"}} \
F_("coins")(x)(n) &= cases(
  0 & "if" n = 0,
  min_(c in "coins", c <= n) {1 + x[n-c]} & "if" forall c: x[n-c] != bot,
  bot & "otherwise"
) \
pi(x) &= x["amount"] "if" x["amount"] != infinity "else" -1
$

=== Complexity Analysis
- *Time Complexity*: $O("amount" times k)$ where $k$ is number of coin types
- *Space Complexity*: $O("amount")$ for storing intermediate results

#let inst_coins = (1, 2, 4);
#let inst_amount = 13;

#figure(
  caption: [Coin Change computation for amount $#inst_amount$ with coins $#inst_coins$ using mapcode framework.],
  $#{
    let INF = 999999
    
    let rho = ((amount, coins)) => {
      let x = ()
      for i in range(0, amount + 1) {
        x.push(none)
      }
      x
    }

    let F_i = (coins) => (x) => ((n,)) => {
      if n == 0 {
        0
      } else {
        let min_coins = INF
        let all_available = true
        
        for c in coins {
          if c <= n {
            let prev = x.at(n - c)
            if prev == none {
              all_available = false
              break
            } else if prev != INF {
              min_coins = calc.min(min_coins, 1 + prev)
            }
          }
        }
        
        if all_available {
          min_coins
        } else {
          none
        }
      }
    }

    let F = (coins) => map_tensor(F_i(coins), dim: 1)

    let pi = (amount) => (x) => {
      x.at(amount)
    }

    let x_h(x, diff_mask: none) = {
      set text(size: 7pt)
      let rows = ()
      
      // Show in groups for readability
      let chunk_size = 7
      for chunk_start in range(0, x.len(), step: chunk_size) {
        let chunk_end = calc.min(chunk_start + chunk_size, x.len())
        let header = ()
        let values = ()
        
        for i in range(chunk_start, chunk_end) {
          header.push(rect(fill: blue.transparentize(85%), inset: 2pt, stroke: 0.4pt, width: 11pt)[#i])
          
          let val = x.at(i)
          let display = if val == none {
            $bot$
          } else if val >= INF {
            $infinity$
          } else {
            str(val)
          }
          
          let cell_fill = if diff_mask != none and diff_mask.at(i) {
            yellow.transparentize(60%)
          } else if val == 0 {
            green.transparentize(85%)
          } else {
            none
          }
          
          values.push(rect(stroke: 0.5pt + gray, fill: cell_fill, inset: 2pt, width: 12pt)[#display])
        }
        
        rows.push(grid(columns: (chunk_end - chunk_start) * (12pt,), rows: 12pt, align: center + horizon, column-gutter: 1pt, ..header))
        rows.push(grid(columns: (chunk_end - chunk_start) * (12pt,), rows: 12pt, align: center + horizon, column-gutter: 1pt, ..values))
        rows.push(v(4pt))
      }
      stack(dir: ttb, spacing: 0pt, ..rows)
    }

    let I_h = ((amount, coins)) => {
      stack(
        dir: ttb,
        spacing: 3pt,
        [*Target Amount:* $#amount$],
        [*Coins:* $#coins$]
      )
    }

    let A_h = (a) => {
      let display = if a == 999999 { "-1" } else { str(a) }
      box(fill: green.transparentize(70%), inset: 8pt, radius: 4pt)[
        *Minimum Coins:* $#display$
      ]
    }

    mapcode-viz(
      rho, F(inst_coins), pi(inst_amount),
      I_h: I_h,
      X_h: x_h,
      A_h: A_h,
      F_name: [$F_("coins")$],
      pi_name: [$mpi (#inst_amount)$],
      group-size: 3,
      cell-size: 10mm,
      scale-fig: 90%
    )((inst_amount, inst_coins))
  }$
)

=== Trace Analysis
At each amount $n$, we consider each coin $c$:
1. If $c <= n$, we look at subproblem $"MinCoins"(n - c)$
2. We add $1$ to the result of the subproblem to account for using coin $c$
3. We take the minimum over all valid coins to get $"MinCoins"(n)$

=== Correctness Verification

For amount $13$ with coins $[1, 2, 4]$:
- Optimal: $4$ coins = $4 + 4 + 4 + 1$
- Our result: $4$ which is correct
