#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *

#show link: underline

== Add Two Numbers #link("https://leetcode.com/problems/add-two-numbers")[LeetCode P.2]

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order, and each of their nodes contains a single digit. Add the two numbers and return the sum as a linked list.

You may assume the two numbers do not contain any leading zero, except the number $0$ itself.

_Example 1_:
/ Input: $l_1 = [2,4,3], l_2 = [5,6,4]$
/ Output: $[7,0,8]$
/ Explanation: $342 + 465 = 807.$

_Example 2_:
/ Input: $l_1 = [0], l_2 = [0]$
/ Output: $[0]$

_Example 3_:
/ Input: $l_1 = [9,9,9,9,9,9,9], l_2 = [9,9,9,9]$
/ Output: $[8,9,9,9,0,0,0,1]$

Constraints:

The number of nodes in each linked list is in the range [1, 100].
0 <= Node.val <= 9
It is guaranteed that the list represents a number that does not have leading zeros.

*Mapcode:*

_primitives_: `sum`($+$), `head`($"head"$)(to get value at head of linked list), `tail`($"tail"$)(to get next nodes in linked list), `div_euclid` ($div$)(integer division), `rem`($mod$)(modulus)

let
- $"next": [0..9] -> [0..9] union bot$ be a successor function.
- $"head": h in [0..9] union bot$ be a head node.
- $| L | : l in [1..100]$ be the length of linked list.
Then the linked list is represented as:
$
  "List" = (h, "next"(h), "next"^2(h), "next"^3(h), ..., "until" bot)
$
$
  m in [0..100] quad n in [0..100]\
  I : l_1: "List" times l_2: "List" quad |l_1| = m quad |l_2| = n\
  X_(l_1, l_2) : k in [0.."max"(m, n)) -> ("next"^k (l_1), "next"^k (l_2), "carry": [0..1], "result": [0..1] union {bot})\
  A : "List"\ \
  rho(l_1, l_2) = { (a, b, "res", "carry") | a in "List", b in "List", "carry" = 0, "res" = bot }\
  F(l_1, l_2)(x_k) = cases(
    vec(a, b, "res", "carry", delim: "[") & "if" a = bot and b = bot and "carry" = 0,
    vec(a, b, "carry", 0, delim: "[") & "if" a = bot and b = bot and "carry" != 0,
    vec(a, b, "digit", "carry", delim: "[") & "otherwise" "where" cases(
                                                & "val"_a = "if" a != bot "then" "head"(a) "else" 0,
                                                & "val"_b = "if" b != bot "then" "head"(b) "else" 0,
                                                & "sum" = "val"_a + "val"_b + x_(k - 1)."carry",
                                                & "digit" = "sum" mod 10,
                                                & "carry" = "sum" div 10
                                              )
  )\
  pi(l_1, l_2)(x) = ["digit" | i in [0..|x|), (?, ?, "digit", ?) = x_i, "digit" != bot] + cases(
    & [x_(|x| - 1)."carry"] & "if" x_(|x| - 1)."carry" != 0,
    & [] & "otherwise"
  )
$

