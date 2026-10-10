#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Merge Sort
#set math.equation(numbering: none)

Sort an array of $n$ elements in ascending order using the merge sort algorithm.

Formal definition:
$
  "mergesort": [A_1, A_2, dots, A_n] -> [A'_1, A'_2, dots, A'_n]
$
where $A'_1 <= A'_2 <= dots <= A'_n$ and ${A'_1, A'_2, dots, A'_n}$ is a permutation of ${A_1, A_2, dots, A_n}$.

Algorithm:
1. Divide the array into two halves
2. Recursively sort each half
3. Merge the two sorted halves

Examples:
- $"mergesort"([]) -> []$
- $"mergesort"([5]) -> [5]$
- $"mergesort"([3, 1, 4, 1, 5, 9, 2, 6]) -> [1, 1, 2, 3, 4, 5, 6, 9]$
- $"mergesort"([38, 27, 43, 3, 9, 82, 10]) -> [3, 9, 10, 27, 38, 43, 82]$

*As mapcode:*

_primitives_: `merge`($union.plus$) combines two sorted subarrays. `split`($divides$) splits array into chunks.

For bottom-up merge sort, we maintain state as $(s, "arr")$ where $s$ is current chunk size:

$
  I = "arr": [NN_0] quad quad quad X & = NN -> (NN times [NN_0])_bot quad quad quad A = [NN_0] \
                          rho("arr") & = {i -> bot | i in NN} \
                              F(x_i) & = cases(
                                         (1, "arr") & "if " i = 0,
                                         x_(i-1) & "if " pi_1(x_(i-1)) >= |pi_2(x_(i-1))|,
                                         (2 dot pi_1(x_(i-1)), "merge-all"(pi_2(x_(i-1)), pi_1(x_(i-1)))) & "otherwise"
                                       ) \
                               pi(x) & = pi_2("first"(x_i | pi_1(x_i) >= |pi_2(x_i)|))
$

where $pi_1, pi_2$ extract components, `merge-all`$(a, s)$ merges adjacent chunks of size $s$ in array $a$.

#let inst_arr = (38, 27, 43, 3);
#figure(
  caption: [Merge sort computation using mapcode for array $#inst_arr$],
  $
    #{
      // Merge two sorted subarrays
      let merge = (arr, start, mid, end) => {
        let result = ()
        // Copy elements before start
        for k in range(0, start) { result.push(arr.at(k)) }

        // Merge arr[start..mid) and arr[mid..end)
        let i = start
        let j = mid
        while i < mid and j < end {
          if arr.at(i) <= arr.at(j) {
            result.push(arr.at(i))
            i += 1
          } else {
            result.push(arr.at(j))
            j += 1
          }
        }
        while i < mid {
          result.push(arr.at(i))
          i += 1
        }
        while j < end {
          result.push(arr.at(j))
          j += 1
        }

        // Copy elements after end
        for k in range(end, arr.len()) { result.push(arr.at(k)) }
        result
      }

      // Merge all adjacent chunks of given size
      let merge_all = (arr, chunk_size) => {
        let result = arr
        let n = arr.len()
        let start = 0
        while start < n {
          let mid = calc.min(start + chunk_size, n)
          let end = calc.min(start + 2 * chunk_size, n)
          if mid < n { result = merge(result, start, mid, end) }
          start += 2 * chunk_size
        }
        result
      }

      // Initialize: state is (chunk_size, array)
      // chunk_size represents the size of already-sorted chunks
      let rho = arr => {
        let x = ()
        let size = calc.ceil(calc.log(arr.len(), base: 2)) + 2
        for i in range(0, size) { x.push(none) }
        x.at(0) = (1, arr) // Start: chunks of size 1 (individual elements, trivially sorted)
        x
      }

      let F_i = x => ((i,)) => {
        if i == 0 {
          x.at(0) // Return the initial state from rho
        } else if x.at(i - 1) != none {
          let (chunk_size, arr) = x.at(i - 1)
          let n = arr.len()

          if chunk_size >= n {
            // Already fully sorted - stay at fixed point
            (chunk_size, arr)
          } else {
            // Merge adjacent chunks and double chunk size
            let new_arr = merge_all(arr, chunk_size)
            (chunk_size * 2, new_arr)
          }
        } else { none }
      }
      let F = map_tensor(F_i, dim: 1)

      let pi = arr => x => {
        for i in range(x.len() - 1, -1, step: -1) {
          if x.at(i) != none {
            let (chunk_size, result_arr) = x.at(i)
            if chunk_size >= arr.len() { return result_arr }
          }
        }
        arr
      }

      let X_h = (x, diff_mask: none) => {
        let cells = ()
        for idx in range(x.len()) {
          let x_i = x.at(idx)
          let val = if x_i != none {
            let (chunk_size, arr) = x_i
            let arr_str = arr.map(str).join(", ")
            [$(s=#chunk_size: #arr_str)$]
          } else { [$bot$] }

          let is_changed = false
          if diff_mask != none and type(diff_mask) == array and idx < diff_mask.len() {
            let mask = diff_mask.at(idx)
            if type(mask) == array { is_changed = mask.any(d => d) } else { is_changed = mask }
          }

          if is_changed { cells.push(rect(fill: yellow.transparentize(70%), inset: 2pt)[$#val$]) } else {
            cells.push(val)
          }
        }
        $vec(delim: "[", ..cells)$
      }

      let A_h = a => if a != none {
        let arr_str = a.map(str).join(", ")
        [$(#arr_str)$]
      } else { [$bot$] }

      mapcode-viz(
        rho,
        F,
        pi(inst_arr),
        X_h: X_h,
        A_h: A_h,
        pi_name: [$mpi$],
        dim: 1,
        group-size: 3,
        cell-size: 10mm,
        scale-fig: 85%,
      )(inst_arr)
    }
  $,
)
