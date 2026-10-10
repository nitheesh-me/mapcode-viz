#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let loop(F, x) = {
  let prev = none
  let curr = x
  while prev != curr {
    prev = curr
    curr = F(curr)
  }
  curr
}

#let limit-map(F) = x => loop(F, x)

#let mapcode(rho, F, pi) = inst => {
  let F_inf = limit-map(F)
  let x0 = rho(inst)
  let xn = F_inf(x0)
  let a = pi(xn)
  a
}

// returns the history, (inst [xs] ans)
#let mapcode-hist(rho, F, pi) = inst => {
  let x0 = rho(inst)
  let xs = (x0,)
  let xn = x0
  while true {
    xn = F(xn)
    if xn == xs.at(-1) {
      break
    }
    xs.push(xn)
  }
  let a = pi(xn)
  (inst, xs, a)
}
#let map_tensor(fun, dim: 0, idx: none) = x => {
  let stack = ()
  let results = ()

  stack.push((x, dim, idx))

  while stack.len() > 0 {
    let (x_curr, dim_curr, idx_curr) = stack.pop()

    if dim_curr == 0 {
      if idx_curr == none {
        results.push(fun(x_curr))
      } else {
        results.push(fun(x_curr)(idx_curr))
      }
    } else {
      let temp = x_curr
      if idx_curr != none {
        for i in idx_curr {
          temp = temp.at(i)
        }
      }

      for i in range(temp.len() - 1, -1, step: -1) {
        let next_idx = if idx_curr == none { (i,) } else { idx_curr + (i,) }
        stack.push((x_curr, dim_curr - 1, next_idx))
      }
    }
  }
  results
}

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

#let _find_dim(self) = (x, depth: 0) => {
  if x == none {
    depth
  } else if type(x) != array {
    depth
  } else {
    let depths = ()
    for item in x {
      depths.push(self(self)(item, depth: depth + 1))
    }
    calc.max(..depths)
  }
}
#let find_dim = _find_dim(_find_dim)


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
  scale-fig: 100%,
  group-size: 3,
  ..args,
) = inst => {
  let (inst, xs, ans) = mapcode-hist(rho, F, pi)(inst)
  let depth = find_dim(xs.at(0))
  if dim == none {
    depth = depth
  } else {
    depth = dim
  }

  // diff
  // let diffs = xs.windows(2).map(((prev, next)) => {
  //   range(next.len()).map((n) => prev.at(n) != next.at(n))
  // })
  // diffs.insert(0, range(xs.at(0).len()).map((n) => false))
  let _get_diff = self => (a, b, depth: 0) => {
    if depth <= 0 {
      a != b
    } else {
      let diffs = ()
      for i in range(a.len()) {
        diffs.push(self(self)(a.at(i), b.at(i), depth: depth - 1))
      }
      diffs
    }
  }
  let get_diff = _get_diff(_get_diff)
  let diffs = xs
    .windows(2)
    .map(((prev, next)) => {
      get_diff(prev, next, depth: depth)
    })
  diffs.insert(0, get_diff(xs.at(0), xs.at(0), depth: depth))

  // drop to depth if needed
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
          node((x_pos, y_pos), X_h(x_i, diff_mask: diffs.at(idx)))
        })
    })


  // cases for positioning of fixed point
  let x_pos_fix = group-size
  let y_pos_fix = if (calc.rem(xs.len(), group-size) in (0, 1)) { calc.div-euclid(xs.len(), group-size) } else {
    calc.div-euclid(xs.len(), group-size) + 1
  }
  if group-size == 1 {
    y_pos_fix = xs.len() - 1
  }

  box(scale(scale-fig, reflow: true)[#diagram(
    ..args,
    node((0, 0), I_h(inst), name: <inst>),
    edge(rho_name, "->"),
    (..grouped_nodes.flatten().intersperse(edge(F_name, "->")),),
    edge(pi_name, "->"),
    node((group-size, 0), A_h(ans)),

    edge((0, 0), (group-size, 0), f_name, "-->"),

    edge((x_pos_fix, y_pos_fix), (x_pos_fix, y_pos_fix), F_name, "->", bend: -100deg, loop-angle: 120deg),
    // edge((group-size, calc.div-euclid(xs.len(), group-size) + 1), (group-size, calc.div-euclid(xs.len(), group-size) + 1), F_name, "->", bend: -120deg, loop-angle: 90deg)
  )])
}