#let inst1 = ((2, 4, 3), (5, 6, 4));
#let inst2 = ((0,), (0,));
#let inst3 = ((9, 9, 9, 9, 9, 9, 9), (9, 9, 9, 9));
#figure(
  caption: [Add Two Numbers computation using mapcode for $l_1 = #inst3.at(0)$ and $l_2 = #inst3.at(1)$],
  $#{
    // primitives
    let head = x => { if type(x) != array { x } else { x.at(0) } }
    let tail = x => { if type(x) != array { x } else { x.slice(1, x.len()) } }
    let next = (x, k) => {
      let curr = x
      for i in range(0, k) { curr = tail(curr) }
      head(curr)
    }


    let rho = ((l1, l2)) => {
      let n = calc.max(l1.len(), l2.len())
      let res = ()
      for i in range(0, n) {
        res.push((
          if i < l1.len() { next(l1, i) } else { none },
          if i < l2.len() { next(l2, i) } else { none },
          none, // result
          0, // carry
        ))
      }
      res
    }
    let F_i = x => ((n,)) => {
      let (a, b, res, carry) = x.at(n)
      if a == none and b == none { if carry == 0 { (a, b, res, carry) } else { (a, b, carry, 0) } } else {
        let val_a = if a != none { head(a) } else { 0 }
        let val_b = if b != none { head(b) } else { 0 }
        let (_, _, _, carry) = if n > 0 { x.at(n - 1) } else { (none, none, none, 0) }
        let sum = val_a + val_b + carry
        let digit = calc.rem(sum, 10)
        let carry_out = calc.div-euclid(sum, 10)
        (tail(a), tail(b), digit, carry_out)
      }
    }
    let F = map_tensor(F_i, dim: 1)

    let pi(x) = {
      // build result as linked list
      let res = ()
      for i in range(0, x.len()) {
        let (_, _, digit, _) = x.at(i)
        res.push(digit)
      }
      let (_, _, _, carry) = x.at(x.len() - 1)
      if carry != 0 { res.push(carry) }
      res
    }

    //   // linked list viz
    let I_h = ((l1, l2)) => {
      diagram(
        (l1.enumerate().map(((i, x)) => node((i, 0), [$#x$], stroke: 1pt))).intersperse(edge("-|>")),
        (l2.enumerate().map(((i, x)) => node((i, 0.5), [$#x$], stroke: 1pt))).intersperse(edge("-|>")),
        node(enclose: ((0, 0), (l1.len() - 1, 0)), fill: teal.transparentize(75%), inset: 2pt),
        node(enclose: ((0, 0.5), (l2.len() - 1, 0.5)), fill: orange.transparentize(75%), inset: 2pt),
      )
    }

    // ((2, 5, none, 0), (4, 6, none, 0), (3, 4, none, 0)),
    // (
    //   (false, false, false, false),
    //   (false, false, false, false),
    //   (false, false, false, false),
    // ),
    // (
    //   (false, false, true, false),
    //   (false, false, true, true),
    //   (false, false, true, false),
    // ),
    // (
    //   (false, false, false, false),
    //   (false, false, false, false),
    //   (false, false, true, false),
    // ),
    // traanspose and viz
    // 2 -> 4 -> 3
    // 5 -> 6 -> 4
    // ... , ... , ...
    // 0, 0, 1
    let X_h = (x, diff_mask: none) => {
      let a = ()
      let b = ()
      let c = ()
      let r = ()
      for i in range(0, x.len()) {
        let (val_a, val_b, res, carry) = x.at(i)
        if val_a != none {
          if diff_mask != none and diff_mask.at(i).at(0) {
            a.push(rect(fill: yellow.transparentize(10%), inset: 2pt)[$#if val_a != none { head(val_a) } else { [$bot$] }$])
          } else { a.push(rect(stroke: none, inset: 2pt)[$#if val_a != none { head(val_a) } else { [$bot$] }$]) }
        }
        if val_b != none {
          if diff_mask != none and diff_mask.at(i).at(1) {
            b.push(rect(fill: yellow.transparentize(10%), inset: 2pt)[$#if val_b != none { head(val_b) } else { [$bot$] }$])
          } else { b.push(rect(stroke: none, inset: 2pt)[$#if val_b != none { head(val_b) } else { [$bot$] }$]) }
        }
        if diff_mask != none and diff_mask.at(i).at(3) {
          c.push(rect(fill: yellow.transparentize(10%), inset: 2pt)[$#carry$])
        } else { c.push(rect(stroke: none, inset: 2pt)[$#carry$]) }
        if diff_mask != none and diff_mask.at(i).at(2) {
          r.push(rect(fill: yellow.transparentize(10%), inset: 2pt)[$#res$])
        } else { r.push(rect(stroke: none, inset: 2pt)[#if res != none { res } else { [$bot$] }]) }
      }
      diagram(
        (a.enumerate().map(((i, x)) => node((i, 0), [#x], stroke: 1pt, inset: 3pt))).intersperse(edge("-|>")),
        (b.enumerate().map(((i, x)) => node((i, 0.5), [#x], stroke: 1pt, inset: 3pt))).intersperse(edge("-|>")),
        node(enclose: ((0, 0), (a.len() - 1, 0)), fill: teal.transparentize(75%), inset: 2pt),
        node(enclose: ((0, 0.5), (b.len() - 1, 0.5)), fill: orange.transparentize(75%), inset: 2pt),
        (c.enumerate().map(((i, x)) => node((i, 1.5), [#x], stroke: 1pt, inset: 3pt))),
        (r.enumerate().map(((i, x)) => node((i, 1), [#x], stroke: 1pt, inset: 2pt))),
        // .intersperse(edge("-|>")),
        node(enclose: ((0, 1), (r.len() - 1, 1)), fill: green.transparentize(75%), inset: 2pt),
      )
    }
    let A_h = a => {
      diagram(
        (a.enumerate().map(((i, x)) => node((i, 0.5), [$#x$], stroke: 1pt))).intersperse(edge("-|>")),
        node(enclose: ((0, 0.5), (a.len() - 1, 0.5)), fill: green.transparentize(75%), inset: 2pt),
      )
    }

    mapcode-viz(
      rho,
      F,
      pi,
      I_h: I_h,
      X_h: X_h,
      A_h: A_h,
      pi_name: [$mpi$],
      group-size: calc.min(2, inst3.at(0).len(), inst3.at(1).len()),
      cell-size: 50mm,
      scale-fig: 45%,
    )(inst3)
  }$,
)
