#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Tower of Hanoi

#set math.equation(numbering: none)

The Tower of Hanoi puzzle: move $n$ disks from source rod $s$ to destination rod $d$ using auxiliary rod $a$, where larger disks cannot be placed on smaller ones.

Recursive definition:
$
"Hanoi"(n, s, d, a) = cases(
  ["Move disk 1 from " s " to " d] & "if " n = 1,
  "Hanoi"(n-1, s, a, d) + ["Move disk " n " from " s " to " d] + "Hanoi"(n-1, a, d, s) & "otherwise"
)
$

*As map code:*

$
I & = n:NN times s:"Rod" times d:"Rod" times a:"Rod" \
X_(n,s,d,a) & = {1..n} times "Rod"^3 -> "List"["Move"]_bot \
A & = "List"["Move"] \
rho(n,s,d,a) & = { (i,p_1,p_2,p_3) -> bot | i in {1..n}, (p_1,p_2,p_3) in "perm"({s,d,a}) } \
F(x_(i,p_1,p_2,p_3)) & = cases(
    ["Move disk 1 from " p_1 " to " p_2] & "if " i = 1,
    x_(i-1,p_1,p_3,p_2) + ["Move disk " i " from " p_1 " to " p_2] + x_(i-1,p_3,p_2,p_1) & "if" x_(i-1,p_1,p_3,p_2) != bot "and" x_(i-1,p_3,p_2,p_1) != bot
  ) \
pi_(n,s,d,a) (x) & = x_(n,s,d,a)
$

#let inst_n_hanoi = 3;
#let inst_src = "A";
#let inst_dest = "C";
#let inst_aux = "B";

#figure(
  caption: [Tower of Hanoi for $n = #inst_n_hanoi$ disks from #inst_src to #inst_dest using auxiliary #inst_aux],
$#{
  let rho = ((n, src, dest, aux)) => {
    let rods = (src, dest, aux)
    let perms = (
      (src, dest, aux), (src, aux, dest),
      (dest, src, aux), (dest, aux, src),
      (aux, src, dest), (aux, dest, src)
    )
    let state = (:)
    for i in range(1, n + 1) {
      for perm in perms {
        let key = str(i) + "-" + perm.at(0) + perm.at(1) + perm.at(2)
        state.insert(key, none)
      }
    }
    state
  }
  
  let F_i = (x) => (state_key) => {
    let val = x.at(state_key)
    if val != none { return val }
    
    let parts = state_key.split("-")
    let n = int(parts.at(0))
    let rods_str = parts.at(1)
    let s = rods_str.at(0)
    let d = rods_str.at(1)
    let a = rods_str.at(2)
    
    if n == 1 {
      return ("Move disk 1 from " + s + " to " + d,)
    }
    
    let key1 = str(n - 1) + "-" + s + a + d
    let key2 = str(n - 1) + "-" + a + d + s
    
    let part1 = x.at(key1, default: none)
    let part2 = x.at(key2, default: none)
    
    if part1 != none and part2 != none {
      let middle = ("Move disk " + str(n) + " from " + s + " to " + d,)
      return part1 + middle + part2
    }
    
    return none
  }
  
  let F = (x) => {
    let x_new = (:)
    for (key, val) in x {
      x_new.insert(key, F_i(x)(key))
    }
    x_new
  }
  
  let pi = ((n, src, dest, aux)) => (x) => {
    let key = str(n) + "-" + src + dest + aux
    x.at(key, default: none)
  }
  
  let x_h(x, diff_mask:none) = {
    set text(size: 7pt)
    let rows = ()
    let sorted_keys = x.keys().sorted()
    for key in sorted_keys {
      let val = x.at(key)
      let display = if val == none {
        bot
      } else {
        let moves_text = val.slice(0, calc.min(2, val.len())).join("; ")
        if val.len() > 2 {
          moves_text = moves_text + "; ..."
        }
        [#moves_text]
      }
      let is_changed = if diff_mask != none and type(diff_mask) == dictionary {
        diff_mask.at(key, default: false)
      } else {
        false
      }
      
      if is_changed {
        rows.push(rect(fill: yellow.transparentize(70%), inset: 2pt, width: 100%)[#key: #display])
      } else {
        rows.push([#key: #display])
      }
    }
    stack(dir: ttb, spacing: 3pt, ..rows)
  }
  
  mapcode-viz(
    rho, F, pi((inst_n_hanoi, inst_src, inst_dest, inst_aux)),
    X_h: x_h,
    pi_name: [$mpi ((#inst_n_hanoi, #inst_src, #inst_dest, #inst_aux))$],
    group-size: 2,
    cell-size: 45mm, scale-fig: 70%
  )((inst_n_hanoi, inst_src, inst_dest, inst_aux))
}$)

#pagebreak()