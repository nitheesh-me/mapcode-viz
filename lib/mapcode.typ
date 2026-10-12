#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// Core model (mirrors `MapCodeUnverified` in Mapcode.lean):
//   run = π ∘ F^∞ ∘ ρ, where F^∞ iterates F until a fixed point.

#let loop(F, x, max-iter: 500) = {
  let prev = none
  let curr = x
  let n = 0
  while prev != curr {
    if n >= max-iter {
      panic("mapcode: no fixed point after " + str(max-iter) + " iterations of F")
    }
    prev = curr
    curr = F(curr)
    n += 1
  }
  curr
}

#let limit-map(F, max-iter: 500) = x => loop(F, x, max-iter: max-iter)

#let mapcode(rho, F, pi, max-iter: 500) = inst => pi(limit-map(F, max-iter: max-iter)(rho(inst)))

// returns the history, (inst [xs] ans); xs = (x0, F x0, ..., x*) with x* the fixed point
#let mapcode-hist(rho, F, pi, max-iter: 500) = inst => {
  let x0 = rho(inst)
  let xs = (x0,)
  let xn = x0
  while true {
    xn = F(xn)
    if xn == xs.at(-1) {
      break
    }
    if xs.len() >= max-iter {
      panic("mapcode: no fixed point after " + str(max-iter) + " iterations of F (is F strict and monotone?)")
    }
    xs.push(xn)
  }
  let a = pi(xn)
  (inst, xs, a)
}

// Lift a pointwise rule `fun(x)(idx)` to a whole-state map over an array of depth `dim`.
#let _map_tensor(self) = (fun, dim: 0, idx: ()) => x => {
  if dim == 0 {
    if idx == none {
      fun(x)
    } else {
      fun(x)(idx)
    }
  } else {
    let results = ()

    // slice till idx
    let temp = x
    if idx != none {
      for i in idx {
        temp = temp.at(i)
      }
    }

    for i in range(temp.len()) {
      results.push(self(self)(fun, dim: dim - 1, idx: idx + (i,))(x))
    }
    results
  }
}
#let map_tensor = _map_tensor(_map_tensor)

// Nesting depth of a state. A dictionary counts as one level (keyed cells);
// its values are compared as whole cells.
#let _find_dim(self) = (x, depth: 0) => {
  if type(x) == dictionary {
    depth + 1
  } else if type(x) != array {
    depth
  } else if x.len() == 0 {
    depth + 1
  } else {
    calc.max(..x.map(item => self(self)(item, depth: depth + 1)))
  }
}
#let find_dim = _find_dim(_find_dim)

// Cell-wise change mask between two states, `depth` levels deep.
// Arrays give arrays of masks, dictionaries give dictionaries of masks;
// shape mismatches collapse to a single bool.
#let _get_diff(self) = (a, b, depth: 0) => {
  if depth <= 0 or type(a) != type(b) {
    a != b
  } else if type(a) == array {
    if a.len() != b.len() {
      a != b
    } else {
      range(a.len()).map(i => self(self)(a.at(i), b.at(i), depth: depth - 1))
    }
  } else if type(a) == dictionary {
    let diffs = (:)
    for k in b.keys() {
      diffs.insert(k, self(self)(a.at(k, default: none), b.at(k), depth: depth - 1))
    }
    diffs
  } else {
    a != b
  }
}
#let get_diff = _get_diff(_get_diff)

// Safe lookup into a diff mask (works for nested arrays, dictionaries, or a bare bool).
#let mask-at(mask, ..idx) = {
  let m = mask
  for i in idx.pos() {
    if type(m) == array or type(m) == dictionary {
      m = m.at(i, default: false)
    } else {
      return m == true
    }
  }
  m == true
}

