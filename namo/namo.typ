#import "/lib/style.typ": *
#import "/lib/mapcode.typ": *
#import "/lib/viz.typ": *
#import "/lib/namo.typ": *

#set document(title: "Motion Planning on Grids as Mapcodes")
#set page(paper: "a4", margin: (x: 1.8cm, y: 2cm), numbering: "1")
#set text(size: 10pt)
#set par(justify: true)
#set heading(numbering: "1.")
#set math.equation(numbering: none)
#set cite(style: "apa")

// ---- Instances -------------------------------------------------------------------------------

// The NAMO door: walls at (2,0) and (2,2), the robot at (0,1), the movable obstacle in the door at
// (2,1), and the goal at (4,0).
#let namo-door = namo-inst(5, 3, ((2, 0), (2, 2)), (0, 1), (2, 1), (4, 0))

// Geometric planning: a grid with two wall segments and gaps; no movable obstacles.
#let geo-walls = range(3).map(y => (3, y)) + range(1, 5).map(y => (5, y))
#let geo = (7, 5, geo-walls, (0, 4), (6, 0))

// Plans, computed from the same mapcode that the figures draw.
#let wave-geo-plan = mapcode-hist(namo-wave-parts(geo).rho, namo-wave-parts(geo).F, namo-wave-parts(geo).pi)(geo).at(2)
#let static-door = namo-static-grid(namo-door)
#let wave-door-plan = mapcode-hist(namo-wave-parts(static-door).rho, namo-wave-parts(static-door).F, namo-wave-parts(static-door).pi)(static-door).at(2)
#let bfs-plan = mapcode-hist(namo-bfs-parts(namo-door).rho, namo-bfs-parts(namo-door).F, namo-bfs-parts(namo-door).pi)(namo-door).at(2)
#let best-plan = mapcode-hist(namo-best-parts(namo-door).rho, namo-best-parts(namo-door).F, namo-best-parts(namo-door).pi)(namo-door).at(2)

#align(center)[
  #text(size: 18pt, weight: "bold")[Motion Planning on Grids as Mapcodes]
  #v(3pt)
  #text(size: 11pt, fill: c-muted)[Geometric planning and navigation among movable obstacles]
]
#v(10pt)

= Problem

A robot must travel from a start cell to a goal cell on a grid. _Geometric planning_ asks for a route
around fixed walls. _Navigation among movable obstacles_ (NAMO) is harder: some obstacles can be
pushed, and they may block every route to the goal, so the robot must move them out of the way.
Deciding whether a NAMO plan exists is NP-hard in general #cite(<wilfong1991>, form: "prose").
#cite(<stilman2005>, form: "prose") introduced NAMO and planned over configurations of the robot and
the movable obstacles, using heuristic search.

#figure(
  caption: [The NAMO door. Walls are dark, $R$ is the robot, $O$ the movable obstacle, and $G$ the goal.
    The only passage is the door at $(2,1)$, which the obstacle blocks.],
  namo-plan-canvas(namo-door, (), s: 1.3cm),
)

#align(center)[#namo-legend()]

#figure(
  caption: [Geometric instance: walls with two gaps; start $S$ bottom-left, goal $G$ top-right.],
  namo-field-canvas(geo, none, s: 0.8cm),
)

== Model

A grid is $g = (W, H, S, s, g)$: its size, its wall cells $S$, a start $s$, and a goal $g$. A NAMO
instance adds one movable obstacle $o$ and a robot start $r_0$. A _configuration_ is a pair
$c = (r, o)$. One move steps the robot to a free neighbour $r'$. If $r'$ holds the obstacle, the robot
pushes it to $o + (r' - r)$, which must be free; otherwise the obstacle stays put. Moves are tried in
the order right, left, down, up.

= Geometric planning: a wavefront

The first case has no movable obstacles. The wavefront grows from the start one cell per step, so the
field it produces is the distance from the start to every reachable cell.

*As mapcode:*

#mc-spec(
  state: [$D$: the distance from the start for each cell, with $bot$ for cells not yet reached.],
  I: $I = (W, H, S, s, g)$,
  X: $X = (ZZ_(>=0) union {bot})^(W times H)$,
  A: $A = "Cells"^* union {bot}$,
  rho: [$rho(I)_c = cases(0 quad "if" c = s, bot quad "otherwise")$],
  F: [$F(D)_c = cases(D_c quad "if" D_c != bot "or" c "is a wall", 1 + min_(c' in N(c), D_(c') != bot) D_(c') quad "otherwise")$],
  pi: [$mpi(D) = "route"(g)$ if $D_g != bot$, else $bot$],
)

Here $N(c)$ are the non-wall neighbours of $c$, and a minimum over an empty set means $F(D)_c = bot$.
The route is read back from the goal by repeatedly stepping to a neighbour with distance one less,
then reversed.

_Correctness._ A reached cell keeps its value, so each value is set once. The values are the
breadth-first distances, so the field reaches a fixed point after at most $W dot H$ steps. The route
read back from the goal follows strictly decreasing distances, so it is a shortest route.

#figure(
  caption: [Wavefront on the geometric instance. Each state shows the distances reached so far, with a
    cell count in the caption. The last state is the fixed point, the distance field from the start.],
  namo-wave-mc(geo, s: 0.55cm, group-size: 3),
)

#figure(
  caption: [The route extracted by $mpi$ from the fixed point: from $S$ to $G$ around the two wall
    segments.],
  namo-route-canvas(geo, wave-geo-plan, s: 0.8cm),
)

