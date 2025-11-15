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
/* ddc */
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

