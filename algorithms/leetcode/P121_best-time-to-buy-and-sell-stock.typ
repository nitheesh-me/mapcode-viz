#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *

#show link: underline

== Best Time to Buy and Sell Stock #link("https://leetcode.com/problems/best-time-to-buy-and-sell-stock")[LeetCode P.121]

You are given an array `prices` where `prices[i]` is the price of a given stock on the `i`-th day.

You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.

Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return `0`.

_Example 1_:
/ Input: $"prices" = [7,1,5,3,6,4]$
/ Output: $5$
/ Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.

_Example 2_:
/ Input: $"prices" = [7,6,4,3,1]$
/ Output: $0$
/ Explanation: In this case, no transactions are done and the max profit = 0.

Constraints:
- $1 <= |"prices"| <= 10^5$
- $0 <= "prices"[i] <= 10^4$

*Mapcode Formalization:*

_primitives_: `max`(max), `subtract`($-$)

The recursion represents choices at each day: skip the day, or buy/sell depending on state.

#set text(size: 9.5pt)
$
n = |"prices"| quad "prices" in NN^n\
I : "prices" in NN^n\
X_("prices") & : [0..n] times {"bought", "not_bought"} -> NN_bot\
A & : NN "maximum profit"\
\
rho("prices") & = { (i, b) -> bot | i in {0 dots n}, b in {"bought", "not_bought"}}\
$
#set text(size: 8.5pt)
$
F_("prices") (x_(i,b)) & = cases(
    0 & "if " i = n,
    max(x_(i+1,"bought"), "prices"_i) & "if " b = "bought" and x_(i+1,"bought") != bot,
    max(x_(i+1,"not_bought"), x_(i+1,"bought") - "prices"_i) & "if " b = "not_bought" "and" x_(i+1,"bought") != bot "and" x_(i+1,"not_bought") != bot,
    bot & "otherwise"
  )\
$
#set text(size: 9.5pt)
$
pi_("prices") (x) & = x_(0,"not_bought")
$

The recursion fills the table backwards from day $n$ to day $0$:
- At the end (day $n$), profit is 0
- If already bought: either skip this day or sell at current price
- If not bought: either skip this day or buy at current price (subtracts from future profit)

#let inst_prices = (7, 1, 5, 3, 6, 4);
#let inst_n = inst_prices.len();

