#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Merge Sort

Compute the binomial coefficient $C(n, k)$, which represents the number of ways to choose $k$ elements from a set of $n$ elements.

Formal definition:
$
m(a) := cases(
  a & "if " |a| <= 1,
  "merge"(m(h_l a), m(h_r a)) & "else"
)
$   

Example:
- C(5, 2) = 10
- C(5, 0) = 1
- C(5, 5) = 1
- C(10, 3) = 120

*As mapcode:*

Primatives
1. array data structure. Also size of array $a$ is given by $|a|$  
2. merge function: $"merge"(a,b)$ returns sorted array containing elements of $a$ and $b$  
3. List Halving operators ($h_l$ and $h_r$): $h_l a$ returns an array with first $⌈(|a|)/2⌉$ elements of $a$ while $h_r a$ returns the rest  
4. Given an array $a$, define family of sets $h^n a$ such that
$
h^n a := cases(
  a & "if " n=0,
  h^{n-1} a union \{h_l x "|" x in  h^{n-1} a\} union \{h_r x "|" x in  h^{n-1} a\} & "else"
)
$


$
I = A = { "set of arrays" } quad
X_(a) & = h^{⌈log_2 |a|⌉}_a -> { "set of arrays" }_bot quad quad quad \
rho(a) & = { "arr" -> bot | "arr" in h^⌈log_2 |a|⌉ a } \
F(x("arr")) & = cases(
    "arr" & "if " |"arr"|<=1,
    "merge"(x(h_l "arr"),x(h_r "arr")) & "if " x(h_l "arr") "," x(h_r "arr") != bot,
    bot & "else"
  )\
pi_(a) (x) & = x(a)
$

#let inst_n = 5;
#let inst_k = 3;
#figure(
  caption: [Binomial Coefficient computation using mapcode for $n = #inst_n$ and $k = #inst_k$; A Pascal's Triangle style visualization is used.],
$#{
  let rho = ((inst_n, inst_k)) => {
    let x = ()
    for i in range(0, inst_n + 1) {
      let row = ()
      for j in range(0, inst_k + 1) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i = (x) => ((i,j)) => {
    if j == 0 or j == i {1}
    else if i >= j {
      let idx = (i, j)
      let val1 = if x.at(i - 1).at(j - 1) != none {x.at(i - 1).at(j - 1)} else {none}
      let val2 = if x.at(i - 1).at(j) != none {x.at(i - 1).at(j)} else {none}
      if val1 != none and val2 != none {val1 + val2} else {none}
    } else {
      none
    }
  }
  let F = map_tensor(F_i, dim: 2)

  let pi = ((n, k)) => (x) => x.at(n).at(k)

  // draw a pascal triangle style matrix
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    // trim if j < i
    let trim = (x) => {
      let res = ()
      for i in range(0, x.len()) {
        let row = ()
        for j in range(0, x.at(i).len()) {
          if j <= i {
            row.push(x.at(i).at(j))
          } else {
            // row.push(none)
          }
        }
        res.push(row)
      }
      res
    }
    x = trim(x)
    let rows = ()
    for i in range(0, x.len()) {
      let row = ()
      for j in range(0, x.at(i).len()) {
        let val = if x.at(i).at(j) != none {[$#x.at(i).at(j)$]} else {[$bot$]}
        if diff_mask != none and diff_mask.at(i).at(j) {
          // changed element: highlight
          row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[$#val$])
        } else {
          row.push(rect(stroke: gray, inset: 4pt)[$#val$])
        }
      }
      rows.push(
        grid(
          columns: row.len() * (14pt,),
          rows: 14pt,
          align: center + horizon,
          ..row
        )
      )
    }
    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho,F, pi((inst_n, inst_k)),
    X_h: x_h,
    pi_name: [$mpi ((#inst_n, #inst_k))$],
    group-size: calc.min(3, inst_n),
    cell-size: 20mm, scale-fig: 85%
  )((inst_n, inst_k))
}
$)