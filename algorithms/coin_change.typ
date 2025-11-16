#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Coin Change (Minimum Coins)
#set math.equation(numbering: none)

Compute the minimum number of coins needed to make a target amount.

Formal definition:
$
"CC"(0) &= 0\
"CC"(n) &= min_(c in "coins", c <= n) (1 + "CC"(n-c)) quad "for" n > 0
$

Example: coins = [1,3,4], amount = 6  
Minimum coins = 2 (using 3+3)

*As mapcode:*

_primitives_: `min` and `add`($+$) are strict. i.e min and add on $bot$ is undefined.

$ 
I = "amount": NN quad quad quad X &= [0.."amount"] -> NN_bot quad quad quad A = NN\
rho("amount") &= {i -> bot | i in [0.."amount"], i > 0} union {0 -> 0}\
F(x)[i] &= cases(
  0 & "if" i = 0,
  min_(c in "coins", c <= i) {1 + x[i - c]} & "if" i > 0 "and deps defined",
  bot & "otherwise"
)\
pi(x) &= x["amount"]
$

#let coins = (1, 3, 4);
#let amount = 6;
#figure(
  caption: [Coin Change computation using mapcode for amount = #amount, coins = #coins],
$
#{
  let rho = (amount) => {
    let x = ()
    for i in range(0, amount + 1) {
      if i == 0 {
        x.push(0)
      } else {
        x.push(none)
      }
    }
    x
  }

  let F_i = (x) => ((i,)) => {
    if i == 0 {
      0
    } else {
      let candidates = ()
      for c in coins {
        if c <= i and x.at(i - c) != none {
          candidates.push(x.at(i - c) + 1)
        }
      }
      if candidates.len() > 0 {
        calc.min(..candidates)
      } else {
        none
      }
    }
  }
  let F = map_tensor(F_i, dim: 1)

  let pi = (i) => (x) => x.at(i)

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }

  mapcode-viz(
    rho, F, pi(amount),
    X_h: X_h,
    pi_name: [$pi (#amount)$],
    group-size: calc.min(7, amount + 1),
    cell-size: 10mm, scale-fig: 85%
  )(amount)
}
$
)
