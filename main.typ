#import "@preview/arkheion:0.1.1": arkheion, arkheion-appendices

#show: arkheion.with(
  title: "Mapcode : Recursion Modeling",
  authors: (
    (name: "Nitheesh Chandra", email: "nitheeshchandra.y@research.iiit.ac.in", affiliation: "TA, PoPL"),
    (name: "Contributors from PoPL 2025, IIITH", email: "", affiliation: "Students, PoPL"),
  ),
  abstract: [
    Recursion modeling in the `mapcode` framework: every algorithm is presented as an
    initialisation $rho$, a transformation $F$ iterated to its fixed point, and a projection $pi$,
    and every figure shows the full sequence of states that $F$ passes through.
  ],
  keywords: ("Mapcode", "Recursion", "Programming"),
  date: datetime.today().display(),
)


#import "lib/style.typ": *

#set math.equation(numbering: none)

= Notations and Conventions

A vector is (zero-)indexed as follows that has size $n+1$:
$
  vec(
    x_0, dots.v, x_n,
    delim: "["
  )_(n+1)
$

A matrix is also (zero-)indexed as follows that has size $m times n$:
$
  mat(
    delim: "[",
    x_(0,0), x_(0,1), dots, x_(0,n-1);
    x_(1,0), x_(1,1), dots, x_(1,n-1);
    dots, dots, dots, dots;
    x_(m-1,0), x_(m-1,1), dots, x_(m-1,n-1)
  )_(m times n)
$

All primitives are _strict_ meaning they do not allow for undefined values (i.e., $bot$) to be used in their computations.

#pagebreak()
#include "chapters/mapcode-model.typ"

#pagebreak()
= Basics
#include "algorithms/basics/factorial.typ"
#pagebreak()
#include "algorithms/basics/fibonacci.typ"
#pagebreak()
#include "algorithms/basics/sum-of-digits.typ"
#pagebreak()
#include "algorithms/basics/digit-reversal.typ"
#pagebreak()
#include "algorithms/basics/parity.typ"
#pagebreak()
#include "algorithms/basics/prefix-sum.typ"

#pagebreak()
= Number Theory and Combinatorics
#include "algorithms/number-theory/gcd.typ"
#pagebreak()
#include "algorithms/number-theory/binary-exponentiation.typ"
#pagebreak()
#include "algorithms/number-theory/binomial-coefficients.typ"
#pagebreak()
#include "algorithms/number-theory/catalan-numbers.typ"
#pagebreak()
#include "algorithms/number-theory/integer-partitions.typ"

#pagebreak()
= Dynamic Programming
#include "algorithms/dp/longest-common-subsequence.typ"
#pagebreak()
#include "algorithms/dp/edit-distance.typ"
#pagebreak()
#include "algorithms/dp/longest-increasing-subsequence.typ"
#pagebreak()
#include "algorithms/dp/knapsack-01.typ"
#pagebreak()
#include "algorithms/dp/subset-sum.typ"
#pagebreak()
#include "algorithms/dp/rod-cutting.typ"
#pagebreak()
#include "algorithms/dp/coin-change.typ"
#pagebreak()
#include "algorithms/dp/matrix-chain.typ"
#pagebreak()
#include "algorithms/dp/decode-ways.typ"

#pagebreak()
= Sorting and Searching
#include "algorithms/sorting-searching/binary-search.typ"
#pagebreak()
#include "algorithms/sorting-searching/merge-sort.typ"

#pagebreak()
= Recursion and Divide-and-Conquer
#include "algorithms/recursion/tower-of-hanoi.typ"
#pagebreak()
#include "algorithms/recursion/n-queens.typ"
#pagebreak()
#include "algorithms/recursion/closest-pair.typ"

#pagebreak()
= Trees and Graphs
#include "algorithms/trees-graphs/tree-height.typ"
#pagebreak()
#include "algorithms/trees-graphs/inorder-traversal.typ"
#pagebreak()
#include "algorithms/trees-graphs/bellman-ford.typ"

#pagebreak()
= LeetCode Problems
#include "algorithms/leetcode/P2_add-two-numbers.typ"
#pagebreak()
#include "algorithms/leetcode/P5_longest-palindrome-substring.typ"
#pagebreak()
#include "algorithms/leetcode/P121_best-time-to-buy-and-sell-stock.typ"
#pagebreak()
#include "algorithms/leetcode/P198_house-robber.typ"

#pagebreak()
#include "chapters/contributors.typ"
