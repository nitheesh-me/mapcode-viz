#import "/lib/style.typ": *
#import "/lib/viz.typ": *

= Notation and Conventions <notation>

This appendix collects the notation used throughout the book. Notation that appears in only one
section (for example the quantum notation of the bonus chapter) is introduced where it is used.

#let ntable(..rows) = table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  table.hline(stroke: 0.5pt),
  ..rows.pos().flatten(),
  table.hline(stroke: 0.5pt),
)

== Numbers, ranges and indexing

#ntable(
  ([$NN$, $ZZ$, $RR$], [natural numbers (including $0$), integers, reals]),
  ([$BB = {"T", "F"}$], [Booleans, drawn as a green T and a red F in the figures]),
  ([$[a..b]$], [the integers $a, a+1, dots, b$ (both ends included; empty if $b < a$)]),
  ([$[a..b)$], [the integers $a, dots, b - 1$ (upper end excluded)]),
  ([$n "div" m$, $n mod m$], [integer quotient and remainder]),
  ([$floor(x)$, $ceil(x)$], [rounding down and up]),
  ([$infinity$], [an ordinary value larger than every number, with $infinity + w = infinity$; by
    convention $min emptyset = infinity$ and $max emptyset$ is stated where it is used]),
)

*Indexing.* Tables and arrays that make up a state are indexed from $0$: a vector of size $n + 1$
and a matrix of size $m times n$ are
$
  vec(x_0, dots.v, x_n, delim: "[")_(n+1)
  quad quad
  mat(
    delim: "[",
    x_(0,0), x_(0,1), dots.h.c, x_(0,n-1);
    x_(1,0), x_(1,1), dots.h.c, x_(1,n-1);
    dots.v, dots.v, dots.down, dots.v;
    x_(m-1,0), x_(m-1,1), dots.h.c, x_(m-1,n-1)
  )_(m times n)
$
Input strings and sequences are indexed from $1$ ($S = S_1 dots S_m$) when a recursion runs over
their prefixes, so that table row $i$ stands for the prefix $S_1 dots S_i$ and row $0$ for the empty
prefix. Each section states which convention it uses.

== Sequences and sets

#ntable(
  ([$V^*$, $V^+$], [finite sequences (lists) of elements of $V$; non-empty sequences. Strings are
    sequences of characters, $Sigma^*$]),
  ([$V^n$], [sequences of length exactly $n$]),
  ([$|l|$], [the length of $l$]),
  ([$l_i$, $l_([i..j))$], [the element at position $i$; the slice of positions $i, dots, j - 1$]),
  ([$[]$, $x :: l$, $l plus.double l'$], [the empty list; $x$ in front of $l$; concatenation]),
  ([$"Set"(V)$, $2^V$], [the finite sets of elements of $V$; all subsets of $V$]),
  ([$emptyset$], [the empty set]),
)

== Undefined values and strictness

The symbol #bot denotes an _undefined_ value. For a set $V$, $V_bot = V union {bot}$ adds it; a state
cell of type $V_bot$ is either a proper value or still undefined.

A primitive operation is _strict_ if applying it to #bot gives #bot: $bot + v = v + bot = bot$,
$max(bot, v) = bot$, and so on. Unless stated otherwise, every primitive in this book is strict.
Comparisons in guards ("if $S_i = T_j$") read only the input, which is always defined; a guard that
would read a #bot cell makes the whole case #bot.

*Strict tables.* Most mapcodes in this book use a state $X = D -> V_bot$ that starts as the table
of undefined cells, $rho(i) = {c |-> bot}$, and an $F$ that recomputes every cell from the previous
state by the recursion being implemented. Because the primitives are strict, a cell becomes defined
only once all the cells it depends on are defined, and from then on it is recomputed from the same,
already correct values, so it never changes again. Three facts follow, and they are used in almost
every chapter:

- the number of undefined cells, $sigma(x) = |{c | x_c = bot}|$, is a bound function: every step
  that changes the state defines at least one new cell, so the fixed point is reached after at most
  one step per cell;
- the predicate $"Inv"(x) <=> forall c . x_c != bot => x_c = r(c)$, where $r$ is the recursive
  definition, is an invariant: a defined cell always holds the value of the recursion;
- if the dependencies of the recursion are well-founded (no cell depends on itself, directly or
  indirectly), then no cell is #bot at the fixed point, so the fixed point is exactly the table the
  recursion defines.

The order in which cells become defined is the dependency order of the recursion; the highlighted
cells in each figure show which sub-problems became available in that step.

== States, tables and maps

#ntable(
  ([$D -> V$], [the functions from $D$ to $V$. A state of type $X = D -> V_bot$ is a _table_ with one
    cell per index in $D$; its cells are written $x_i$, $x_(i,j)$]),
  ([$x |-> e$], [the function that maps $x$ to $e$ (an anonymous function)]),
  ([${i |-> e | i in D}$], [the table whose cell $i$ holds $e$, for each $i in D$; ${i |-> bot}$ is the
    table of undefined cells]),
  ([$F(x)_i = dots$], [defines every cell of the new state $F(x)$ from the _old_ state $x$ at once
    (a synchronous update)]),
  ([$cases(e_1 & "if" b_1, e_2 & "otherwise")$], [case analysis; the guards are tried from top to
    bottom]),
  ([$[P]$], [the Iverson bracket: $1$ if the condition $P$ holds, $0$ otherwise]),
  ([$f(x) -> y$], [in the lists of examples: the input $x$ evaluates to the output $y$]),
)