#figure(
  caption: [Best Time to Buy and Sell Stock using \ mapcode for $"prices" = #inst_prices$; state table showing \ maximum profit achievable from each day in each state.],
  gap: 3em,
$#{
  // Input visualization: display the input array
  let I_h = (prices) => {
    text(repr(prices))
  }

  // Output visualization: display the final profit
  let A_h = (profit) => {
    text(str(profit))
  }

  let rho = (prices) => {
    let n = prices.len()
    let x = ()
    // States: (day, bought_status)
    // We need n+1 days (0 to n)
    // The 'bought' state represents the maximum possible selling price from this day forward.
    for i in range(0, n + 1) {
      x.push((none, none))  // (bought, not_bought)
    }
    x
  }

    let F_i = (prices) => (x) => ((i,)) => {
    let n = prices.len()
    let (bought, not_bought) = x.at(i)
    
    if i == n {
      // Base case: at end, profit is 0
      (0, 0)
    } else if i < n {
      let (next_bought, next_not_bought) = x.at(i + 1)
      
      let new_bought = none
      let new_not_bought = none
      
      // If already bought: can sell at current price or skip
      if next_bought != none {
        let skip = next_bought
        let sell = prices.at(i)  // Selling gives us the price directly
        new_bought = calc.max(skip, sell)
      }
      
      // If not bought: can buy at current price (subtracting cost) or skip
      if next_bought != none and next_not_bought != none {
        let skip = next_not_bought
        let buy = next_bought - prices.at(i)  // Buying: future profit minus cost
        new_not_bought = calc.max(skip, buy)
      }
      
      (new_bought, new_not_bought)
    } else {
      (bought, not_bought)
    }
  }
  
  let F = (prices) => map_tensor(F_i(prices), dim: 1)

  let pi = (prices) => (x) => {
    // Start from day 0, not bought state
    let (_, not_bought) = x.at(0)
    not_bought
  }

  // Visualization helper
  let x_h(x, diff_mask: none) = {
    set text(weight: "bold", size: 8pt)
    let n = x.len()
    let rows = ()
    
    // Header
    let header = ()
    header.push(rect(fill: purple.transparentize(70%), inset: 5pt, stroke: gray)[Day])
    header.push(rect(fill: orange.transparentize(70%), inset: 5pt, stroke: gray)[Price])
    header.push(rect(fill: teal.transparentize(70%), inset: 5pt, stroke: gray)[Bought])
    header.push(rect(fill: green.transparentize(70%), inset: 5pt, stroke: gray)[Not Bought])
    rows.push(grid(columns: (35pt, 35pt, 45pt, 55pt), rows: 20pt, align: center + horizon, ..header))
    
    for i in range(0, n) {
      let row = ()
      let (bought, not_bought) = x.at(i)
      
      // Day number
      row.push(rect(fill: purple.transparentize(80%), inset: 5pt, stroke: gray)[$#i$])
      
      // Price (if not at end)
      if i < inst_prices.len() {
        row.push(rect(inset: 5pt, stroke: gray)[$#inst_prices.at(i)$])
      } else {
        row.push(rect(inset: 5pt, stroke: gray)[$-$])
      }
      
      // Bought state
      let bought_val = if bought != none {[$#bought$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i).at(0) {
        row.push(rect(stroke: gray, fill: yellow.transparentize(50%), inset: 5pt)[$#bought_val$])
      } else {
        row.push(rect(stroke: gray, inset: 5pt)[$#bought_val$])
      }
      
      // Not bought state
      let not_bought_val = if not_bought != none {[$#not_bought$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i).at(1) {
        row.push(rect(stroke: gray, fill: yellow.transparentize(50%), inset: 5pt)[$#not_bought_val$])
      } else {
        row.push(rect(stroke: gray, inset: 5pt)[$#not_bought_val$])
      }
      
      rows.push(grid(columns: (35pt, 35pt, 45pt, 55pt), rows: 20pt, align: center + horizon, ..row))
    }
    
    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho, F(inst_prices), pi(inst_prices),
    I_h: I_h,
    X_h: x_h,
    A_h: A_h,
    pi_name: [$mpi$],
    group-size: 2,
    cell-size: 90mm, 
    scale-fig: 60%
  )(inst_prices)
}$)

#pagebreak()

=== Additional Test Cases

#let test_cases = ((7, 6, 4, 3, 1), (2, 4, 1), (3, 3, 5, 0, 0, 3, 1, 4))

#for test_prices in test_cases [
  #let test_n = test_prices.len()
  #figure(
    caption: [Best Time to Buy/Sell Stock for \ $"prices" = #test_prices$],
    gap: 4.5em,
  $#{
    let I_h = (prices) => {
      text(repr(prices))
    }

    let A_h = (profit) => {
      text(str(profit))
    }

    let rho = (prices) => {
      let n = prices.len()
      let x = ()
      // The 'bought' state represents the maximum possible selling price from this day forward.
      for i in range(0, n + 1) {
        x.push((none, none))
      }
      x
    }

    let F_i = (prices) => (x) => ((i,)) => {
      let n = prices.len()
      let (bought, not_bought) = x.at(i)
      
      if i == n {
        (0, 0)
      } else if i < n {
        let (next_bought, next_not_bought) = x.at(i + 1)
        
        let new_bought = none
        let new_not_bought = none
        
        if next_bought != none {
          let skip = next_bought
          let sell = prices.at(i)
          new_bought = calc.max(skip, sell)
        }
        
        if next_bought != none and next_not_bought != none {
          let skip = next_not_bought
          let buy = next_bought - prices.at(i)
          new_not_bought = calc.max(skip, buy)
        }
        
        (new_bought, new_not_bought)
      } else {
        (bought, not_bought)
      }
    }
    
    let F = (prices) => map_tensor(F_i(prices), dim: 1)

    let pi = (prices) => (x) => {
      let (_, not_bought) = x.at(0)
      not_bought
    }

    let x_h(x, diff_mask: none) = {
      set text(weight: "bold", size: 8pt)
      let n = x.len()
      let rows = ()
      
      let header = ()
      header.push(rect(fill: purple.transparentize(70%), inset: 5pt, stroke: gray)[Day])
      header.push(rect(fill: orange.transparentize(70%), inset: 5pt, stroke: gray)[Price])
      header.push(rect(fill: teal.transparentize(70%), inset: 5pt, stroke: gray)[Bought])
      header.push(rect(fill: green.transparentize(70%), inset: 5pt, stroke: gray)[Not Bought])
      rows.push(grid(columns: (35pt, 35pt, 45pt, 55pt), rows: 20pt, align: center + horizon, ..header))
      
      for i in range(0, n) {
        let row = ()
        let (bought, not_bought) = x.at(i)
        
        row.push(rect(fill: purple.transparentize(80%), inset: 5pt, stroke: gray)[$#i$])
        
        if i < test_prices.len() {
          row.push(rect(inset: 5pt, stroke: gray)[$#test_prices.at(i)$])
        } else {
          row.push(rect(inset: 5pt, stroke: gray)[$-$])
        }
        
        let bought_val = if bought != none {[$#bought$]} else {[$bot$]}
        if diff_mask != none and diff_mask.at(i).at(0) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(50%), inset: 5pt)[$#bought_val$])
        } else {
          row.push(rect(stroke: gray, inset: 5pt)[$#bought_val$])
        }
        
        let not_bought_val = if not_bought != none {[$#not_bought$]} else {[$bot$]}
        if diff_mask != none and diff_mask.at(i).at(1) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(50%), inset: 5pt)[$#not_bought_val$])
        } else {
          row.push(rect(stroke: gray, inset: 5pt)[$#not_bought_val$])
        }
        
        rows.push(grid(columns: (35pt, 35pt, 45pt, 55pt), rows: 20pt, align: center + horizon, ..row))
      }
      
      grid(align: center, ..rows)
    }

    mapcode-viz(
      rho, F(test_prices), pi(test_prices),
      I_h: I_h,
      X_h: x_h,
      A_h: A_h,
      pi_name: [$mpi$],
      group-size: 2,
      cell-size: 80mm, 
      scale-fig: 55%
    )(test_prices)
  }$)
]