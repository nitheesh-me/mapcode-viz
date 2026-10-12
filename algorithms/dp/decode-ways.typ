#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Decode Ways
#set math.equation(numbering: none)

A message of letters is encoded as digits by $"A" -> #raw("1")$, $"B" -> #raw("2")$, ..., $"Z" -> #raw("26")$.
Given a digit string $s = s_1 s_2 dots s_n$, count the ways to decode it. A single digit decodes
if it is `1`–`9` (never `0`), and a pair of digits decodes if it is `10`–`26`.

Formal definition: let $d(i)$ be the number of decodings of the prefix $s_1 dots s_i$. Using the
Iverson bracket $[P] in {0, 1}$:
$
  d(i) = cases(
    1 & "if " i = 0,
    [s_1 != #raw("0")] & "if " i = 1,
    [s_i != #raw("0")] dot d(i-1) + [10 <= s_(i-1) s_i <= 26] dot d(i-2) & "if " i >= 2
  )
$
The first term counts decodings whose last letter uses the single digit $s_i$; the second those
whose last letter uses the pair $s_(i-1) s_i$.

#let decode-rho = s => range(s.len() + 1).map(_ => none)
#let decode-F(s) = map_tensor(
  x => ((i,)) => {
    if i == 0 { return 1 }
    let one = if s.at(i - 1) != "0" { 1 } else { 0 }
    if i == 1 { return one }
    if x.at(i - 1) == none or x.at(i - 2) == none { return none }
    let pair = int(s.slice(i - 2, i))
    let two = if 10 <= pair and pair <= 26 { 1 } else { 0 }
    one * x.at(i - 1) + two * x.at(i - 2)
  },
  dim: 1,
)
#let decode-pi(s) = x => x.at(s.len())

Examples (the counts are computed by the mapcode below):
#for (s, note) in (
  ("12", [AB, L]),
  ("226", [BBF, BZ, VF]),
  ("06", [a leading `0` never decodes]),
  ("11106", [AAJF, KJF]),
  ("1201234", []),
) [
  - $#raw(s) -> #mapcode(decode-rho, decode-F(s), decode-pi(s))(s)$ #if note != [] [(#note)]
]

*As mapcode:*

_primitives_: `add`($+$) and `mul`($dot$) are strict, i.e. $bot + v = v + bot = bot$; the
brackets $[dots]$ only read $s$ and are always defined.

#mc-spec(
  state: [The state is a table $x$ indexed by prefix length: cell $x_i$ holds the number $d(i)$
    of decodings of $s_1 dots s_i$, or $bot$ while it is not yet known.],
  I: $I = s : {#raw("0"), dots, #raw("9")}^n$,
  X: $X = X_n = [0..n] -> NN_bot$,
  A: $A = NN$,
  rho: $rho(s) = {i |-> bot | i in [0..n]}$,
  F: $F = F_s, quad F_s (x)_i = cases(1 & "if " i = 0, o_1 & "if " i = 1, o_i dot x_(i-1) + t_i dot x_(i-2) & "if " i >= 2)$,
  pi: $pi = pi_n = x |-> x_n$,
  sigma: $sigma(x) = |{i | x_i = bot}|$,
  inv: $"Inv"(x) <=> forall i . x_i != bot => x_i = d(i)$,
)
where $o_i = [s_i != #raw("0")]$ and $t_i = [10 <= s_(i-1) s_i <= 26]$; by strictness cell
$i >= 2$ stays $bot$ while $x_(i-1)$ or $x_(i-2)$ is $bot$. Once defined, a cell holds exactly
$d(i)$ and never changes, so each changing step lowers $sigma$ and keeps $"Inv"$. Cells $0$ and
$1$ are set in the first step and cell $i$ one step after cell $i - 1$, so after $n$ steps
$pi_n (x) = d(n)$. Each cell is drawn under its index $i$ and the digit $s_i$ that ends the prefix.

#let decode-mc(s) = {
  let n = s.len()
  let X_h = (x, diff_mask: none) => {
    let idx = range(n + 1).map(i => label-cell([#i]))
    stack(
      dir: ttb,
      grid(columns: n + 1, ..idx),
      vec-view(x, diff_mask, labels: ([], ..s.clusters().map(c => text(fill: c-accent, raw(c))))),
    )
  }
  mapcode-viz(
    decode-rho,
    decode-F(s),
    decode-pi(s),
    I_h: s => [$s = #raw(s)$],
    X_h: X_h,
    F_name: [$F_s$],
    pi_name: [$mpi_#n$],
    group-size: 3,
    spacing: (8mm, 10mm),
  )(s)
}

#let inst = "11106"
#figure(
  caption: [Decode ways via mapcode for $s = #raw(inst)$; the answer $2$ counts AAJF and KJF.],
  decode-mc(inst),
)

For $s = #raw(inst)$ the fixed point is $d = (1, 1, 2, 3, 2, 2)$: $d(4) = d(2) = 2$ because
$s_4 = #raw("0")$ can only be read as part of `10`, and $d(5) = d(4) = 2$ because `06` is not a
letter.
