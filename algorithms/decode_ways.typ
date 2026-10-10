#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Decode Ways

Count the number of ways to decode a string of digits, where digits map to letters ('1' = 'A', '2' = 'B', ..., '26' = 'Z').

*Key Rules:*
- Single digit: '1'-'9' → valid (not '0')
- Two digits: '10'-'26' → valid
- Leading '0' → invalid

*Recursive Formula:*
$
"dp"[i] = cases(
  1 & "if " i = 0,
  "dp"[i-1] & "if " s[i-1] != '0' "(single valid only)",
  "dp"[i-2] & "if " s[i-1] = '0' and 10 <= s[i-2:i] <= 26 "(double only)",
  "dp"[i-1] + "dp"[i-2] & "if both valid"
)
$

*As mapcode:*

_primitives_: `add`($+$), `int`, `geq`($>=$), `leq`($<=$), `neq`($!=$) are strict.

$ 
I = s:"String" quad quad quad
&n = |s|\
X_s &= [0..n] -> NN_bot quad quad quad
A = NN\
rho(s) & = { i -> bot | i in {0 dots n}} \
F(x_i) & = cases(
    1 & "if " i = 0,
    1 & "if " i = 1 and s[0] != '0',
    0 & "if " i = 1 and s[0] = '0',
    "compute"(i) & "if " i >= 2
  )\
pi(x) & = x_n
$

where $"compute"(i)$ considers both single-digit and two-digit decodings.

#let examples = (
  ("12", "AB or L"),
  ("226", "BZ, VF, or BBF"),
  ("06", "Invalid"),
  ("27", "BG only"),
  ("11106", "AAJF or KJF"),
  ("1201234", "Multiple ways"),
);

#figure(
  caption: [Decode Ways - Summary of Examples],
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    stroke: 0.5pt,
    inset: 8pt,
    
    table.cell(fill: gray.lighten(60%))[*String*],
    table.cell(fill: gray.lighten(60%))[*dp Array*],
    table.cell(fill: gray.lighten(60%))[*Result*],
    table.cell(fill: gray.lighten(60%))[*Decodings*],
    
    ..examples.map(((s, desc)) => {
      let n = s.len()
      
      // Compute DP array
      let dp = (1,)
      
      // dp[1]
      if s.at(0) == "0" {
        dp.push(0)
      } else {
        dp.push(1)
      }
      
      // dp[2..n]
      for i in range(2, n + 1) {
        let ways = 0
        
        // Single digit
        if s.at(i - 1) != "0" {
          ways = ways + dp.at(i - 1)
        }
        
        // Two digits
        let two_str = s.slice(i - 2, i)
        let val = int(two_str)
        if val >= 10 and val <= 26 {
          ways = ways + dp.at(i - 2)
        }
        
        dp.push(ways)
      }
      
      let result = dp.at(n)
      let result_color = if result == 0 { red } else { green }
      
      (
        [*#s*],
        [#dp.map(v => str(v)).join(", ")],
        text(fill: result_color, weight: "bold")[#result],
        [#desc],
      )
    }).flatten()
  )
)

// Larger example: "11106"
#let inst_s = "11106";
#let inst_n = inst_s.len();
#figure(
  caption: [Detailed trace for s = "#inst_s"],
$#{
  let s = inst_s
  let n = s.len()
  
  let rho = (s) => {
    let x = ()
    for i in range(0, n + 1) {
      x.push(none)
    }
    x
  }
  
  let is_valid_two_digit = (s, i) => {
    if i < 2 { return false }
    let two_digit_str = s.slice(i - 2, i)
    let val = int(two_digit_str)
    val >= 10 and val <= 26
  }
  
  let F_i = (x) => ((i,)) => {
    if i == 0 {
      1
    } else if i == 1 {
      if s.at(0) == "0" { 0 } else { 1 }
    } else {
      if x.at(i - 1) == none or x.at(i - 2) == none {
        return none
      }
      
      let ways = 0
      if s.at(i - 1) != "0" {
        ways = ways + x.at(i - 1)
      }
      if is_valid_two_digit(s, i) {
        ways = ways + x.at(i - 2)
      }
      ways
    }
  }
  
  let F = map_tensor(F_i, dim: 1)
  let pi = (n) => (x) => x.at(n)
  
  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }
  
  mapcode-viz(
    rho, F, pi(n),
    X_h: X_h,
    pi_name: $pi$,
    group-size: calc.min(6, n + 1),
    cell-size: 12mm,
    scale-fig: 95%
  )(s)
}
$
)

// Even larger example: "1201234"
#let inst_s2 = "1201234";
#let inst_n2 = inst_s2.len();
#figure(
  caption: [Detailed trace for s = "#inst_s2" (larger example)],
$#{
  let s = inst_s2
  let n = s.len()
  
  let rho = (s) => {
    let x = ()
    for i in range(0, n + 1) {
      x.push(none)
    }
    x
  }
  
  let is_valid_two_digit = (s, i) => {
    if i < 2 { return false }
    let two_digit_str = s.slice(i - 2, i)
    let val = int(two_digit_str)
    val >= 10 and val <= 26
  }
  
  let F_i = (x) => ((i,)) => {
    if i == 0 {
      1
    } else if i == 1 {
      if s.at(0) == "0" { 0 } else { 1 }
    } else {
      if x.at(i - 1) == none or x.at(i - 2) == none {
        return none
      }
      
      let ways = 0
      if s.at(i - 1) != "0" {
        ways = ways + x.at(i - 1)
      }
      if is_valid_two_digit(s, i) {
        ways = ways + x.at(i - 2)
      }
      ways
    }
  }
  
  let F = map_tensor(F_i, dim: 1)
  let pi = (n) => (x) => x.at(n)
  
  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, x_i)) => {
      let val = if x_i != none {[$#x_i$]} else {[$bot$]}
      if diff_mask != none and diff_mask.at(i) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]
      } else {
        rect(stroke: none, inset: 2pt)[$#val$]
      }
    })
    $vec(delim: "[", ..cells)$
  }
  
  mapcode-viz(
    rho, F, pi(n),
    X_h: X_h,
    pi_name: $pi$,
    group-size: calc.min(8, n + 1),
    cell-size: 10mm,
    scale-fig: 90%
  )(s)
}
$
)

*Interpretation for s = "#inst_s":*
- dp[0] = 1: "" (empty) → 1 way
- dp[1] = 1: "1" → 1 way (A)
- dp[2] = 2: "11" → 2 ways (AA, K)
- dp[3] = 2: "111" → 2 ways (AAA, AK, KA - but limited by previous)
- dp[4] = 1: "1110" → 1 way (only "10" is valid for the "0")
- dp[5] = 2: "11106" → 2 ways (AAJF, KJF)

*Interpretation for s = "#inst_s2":*
The string "1201234" has multiple valid decodings due to various combinations of single and double-digit interpretations.