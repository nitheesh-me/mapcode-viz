#import "@preview/arkheion:0.1.1": arkheion, arkheion-appendices

#show: arkheion.with(
  title: "Mapcode : Recursion Modeling",
  authors: (
    (name: "Nitheesh Chandra", email: "nitheeshchandra.y@research.iiit.ac.in", affiliation: "TA, PoPL"),
    (name: "Contributors from PoPL 2025, IIITH", email: "", affiliation: "Students, PoPL"),
  ),
  abstract: [
    Recursive algorithms are usually taught through code and call trees. These show what an
    algorithm computes but hide the order in which sub-problems become available. The mapcode
    model makes that order explicit. A computation is an initialisation $rho$, a transformation
    $F$ iterated to a fixed point, and a projection $pi$. Applying the model systematically
    requires two things: a uniform recipe for recasting algorithms in this form, and a way to
    show every iteration. We provide both for more than thirty algorithms, spanning dynamic
    programming, number theory, sorting and searching, divide-and-conquer, backtracking, and
    trees and graphs. In most of them the state is a table of sub-problems that starts
    undefined, and $F$ fills a cell only once the cells it depends on are defined, so the fixed
    point is exactly the table the recursion defines. Every run is drawn in
    full, highlighting the cells that each step of $F$ defines. A companion Lean 4
    formalisation proves mapcodes correct using a decreasing bound function and a preserved
    invariant, and the figures can display both. Together these make each algorithm's
    dependency structure and correctness argument directly visible, giving a uniform
    foundation for teaching recursion.
  ],
  keywords: ("Mapcode", "Recursion", "Fixed points", "Dynamic programming", "Program verification", "Visualization"),
  date: datetime.today().display(),
)


#import "lib/style.typ": *
#show table: set par(justify: false)
#set cite(style: "apa")

#set math.equation(numbering: none)

#pagebreak()
#heading(outlined: false, numbering: none)[Contents]
#columns(2, gutter: 1.2em, text(size: 0.92em, outline(title: none, depth: 2, indent: auto)))
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
#include "chapters/bonus-quantum.typ"

#pagebreak()
#bibliography("refs.bib", title: "References", style: "apa")

#pagebreak()
#include "chapters/contributors.typ"

#pagebreak()
#counter(heading).update(0)
#set heading(numbering: "A.1")
#include "chapters/notation.typ"
