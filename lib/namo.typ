// Motion planning on grids as mapcodes: geometric planning (wavefront) and navigation among
// movable obstacles (NAMO). Every figure is vector (cetz).
//
// Grid instance:  g = (W, H, walls, start, goal). Cells are (x, y); y = 0 is the top row.
// NAMO instance:  inst = (W, H, walls, robot0, obstacle0, goal). A configuration is
//                 cfg = (robot, obstacle). A move steps the robot to a free neighbour, or pushes
//                 the obstacle one cell further in the same direction when that cell is free.
#import "style.typ": *
#import "mapcode.typ": *
#import "viz.typ": *
#import "@preview/cetz:0.5.2"

#let namo-pal = (
  robot: rgb("#2563eb"),
  obstacle: rgb("#f59e0b"),
  goal: rgb("#15803d"),
  goal-bg: rgb("#dcfce7"),
  start: rgb("#7c3aed"),
  wall: rgb("#334155"),
  grid: luma(200),
  accent: rgb("#1d4ed8"),
  ink: luma(40),
)

#let namo-inst(W, H, walls, r0, o0, goal) = (W, H, walls, r0, o0, goal)

#let namo-free(inst, p) = {
  let (w, h, walls) = (inst.at(0), inst.at(1), inst.at(2))
  p.at(0) >= 0 and p.at(0) < w and p.at(1) >= 0 and p.at(1) < h and not walls.any(q => q == p)
}

// Successor configurations of `cfg`, in the fixed order right, left, down, up.
#let namo-succ(inst, cfg) = {
  let (r, o) = cfg
  let out = ()
  for d in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
    let r2 = (r.at(0) + d.at(0), r.at(1) + d.at(1))
    if not namo-free(inst, r2) { continue }
    if r2 == o {
      let o2 = (o.at(0) + d.at(0), o.at(1) + d.at(1))
      if namo-free(inst, o2) { out.push((r2, o2)) }
    } else {
      out.push((r2, o))
    }
  }
  out
}

// Manhattan distance from the robot to the goal: the heuristic of the best-first solver.
#let namo-h(inst, cfg) = {
  let goal = inst.at(5)
  calc.abs(cfg.at(0).at(0) - goal.at(0)) + calc.abs(cfg.at(0).at(1) - goal.at(1))
}

// ---------------------------------------------------------------------------------------------
// Drawings
// ---------------------------------------------------------------------------------------------

