# Mapcode Visualization

Mapcode Visualization models recursion and algorithms in the *mapcode* framework (Viswanath, *Mapcode: An Introduction to Mathematical Computer Science*). Each algorithm is an initialisation $\rho : I \to X$, a transformation $F : X \to X$ iterated to its fixed point, and a projection $\pi : X \to A$. Every figure in the generated book draws the whole run: the instance, each state $x_0, F(x_0), \dots$ with the cells changed by the last step highlighted, the fixed point, and the answer.

`Mapcode.lean` formalises the model in Lean 4. It contains the unverified triple and a verified version with a variant $\sigma$ and an invariant value $\theta$. The book's first chapter summarises it.

## Contents
| Chapter | Algorithms |
|---|---|
| The Mapcode Model | factorial (two ways) and bubble sort, shown with variant/invariant |
| Basics | factorial, Fibonacci, sum of digits, digit reversal, parity, prefix sum |
| Number Theory and Combinatorics | Euclid's GCD, binary exponentiation, binomial coefficients, Catalan numbers, integer partitions |
| Dynamic Programming | LCS, edit distance, LIS, 0/1 knapsack, subset sum, rod cutting, coin change, matrix-chain multiplication, decode ways |
| Sorting and Searching | binary search, merge sort |
| Recursion and Divide-and-Conquer | Tower of Hanoi, N-Queens, closest pair of points |
| Trees and Graphs | tree height, inorder traversal, Bellman–Ford |
| LeetCode | add two numbers, longest palindromic substring, best time to buy/sell stock, house robber |

## Layout
```
main.typ                 book entry point (chapters + includes)
chapters/                intro chapter on the model, contributors
algorithms/<chapter>/    one .typ file per algorithm
lib/mapcode.typ          mapcode, mapcode-hist, map_tensor, mapcode-viz
lib/viz.typ              shared renderers: vec/table/array views, trees (cetz),
                         graphs (fletcher), chessboards (board-n-pieces),
                         plots (lilaq), pseudocode (lovelace)
lib/style.typ            palette and notation helpers
Mapcode.lean             Lean formalisation of the model
```

## Building
Requires [Typst](https://typst.app/) 0.15 or newer. Packages are downloaded automatically on first compile.
```bash
git clone https://github.com/nitheesh-me/mapcode-viz.git
cd mapcode-viz
typst compile main.typ        # -> main.pdf
```
You can also preview it live with the [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) VS Code extension.

CI compiles the book on every push and pull request. Pushing a tag publishes a release with the PDF.

## Contributing
See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for the algorithm template and the rules every mapcode should follow.

## License
Apache-2.0. See [LICENSE](LICENSE).

## Contact
- **Nitheesh Chandra**: nitheeshchandra.y@research.iiit.ac.in
