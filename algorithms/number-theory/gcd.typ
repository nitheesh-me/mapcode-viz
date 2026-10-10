#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Euclidean GCD
#set math.equation(numbering: none)

Compute the greatest common divisor (GCD, also called HCF, highest common factor) of two
non-negative integers $a$ and $b$.

Formal definition:
$
  gcd(a, b) = max { d in NN | d divides a "and" d divides b } quad "for" (a, b) != (0, 0),
  quad gcd(0, 0) = 0
$

Euclid's algorithm rests on $gcd(a, b) = gcd(b, a mod b)$ for $b != 0$ and $gcd(a, 0) = a$.

Examples:
- $gcd(0, 0) -> 0$
- $gcd(2, 3) -> 1$
- $gcd(48, 18) -> 6$
- $gcd(69, 96) -> 3$

*As mapcode:*

_primitives_: `mod`, `max` and `min` are strict, i.e. they return $bot$ if an argument is
$bot$. For a pair $p = (u, v)$ write $p_1 = u$ and $p_2 = v$.

The state records the whole remainder sequence, one pair per cell. Its length must be fixed by
$rho$, so we use Lamé's bound: if Euclid performs $N$ division steps on $(a, b)$ with
$a >= b >= 1$, then $b >= "Fib"(N+1) >= phi^(N-1)$, where $phi = (1 + sqrt(5)) slash 2$. Hence
$N <= L(b) = floor(log_phi b) + 1$ (and $L(0) = 0$), and cells $0..L$ always suffice.
Consecutive Fibonacci numbers meet the bound exactly.

$
  I = NN times NN quad quad X_(a,b) = [0..L] -> (NN times NN)_bot quad quad A = NN
  quad quad "where" L = L(min(a, b)) \
  rho(a, b) = {i -> bot | i in [0..L]} \
  F_(a,b)(x)_i = cases(
    (max(a, b), min(a, b)) & "if " i = 0,
    ((x_(i-1))_2, space (x_(i-1))_1 mod (x_(i-1))_2) & "if " i >= 1 "and" (x_(i-1))_2 != 0,
    bot & "if " i >= 1 "and" (x_(i-1) = bot "or" (x_(i-1))_2 = 0)
  ) \
  pi(x) = (x_i)_1 quad "for the unique" i "with" x_i != bot "and" (x_i)_2 = 0
$

Each step of $F$ defines one more pair of the remainder sequence. Once a pair $(g, 0)$ appears,
every later cell stays $bot$, so the state stops changing; $pi$ reads $g$ off that last pair.

#let gcd-mc(inst) = {
  let (a, b) = inst
  let phi = (1 + calc.sqrt(5)) / 2
  let lame(m) = if m == 0 { 0 } else { calc.floor(calc.log(m, base: phi)) + 1 }
  let rho = ((a, b)) => range(lame(calc.min(a, b)) + 1).map(_ => none)
  let F_ab = x => ((i,)) => {
    if i == 0 { (calc.max(a, b), calc.min(a, b)) } else {
      let p = x.at(i - 1)
      if p == none or p.at(1) == 0 { none } else { (p.at(1), calc.rem(p.at(0), p.at(1))) }
    }
  }
  let F = map_tensor(F_ab, dim: 1)
  let pi = x => {
    let last = x.find(p => p != none and p.at(1) == 0)
    if last == none { none } else { last.at(0) }
  }
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((a, b)) => [$(#a, #b)$],
    X_h: (x, diff_mask: none) => vec-view(
      x,
      diff_mask,
      vertical: true,
      width: 3.6em,
      fmt: p => if p == none { botc } else { $(#p.at(0), #p.at(1))$ },
    ),
    F_name: [$F_(a,b)$],
    pi_name: [$mpi$],
    dim: 1,
    group-size: 6,
    spacing: (6mm, 8mm),
  )(inst)
}

#let inst = (69, 96)
#figure(
  caption: [Euclid's GCD via mapcode for $(a, b) = (#inst.at(0), #inst.at(1))$; here
    $L(69) = 9$ but only six pairs are needed.],
  gcd-mc(inst),
)

The worst case is a pair of consecutive Fibonacci numbers, where every cell up to Lamé's bound
is used:

#let inst2 = (89, 55)
#figure(
  caption: [Euclid's GCD via mapcode for the Fibonacci pair $(#inst2.at(0), #inst2.at(1))$:
    $L(55) = 9$, and all ten cells $0..9$ are filled.],
  gcd-mc(inst2),
)
