#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

#show link: underline

== Longest Palindromic Substring #link("https://leetcode.com/problems/longest-palindromic-substring")[LeetCode P.5]
#set math.equation(numbering: none)

Given a string $s$, return the longest substring of $s$ that is a palindrome, i.e. reads the same
forwards and backwards. If several have maximal length, return the leftmost.

Formal definition, writing $P(i, j)$ for "$s_i dots s_j$ is a palindrome":
$
  P(i, j) & = cases(
    "true" & "if " i = j,
    s_i = s_j & "if " j = i + 1,
    s_i = s_j and P(i+1, j-1) & "if " j > i + 1
  ) \
  "lps"(s) & = s_(i^*) dots s_(j^*) quad "where" (i^*, j^*) = op("argmax", limits: #true)_(i <= j, thin P(i, j)) (j - i + 1)
$

Examples:
- `"babad"` $->$ `"bab"` (`"aba"` is equally long but starts later)
- `"cbbd"` $->$ `"bb"`
- `"racecar"` $->$ `"racecar"`

Constraints: $1 <= |s| <= 1000$, and $s$ consists of digits and English letters.

*As mapcode:*

_primitives_: `and`($and$) and `equals`($=$) are strict, i.e. they return $bot$ if any argument is $bot$.

$
  I = Sigma^+ quad quad X_s = {(i, j) | 0 <= i <= j < n} -> BB_bot quad quad A = Sigma^+ \
  rho(s) = {(i, j) -> bot | 0 <= i <= j < n} \
  F_s (x)_(i,j) = cases(
    "true" & "if " i = j,
    s_i = s_j & "if " j = i + 1,
    s_i = s_j and x_(i+1, j-1) & "if " j > i + 1
  ) \
  pi_s (x) = s_(i^*) dots s_(j^*) quad "where" (i^*, j^*) "is the leftmost cell of maximal" j - i "with" x_(i,j) = "true"
$

Cells of length $1$ and $2$ are set in the first step; a cell of length $ell >= 3$ needs the cell of
length $ell - 2$ inside it and is set in step $ceil(ell \/ 2)$. Cells with $j < i$ lie outside the
domain and are shaded.

#let lps-mc(s) = {
  let cs = s.codepoints()
  let n = cs.len()
  let rho = s => range(n).map(_ => range(n).map(_ => none))
  let F_ij = cs => x => ((i, j)) => {
    if j < i { none } else if i == j { true } else if j == i + 1 { cs.at(i) == cs.at(j) } else {
      let inner = x.at(i + 1).at(j - 1)
      if inner == none { none } else { cs.at(i) == cs.at(j) and inner }
    }
  }
  let F = cs => map_tensor(F_ij(cs), dim: 2)
  let pi = x => {
    let (best-i, best-len) = (0, 1)
    for i in range(n) {
      for j in range(i, n) {
        if x.at(i).at(j) == true and j - i + 1 > best-len { (best-i, best-len) = (i, j - i + 1) }
      }
    }
    cs.slice(best-i, best-i + best-len).join()
  }
  let X_h = (x, diff_mask: none) => table-view(
    x,
    diff_mask,
    row-labels: cs.map(raw),
    col-labels: cs.map(raw),
    corner: $i \\ j$,
    shade: (i, j) => j < i,
    fill: (i, j) => if x.at(i).at(j) == true { c-done } else { none },
  )
  mapcode-viz(
    rho,
    F(cs),
    pi,
    I_h: s => raw("\"" + s + "\""),
    X_h: X_h,
    A_h: a => raw("\"" + a + "\""),
    pi_name: [$mpi_s$],
    group-size: 3,
    spacing: (8mm, 10mm),
    node-shape: rect,
  )(s)
}

#figure(
  caption: [Longest palindromic substring via mapcode for `"babad"`. Cell $(i, j)$ says whether
    $s_i dots s_j$ is a palindrome; green cells are palindromes.],
  lps-mc("babad"),
)
#legend

#figure(
  caption: [The same mapcode for `"cbbd"`.],
  lps-mc("cbbd"),
)
