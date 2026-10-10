// Shared renderers for mapcode states. Every helper takes the state (or a slice of it)
// plus the diff mask produced by `mapcode-viz`, and highlights cells changed by the last F.
#import "style.typ": *
#import "mapcode.typ": mask-at
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/board-n-pieces:0.9.0" as chess
#import "@preview/lovelace:0.3.1": pseudocode-list

// ⊥ in the muted style used throughout the book.
#let botc = bot

// Default rendering of a cell value: none ↦ ⊥, ±inf ↦ ±∞, bools ↦ coloured T/F.
#let show-val(v) = {
  if v == none { botc } else if type(v) == float and v == calc.inf { $infinity$ } else if (
    type(v) == float and v == -calc.inf
  ) { $-infinity$ } else if type(v) == bool {
    if v { text(fill: c-good, weight: "bold")[T] } else { text(fill: c-bad, weight: "bold")[F] }
  } else if type(v) == str { raw(v) } else if type(v) == content { v } else { $#v$ }
}

// One boxed cell. `width: auto` sizes the cell to its content (for long values).
#let cell(v, changed: false, fill: none, fmt: show-val, width: 1.9em, height: 1.6em, stroke: 0.5pt + c-grid) = box(
  width: width,
  height: height,
  inset: if width == auto { (x: 0.4em) } else { 0pt },
  fill: if changed { c-changed } else { fill },
  stroke: stroke,
  align(center + horizon, text(size: 0.9em, fmt(v))),
)

// A label cell (headers, indices).
#let label-cell(body, fill: none, width: 1.9em, height: 1.6em) = box(
  width: width,
  height: height,
  inset: if width == auto { (x: 0.4em) } else { 0pt },
  fill: fill,
  align(center + horizon, text(size: 0.8em, fill: if fill == none { c-muted } else { black }, body)),
)