= Why obstacles must be planned for

Suppose the movable obstacle is treated as a fixed wall. The wavefront then has no route through the
door, and the mapcode terminates with $mpi = bot$. This is the baseline that a NAMO planner has to
beat: a fixed-wall planner says there is no route at all, even though pushing the obstacle through
the door gives one.

#figure(
  caption: [The NAMO door with the obstacle treated as a wall. The wavefront fills the left room and
    never reaches the goal, so $mpi = bot$.],
  namo-wave-mc(static-door, s: 0.6cm, group-size: 3),
)

= Navigation among movable obstacles: layered search

The first NAMO solver searches over configurations $c = (r, o)$. It expands one layer per step of $F$
and stores each seen configuration with its parent, so the plan can be read back from the goal.

*As mapcode:*

#mc-spec(
  state: [$x = (Q, S, g)$: the current layer $Q$, the seen map $S$, and the goal $g$ once reached.],
  I: $I = (W, H, S_"walls", r_0, o_0, g_"cell")$,
  X: $X = "Layers" times "Maps" times ({bot} union "Configs")$,
  A: $A = "Configs"^* union {bot}$,
  rho: [$rho(I) = (⟨c_0⟩, {c_0 mapsto (bot, c_0)}, g_0)$],
  F: [$F(x) = (Q', S', g')$ if $g = bot$, $Q != emptyset$; else $F(x) = x$],
  pi: [$mpi(x) = "path"(g)$ if $g != bot$; else $bot$],
)

Here $c_0 = (r_0, o_0)$ and $g_0 = c_0$ if $r_0 = g_"cell"$, else $g_0 = bot$. In $F$, $Q'$ is the set
of unseen $c' in N(c)$ for $c in Q$, $S'$ extends $S$ by $c' mapsto (c, c')$, and $g'$ is the first
$c'$ in $Q'$ with the robot on $g_"cell"$. The helper $"path"(g)$ follows parents from $g$ back to
$c_0$ and reverses the result.

_Correctness._ Each configuration enters $S$ at most once, and there are finitely many configurations,
so $F$ reaches a fixed point. Each layer holds configurations at the same distance from $c_0$, so the
recovered path is a shortest sequence of moves.

#figure(
  caption: [Layered search on the NAMO door. Each state shows the current layer of configurations.
    The last state is the goal configuration reached, after 20 configurations have been seen.],
  namo-bfs-mc(namo-door, s: 0.5cm, group-size: 2),
)

#figure(
  caption: [The plan extracted by $mpi$: six configurations from $c_0$ to the goal, five moves. The
    robot's route is solid and numbered; the obstacle's route is dashed.],
  namo-plan-canvas(namo-door, bfs-plan, s: 1.1cm),
)

= Navigation among movable obstacles: best-first search

The second solver uses the Manhattan distance from the robot to the goal as a heuristic. Each step
expands the open configuration with the smallest value, earliest on ties, and it stops when it pops
a goal configuration. This is greedy search: it is not guaranteed to give the shortest plan.

*As mapcode:*

#mc-spec(
  state: [$x = (O, S, g)$: the open list $O$, the seen map $S$, and the goal $g$ once popped.],
  I: $I = (W, H, S_"walls", r_0, o_0, g_"cell")$,
  X: $X = "Lists" times "Maps" times ({bot} union "Configs")$,
  A: $A = "Configs"^* union {bot}$,
  rho: [$rho(I) = (⟨c_0⟩, {c_0 mapsto (bot, c_0)}, bot)$],
  F: [$F(x) = (O', S', g')$ if $g = bot$, $O != emptyset$; else $F(x) = x$],
  pi: [$mpi(x) = "path"(g)$ if $g != bot$; else $bot$],
)

In $F$, $c$ is the earliest entry of $O$ minimising $h(c) = |r_x - g_x| + |r_y - g_y|$. If $c$ is the
goal, the result has $g' = c$ and $S' = S$. Otherwise $c$ is removed from $O$, its unseen successors
are appended to $O$ and added to $S$, and $g' = bot$.

_Correctness._ As before, each configuration is pushed at most once, so the open list drains or the
goal is popped.

#figure(
  caption: [Best-first search on the NAMO door. Each state shows the open list with each entry's
    heuristic value $h$. Only the first six entries are drawn. The last state is the goal popped.],
  namo-best-mc(namo-door, s: 0.5cm, group-size: 2),
)

#figure(
  caption: [The plan extracted by $mpi$ from the best-first run: five moves, the same route as the
    layered search.],
  namo-plan-canvas(namo-door, best-plan, s: 1.1cm),
)

= Comparison

#table(
  columns: (auto, auto, auto, auto),
  align: (left, right, right, right),
  stroke: 0.4pt + c-grid,
  inset: 6pt,
  [*Method*], [*Configurations seen*], [*Plan moves*], [*Optimal*],
  [Wavefront, obstacle as wall], [no plan], [--], [--],
  [Layered breadth-first], [20], [5], [yes],
  [Best-first, Manhattan], [13], [5], [on this instance],
)

The wavefront is the geometric planner: it solves the static problem exactly and is fast on fixed
walls, but it cannot use a movable obstacle. The two NAMO solvers search over configurations, which
lets them push the obstacle. Both NAMO solvers find the same five-move plan. The comparison uses
one NAMO instance, so it does not show that best-first is faster in general.

#pagebreak()
#bibliography("/refs.bib", title: "References", style: "apa")
