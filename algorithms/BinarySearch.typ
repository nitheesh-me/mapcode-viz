#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Binary Search
#set math.equation(numbering: none)

Search for a target value in a sorted array and return its index. If the target is not found, return -1.

Formal definition:
$
"bs"("low", "high") = cases(
  -1 & "if " "low" > "high",
  "mid" & "if " A["mid"] = "target",
  "bs"("low", "mid"-1) & "if " A["mid"] > "target",
  "bs"("mid"+1, "high") & "if " A["mid"] < "target"
)
$

where $"mid" = floor(("low" + "high")/2)$

Examples:
- $A = [1, 3, 5, 7, 9]$, target $= 5 -> 2$
- $A = [1, 3, 5, 7, 9]$, target $= 6 -> -1$

*As mapcode:*

_primitives_: `comparison` ($<$, $=$), `arithmetic` ($+$, $-$, $floor(dot / 2)$) are strict. i.e., operations on $bot$ are undefined.

$
I = (A: ZZ^*, "target": ZZ) quad quad quad
X &= (NN times NN) -> (ZZ union {-1} union {bot}) quad quad quad
A = ZZ union {-1}\
rho(A, "target") &= {("low", "high") -> bot | "low" in {0 dots n}, "high" in {-1 dots n-1}}\
F(x_(l,h)) &= cases(
  -1 & "if " l > h,
  m & "if " A[m] = "target",
  x_(l, m-1) & "if " A[m] > "target",
  x_(m+1, h) & "if " A[m] < "target"
) quad "where " m = floor((l + h)/2)\
pi(x) &= x_(0, n-1) quad "where " n = |A|
$

#let inst_arr = (1, 3, 5, 7, 9, 11, 13, 15, 17, 19);
#let inst_target = 13;
#let inst_n = inst_arr.len();

#figure(
  caption: [Binary Search computation using mapcode for $A = #inst_arr$ and target $= #inst_target$],
$
#{
  let rho = ((arr, target)) => {
    let n = arr.len()
    let x = (:)
    for low in range(0, n + 1) {
      for high in range(low - 1, n) {
        let key = "(" + str(low) + "," + str(high) + ")"
        x.insert(key, none)
      }
    }
    x
  }

  let F_key = ((arr, target)) => (x) => (key) => {
    // Parse key string like "(0, 9)" back to (low, high)
    let parts = key.trim("(").trim(")").split(",")
    let low = int(parts.at(0).trim())
    let high = int(parts.at(1).trim())
    
    if low > high {
      -1
    } else {
      let mid = calc.floor((low + high) / 2)
      if arr.at(mid) == target {
        mid
      } else if arr.at(mid) > target {
        let dep_key = "(" + str(low) + "," + str(mid - 1) + ")"
        if dep_key in x and x.at(dep_key) != none {
          x.at(dep_key)
        } else {
          none
        }
      } else {
        let dep_key = "(" + str(mid + 1) + "," + str(high) + ")"
        if dep_key in x and x.at(dep_key) != none {
          x.at(dep_key)
        } else {
          none
        }
      }
    }
  }

  let F = ((arr, target)) => (x) => {
    let x_new = (:)
    for (key, val) in x {
      if val != none {
        x_new.insert(key, val)
      } else {
        x_new.insert(key, F_key((arr, target))(x)(key))
      }
    }
    x_new
  }

  let pi = ((arr, target)) => (x) => {
    let n = arr.len()
    if n == 0 { return -1 }
    let key = "(" + str(0) + "," + str(n - 1) + ")"
    let result = x.at(key)
    if result == none { -1 } else { result }
  }

  let X_h = (x, diff_mask: none) => {
    // Show only key ranges for visualization
    let entries = x.pairs().sorted(key: ((k, v)) => k)
    let cells = ()
    
    // Show important ranges
    let important_keys = ("(0," + str(inst_n - 1) + ")", "(0,4)", "(5,9)", "(6,9)", "(6,7)", "(6,6)")
    for key in important_keys {
      if key in x {
        let val = if x.at(key) != none {[$#x.at(key)$]} else {[$bot$]}
        cells.push(table.cell([$#key$]))
        cells.push(table.cell([$-> #val$]))
      }
    }
    
    table(
      columns: 2,
      align: (right, left),
      stroke: none,
      inset: 3pt,
      ..cells
    )
  }

  mapcode-viz(
    rho, F((inst_arr, inst_target)), pi((inst_arr, inst_target)),
    X_h: X_h,
    pi_name: [$mpi$],
    group-size: 3,
    cell-size: 50mm, scale-fig: 80%
  )((inst_arr, inst_target))
}
$
)

