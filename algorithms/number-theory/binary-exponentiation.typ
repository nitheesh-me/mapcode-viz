#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Binary Exponentiation
#set math.equation(numbering: none)

Compute $b^e$ for a base $b in NN$ and a non-negative integer exponent $e$, using only
$O(log e)$ multiplications.

Formal definition:
$
  "pow"(b, e) = cases(
    1 & "if " e = 0,
    "pow"(b, floor(e slash 2))^2 & "if " e "is even",
    b dot "pow"(b, floor(e slash 2))^2 & "if " e "is odd"
  )
$

Examples:
- $"pow"(2, 10) -> 1024$
- $"pow"(3, 5) -> 243$
- $"pow"(2, 13) -> 8192$

*As mapcode:*

_primitives_: `mult`($dot$) is strict, i.e. $bot dot v = v dot bot = bot$.

Only the exponents reached by repeated halving are ever needed, so the state is a sparse table
indexed by the key set $K(e) = {floor(e slash 2^j) | j >= 0}$, which contains $0$ and has
$floor(log_2 e) + 2$ elements for $e >= 1$.

$
  I = NN times NN quad quad X_(b,e) = K(e) -> NN_bot quad quad A = NN \
  rho(b, e) = {k -> bot | k in K(e)} \
  F_b (x)_k = cases(
    1 & "if " k = 0,
    (x_(floor(k slash 2)))^2 & "if " k > 0 "is even",
    b dot (x_(floor(k slash 2)))^2 & "if " k "is odd"
  ) \
  pi_e (x) = x_e
$

$K(e)$ is closed under $k |-> floor(k slash 2)$, so every cell's dependency is in the table.
The keys fill from $0$ upwards, one per step, and the fixed point is reached after
$|K(e)|$ steps.

#let binexp-mc(inst) = {
  let (b, e) = inst
  // Sparse state: a dictionary keyed by the exponents in K(e), in increasing order.
  let rho = ((b, e)) => {
    let keys = (0,)
    let k = e
    while k > 0 {
      keys.push(k)
      k = calc.quo(k, 2)
    }
    let x = (:)
    for k in keys.sorted() { x.insert(str(k), none) }
    x
  }
  let F = x => {
    let y = (:)
    for (key, _) in x {
      let k = int(key)
      let v = if k == 0 { 1 } else {
        let h = x.at(str(calc.quo(k, 2)))
        if h == none { none } else if calc.even(k) { h * h } else { b * h * h }
      }
      y.insert(key, v)
    }
    y
  }
  let pi = x => x.at(str(e))
  mapcode-viz(
    rho,
    F,
    pi,
    I_h: ((b, e)) => [$#b^#e$],
    X_h: (x, diff_mask: none) => {
      let keys = x.keys()
      vec-view(
        x.values(),
        keys.map(k => mask-at(diff_mask, k)),
        labels: keys.map(k => [$#k$]),
        vertical: true,
        width: 3em,
      )
    },
    F_name: [$F_b$],
    pi_name: [$mpi_#e$],
    group-size: 3,
    spacing: (8mm, 10mm),
    node-shape: rect,
  )(inst)
}

#let inst = (2, 13)
#figure(
  caption: [Binary exponentiation via mapcode for $#inst.at(0)^#inst.at(1)$. The key column
    lists $K(#inst.at(1))$; odd keys multiply by the base.],
  binexp-mc(inst),
)
#legend
