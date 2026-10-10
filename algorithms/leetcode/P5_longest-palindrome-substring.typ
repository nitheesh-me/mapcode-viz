#import "../../lib/style.typ": *
#import "../../lib/mapcode.typ": *

#show link: underline

== Longest Palindromic Substring #link("https://leetcode.com/problems/longest-palindromic-substring")[LeetCode P.5]

Given a string `s`, return the longest palindromic substring in `s`.

A string is palindromic if it reads the same forward and backward.

_Example 1_:
/ Input: $s = "babad"$
/ Output: $"bab"$
/ Explanation: "aba" is also a valid answer.

_Example 2_:
/ Input: $s = "cbbd"$
/ Output: $"bb"$

_Example 3_:
/ Input: $s = "racecar"$
/ Output: $"racecar"$

Constraints:
- $1 <= |s| <= 1000$
- $s$ consists of only digits and English letters.

*Mapcode Formalization:*

_primitives_: `and`($and$), `equals`($=$), `max`(max)

A palindrome check can be expressed recursively:
- A single character is always a palindrome
- Two characters are palindromic if they're equal
- A substring $s[i..j]$ is palindromic if $s[i] = s[j]$ and $s[i+1..j-1]$ is palindromic

$
n = |s| quad s in Sigma^* quad Sigma = {"letters and digits"}\
I : s in Sigma^*\
X_s & : [0..n) times [0..n) -> {bot, "True", "False"}\
A & : (i:"start index", l:"length") in NN times NN\
\
rho(s) & = { (i,j) -> bot | i in {0 dots n-1}, j in {0 dots n-1}}\
\
F_s (x_(i,j)) & = cases(
    "True" & "if " i = j,
    s_i = s_j & "if " j = i + 1,
    s_i = s_j and x_(i+1,j-1) & "if " j > i + 1 and x_(i+1,j-1) != bot,
    bot & "otherwise"
  )\
\
pi_s (x) & = (i^*, l^*) "where"\
& i^*, l^* = arg max_((i,j) : x_(i,j) = "True") (j - i + 1)\
& "result substring" = s[i^* : i^* + l^*]
$

#let inst_s = "babad";
#let inst_n = inst_s.len();

