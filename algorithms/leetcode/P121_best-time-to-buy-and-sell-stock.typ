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

#mc-spec(
  state: [Scanning the days backwards, cell $x_i$ of the state holds the pair $(m_i, q_i)$: $m_i$ is
    the highest price on day $i$ or later ($m_n = 0$: nothing left to sell on), and $q_i$ is the
    best profit from buying and selling within days $i, dots, n - 1$; it is $bot$ until cell
    $i + 1$ is known.],
  I: $I = NN^n$,
  X: $X = X_p = [0..n] -> (NN times NN)_bot$,
  A: $A = NN$,
  rho: $rho(p) = {i |-> bot | i in [0..n]}$,
  F: $F = F_p, quad F_p (x)_i = cases((0, 0) & "if" i = n, "st"_i (x_(i+1)) & "if" i < n)$,
  pi: $pi(x) = q_0$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = (M(i), "profit"(p_([i..n))))$,
)
where $"st"_i (m, q) = (max(m, p_i), thin max(q, m - p_i))$ (strict in its argument), $(m_0, q_0) = x_0$, and $M(i) = max({0} union {p_k | i <= k < n})$. Cell $n$ is set to
$(0, 0) = (M(n), "profit"([]))$ in the first step, and by strictness cell $i$ is set only once
$x_(i+1) = (m_(i+1), q_(i+1))$ is; then it gets $M(i) = max(M(i+1), p_i)$ and $"profit"(p_([i..n)))$, since the best
trade from day $i$ either starts later or buys on day $i$ and sells at the best later price, earning
$m_(i+1) - p_i$. Defined cells never change, so each non-fixed step defines a new cell and decreases
$sigma$; the table fills right to left, reaches its fixed point after $n + 1$ steps, and then
$pi(x) = "profit"(p)$.

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
    F_name: [$F_p$],
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