== Mapcode notation

#ntable(
  ([$I$, $X$, $A$], [the input, state and answer spaces]),
  ([$rho$, $F$, $pi$], [initialisation $I -> X$, transformation $X -> X$, projection $X -> A$; $F$ is
    iterated to a fixed point (@mapcode-model)]),
  ([$"fix"(F)$, $"con"(F)$], [the fixed points of $F$; its convergent points, the states from which
    iteration reaches a fixed point in finitely many steps]),
  ([$F^infinity$], [the limit map $"con"(F) -> "fix"(F)$: iterate $F$ until it stops changing]),
  ([$X_n$, $F_S$, $pi_n$], [a subscript names the instance data a space or map depends on, e.g.
    $F_(S,T)$ for the strings $S$ and $T$. In the figures the subscript is replaced by the concrete
    instance when it is short ($F_({3,5})$, $pi_6$)]),
  ([$X'_n$, $F'_n$], [a prime distinguishes a variant from an earlier map with the same role]),
  ([$sigma$], [a _bound function_ $X -> NN$ that strictly decreases on every step of $F$ that changes the
    state, so iteration terminates]),
  ([$theta$], [an _invariant value_ $X -> A$: it equals the specification at $rho(i)$, is unchanged by
    $F$, and equals $pi$ at the fixed point]),
  ([$"Inv"$], [an _invariant predicate_ on states, true initially and preserved by $F$]),
)
Every algorithm is specified by a block of three rows: $I$, $X$, $A$; then $rho$, $F$, $pi$; then
$sigma$ and $theta$ (or $"Inv"$), followed by one sentence explaining why they are correct.

== Figures

Every figure draws a complete run: the instance at the top left, a $rho$ edge down to the initial
state, the successive states left to right and row by row joined by $F$ edges, the fixed point
marked by an $F$ self-loop, and a $pi$ edge up to the answer at the top right. The dashed edge across
the top is the specification $f$. Colours have a fixed meaning:

#ntable(
  ([#box(width: 1.4em, height: 0.9em, fill: c-changed, stroke: 0.4pt + c-grid)], [a cell changed by the last step of $F$]),
  ([#bot], [an undefined cell]),
  ([#box(width: 1.4em, height: 0.9em, fill: c-shade, stroke: 0.4pt + c-grid)], [a cell outside the domain of the table]),
  ([#box(width: 1.4em, height: 0.9em, fill: c-done, stroke: 0.4pt + c-grid)], [a cell or node that is already final: resolved, sorted, found]),
  ([#box(width: 1.4em, height: 0.9em, fill: c-header, stroke: 0.4pt + c-grid) #box(width: 1.4em, height: 0.9em, fill: c-side, stroke: 0.4pt + c-grid)],
    [column and row labels of a table]),
  ([#text(fill: c-accent, weight: "bold")[$arrow.t$ j]], [a pointer into an array, or an edge or item in focus]),
)
Where a state carries a bound function or invariant, its value is printed under the state
($sigma = dots$, $theta = dots$).
