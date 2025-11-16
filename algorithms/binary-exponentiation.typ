#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *

== Binary Exponentiation
#set math.equation(numbering: none)

Compute $"base"^"exp"$ for a non-negative integer exponent.

Formal definition:
$
"pow"("base", "exp") &= cases(
  1 & "if " exp = 0,
  ("pow"("base", "exp"/2))^2 & "if " "exp" " is even",
  "base" * ("pow"("base", "exp"/2))^2 & "if " "exp" " is odd"
)
$

Examples:
- $"pow"(2, 10) -> 1024$
- $"pow"(3, 5) -> 243$

*As mapcode:*

_primitives_: `mult`($*$) is strict.

$ I = ("base", "exp"): NN times NN quad quad quad X_"exp" &= "Map"(NN -> NN_bot) quad quad quad A = NN\
rho("base", "exp") & = {e -> bot | e " is a required subproblem for " "exp"}\
F(x_"exp") & = cases(
  1 & "if " e = 0,
  (x_(e/2))^2 & "if " e " is even",
  "base" * (x_(e/2))^2 & "if " e " is odd"
 )\
 pi(x) & = x_"exp"
$


#let inst_base = 2;
#let inst_exp = 10;
#figure(
  caption: [Binary Exponentiation computation using mapcode for $#inst_base^#inst_exp$],
$
#{
  let get_val = (x, key) => {
    let item = x.find(p => p.at(0) == key)
    if item != none {
      item.at(1)
    } else {
      none
    }
  }

  let rho = ((base, exp)) => {
    let keys = ()
    let current_exp = exp
    while true {
      keys.push(current_exp)
      if current_exp == 0 {
        break
      }
      current_exp = calc.floor(current_exp / 2)
    }
    keys.sorted().map(k => (k, none))
  }

  let F_i = ((base, exp)) => (x) => (elem) => {
    let e = elem.at(0)
    let val = elem.at(1)
    if val != none {
      return (e, val)
    }

    if e == 0 {
      (e, 1)
    } else if calc.rem(e, 2) == 0 {
      let half_e = calc.floor(e/2);
      let half_val = get_val(x, half_e)
      if half_val != none {
        (e, half_val * half_val)
      } else {
        (e, none)
      }
    } else {
      let half_e = calc.floor(e/2);
      let half_val = get_val(x, half_e)
      if half_val != none {
        (e, base * half_val * half_val)
      } else {
        (e, none)
      }
    }
  }

  let F = ((base, exp)) => (x) => {
    x.map(elem => F_i((base, exp))(x)(elem))
  }

  let pi = ((base, exp)) => (x) => get_val(x, exp)

  let X_h = (x, diff_mask: none) => {
    let cells = x.enumerate().map(((i, p)) => {
      let key = p.at(0)
      let val = p.at(1)
      let val_str = if val != none {[$#val$]} else {[$bot$]}
      let cell_content = [$#key -> #val_str$]
      if diff_mask != none and diff_mask.at(i).at(1) {
        rect(fill: yellow.transparentize(70%), inset: 2pt)[#cell_content]
      } else {
        rect(stroke: none, inset: 2pt)[#cell_content]
      }
    })
    $vec(delim: "{", ..cells)$
  }

  mapcode-viz(
    rho, F((inst_base, inst_exp)), pi((inst_base, inst_exp)),
    I_h: ((b,e)) => [$#b^#e$],
    X_h: X_h,
    pi_name: [$pi ((#inst_base, #inst_exp))$],
    group-size: 2,
    cell-size: 30mm,
    scale-fig: 95%
  )((inst_base, inst_exp))
}
$
)
