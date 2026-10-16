#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *

== Navigation Among Movable Obstacles <sec-namo>
#set math.equation(numbering: none)

A robot must reach a goal cell, but some obstacles block the way and can themselves be moved.
This is _navigation among movable obstacles_ (NAMO). Deciding whether a plan exists is NP-hard in
general #cite(<wilfong1991>, form: "prose"). #cite(<stilman2005>, form: "prose") introduce NAMO and
plan by searching over configurations of the robot and the movable obstacles; their planner adds
heuristics and a decomposition of the state space that this entry does not model.

Here the problem is reduced to its simplest form. The grid has walls and a single movable obstacle
$o$. The robot moves one cell at a time into a free neighbour. If the neighbour holds the obstacle,
the robot pushes it one cell further in the same direction, provided that cell is free. A search
over robot–obstacle configurations finds a plan that moves the obstacle out of the way. The search
is breadth-first, one layer per step of $F$.

Example: on the $5 times 3$ grid below the wall cells $(2,0)$ and $(2,2)$ leave a single door at
$(2,1)$, which holds the obstacle. The robot cannot pass without pushing the obstacle through the
door and into the right room. The plan has five moves.

*As mapcode:*

_primitives_: a configuration is $c = (r, o)$ with $r, o in ZZ^2$ the robot and obstacle cells.
The successor relation $N(c)$ holds for $c'$ when the robot moves to a free neighbour (leaving
$o$ in place) or pushes the obstacle one cell as above; both cells must lie in the grid and off the
walls.

#mc-spec(
  state: [$x = (Q, S, g)$: the current layer $Q$, the seen map $S$, and the goal $g$ once reached.],
  I: $I = (W, H, S_"walls", r_0, o_0, g_"cell")$,
  X: $X = "Layers" times "Maps" times ({bot} union "Configs")$,
  A: $A = "Configs"^* union {bot}$,
  rho: [$rho(I) = (⟨c_0⟩, {c_0 mapsto (bot, c_0)}, g_0)$],
  F: [$F(x) = (Q', S', g')$ if $g = bot$, $Q != emptyset$; else $F(x) = x$],
  pi: [$mpi(x) = "path"(g)$ if $g != bot$; else $bot$],
)

Here $c_0 = (r_0, o_0)$ and $g_0 = c_0$ if $r_0 = g_"cell"$, else $g_0 = bot$. In $F$, $Q'$ is the set of
unseen $c' in N(c)$ for $c in Q$, $S'$ extends $S$ by $c' mapsto (c, c')$, and $g'$ is the first $c'$
in $Q'$ with the robot on $g_"cell"$. The helper $"path"(g)$ follows parents from $g$ back to $c_0$ and
reverses the result.

_Correctness._ A configuration is added to $S$ at most once, and the search space is finite, so $F$
reaches a fixed point within $|"Configs"|$ steps. A fixed point is either a goal state or a state with
empty $Q$ and no goal, meaning no configuration reachable from $rho(I)$ places the robot on the goal.
Each step of $F$ adds the successors of the current layer, so the path recovered by $mpi$ is a shortest
sequence of moves from $c_0$ to a goal configuration.

#let namo-cell = 0.55em

// One configuration of the instance as a small board. Walls are dark, the robot is R, the obstacle
// is O, and the goal cell is marked G.
#let namo-board(inst, cfg, mark: none) = {
  let w = inst.at(0)
  let h = inst.at(1)
  let walls = inst.at(2)
  let goal = inst.at(5)
  let (r, o) = cfg
  let cells = range(h).map(y => range(w).map(x => {
    let p = (x, y)
    let fill = if walls.any(q => q == p) {
      luma(70)
    } else if p == r {
      c-active
    } else if p == o {
      c-changed
    } else if p == goal {
      c-done
    } else {
      white
    }
    let content = if p == r { [R] } else if p == o { [O] } else if p == goal { [G] } else { [] }
    box(
      width: namo-cell,
      height: namo-cell,
      fill: fill,
      stroke: 0.3pt + c-grid,
      align(center + horizon, text(size: 0.7em, weight: "bold", content)),
    )
  })).flatten()
  let board = grid(columns: (namo-cell,) * w, rows: (namo-cell,) * h, ..cells)
  if mark == none { board } else { box(stroke: 1pt + c-accent, inset: 1pt, board) }
}

