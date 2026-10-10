= Contributors

The examples were contributed by students of _Principles of Programming Languages_ (PoPL 2025,
IIIT Hyderabad) through pull requests to
#link("https://github.com/nitheesh-me/mapcode-viz")[`nitheesh-me/mapcode-viz`], and later
consolidated: where several pull requests covered the same algorithm, one was kept and ideas
from the others were folded in.

#let gh(u) = link("https://github.com/" + u, raw("@" + u))
#table(
  columns: (auto, 1fr, auto),
  stroke: none,
  inset: (x: 6pt, y: 3pt),
  table.hline(stroke: 0.5pt),
  [*Algorithm*], [*Contributor(s)*], [*PR*],
  table.hline(stroke: 0.3pt),
  [Factorial, Fibonacci, Binomial coefficients, LCS, Add two numbers], gh("nitheesh-me"), [—],
  [0/1 Knapsack], gh("nitheesh-me"), [\#1],
  [Euclidean GCD], gh("kitswas"), [\#2],
  [Catalan numbers], gh("Hardik1106"), [\#3],
  [Edit distance], [#gh("Hardik1106"), with ideas from #gh("AyushRawal") and #gh("gaurav-behera")], [\#3, \#24, \#5],
  [Integer partitions], [#gh("gaurav-behera"), partition listing by #gh("Chasmiccoder")], [\#5, \#28],
  [N-Queens, Closest pair of points], gh("gaurav-behera"), [\#5],
  [Matrix-chain multiplication], gh("mayank3135432"), [\#7],
  [Sum of digits, Prefix sum], gh("RaunakSeksaria"), [\#8, \#9],
  [Decode ways], gh("miryala10sathvika"), [\#14],
  [Longest palindromic substring, Best time to buy/sell stock], gh("divijhm"), [\#15],
  [Rod cutting, Subset sum], gh("vanshg1729"), [\#17],
  [House robber; coin-change table layout], gh("Dileepadari"), [\#19],
  [Parity, Digit reversal], gh("Harshit-Lalwani"), [\#20],
  [Binary exponentiation], gh("Varun0157"), [\#21],
  [Binary search, Inorder traversal], gh("vishesh312"), [\#22],
  [Coin change], gh("AyushRawal"), [\#23],
  [Bellman–Ford, Tree height], gh("SANS-Surya-o"), [\#25],
  [Longest increasing subsequence, Tower of Hanoi], [#gh("walkeee3"), move lists after #gh("PavitraPi")], [\#27, \#12],
  [Merge sort], gh("Chasmiccoder"), [\#28],
  table.hline(stroke: 0.5pt),
)

Thanks also to #gh("Manas-7854"), #gh("s1darthvader"), #gh("Egomax4"), #gh("alext04"),
#gh("AndyJocy") and #gh("Varun0157") for alternative formulations (\#6, \#10, \#11, \#13, \#16,
\#18) that informed the final versions.
