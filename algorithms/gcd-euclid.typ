#import "../lib/style.typ": *
#import "../lib/mapcode.typ": *


== Euclidean GCD
#set math.equation(numbering: none)

Compute the Greatest Common Divisor (GCD) (also called HCF, Highest Common Factor) of two non-negative integers $a$ and $b$. i.e $a, b in NN_0, a >= 0, b >= 0$

Formal definition:
$
  gcd(a, b) = max { d in NN_0 mid d divides a "and" d divides b }
$
Equivalently:
$
  gcd(a, b) = max { d in NN_0 mid exists m, n in NN_0 : a = d times m "and" b = d times n }
$
Examples:
- $"gcd"(0, 0) -> 0$
- $"gcd"(2, 3) -> 1$
- $"gcd"(48, 18) -> 6$
- $"gcd"(56, 98) -> 14$

*As mapcode:*

_primitives_: `mod`($mod$) is strict. i.e operation on $bot$ is undefined.

$
  I = (a,b): NN_0 times NN_0 quad quad quad X & = NN -> (NN_0 times NN_0)_bot quad quad quad A = NN_0 \
                                    rho(a, b) & = {i -> bot | i in NN} \
                                       F(x_i) & = cases(
                                                  (a,b) & "if " i = 0,
                                                  x_(i-1) & "if " pi_2(x_(i-1)) = 0,
                                                  (pi_2(x_(i-1)), pi_1(x_(i-1)) mod pi_2(x_(i-1))) & "if " pi_2(x_(i-1)) != 0
                                                ) \
                                        pi(x) & = pi_1("first"(x_i | pi_2(x_i) = 0))
$

where $pi_1$ and $pi_2$ extract the first and second components of a pair.


#let inst_a = 69;
#let inst_b = 96;
#figure(
  caption: [GCD computation using mapcode for $gcd(#str(inst_a), #str(inst_b))$],
  $
    #{
      let max = (a, b) => if a >= b { a } else { b }
      let min = (a, b) => if a <= b { a } else { b }

      let rho = ((a, b)) => {
        // Preallocate array with reasonable size (estimate log2(max(a,b)) + 2)
        let max_val = calc.max(a, b)
        let estimated_steps = if max_val > 0 { calc.floor(calc.log(max_val, base: 2)) + 3 } else { 3 }
        let x = ()
        for i in range(0, estimated_steps) { x.push(none) }
        x.at(0) = (max(a, b), min(a, b))
        x
      }

      let F_i = x => ((i,)) => {
        if i == 0 { x.at(0) } else if i > 0 and x.at(i - 1) != none {
          let (a_prev, b_prev) = x.at(i - 1)
          if b_prev == 0 {
            none // Stop filling array once we reach b=0
          } else { (b_prev, calc.rem(a_prev, b_prev)) }
        } else { none }
      }
      let F = map_tensor(F_i, dim: 1)

      let pi = (a, b) => x => {
        for i in range(0, x.len()) {
          if x.at(i) != none {
            let (a_i, b_i) = x.at(i)
            if b_i == 0 { return a_i }
          }
        }
        return none
      }

      let X_h = (x, diff_mask: none) => {
        // Show all cells including none (as bot)
        let cells = ()
        for idx in range(x.len()) {
          let x_i = x.at(idx)
          let val = if x_i != none {
            let (a, b) = x_i
            [$(#a, #b)$]
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

      let A_h = a => if a != none { [$#a$] } else { [$bot$] }

      mapcode-viz(
        rho,
        F,
        pi(inst_a, inst_b),
        X_h: X_h,
        A_h: A_h,
        pi_name: [$mpi$],
        dim: 1,
        group-size: 6,
        cell-size: 10mm,
        scale-fig: 85%,
      )((inst_a, inst_b))
    }
  $,
)