// 1-D state x : [0..n] → V. Horizontal (index row above values) by default; `wrap` breaks
// long vectors into several rows, `vertical` stacks index/value pairs.
#let vec-view(
  x,
  mask,
  labels: auto,
  fmt: show-val,
  vertical: false,
  wrap: none,
  width: 1.9em,
  fill: i => none,
) = {
  let labels = if labels == auto { range(x.len()).map(i => [#i]) } else { labels }
  let cells = range(x.len()).map(i => cell(x.at(i), changed: mask-at(mask, i), fmt: fmt, width: width, fill: fill(
    i,
  )))
  let labs = labels.map(l => label-cell(l, width: width))
  if vertical {
    grid(columns: 2, column-gutter: 2pt, row-gutter: 0pt, align: center + horizon, ..range(x.len())
      .map(i => (labs.at(i), cells.at(i)))
      .flatten())
  } else {
    let w = if wrap == none { calc.max(x.len(), 1) } else { wrap }
    let rows = range(x.len()).chunks(w)
    stack(dir: ttb, spacing: 4pt, ..rows.map(r => grid(columns: r.len(), gutter: 0pt, ..r.map(i => labs.at(i)), ..r.map(
      i => cells.at(i),
    ))))
  }
}

// 2-D state x : [0..m]×[0..n] → V as a DP table. `shade(i, j)` greys cells outside the
// domain; `row-labels` / `col-labels` add a header column / row.
#let table-view(
  x,
  mask,
  row-labels: none,
  col-labels: none,
  corner: [],
  fmt: show-val,
  shade: (i, j) => false,
  fill: (i, j) => none,
  width: 1.9em,
  height: 1.6em,
) = {
  let m = x.len()
  let n = if m > 0 { x.at(0).len() } else { 0 }
  let cells = ()
  if col-labels != none {
    if row-labels != none { cells.push(label-cell(corner, width: width, height: height)) }
    for c in col-labels { cells.push(label-cell(c, fill: c-header, width: width, height: height)) }
  }
  for i in range(m) {
    if row-labels != none { cells.push(label-cell(row-labels.at(i), fill: c-side, width: width, height: height)) }
    for j in range(n) {
      let f = if shade(i, j) { c-shade } else { fill(i, j) }
      cells.push(if shade(i, j) and x.at(i).at(j) == none {
        box(width: width, height: height, fill: c-shade, stroke: 0.5pt + c-grid)
      } else {
        cell(x.at(i).at(j), changed: mask-at(mask, i, j), fmt: fmt, fill: f, width: width, height: height)
      })
    }
  }
  grid(columns: n + if row-labels != none { 1 } else { 0 }, gutter: 0pt, ..cells)
}

// Array with named pointers underneath (e.g. (l: 0, m: 4, h: 9)) and optional coloured
// index ranges `runs: ((lo, hi, color), ...)` (inclusive) for merges / partitions.
#let array-view(arr, mask: none, pointers: (:), runs: (), fmt: show-val, width: 1.9em, dim-outside: none) = {
  let n = arr.len()
  let fill-at(i) = {
    let f = none
    for (lo, hi, col) in runs {
      if lo <= i and i <= hi { f = col }
    }
    if dim-outside != none and (i < dim-outside.at(0) or i > dim-outside.at(1)) { f = c-shade }
    f
  }
  let ptr-row = range(n).map(i => {
    let names = pointers.pairs().filter(((k, v)) => v == i).map(((k, v)) => k)
    if names.len() == 0 { label-cell([], width: width) } else {
      label-cell(text(fill: c-accent, weight: "bold")[$arrow.t$\ #names.join(",")], width: width, height: 2.4em)
    }
  })
  grid(
    columns: calc.max(n, 1),
    gutter: 0pt,
    ..range(n).map(i => label-cell([#i], width: width, height: 1.1em)),
    ..range(n).map(i => cell(arr.at(i), changed: mask-at(mask, i), fill: fill-at(i), fmt: fmt, width: width)),
    ..ptr-row,
  )
}

// Rooted tree drawn with cetz. `children` maps a node id to its list of child ids (dict
// with string keys, or array indexed by id). `label(id)` gives the node text and
// `node-fill(id)` its colour (e.g. c-done once its value is known).
#let tree-view(
  children,
  root: 0,
  label: id => [#id],
  node-fill: id => white,
  radius: 0.38,
  spread: 0.9,
  grow: 1.1,
) = {
  let kids(id) = if type(children) == dictionary { children.at(str(id), default: ()) } else { children.at(id) }
  let build(self, id) = {
    let ks = kids(id)
    if ks.len() == 0 { (id,) } else { (id, ..ks.map(k => self(self, k))) }
  }
  cetz.canvas({
    import cetz.draw: *
    cetz.tree.tree(
      build(build, root),
      spread: spread,
      grow: grow,
      draw-node: node => {
        circle((0, 0), radius: radius, fill: node-fill(node.content), stroke: 0.6pt + luma(80))
        content((0, 0), text(size: 0.75em, label(node.content)))
      },
      draw-edge: (parent, child) => line(
        parent.group-name,
        child.group-name,
        stroke: 0.6pt + luma(110),
        mark: (end: "stealth", fill: luma(110), scale: 0.5),
      ),
    )
  })
}

// Weighted directed graph drawn with fletcher. `pos` maps vertex → (x, y) grid position,
// `edges` is ((u, v, w), ...). `label(v)` renders the vertex, `node-fill(v)` its colour,
// `edge-active((u, v, w))` marks edges to highlight (e.g. relaxed in the last step).
#let graph-view(
  pos,
  edges,
  label: v => [#v],
  node-fill: v => white,
  edge-active: e => false,
  spacing: (14mm, 10mm),
  bend: e => 0deg,
) = {
  let vs = if type(pos) == dictionary { pos.keys() } else { range(pos.len()) }
  let at(v) = if type(pos) == dictionary { pos.at(str(v)) } else { pos.at(v) }
  fletcher.diagram(
    spacing: spacing,
    node-stroke: 0.6pt + luma(80),
    ..vs.map(v => fletcher.node(at(v), label(v), shape: circle, fill: node-fill(v), inset: 3pt)),
    ..edges.map(e => {
      let (u, v, w) = e
      let hot = edge-active(e)
      fletcher.edge(
        at(u),
        at(v),
        text(size: 0.75em, fill: if hot { c-accent } else { luma(60) })[$#w$],
        "-|>",
        stroke: if hot { 1.2pt + c-accent } else { 0.6pt + luma(120) },
        bend: bend(e),
        label-side: center,
        label-fill: white,
      )
    }),
  )
}

// n×n chessboard with queens; `queens.at(r)` is the column of the queen in row r
// (or none). Rows are drawn top to bottom. Uses board-n-pieces.
#let board-view(n, queens, square-size: 3.2mm) = {
  let ranks = range(n).map(r => {
    let q = queens.at(r, default: none)
    range(n).map(c => if q == c { "Q" } else { "." }).join()
  })
  chess.board(chess.position(..ranks), square-size: square-size)
}

// Tower-of-Hanoi pegs: `pegs` is three arrays of disc sizes, bottom first.
#let pegs-view(pegs, n, unit: 0.16, height: 0.22, names: ("A", "B", "C"), moved: none) = cetz.canvas({
  import cetz.draw: *
  let w = (n + 1) * unit * 2
  for p in range(3) {
    let cx = p * (w + 0.25)
    line((cx - w / 2, 0), (cx + w / 2, 0), stroke: 1pt + luma(90))
    line((cx, 0), (cx, (n + 0.6) * height), stroke: 1.4pt + luma(150))
    content((cx, -0.22), text(size: 0.7em, fill: c-muted, names.at(p)))
    for (k, d) in pegs.at(p).enumerate() {
      let hw = (d + 0.5) * unit
      let top = k == pegs.at(p).len() - 1
      rect(
        (cx - hw, k * height),
        (cx + hw, (k + 1) * height),
        fill: if top and moved == p { c-changed.opacify(40%) } else { c-active },
        stroke: 0.4pt + luma(60),
        radius: 0.03,
      )
    }
  }
})

// Small line plot of a sequence (e.g. the variant σ along the iteration).
#let sparkline(values, width: 4cm, height: 1.6cm, xlabel: none, ylabel: none) = lq.diagram(
  width: width,
  height: height,
  xlabel: xlabel,
  ylabel: ylabel,
  lq.plot(range(values.len()), values, mark-size: 3pt),
)

// Pseudocode box (lovelace) with consistent styling.
#let pseudo(title: none, body) = block(
  stroke: (left: 2pt + c-accent),
  inset: (left: 8pt, y: 4pt),
  {
    if title != none { text(weight: "bold", size: 0.9em, title) }
    pseudocode-list(booktabs: false, numbered-title: none, body)
  },
)

// Standard "State" caption line under a mapcode figure.
#let legend = text(size: 0.8em, fill: c-muted)[
  #box(width: 0.9em, height: 0.8em, fill: c-changed, stroke: 0.4pt + c-grid) changed by last $F$ #h(1em)
  #botc undefined #h(1em)
  #box(width: 0.9em, height: 0.8em, fill: c-shade, stroke: 0.4pt + c-grid) outside domain
]
