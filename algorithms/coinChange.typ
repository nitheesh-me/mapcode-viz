#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Coin Change

#set math.equation(numbering: none)

Given coins of denominations $c_1, c_2, ..., c_k$ and target amount $n$, find the minimum number of coins needed to make that amount.

Recursive definition:
$
"coinChange"(n, C) = cases(
  0 & "if " n = 0,
  infinity & "if " n < 0,
  min_(c in C) (1 + "coinChange"(n - c, C)) & "otherwise"
)
$

*As map code:*
$
I & = NN times "Set"[NN] \
X_(n,C) & = {0..n} -> NN_bot \
A & = NN union {infinity} \
rho(n,C) & = { i -> bot | i in {0..n} } \
F(x_i) & = cases(
    0 & "if " i = 0,
    min{1 + x_(i-c) | c in C, i >= c, x_(i-c) != bot} & "if " i > 0 "and" exists c in C : x_(i-c) != bot,
    infinity & "otherwise"
  ) \
pi_(n,C) (x) & = x_n
$

#let inst_amount = 11;
#let inst_coins = (1, 3, 4);

#figure(
  caption: [Coin exchange for amount $#inst_amount$ with coins $#inst_coins$],
$#{
  let rho = ((amount, coins)) => {
    let state = (:)
    for i in range(0, amount + 1) {
      state.insert(str(i), none)
    }
    state
  }
  
  let F_i = (x, coins) => (state_key) => {
    let val = x.at(state_key)
    if val != none { return val }
    
    let amount = int(state_key)
    
    if amount == 0 {
      return 0
    }
    
    let min_coins = none
    for coin in coins {
      if amount >= coin {
        let sub_key = str(amount - coin)
        let sub_val = x.at(sub_key, default: none)
        if sub_val != none {
          let curr = 1 + sub_val
          if min_coins == none or curr < min_coins {
            min_coins = curr
          }
        }
      }
    }
    
    return min_coins
  }
  
  let F = (x, coins) => {
    let x_new = (:)
    for (key, val) in x {
      x_new.insert(key, F_i(x, coins)(key))
    }
    x_new
  }
  
  let pi = ((amount, coins)) => (x) => {
    x.at(str(amount), default: none)
  }
  
  let x_h(x, diff_mask:none) = {
    set text(size: 8pt)
    let rows = ()
    let sorted_keys = x.keys().sorted(key: k => int(k))
    for key in sorted_keys {
      let val = x.at(key)
      let display = if val == none {
        bot
      } else {
        str(val)
      }
      let is_changed = if diff_mask != none and type(diff_mask) == dictionary {
        diff_mask.at(key, default: false)
      } else {
        false
      }
      
      if is_changed {
        rows.push(rect(fill: yellow.transparentize(70%), inset: 2pt, width: 100%)[amt=#key: #display])
      } else {
        rows.push([amt=#key: #display])
      }
    }
    stack(dir: ttb, spacing: 3pt, ..rows)
  }
  
  mapcode-viz(
    rho, (x) => F(x, inst_coins), pi((inst_amount, inst_coins)),
    X_h: x_h,
    pi_name: [$mpi ((#inst_amount, #inst_coins))$],
    group-size: 4,
    cell-size: 40mm, scale-fig: 75%
  )((inst_amount, inst_coins))
}$)