// One NAMO configuration: walls dark, robot a blue disc (R), obstacle an amber square (O), goal a
// green cell (G). `frame` boxes the board in the accent colour; `badge` is a label under it.
#let namo-cfg-canvas(inst, cfg, s: 0.38cm, frame: false, badge: none) = {
  let (w, h, walls, goal) = (inst.at(0), inst.at(1), inst.at(2), inst.at(5))
  let (r, o) = cfg
  let ctr(p) = (p.at(0) + 0.5, h - 0.5 - p.at(1))
  cetz.canvas(length: s, {
    import cetz.draw: *
    for x in range(w) {
      for y in range(h) {
        let fill = if walls.any(q => q == (x, y)) {
          namo-pal.wall
        } else if goal.at(0) == x and goal.at(1) == y {
          namo-pal.goal-bg
        } else {
          white
        }
        rect((x, h - 1 - y), (x + 1, h - y), fill: fill, stroke: 0.35pt + namo-pal.grid)
      }
    }
    content(ctr(goal), text(fill: namo-pal.goal, weight: "bold", size: 0.85em)[G])
    rect((o.at(0) + 0.12, h - 0.88 - o.at(1)), (o.at(0) + 0.88, h - 0.12 - o.at(1)), fill: namo-pal.obstacle, radius: 0.12, stroke: 0.5pt + luma(90))
    content(ctr(o), text(fill: white, weight: "bold", size: 0.75em)[O])
    circle(ctr(r), radius: 0.36, fill: namo-pal.robot, stroke: none)
    content(ctr(r), text(fill: white, weight: "bold", size: 0.75em)[R])
    if frame { rect((0, 0), (w, h), stroke: 1.4pt + namo-pal.accent, radius: 0.04) }
    if badge != none { content((w / 2, -0.6), text(size: 0.8em, fill: luma(90))[#badge]) }
  })
}

// Heat colour for t in [0, 1]: pale at the start, deep indigo far away.
#let namo-heat(t) = color.mix(
  (rgb("#e0e7ff"), (1 - t) * 100%),
  (rgb("#3730a3"), t * 100%),
)

// A distance field on a grid. `field` is none for a bare instance.
#let namo-field-canvas(g, field, s: 0.5cm, frame: false, badge: none) = {
  let (w, h, walls, start, goal) = (g.at(0), g.at(1), g.at(2), g.at(3), g.at(4))
  let vals = if field == none { () } else { field.flatten().filter(v => v != none) }
  let mx = if vals.len() > 0 { calc.max(..vals) } else { 1 }
  let mx = calc.max(mx, 1)
  let ctr(p) = (p.at(0) + 0.5, h - 0.5 - p.at(1))
  cetz.canvas(length: s, {
    import cetz.draw: *
    for x in range(w) {
      for y in range(h) {
        let v = if field == none { none } else { field.at(y).at(x) }
        let blocked = walls.any(q => q == (x, y))
        let fill = if blocked {
          namo-pal.wall
        } else if v == none {
          white
        } else {
          namo-heat(v / mx)
        }
        rect((x, h - 1 - y), (x + 1, h - y), fill: fill, stroke: 0.35pt + namo-pal.grid)
        if not blocked and v != none {
          content(ctr((x, y)), text(size: 0.72em, fill: if v / mx > 0.55 { white } else { namo-pal.ink })[#v])
        }
      }
    }
    // Start and goal markers sit in the corners so they never hide a distance value.
    content((start.at(0) + 0.82, h - 0.18 - start.at(1)), text(size: 0.6em, weight: "bold", fill: namo-pal.start)[S])
    content((goal.at(0) + 0.82, h - 0.18 - goal.at(1)), text(size: 0.6em, weight: "bold", fill: namo-pal.goal)[G])
    if frame { rect((0, 0), (w, h), stroke: 1.4pt + namo-pal.accent, radius: 0.04) }
    if badge != none { content((w / 2, -0.6), text(size: 0.8em, fill: luma(90))[#badge]) }
  })
}

// A route on a grid: cells visited in order, with numbered steps and arrows.
#let namo-route-canvas(g, route, s: 0.38cm) = {
  let (w, h, walls, start, goal) = (g.at(0), g.at(1), g.at(2), g.at(3), g.at(4))
  let ctr(p) = (p.at(0) + 0.5, h - 0.5 - p.at(1))
  cetz.canvas(length: s, {
    import cetz.draw: *
    for x in range(w) {
      for y in range(h) {
        let fill = if walls.any(q => q == (x, y)) { namo-pal.wall } else { white }
        rect((x, h - 1 - y), (x + 1, h - y), fill: fill, stroke: 0.35pt + namo-pal.grid)
      }
    }
    content((goal.at(0) + 0.82, h - 0.18 - goal.at(1)), text(size: 0.6em, weight: "bold", fill: namo-pal.goal)[G])
    if route != none {
      for k in range(route.len() - 1) {
        line(ctr(route.at(k)), ctr(route.at(k + 1)), stroke: (paint: namo-pal.accent, thickness: 1.8pt), mark: (end: ">", fill: namo-pal.accent))
      }
      for (k, p) in route.enumerate() {
        circle(ctr(p), radius: 0.22, fill: white, stroke: 0.8pt + namo-pal.accent)
        content(ctr(p), text(size: 0.6em, weight: "bold", fill: namo-pal.accent)[#k])
      }
    }
  })
}

// The plan of a NAMO solver, drawn on the grid: the robot's route (numbered) and the obstacle's
// route (dashed). A plan of length 0 draws the instance itself.
#let namo-plan-canvas(inst, path, s: 0.9cm) = {
  let (w, h, walls, goal) = (inst.at(0), inst.at(1), inst.at(2), inst.at(5))
  let ctr(p) = (p.at(0) + 0.5, h - 0.5 - p.at(1))
  cetz.canvas(length: s, {
    import cetz.draw: *
    for x in range(w) {
      for y in range(h) {
        let fill = if walls.any(q => q == (x, y)) { namo-pal.wall } else { white }
        rect((x, h - 1 - y), (x + 1, h - y), fill: fill, stroke: 0.5pt + namo-pal.grid)
      }
    }
    content((goal.at(0) + 0.8, h - 0.2 - goal.at(1)), text(size: 0.7em, weight: "bold", fill: namo-pal.goal)[G])
    let robot = if path.len() > 0 { path.map(c => c.at(0)) } else { (inst.at(3),) }
    let obst = if path.len() > 0 { path.map(c => c.at(1)) } else { (inst.at(4),) }
    for k in range(obst.len() - 1) {
      if obst.at(k) != obst.at(k + 1) {
        line(ctr(obst.at(k)), ctr(obst.at(k + 1)), stroke: (paint: namo-pal.obstacle, thickness: 2.5pt, dash: "dashed"), mark: (end: ">", fill: namo-pal.obstacle))
      }
    }
    for k in range(robot.len() - 1) {
      line(ctr(robot.at(k)), ctr(robot.at(k + 1)), stroke: (paint: namo-pal.accent, thickness: 1.8pt), mark: (end: ">", fill: namo-pal.accent))
    }
    for (k, p) in robot.enumerate() {
      circle(ctr(p), radius: 0.24, fill: white, stroke: 0.8pt + namo-pal.accent)
      content(ctr(p), text(size: 0.6em, weight: "bold", fill: namo-pal.accent)[#k])
    }
    let last = obst.at(-1)
    rect((last.at(0) + 0.14, h - 0.86 - last.at(1)), (last.at(0) + 0.86, h - 0.14 - last.at(1)), fill: namo-pal.obstacle, radius: 0.12, stroke: 0.5pt + luma(90))
    content(ctr(last), text(size: 0.7em, weight: "bold", fill: white)[O])
  })
}

// A strip of boards for a list of configurations, numbered from 0.
#let namo-path-strip(inst, path, s: 0.38cm) = {
  if path == none {
    [no plan]
  } else {
    grid(
      columns: 3,
      column-gutter: 8pt,
      row-gutter: 6pt,
      ..path.enumerate().map(((i, c)) => namo-cfg-canvas(inst, c, s: s, badge: [#i])),
    )
  }
}

// ---------------------------------------------------------------------------------------------
// Geometric planning: a wavefront on a grid
// ---------------------------------------------------------------------------------------------

// State: a W×H array of distances from the start, with none (⊥) for cells not yet reached.
// F sets every unreached free cell that has a reached neighbour to one more than the smallest such
// neighbour, so the field is the breadth-first distance from the start. The projection walks back
// from the goal along decreasing distance and returns the route from start to goal, or none.
#let namo-wave-parts(g, s: 0.5cm) = {
  let (w, h, walls, start, goal) = (g.at(0), g.at(1), g.at(2), g.at(3), g.at(4))
  let blocked(p) = walls.any(q => q == p)
  let inside(p) = p.at(0) >= 0 and p.at(0) < w and p.at(1) >= 0 and p.at(1) < h
  let nbrs(p) = (
    (p.at(0) + 1, p.at(1)),
    (p.at(0) - 1, p.at(1)),
    (p.at(0), p.at(1) + 1),
    (p.at(0), p.at(1) - 1),
  ).filter(q => inside(q) and not blocked(q))

  let rho = g => range(h).map(y => range(w).map(x => if (x, y) == start { 0 } else { none }))

  let F = d => range(h).map(y => range(w).map(x => {
    let v = d.at(y).at(x)
    if v != none or blocked((x, y)) {
      v
    } else {
      let vals = nbrs((x, y)).map(q => d.at(q.at(1)).at(q.at(0))).filter(u => u != none)
      if vals.len() > 0 { calc.min(..vals) + 1 } else { none }
    }
  }))

  let pi = d => {
    let val(p) = d.at(p.at(1)).at(p.at(0))
    if val(goal) == none { return none }
    let cur = goal
    let route = (cur,)
    while val(cur) > 0 {
      let v = val(cur)
      cur = nbrs(cur).find(q => val(q) == v - 1)
      route.push(cur)
    }
    route.rev()
  }

  let X_h = (x, diff_mask: none) => {
    let reached = x.flatten().filter(v => v != none).len()
    namo-field-canvas(g, x, s: s, badge: [#reached #if reached == 1 [cell] else [cells] reached])
  }

  (rho: rho, F: F, pi: pi, X_h: X_h)
}

#let namo-wave-mc(g, s: 0.5cm, group-size: 3) = {
  let p = namo-wave-parts(g, s: s)
  mapcode-viz(
    p.rho,
    p.F,
    p.pi,
    I_h: i => namo-field-canvas(i, none, s: s),
    X_h: p.X_h,
    A_h: a => if a == none { [no plan] } else { namo-route-canvas(g, a, s: s) },
    F_name: [$F$],
    pi_name: [$mpi$],
    dim: 0,
    group-size: group-size,
    spacing: (12mm, 10mm),
  )(g)
}

// ---------------------------------------------------------------------------------------------
// NAMO solvers
// ---------------------------------------------------------------------------------------------

// Breadth-first search by layers. State: (frontier, seen, found).
// `seen` maps repr(cfg) to (repr(parent), cfg); the start has parent none.
#let namo-bfs-parts(inst, s: 0.38cm) = {
  let c0 = (inst.at(3), inst.at(4))
  let goal = inst.at(5)

  let rho = inst => (
    frontier: (c0,),
    seen: ((repr(c0)): (none, c0)),
    found: if c0.at(0) == goal { repr(c0) } else { none },
  )

  let F = x => {
    if x.found != none or x.frontier.len() == 0 { return x }
    let seen = x.seen
    let new = ()
    let found = none
    for c in x.frontier {
      for s2 in namo-succ(inst, c) {
        let k = repr(s2)
        if k in seen { continue }
        seen.insert(k, (repr(c), s2))
        new.push(s2)
        if found == none and s2.at(0) == goal { found = k }
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
        spacing: 4pt,
        namo-cfg-canvas(inst, x.seen.at(x.found).at(1), s: s, frame: true),
        align(center, text(size: 0.75em, fill: c-muted)[goal reached · #x.seen.len() configs seen]),
      )
    } else if x.frontier.len() == 0 {
      align(center, text(size: 0.75em, fill: c-muted)[no plan · #x.seen.len() configs seen])
    } else {
      stack(
        dir: ttb,
        spacing: 4pt,
        grid(
          columns: 3,
          column-gutter: 6pt,
          row-gutter: 4pt,
          ..x.frontier.map(c => namo-cfg-canvas(inst, c, s: s)),
        ),
        align(center, text(size: 0.75em, fill: c-muted)[layer of #x.frontier.len() · #x.seen.len() seen]),
      )
    }
  }

  (rho: rho, F: F, pi: pi, X_h: X_h)
}

// Best-first search. State: (open, seen, found). Each step of F pops the open configuration with
// the smallest Manhattan distance of its robot to the goal (earliest one on ties) and expands it.
#let namo-best-parts(inst, s: 0.38cm) = {
  let c0 = (inst.at(3), inst.at(4))
  let goal = inst.at(5)

  let rho = inst => (
    open: (c0,),
    seen: ((repr(c0)): (none, c0)),
    found: none,
  )

  let F = x => {
    if x.found != none or x.open.len() == 0 { return x }
    let idx = 0
    for (k, c) in x.open.enumerate() {
      if namo-h(inst, c) < namo-h(inst, x.open.at(idx)) { idx = k }
    }
    let open = x.open
    let c = open.remove(idx)
    if c.at(0) == goal {
      return (open: open, seen: x.seen, found: repr(c))
    }
    let seen = x.seen
    for s2 in namo-succ(inst, c) {
      let k = repr(s2)
      if k in seen { continue }
      seen.insert(k, (repr(c), s2))
      open.push(s2)
    }
    (open: open, seen: seen, found: none)
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
        spacing: 4pt,
        namo-cfg-canvas(inst, x.seen.at(x.found).at(1), s: s, frame: true),
        align(center, text(size: 0.75em, fill: c-muted)[goal popped · #x.seen.len() seen]),
      )
    } else if x.open.len() == 0 {
      align(center, text(size: 0.75em, fill: c-muted)[open list empty · no plan])
    } else {
      let shown = x.open.slice(0, calc.min(x.open.len(), 6))
      stack(
        dir: ttb,
        spacing: 4pt,
        grid(
          columns: 3,
          column-gutter: 6pt,
          row-gutter: 4pt,
          ..shown.map(c => namo-cfg-canvas(inst, c, s: s, badge: [h = #namo-h(inst, c)])),
        ),
        align(center, text(size: 0.75em, fill: c-muted)[
          open #x.open.len() · seen #x.seen.len()
          #if x.open.len() > 6 [ · first 6 shown]
        ]),
      )
    }
  }

  (rho: rho, F: F, pi: pi, X_h: X_h)
}

#let namo-bfs-mc(inst, s: 0.45cm, group-size: 3) = {
  let p = namo-bfs-parts(inst, s: s)
  mapcode-viz(
    p.rho,
    p.F,
    p.pi,
    I_h: i => namo-cfg-canvas(i, (inst.at(3), inst.at(4)), s: s),
    X_h: p.X_h,
    A_h: a => namo-path-strip(inst, a, s: s),
    F_name: [$F$],
    pi_name: [$mpi$],
    dim: 0,
    group-size: group-size,
    spacing: (12mm, 10mm),
  )(inst)
}

#let namo-best-mc(inst, s: 0.45cm, group-size: 3) = {
  let p = namo-best-parts(inst, s: s)
  mapcode-viz(
    p.rho,
    p.F,
    p.pi,
    I_h: i => namo-cfg-canvas(i, (inst.at(3), inst.at(4)), s: s),
    X_h: p.X_h,
    A_h: a => namo-path-strip(inst, a, s: s),
    F_name: [$F$],
    pi_name: [$mpi$],
    dim: 0,
    group-size: group-size,
    spacing: (12mm, 10mm),
  )(inst)
}

// The static grid obtained by treating the movable obstacle as a wall. Planning on it ignores
// that the obstacle can be moved, so it is the baseline that NAMO has to beat.
#let namo-static-grid(inst) = (
  inst.at(0),
  inst.at(1),
  inst.at(2) + ((inst.at(4).at(0), inst.at(4).at(1)),),
  inst.at(3),
  inst.at(5),
)

// Legend shared by every figure: what each symbol means.
#let namo-legend(s: 0.42cm) = cetz.canvas(length: s, {
  import cetz.draw: *
  let items = (
    (kind: "wall"),
    (kind: "robot"),
    (kind: "obstacle"),
    (kind: "goal"),
    (kind: "start"),
  )
  let labels = ("wall", "robot", "movable obstacle", "goal", "start")
  let x = 0
  for (k, it) in items.enumerate() {
    let y = 0
    if it.kind == "wall" { rect((x, y), (x + 0.8, y + 0.8), fill: namo-pal.wall) }
    if it.kind == "robot" { circle((x + 0.4, y + 0.4), radius: 0.34, fill: namo-pal.robot) }
    if it.kind == "obstacle" { rect((x + 0.08, y + 0.08), (x + 0.72, y + 0.72), fill: namo-pal.obstacle, radius: 0.1) }
    if it.kind == "goal" { rect((x, y), (x + 0.8, y + 0.8), fill: namo-pal.goal-bg, stroke: 0.35pt + namo-pal.grid) }
    if it.kind == "start" { rect((x, y), (x + 0.8, y + 0.8), fill: white, stroke: 1.2pt + namo-pal.start) }
    content((x + 0.4, y + 0.4), text(fill: if it.kind == "wall" or it.kind == "robot" or it.kind == "obstacle" { white } else { namo-pal.ink }, weight: "bold", size: 0.7em)[
      #if it.kind == "robot" [R] else if it.kind == "obstacle" [O] else if it.kind == "goal" [G] else if it.kind == "start" [S] else []
    ])
    content((x + 0.4, y - 0.9), anchor: "north", text(size: 0.75em, fill: luma(90))[#labels.at(k)])
    x += 2.6
  }
})
