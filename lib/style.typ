#set math.mat(row-gap: 0.25em, column-gap: 0.1em)
#set math.vec(gap: 0.1em)

#set cite(style: "apa")
#show link: underline
#let bot = text(stroke: maroon)[$bot$]
#let mpi = $pi$

// Shared palette for all visualizations (see lib/viz.typ).
#let c-changed = rgb("#fbbf24").transparentize(55%) // cell updated by the last F step
#let c-done = rgb("#34d399").transparentize(65%) // cell / node already resolved
#let c-active = rgb("#60a5fa").transparentize(55%) // current focus (pointer, edge, node)
#let c-header = rgb("#e0e7ff") // column labels
#let c-side = rgb("#dcfce7") // row labels
#let c-shade = luma(238) // cells outside the domain (e.g. lower triangle)
#let c-grid = luma(185) // cell borders
#let c-muted = luma(140) // ⊥ and index labels
#let c-accent = rgb("#2563eb")
#let c-good = rgb("#15803d")
#let c-bad = rgb("#b91c1c")