// Successor configurations of `cfg` in instance `inst`.
#let namo-succ(inst, cfg) = {
  let w = inst.at(0)
  let h = inst.at(1)
  let walls = inst.at(2)
  let (r, o) = cfg
  let inside(p) = p.at(0) >= 0 and p.at(0) < w and p.at(1) >= 0 and p.at(1) < h
  let free(p) = inside(p) and not walls.any(q => q == p)
  let out = ()
  for d in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
    let r2 = (r.at(0) + d.at(0), r.at(1) + d.at(1))
    if not free(r2) { continue }
    if r2 == o {
      let o2 = (o.at(0) + d.at(0), o.at(1) + d.at(1))
      if free(o2) { out.push((r2, o2)) }
    } else {
      out.push((r2, o))
    }
  }
  out
}

// The mapcode for an instance `inst = (W, H, walls, robot0, obstacle0, goal)`.
#let namo-mc(inst) = {
  let (r0, o0) = (inst.at(3), inst.at(4))
  let goal = inst.at(5)
  let c0 = (r0, o0)

  let rho = inst => (
    frontier: (c0,),
    seen: ((repr(c0)): (none, c0)),
    found: if r0 == goal { repr(c0) } else { none },
  )

  let F-step(inst) = x => {
    if x.found != none or x.frontier.len() == 0 { return x }
    let seen = x.seen
    let new = ()
    let found = none
    for c in x.frontier {
      for s in namo-succ(inst, c) {
        let k = repr(s)
        if k in seen { continue }
        seen.insert(k, (repr(c), s))
        new.push(s)
        if found == none and s.at(0) == goal { found = k }
      }
    }
    (frontier: new, seen: seen, found: found)
  }

  let pi = x => {
    if x.found == none { return none }
    let path = ()
    let k = x.found
    while k != none {
      let (parent, cfg) = x.seen.at(k)
      path.push(cfg)
      k = parent
    }
    path.rev()
  }

  let X_h = (x, diff_mask: none) => {
    if x.found != none {
      stack(
        dir: ttb,
        spacing: 3pt,
        namo-board(inst, x.seen.at(x.found).at(1), mark: true),
        align(center, text(size: 0.75em, fill: c-muted)[goal reached · #x.seen.len() configs seen]),
      )
    } else if x.frontier.len() == 0 {
      align(center, text(size: 0.75em, fill: c-muted)[no plan · #x.seen.len() configs seen])
    } else {
      stack(
        dir: ttb,
        spacing: 3pt,
        grid(
          columns: 3,
          column-gutter: 4pt,
          row-gutter: 3pt,
          ..x.frontier.map(c => namo-board(inst, c)),
        ),
        align(center, text(size: 0.75em, fill: c-muted)[layer of #x.frontier.len() · #x.seen.len() seen]),
      )
    }
  }

  let A_h = a => {
    if a == none {
      [no plan]
    } else {
      grid(
        columns: 4,
        column-gutter: 6pt,
        row-gutter: 4pt,
        ..a.enumerate().map(((i, c)) => stack(
          dir: ttb,
          spacing: 2pt,
          align(center, text(size: 0.7em, fill: c-muted)[#i]),
          namo-board(inst, c),
        )),
      )
    }
  }

  mapcode-viz(
    rho,
    F-step(inst),
    pi,
    I_h: i => namo-board(i, (r0, o0)),
    X_h: X_h,
    A_h: A_h,
    F_name: [$F$],
    pi_name: [$mpi$],
    dim: 0,
    group-size: 3,
    spacing: (12mm, 10mm),
  )(inst)
}

// Instance of the example above: walls at (2,0) and (2,2), robot at (0,1), obstacle at (2,1),
// goal at (4,0).
#let inst = (5, 3, ((2, 0), (2, 2)), (0, 1), (2, 1), (4, 0))

#figure(
  caption: [Layered search for NAMO via mapcode on the $5 times 3$ example. Each state shows the
    current layer of robot–obstacle configurations (robot R, obstacle O, goal G). The last state
    marks the goal configuration that was reached.],
  namo-mc(inst),
)
