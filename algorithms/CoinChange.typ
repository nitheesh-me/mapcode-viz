#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Coin Change (dynamic programming, mapcode)

Compute the minimum number of coins needed to make a given amount using a given set of coin denominations. Each coin can be used multiple times.

Formal definition:
$
"MinCoins"(a) = cases(
  0 & "if " a = 0,
  1 + min_(c in "coins", c <= a) "MinCoins"(a - c) & "if " a > 0
)
$

*As mapcode:*

_primitives_: `min`, `add`($+$), `leq`($<=$)

$
I = a:NN times "coins":[NN]^k quad quad quad
X_a & = [0..a] -> NN union {infinity}_bot quad quad quad
A = NN union {infinity}\
rho(a, "coins") & = { i -> bot | i in {0 dots a}} \
F_("coins")(x_i) & = cases(
    0 & "if " i = 0,
    1 + min_(c in "coins", c <= i) x_(i - c) & "if " i > 0 "and all deps met",
    infinity & "if " i > 0 "and no coin works"
  )\
pi_a (x) & = x_a
$

#let inst_amount = 13;
#let inst_coins = (1, 4, 6);

#figure(
  caption: [Coin Change DP array for amount = #inst_amount, coins = #inst_coins.],
$#{
  let rho = ((inst_amount, inst_coins)) => {
    let x = ()
    for i in range(0, inst_amount + 1) {
      x.push(none)
    }
    x
  }

  let F_i = ((coins,)) => (x) => ((i,)) => {
    if i == 0 {
      0
    } else {
      // Check if all dependencies are met
      let all_deps_met = true
      for coin in coins {
        if i >= coin and x.at(i - coin) == none {
          all_deps_met = false
        }
      }

      if all_deps_met {
        // Compute minimum
        let min_val = calc.inf
        for coin in coins {
          if i >= coin {
            let dep_val = x.at(i - coin)
            if dep_val != calc.inf {
              min_val = calc.min(min_val, 1 + dep_val)
            }
          }
        }
        min_val
      } else {
        none
      }
    }
  }

  let F = ((coins,)) => map_tensor(F_i((coins,)), dim: 1)

  let pi = ((amount,)) => (x) => x.at(amount)

  let I_h((inst_amount, inst_coins)) = {
    [
      $a: #inst_amount$,
      $"coins": vec(..#inst_coins.map(c => [#c]), delim: "[")_(#inst_coins.len())$,
    ]
  }

  // visualization: 1D array as vertical table (index in left column, value in right column)
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()

    // Each row contains: [index, value]
    for i in range(0, x.len()) {
      let row = ()
      
      // Column 1: index (orange header)
      row.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#i$])
      
      // Column 2: value
      let val = if x.at(i) == none {
        [$bot$]
      } else if x.at(i) == calc.inf {
        [$infinity$]
      } else {
        [$#x.at(i)$]
      }
      
      if diff_mask != none and diff_mask.at(i) {
        row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[$#val$])
      } else {
        row.push(rect(stroke: gray, inset: 4pt)[$#val$])
      }
      
      rows.push(grid(columns: 2 * (20pt,), rows: 16pt, align: center + horizon, ..row))
    }

    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho, F((inst_coins,)), pi((inst_amount,)),
    I_h: I_h,
    X_h: x_h,
    F_name: [$F_("coins")$],
    pi_name: [$\pi_(#inst_amount)$],
    group-size: 5,
    cell-size: 30mm, scale-fig: 75%
  )((inst_amount, inst_coins))
}$)

