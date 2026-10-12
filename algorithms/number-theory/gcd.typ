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
$rho$, so we use Lamé's bound @lame1844 @knuth1997[§4.5.3]: if Euclid performs $N$ division steps on $(a, b)$ with
$a >= b >= 1$, then $b >= "Fib"(N+1) >= phi^(N-1)$, where $phi = (1 + sqrt(5)) slash 2$. Hence
$N <= L(b) = floor(log_phi b) + 1$ (and $L(0) = 0$), and cells $0..L$ always suffice.
Consecutive Fibonacci numbers meet the bound exactly.

#mc-spec(
  state: [For fixed $(a, b)$, cell $i$ of the table holds the $i$-th pair $(u, v)$ of the
    remainder sequence, from $(max(a, b), min(a, b))$ down to the final pair $(g, 0)$; cells past
    that pair, and cells not reached yet, are $bot$.],
  I: $I = NN times NN$,
  X: $X = X_(a,b) = [0..L] -> (NN times NN)_bot$,
  A: $A = NN$,
  rho: $rho(a, b)_i = bot$,
  F: $F = F_(a,b), quad F_(a,b)(x)_i = cases(
    (max(a, b), min(a, b)) & "if " i = 0,
    "nx"(x_(i-1)) & "if " i >= 1
  )$,
  pi: $pi(x) = (x_t)_1$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = r_i and gcd(x_i) = gcd(a, b)$,
)
where $L = L(min(a, b))$, $t$ is the index of the final pair ($x_t != bot$, $(x_t)_2 = 0$),
and $"nx"$ is one division step, $"nx"(u, v) = (v, u mod v)$ for $v != 0$, with
$"nx"(u, 0) = "nx"(bot) = bot$; $r_i$ is the remainder sequence
$r_0 = (max(a, b), min(a, b))$, $r_i = "nx"(r_(i-1))$, and $gcd(x_i)$ is the gcd of the pair.

Cell $0$ is constant and cell $i$ reads only cell $i - 1$, so a defined cell never changes and
every changing step defines a new pair, which makes $sigma$ drop; cells after the final pair
$(g, 0)$ stay $bot$ forever, so $sigma$ need not reach $0$. Each new pair is the next $r_i$, and
Euclid's identity $gcd(u, v) = gcd(v, u mod v)$ keeps $gcd(x_i) = gcd(a, b)$; Lamé's bound
puts the final pair $(g, 0) = (gcd(a, b), 0)$ inside $[0..L]$, so $pi$ returns $gcd(a, b)$.

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
    F_name: [$F_(#a, #b)$],
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
