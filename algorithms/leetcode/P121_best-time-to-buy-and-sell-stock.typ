#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

#show link: underline

== Best Time to Buy and Sell Stock #link("https://leetcode.com/problems/best-time-to-buy-and-sell-stock")[LeetCode P.121]
#set math.equation(numbering: none)

You are given an array $p$ where $p_i$ is the price of a stock on day $i$. Choose one day to buy
and a later day to sell, maximising the profit. Return the maximum profit, or $0$ if no
transaction makes a profit.

Formal definition, for $p in NN^n$:
$
  "profit"(p) = max(0, max_(0 <= i < j < n) p_j - p_i)
$

Examples (days are numbered from $0$):
- $p = [7, 1, 5, 3, 6, 4] -> 5$: buy on day $1$ (price $1$), sell on day $4$ (price $6$)
- $p = [7, 6, 4, 3, 1] -> 0$: prices only fall, so no transaction is made

Constraints: $1 <= n <= 10^5$ and $0 <= p_i <= 10^4$.

*As mapcode:*

_primitives_: `max` and `sub`($-$) are strict, i.e. they return $bot$ if any argument is $bot$.

Scan the days backwards. Cell $i$ holds a pair $(m_i, q_i)$:
- $m_i$ is the highest price on day $i$ or later, i.e. the best price at which a stock bought
  before day $i$ can still be sold ($m_n = 0$: nothing left to sell on);
- $q_i$ is the best profit from buying and selling within days $i, dots, n - 1$.

Buying on day $i$ and selling at the best later price earns $m_(i+1) - p_i$.

$
  I = NN^n quad quad X_p = [0..n] -> (NN times NN)_bot quad quad A = NN \
  rho(p) = {i -> bot | i in [0..n]} \
  F_p (x)_i = cases(
    (0, 0) & "if " i = n,
    (max(m_(i+1), p_i), thin max(q_(i+1), m_(i+1) - p_i)) & "if " i < n "where" (m_(i+1), q_(i+1)) = x_(i+1)
  ) \
  pi(x) = q_0 quad "where" (m_0, q_0) = x_0
$

Cell $n$ is set in the first step and every cell $i$ one step after cell $i+1$, so the table
fills right to left and reaches its fixed point after $n + 1$ steps.

#let stock-mc(prices) = {
  let n = prices.len()
  let rho = p => range(p.len() + 1).map(_ => none)
  let F_i = p => x => ((i,)) => {
    if i == n { (0, 0) } else if x.at(i + 1) == none { none } else {
      let (m, q) = x.at(i + 1)
      (calc.max(m, p.at(i)), calc.max(q, m - p.at(i)))
    }
  }
  let F = p => map_tensor(F_i(p), dim: 1)
  let pi = x => x.at(0).at(1)
  let get = (x, i, k) => if x.at(i) == none { none } else { x.at(i).at(k) }
  let X_h = (x, diff_mask: none) => table-view(
    (
      prices + (none,),
      range(n + 1).map(i => get(x, i, 0)),
      range(n + 1).map(i => get(x, i, 1)),
    ),
    (
      range(n + 1).map(_ => false),
      range(n + 1).map(i => mask-at(diff_mask, i, 0)),
      range(n + 1).map(i => mask-at(diff_mask, i, 1)),
    ),
    row-labels: ($p_i$, $m_i$, $q_i$),
    col-labels: range(n + 1).map(i => [#i]),
    corner: $i$,
    shade: (r, i) => r == 0 and i == n,
  )
  mapcode-viz(
    rho,
    F(prices),
    pi,
    I_h: p => vec-view(p, none),
    X_h: X_h,
    pi_name: [$mpi$],
    group-size: 2,
    spacing: (10mm, 8mm),
    node-shape: rect,
  )(prices)
}

// Price chart with the optimal buy and sell days (for illustration only).
#let stock-chart(prices) = {
  let n = prices.len()
  let (best, buy, sell) = (0, none, none)
  for i in range(n) {
    for j in range(i + 1, n) {
      if prices.at(j) - prices.at(i) > best { (best, buy, sell) = (prices.at(j) - prices.at(i), i, j) }
    }
  }
  lq.diagram(
    width: 7cm,
    height: 3.5cm,
    xlabel: [day $i$],
    ylabel: [price $p_i$],
    legend: (position: bottom + right),
    lq.plot(range(n), prices, color: luma(110), mark-size: 3pt),
    ..if buy != none {
      (
        lq.scatter((buy,), (prices.at(buy),), color: c-good, size: 7pt, label: [buy]),
        lq.scatter((sell,), (prices.at(sell),), color: c-bad, size: 7pt, label: [sell]),
      )
    },
  )
}

#let inst = (7, 1, 5, 3, 6, 4)
#figure(
  caption: [Prices $p = [7, 1, 5, 3, 6, 4]$ with the optimal buy (day $1$) and sell (day $4$).],
  stock-chart(inst),
)

#figure(
  caption: [Best time to buy and sell stock via mapcode for $p = [7, 1, 5, 3, 6, 4]$. Row $m_i$ is the
    highest price from day $i$ on, row $q_i$ the best profit from day $i$ on.],
  stock-mc(inst),
)
#legend
