#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Closest Pair of Points
#set math.equation(numbering: none)

Compute the minimum Euclidean distance between any two points in a given set of 2D points.

Formal definition (Divide and Conquer):
Let $P_x$ be the list of points sorted by x-coordinate.
Let $f(i, j)$ be the minimum squared distance in the slice $P_x[i..j]$.

$
f(i, j) = cases(
  "brute_force_sq"(P_x[i..j]) & "if " j - i + 1 <= 3,
  min(f(i, k), f(k+1, j), delta_"strip_sq") & "if " j - i + 1 > 3
)
$
where $k = floor((i + j) / 2)$, and $delta_"strip_sq"$ is the minimum squared distance found in the vertical strip.

Example:
- $P = {(2, 3), (5, 1), (3, 4)} -> "dist" = sqrt(2) approx 1.414$ (between (2,3) and (3,4))

*As mapcode:*

_primitives_: `min`, `sqrt`, `abs`, `dist`

$
// I is a list of points P. Let n = |P|.
// P_x is the static, pre-sorted list of points.
// X[i, j] stores f(i, j), the min *squared* dist in P_x[i..j]
I = P:"List"["Point"] quad quad
X_n & = [0..n-1] times [0..n-1] -> RR_bot quad quad
A = RR\

rho(P) & = { (i,j) -> bot | 0 <= i < n, 0 <= j < n} \

// F depends on the pre-sorted list P_x
F_(P_x)(x_(i,j)) & = cases(
    "brute_force_sq"(P_x[i..j]) & "if " j - i + 1 <= 3,
    min(x_(i, k), x_(k+1, j), delta_"strip_sq") & "if " j - i + 1 > 3 " and " x_(i,k) != bot, x_(k+1,j) != bot
  )\

pi_P (x) & = "sqrt"(x_(0, n-1)) quad quad "where" n = |P|
$

// --- Visualization ---
// Helper functions (from Python implementation)
#let dist_sq = (p1, p2) => {
  (p1.at(0) - p2.at(0))*(p1.at(0) - p2.at(0)) + (p1.at(1) - p2.at(1))*(p1.at(1) - p2.at(1))
}

#let brute_force_cpp = (points) => {
  let min_d_sq = 1e100 // infinity
  let n = points.len()
  if n < 2 { return min_d_sq }
  for i in range(n) {
    for j in range(i + 1, n) {
      let d_sq = dist_sq(points.at(i), points.at(j))
      if d_sq < min_d_sq { min_d_sq = d_sq }
    }
  }
  min_d_sq
}

#let strip_closest = (strip, min_delta_sq) => {
  let min_d_sq = min_delta_sq
  let n = strip.len()
  for i in range(n) {
    for j in range(i + 1, n) {
      let y_diff = strip.at(j).at(1) - strip.at(i).at(1)
      if (y_diff * y_diff) >= min_d_sq { break }
      
      let d_sq = dist_sq(strip.at(i), strip.at(j))
      if d_sq < min_d_sq { min_d_sq = d_sq }
    }
  }
  min_d_sq
}


#let inst_P = ((2, 3), (1, 9), (4, 5), (5, 1), (2, 1), (3, 4), (7, 8), (2, 6), (8, 2), (6, 3), (1, 1), (2, 2), (3, 3));
#let P_x_sorted = inst_P.sorted(key: p => p.at(0));
#let inst_n = inst_P.len();

#figure(
  caption: [Closest Pair of Points computation using mapcode for $n = #inst_n$ points; dynamic-programming table visualization. The table $X[i, j]$ stores the minimum squared distance for points $P_x[i..j]$.],
$
#{
  let rho = (P) => {
    let n = P.len()
    let x = ()
    for i in range(n) {
      let row = ()
      for j in range(n) {
        // We only care about (i, j) where j > i
        row.push(none) 
      }
      x.push(row)
    }
    x
  }

  // F_i takes the pre-sorted list P_x as an argument
  let F_i = (P_x) => (x) => ((i, j)) => {
    // We only compute for the upper triangle j > i
    if j <= i { return none }

    let length = j - i + 1
    let current_slice = P_x.slice(i, j + 1)

    // Base case: brute force for <= 3 points
    if length <= 3 {
      return brute_force_cpp(current_slice)
    }

    // Recursive case
    let k = calc.floor((i + j) / 2)

    let delta_L_sq = x.at(i).at(k)
    let delta_R_sq = x.at(k + 1).at(j)

    if delta_L_sq == none or delta_R_sq == none {
      return none // Dependencies not met
    }

    let delta_sq = calc.min(delta_L_sq, delta_R_sq)
    let delta = calc.sqrt(delta_sq)
    let median_x = P_x.at(k).at(0)

    // Build the strip
    let strip = ()
    for p in current_slice {
      if calc.abs(p.at(0) - median_x) < delta {
        strip.push(p)
      }
    }
    
    // Sort strip by y
    let strip_y = strip.sorted(key: p => p.at(1))

    let delta_strip_sq = strip_closest(strip_y, delta_sq)

    return calc.min(delta_sq, delta_strip_sq)
  }
  
  let F = (P_x) => map_tensor(F_i(P_x), dim: 2)

  let pi = (P) => (x) => {
    let n = P.len()
    if n < 2 { return 1e100 }
    let final_dist_sq = x.at(0).at(n - 1)
    
    if final_dist_sq == none {
      return none
    }
    // Return the actual distance, not the squared distance
    return calc.sqrt(final_dist_sq)
  }

  // draw DP table (n x n)
  let x_h(x, diff_mask:none) = {
    set text(weight: "bold")
    let rows = ()
    let n = x.len()

    // Header row: show j index
    let header_cells = ()
    header_cells.push(rect(stroke: none, inset: 4pt)[$i/j$]) // Top-left corner
    for j in range(n) {
      header_cells.push(rect(fill: orange.transparentize(70%), inset: 4pt)[$#j$])
    }
    rows.push(grid(columns: header_cells.len() * (14pt,), rows: 14pt, align: center + horizon, ..header_cells))

    
    for i in range(n) {
      let row = ()
      // Left label: i index
      row.push(rect(fill: green.transparentize(70%), inset: 4pt)[$#i$])

      for j in range(n) {
        let val_raw = x.at(i).at(j)
        // Show rounded squared distances
        let val = if val_raw != none {
            [$#calc.round(val_raw, digits: 1)$]
          } else {
            [$bot$]
          }
        
        // Gray out the lower triangle (j <= i)
        let cell_fill = if j <= i { gray.transparentize(70%) } else { none }
        
        if diff_mask != none and diff_mask.at(i).at(j) {
          row.push(rect(stroke: gray, fill: yellow.transparentize(70%), inset: 4pt)[$#val$])
        } else {
          row.push(rect(stroke: gray, fill: cell_fill, inset: 4pt)[$#val$])
        }
      }
      rows.push(grid(columns: row.len() * (14pt,), rows: 14pt, align: center + horizon, ..row))
    }
    grid(align: center, ..rows)
  }


  mapcode-viz(
    rho,
    F(P_x_sorted), // Pass the sorted list to F
    pi(inst_P),
    X_h: x_h,
    pi_name: [$mpi(P)$],
    group-size: calc.min(2, inst_n),
    cell-size: 60mm, scale-fig: 75%
  )(inst_P)
}
$
)