#let mapcode-viz(
  rho,
  F,
  pi,
  I_h: i => [#i],
  X_h: (x, diff_mask: none) => [#x],
  A_h: a => [#a],
  f_name: [$f$],
  rho_name: [$rho$],
  F_name: [$F$],
  pi_name: [$pi$],
  dim: none,
  scale-fig: auto,
  group-size: 3,
  // Optional annotations from the verified model (`Mapcode` in Mapcode.lean):
  // sigma: X -> Nat, a variant that strictly decreases until the fixed point;
  // theta: X -> A, an invariant preserved by F that equals π at the fixed point.
  sigma: none,
  theta: none,
  sigma_name: [$sigma$],
  theta_name: [$theta$],
  max-iter: 500,
  ..args,
) = inst => {
  let (inst, xs, ans) = mapcode-hist(rho, F, pi, max-iter: max-iter)(inst)
  let depth = if dim == none { find_dim(xs.at(0)) } else { dim }

  let diffs = xs.windows(2).map(((prev, next)) => get_diff(prev, next, depth: depth))
  diffs.insert(0, get_diff(xs.at(0), xs.at(0), depth: depth))

  let annotate(x, body) = {
    if sigma == none and theta == none { return body }
    let notes = ()
    if sigma != none { notes.push([#sigma_name $= #sigma(x)$]) }
    if theta != none { notes.push([#theta_name $= #theta(x)$]) }
    stack(
      dir: ttb,
      spacing: 3pt,
      body,
      align(center, text(size: 0.75em, fill: luma(90), notes.join(h(0.8em)))),
    )
  }

  let grouped_nodes = xs
    .chunks(group-size)
    .enumerate(start: 1)
    .map(((group_idx, group)) => {
      group
        .enumerate()
        .map(((i, x_i)) => {
          let idx = (group_idx - 1) * group-size + i
          let x_pos = if idx < xs.len() - 1 { i } else { group-size }
          let y_pos = if (idx == xs.len() - 1 and i == 0) { group_idx - 1 } else { group_idx }
          node((x_pos, y_pos), annotate(x_i, X_h(x_i, diff_mask: diffs.at(idx))), name: label("s" + str(idx)))
        })
    })
    .flatten()

  // F edges between consecutive states. The edge wrapping to the next row runs from the
  // lower-left corner of the last state of a row to the upper-right corner of the first state
  // of the next row, so it stays in the gap between the rows instead of crossing other nodes.
  let chain = ()
  for (idx, n) in grouped_nodes.enumerate() {
    if idx > 0 {
      let wraps = calc.rem(idx, group-size) == 0 and idx < xs.len() - 1
      chain.push(if wraps {
        edge(
          label("s" + str(idx - 1) + ".south-west"),
          label("s" + str(idx) + ".north-east"),
          F_name,
          "->",
          label-side: center,
          label-pos: 0.5,
          label-fill: white,
        )
      } else { edge(F_name, "->") })
    }
    chain.push(n)
  }

  // cases for positioning of fixed point
  let x_pos_fix = group-size
  let y_pos_fix = if (calc.rem(xs.len(), group-size) in (0, 1)) { calc.div-euclid(xs.len(), group-size) } else {
    calc.div-euclid(xs.len(), group-size) + 1
  }
  if group-size == 1 {
    y_pos_fix = xs.len() - 1
  }

  // Rectangular nodes by default: fletcher's auto shape turns square-ish states (tables)
  // into circles, which makes edges overlap them.
  let fig = diagram(
    ..args.pos(),
    ..((node-shape: rect) + args.named()),
    node((0, 0), I_h(inst), name: <inst>),
    edge(rho_name, "->"),
    ..chain,
    edge(pi_name, "->"),
    node((group-size, 0), A_h(ans)),

    edge((0, 0), (group-size, 0), f_name, "-->"),

    edge((x_pos_fix, y_pos_fix), (x_pos_fix, y_pos_fix), F_name, "->", bend: -100deg, loop-angle: 120deg),
  )

  // Scale by `scale-fig`, but never wider than the available width.
  layout(size => {
    let w = measure(fig).width
    let fit = if w > 0pt and size.width < w { size.width / w * 100% } else { 100% }
    let s = if scale-fig == auto { fit } else { calc.min(scale-fig, fit) }
    box(scale(s, reflow: true, fig))
  })
}