#figure(
  caption: [Longest Palindromic Substring computation using mapcode for $s = "#inst_s"$; dynamic-programming table where each cell $(i,j)$ indicates if substring $s[i..j]$ is palindromic. Legend: #box(fill: orange.transparentize(70%), inset: 3pt, stroke: gray)[column headers], #box(fill: green.transparentize(70%), inset: 3pt, stroke: gray)[row headers], #box(fill: blue.transparentize(70%), inset: 3pt, stroke: gray)[palindrome (T)], #box(fill: gray.transparentize(90%), inset: 3pt, stroke: gray)[invalid cells], #box(fill: yellow.transparentize(50%), inset: 3pt, stroke: gray)[updated cells]],
$#{
  // Convert string to array for indexing
  let s_arr = inst_s.codepoints()
  
  let rho = (s) => {
    let n = s.len()
    let x = ()
    for i in range(0, n) {
      let row = ()
      for j in range(0, n) {
        row.push(none)
      }
      x.push(row)
    }
    x
  }

  let F_i = (s) => (x) => ((i, j)) => {
    let n = s.len()
    let s_arr = s.codepoints()
    
    if i == j {
      // Single character is always palindrome
      true
    } else if j == i + 1 {
      // Two characters: check if equal
      s_arr.at(i) == s_arr.at(j)
    } else if j > i + 1 {
      // Longer substring: check ends and inner
      if i + 1 < n and j - 1 < n and x.at(i + 1).at(j - 1) != none {
        (s_arr.at(i) == s_arr.at(j)) and x.at(i + 1).at(j - 1)
      } else {
        none
      }
    } else {
      none
    }
  }
  
  let F = (s) => map_tensor(F_i(s), dim: 2)

  let pi = (s) => (x) => {
    let n = s.len()
    let max_len = 1
    let start = 0
    
    for i in range(0, n) {
      for j in range(i, n) {
        if x.at(i).at(j) == true and (j - i + 1) > max_len {
          max_len = j - i + 1
          start = i
        }
      }
    }
    
    // Return the substring
    let s_arr = s.codepoints()
    s_arr.slice(start, start + max_len).join("")
  }

  // Visualization helper for input
  let I_h = (s) => {
    text(weight: "bold", size: 11pt)["#s"]
  }

  // Visualization helper for output
  let A_h = (res) => {
    text(weight: "bold", size: 11pt, fill: blue)["#res"]
  }

  // Visualization helper for DP table
  let x_h(x, diff_mask: none) = {
    set text(weight: "bold", size: 9pt)
    let n = x.len()
    let rows = ()
    
    // Header row with string characters
    let header_cells = ()
    header_cells.push(rect(stroke: none, inset: 3pt)[$emptyset$])
    for j in range(0, n) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 3pt, stroke: gray)[#s_arr.at(j)])
    }
    rows.push(grid(columns: header_cells.len() * (12pt,), rows: 12pt, align: center + horizon, ..header_cells))

    for i in range(0, n) {
      let row = ()
      // Left label with character
      row.push(rect(fill: green.transparentize(70%), inset: 3pt, stroke: gray)[#s_arr.at(i)])
      
      for j in range(0, n) {
        let val = if x.at(i).at(j) == none {
          [$bot$]
        } else if x.at(i).at(j) == true {
          [T]
        } else {
          [F]
        }
        
        let cell_color = if j < i {
          gray.transparentize(90%)
        } else if x.at(i).at(j) == true {
          blue.transparentize(70%)
        } else {
          white
        }
        
        if diff_mask != none and diff_mask.at(i).at(j) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(50%), inset: 3pt)[$#val$])
        } else {
          row.push(rect(stroke: gray, fill: cell_color, inset: 3pt)[$#val$])
        }
      }
      rows.push(grid(columns: row.len() * (12pt,), rows: 12pt, align: center + horizon, ..row))
    }
    grid(align: center, ..rows)
  }

  mapcode-viz(
    rho, F(inst_s), pi(inst_s),
    I_h: I_h,
    X_h: x_h,
    A_h: A_h,
    pi_name: [$mpi$],
    group-size: 2,
    cell-size: 45mm, 
    scale-fig: 70%
  )(inst_s)
}$)

#pagebreak()

=== Additional Test Cases

#let test_cases = ("cbbd", "a", "ac")

#for test_s in test_cases [
  #let test_n = test_s.len()
  #figure(
    caption: [LPS for $s = "#test_s"$. Legend: #box(fill: orange.transparentize(70%), inset: 3pt, stroke: gray)[column headers], #box(fill: green.transparentize(70%), inset: 3pt, stroke: gray)[row headers], #box(fill: blue.transparentize(70%), inset: 3pt, stroke: gray)[palindrome (T)], #box(fill: gray.transparentize(90%), inset: 3pt, stroke: gray)[invalid cells], #box(fill: yellow.transparentize(50%), inset: 3pt, stroke: gray)[updated cells]],
  $#{
    let s_arr = test_s.codepoints()
    
    let rho = (s) => {
      let n = s.len()
      let x = ()
      for i in range(0, n) {
        let row = ()
        for j in range(0, n) {
          row.push(none)
        }
        x.push(row)
      }
      x
    }

    let F_i = (s) => (x) => ((i, j)) => {
      let n = s.len()
      let s_arr = s.codepoints()
      
      if i == j {
        true
      } else if j == i + 1 {
        s_arr.at(i) == s_arr.at(j)
      } else if j > i + 1 {
        if i + 1 < n and j - 1 < n and x.at(i + 1).at(j - 1) != none {
          (s_arr.at(i) == s_arr.at(j)) and x.at(i + 1).at(j - 1)
        } else {
          none
        }
      } else {
        none
      }
    }
    
    let F = (s) => map_tensor(F_i(s), dim: 2)

    let pi = (s) => (x) => {
      let n = s.len()
      let max_len = 1
      let start = 0
      
      for i in range(0, n) {
        for j in range(i, n) {
          if x.at(i).at(j) == true and (j - i + 1) > max_len {
            max_len = j - i + 1
            start = i
          }
        }
      }
      
      let s_arr = s.codepoints()
      s_arr.slice(start, start + max_len).join("")
    }

    let I_h = (s) => {
      text(weight: "bold", size: 11pt)["#s"]
    }

    let A_h = (res) => {
      text(weight: "bold", size: 11pt, fill: blue)["#res"]
    }

    let x_h(x, diff_mask: none) = {
      set text(weight: "bold", size: 9pt)
      let n = x.len()
      let rows = ()
      
      let header_cells = ()
      header_cells.push(rect(stroke: none, inset: 3pt)[$emptyset$])
      for j in range(0, n) {
        header_cells.push(rect(fill: orange.transparentize(70%), inset: 3pt, stroke: gray)[#s_arr.at(j)])
      }
      rows.push(grid(columns: header_cells.len() * (12pt,), rows: 12pt, align: center + horizon, ..header_cells))

      for i in range(0, n) {
        let row = ()
        row.push(rect(fill: green.transparentize(70%), inset: 3pt, stroke: gray)[#s_arr.at(i)])
        
        for j in range(0, n) {
          let val = if x.at(i).at(j) == none {
            [$bot$]
          } else if x.at(i).at(j) == true {
            [T]
          } else {
            [F]
          }
          
          let cell_color = if j < i {
            gray.transparentize(90%)
          } else if x.at(i).at(j) == true {
            blue.transparentize(70%)
          } else {
            white
          }
          
          if diff_mask != none and diff_mask.at(i).at(j) {
            row.push(rect(stroke: gray, fill: yellow.transparentize(50%), inset: 3pt)[$#val$])
          } else {
            row.push(rect(stroke: gray, fill: cell_color, inset: 3pt)[$#val$])
          }
        }
        rows.push(grid(columns: row.len() * (12pt,), rows: 12pt, align: center + horizon, ..row))
      }
      grid(align: center, ..rows)
    }

    mapcode-viz(
      rho, F(test_s), pi(test_s),
      I_h: I_h,
      X_h: x_h,
      A_h: A_h,
      pi_name: [$mpi$],
      group-size: 2,
      cell-size: 30mm, 
      scale-fig: 100%
    )(test_s)
  }$)
]