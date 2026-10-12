universe u v w

structure MapCodeUnverified where
  {I : Type u}
  {A : Type v}
  {X : Type w}
  ρ : I → X
  F : X → X
  π : X → A
  EQX : X → X → Prop := (· = ·)
  EQX_equiv : Equivalence EQX := by exact ⟨Eq.refl, Eq.symm, Eq.trans⟩
namespace MapCodeUnverified

variable (m : MapCodeUnverified) [DecidableRel m.EQX]

partial def runTillFix (x : m.X) : m.X :=
  let x' := m.F x
  if m.EQX x' x then x else runTillFix x'

def run : m.I → m.A :=
  m.π ∘ m.runTillFix ∘ m.ρ

end MapCodeUnverified


namespace MapCodeUnverified.Example
/-! ### Example: factorial

State `(n, acc)`; each step moves `n` into the accumulator until `n = 0`. -/
-- `reducible` lets instance search unfold `EQ` to `=`, inferring `DecidableRel EQ`.
@[reducible]
def factorialMC : MapCodeUnverified where
  ρ n := (n, 1)
  F
    | (n + 1, acc) => (n, acc * (n + 1))
    | s => s
  π := Prod.snd


def factorial (n : Nat) : Nat :=
  factorialMC.run n

#eval factorial 5     -- 120
#reduce factorial 5   -- `runTillFix` is opaque(by partial) so not reduciable
#guard factorial 5 = 120

/-- Factorial counting up: state `(k, acc)` with `k ≤ n`; `acc` runs through `1, 1*2, 1*2*3, …`. -/
@[reducible]
def factorialMC' (n : Nat) : MapCodeUnverified where
  I := Nat
  A := Nat
  X := {s : Nat × Nat // s.1 ≤ n}
  ρ n := ⟨(0, 1), by simp⟩
  F | ⟨(k, acc), h⟩ =>
    if hk : k < n
    then ⟨(k + 1, acc * (k + 1)), hk⟩
    else ⟨(k, acc), h⟩
  π | ⟨(_, acc), _⟩ => acc

def factorial' (n : Nat) : Nat :=
  (factorialMC' n).run n

#eval factorial' 5     -- 120
#reduce factorial' 5   -- `runTillFix` is opaque(by partial) so not reduciable
#guard factorial' 5 = 120
#print axioms factorialMC'

/-! ### Example: bubble sort -/

def bubble : List Nat → List Nat
  | [] => []
  | [x] => [x]
  | x :: y :: rest =>
    if x ≤ y then
      x :: bubble (y :: rest)
    else
      y :: bubble (x :: rest)

def bubbleSortN : Nat → List Nat → List Nat
  | 0, l => l
  | k + 1, l => bubbleSortN k (bubble l)

def bubbleSort (l : List Nat) : List Nat :=
  bubbleSortN l.length l

/-- Bubble sort: state `(k, l)` where `k` is the number of remaining bubble passes. -/
@[reducible]
def bubbleSortMC : MapCodeUnverified where
  I := List Nat
  A := List Nat
  X := Nat × List Nat
  ρ l := (l.length, l)
  F
    | (k + 1, l) => (k, bubble l)
    | s => s
  π := Prod.snd

def bsort (l : List Nat) : List Nat :=
  bubbleSortMC.run l

#eval bsort [5, 1, 4, 2, 8]     -- [1, 2, 4, 5, 8]
#guard bsort [5, 1, 4, 2, 8] = [1, 2, 4, 5, 8]

/-- Parameterized bubble sort on a fixed input list `orig`. -/
@[reducible]
def bubbleSortMC' (orig : List Nat) : MapCodeUnverified where
  I := Unit
  A := List Nat
  X := Nat × List Nat
  ρ _ := (orig.length, orig)
  F
    | (k + 1, l) => (k, bubble l)
    | s => s
  π := Prod.snd

def bsort' (orig : List Nat) : List Nat :=
  (bubbleSortMC' orig).run ()

#eval bsort' [5, 1, 4, 2, 8]    -- [1, 2, 4, 5, 8]
#guard bsort' [5, 1, 4, 2, 8] = [1, 2, 4, 5, 8]
end MapCodeUnverified.Example


structure Mapcode extends MapCodeUnverified where
  f : I → A
  σ : X → Nat
  θ : X → A
  EQA : A → A → Prop := (· = ·)
  EQA_equiv : Equivalence EQA := by exact ⟨Eq.refl, Eq.symm, Eq.trans⟩
  σ_decreases : ∀ x, ¬ EQX (F x) x → σ (F x) < σ x  -- variant: strictly decreases
  θ_init : ∀ i, EQA (θ (ρ i)) (f i)                 -- initialization: `θ` starts at the spec
  θ_preserved : ∀ x, EQA (θ (F x)) (θ x)            -- preservation: every step keeps `θ`
  θ_final : ∀ x, EQX (F x) x → EQA (θ x) (π x)      -- at exit `θ` is the output


namespace Mapcode
variable (m : Mapcode) [DecidableRel m.EQX]

instance : Trans m.EQA m.EQA m.EQA := ⟨m.EQA_equiv.trans⟩

def runTillFix (x : m.X) : {xf : m.X // m.EQX (m.F xf) xf ∧ m.EQA (m.θ xf) (m.θ x)} :=
  if hx : m.EQX (m.F x) x then
    ⟨x, hx, m.EQA_equiv.refl _⟩
  else
    let ⟨xf, hfix, hθ⟩ := runTillFix (m.F x)
    ⟨xf, hfix, calc
      m.EQA (m.θ xf) (m.θ (m.F x)) := hθ
      m.EQA _        (m.θ x)       := m.θ_preserved x⟩
  termination_by m.σ x
  decreasing_by exact m.σ_decreases x hx

def runWithProof (i : m.I) : {a : m.A // m.EQA a (m.f i)} :=
  let ⟨xf, hfix, hθ⟩ := m.runTillFix (m.ρ i)
  ⟨m.π xf, calc
    m.EQA (m.π xf) (m.θ xf)      := m.EQA_equiv.symm (m.θ_final xf hfix)
    m.EQA _        (m.θ (m.ρ i)) := hθ
    m.EQA _        (m.f i)       := m.θ_init i⟩

end Mapcode


namespace Mapcode.Example

open MapCodeUnverified.Example (factorialMC)

/-- There exists a duplicate-free list containing exactly the natural numbers from 1 to n, whose product is p.-/
def IsFact (n p : Nat) : Prop :=
  ∃ l : List Nat,
    l.Nodup ∧
    (∀ k, k ∈ l ↔ 1 ≤ k ∧ k ≤ n) ∧
    l.prod = p

/-- Two duplicate-free lists with the same members are permutations of each other.
(Core Lean lacks Mathlib's `List.perm_ext_iff_of_nodup`, so we prove it via counts:
a duplicate-free list has every count `≤ 1`, and count `> 0` is membership.) -/
theorem perm_of_nodup {l l' : List Nat} (h : l.Nodup) (h' : l'.Nodup)
    (hm : ∀ k, k ∈ l ↔ k ∈ l') : l.Perm l' := by
  rw [List.perm_iff_count]
  intro a
  have h1 := List.nodup_iff_count.mp h a
  have h2 := List.nodup_iff_count.mp h' a
  have h3 : 0 < List.count a l ↔ 0 < List.count a l' := by
    simp [List.count_pos_iff, hm]
  omega

theorem IsFact.unique {n p q : Nat} : IsFact n p → IsFact n q → p = q := by
  rintro ⟨l, hl, hmem, rfl⟩ ⟨l', hl', hmem', rfl⟩
  exact (perm_of_nodup hl hl' fun k => (hmem k).trans (hmem' k).symm).prod_nat
#print axioms  IsFact.unique


theorem isFact_range (n : Nat) : IsFact n (List.range' 1 n).prod :=
  ⟨_, List.nodup_range', fun _ => by simp [List.mem_range'_1]; omega, rfl⟩
#print axioms  isFact_range

private def factImpl (n : Nat) : Nat := (List.range' 1 n).prod

/-- Factorial, specified as `IsFact` (no order); compiled via `factImpl`. -/
@[implemented_by factImpl]
noncomputable def fact (n : Nat) : Nat := Classical.choose ⟨_, isFact_range n⟩

theorem isFact_fact (n : Nat) : IsFact n (fact n) := Classical.choose_spec ⟨_, isFact_range n⟩
#print axioms  isFact_fact

theorem fact_zero : fact 0 = 1 :=
  (isFact_fact 0).unique ⟨[], .nil, by simp; omega, rfl⟩
#print axioms  fact_zero

theorem fact_succ (n : Nat) : fact (n + 1) = (n + 1) * fact n := by
  obtain ⟨l, hl, hmem, hp⟩ := isFact_fact n
  refine (isFact_fact (n + 1)).unique ⟨(n + 1) :: l, ?_, ?_, ?_⟩
  · exact .cons (fun k hk => by have := (hmem k).mp hk; omega) hl
  · intro k; simp [hmem]; omega
  · simp [hp]
#print axioms  fact_succ

/-- `factorialMC` with `θ (n, acc) = acc * n!`, preserved by every step. -/
@[reducible]
def factorialMCV : Mapcode where
  toMapCodeUnverified := factorialMC
  f := fact
  σ := Prod.fst
  θ | (n, acc) => acc * fact n
  σ_decreases
    | (0, _), h => (h rfl).elim
    | (n + 1, _), _ => n.lt_succ_self
  θ_init n := Nat.one_mul _
  θ_preserved
    | (0, _) => rfl
    | (n + 1, acc) =>
      show acc * (n + 1) * fact n = acc * fact (n + 1) by rw [fact_succ, Nat.mul_assoc]
  θ_final
    | (0, acc), _ =>
      show acc * fact 0 = acc from (congrArg (acc * ·) fact_zero).trans acc.mul_one
    | (n + 1, _), h => absurd (congrArg Prod.fst h) n.succ_ne_self.symm

/-- `factorialMC' n` with `θ (k, acc) = acc * (k+1)⋯n`, preserved by every step. -/
@[reducible]
def factorialMCV' (n : Nat) : Mapcode where
  toMapCodeUnverified := MapCodeUnverified.Example.factorialMC' n
  f _ := fact n
  σ | ⟨(k, _), _⟩ => n - k
  θ | ⟨(k, acc), _⟩ => acc * (List.range' (k + 1) (n - k)).prod
  σ_decreases
    | ⟨(k, acc), h⟩, hne => by
      by_cases hk : k < n
      · simp [hk]; omega
      · exact (hne (by simp [hk])).elim
  θ_init _ := by simpa using ((isFact_fact n).unique (isFact_range n)).symm
  θ_preserved
    | ⟨(k, acc), h⟩ => by
      by_cases hk : k < n
      · have : n - k = n - (k + 1) + 1 := by omega
        simp [hk, this, List.range'_succ, Nat.mul_assoc]
      · simp [hk]
  θ_final
    | ⟨(k, acc), h⟩, hfix => by
      have h : k ≤ n := h
      by_cases hk : k < n
      · simp [hk] at hfix
      · obtain rfl : k = n := by omega
        simp [MapCodeUnverified.Example.factorialMC']

def factorial' (n : Nat) : {a : Nat // a = fact n} :=
  (factorialMCV' n).runWithProof n

#eval (factorial' 5).val   -- 120

def factorial (n : Nat) : {a : Nat // a = fact n} :=
  factorialMCV.runWithProof n

#reduce (factorial 5).val
#eval (factorial 5).val   -- 120
#guard (factorial 5).val = 120
#check (factorial 5).property

open MapCodeUnverified.Example (bubble bubbleSortN bubbleSort bubbleSortMC bubbleSortMC')

theorem bubble_length : ∀ (l : List Nat), (bubble l).length = l.length
  | [] => by unfold bubble; rfl
  | [x] => by unfold bubble; rfl
  | x :: y :: rest => by
    unfold bubble
    split
    · simp [bubble_length (y :: rest)]
    · simp [bubble_length (x :: rest)]

theorem bubble_perm : ∀ (l : List Nat), (bubble l).Perm l
  | [] => by unfold bubble; exact .nil
  | [x] => by unfold bubble; exact .refl _
  | x :: y :: rest => by
    unfold bubble
    split
    · exact .cons x (bubble_perm (y :: rest))
    · exact .trans (.cons y (bubble_perm (x :: rest))) (.swap x y rest)

/-- `bubbleSortMC` with `θ (k, l) = bubbleSortN k l`, preserved by every step. -/
@[reducible]
def bubbleSortMCV : Mapcode where
  toMapCodeUnverified := bubbleSortMC
  f := bubbleSort
  σ := Prod.fst
  θ | (k, l) => bubbleSortN k l
  σ_decreases
    | (0, _), h => (h rfl).elim
    | (k + 1, _), _ => Nat.lt_succ_self k
  θ_init _ := rfl
  θ_preserved
    | (0, _) => rfl
    | (k + 1, _) => rfl
  θ_final
    | (0, _), _ => rfl
    | (k + 1, _), h => absurd (congrArg Prod.fst h) k.succ_ne_self.symm

def bsortVerified (l : List Nat) : {a : List Nat // a = bubbleSort l} :=
  bubbleSortMCV.runWithProof l

#eval (bsortVerified [5, 1, 4, 2, 8]).val   -- [1, 2, 4, 5, 8]
#guard (bsortVerified [5, 1, 4, 2, 8]).val = [1, 2, 4, 5, 8]
#check (bsortVerified [5, 1, 4, 2, 8]).property

/-- Parameterized verified bubble sort on a fixed input list `orig`. -/
@[reducible]
def bubbleSortMCV' (orig : List Nat) : Mapcode where
  toMapCodeUnverified := bubbleSortMC' orig
  f _ := bubbleSort orig
  σ := Prod.fst
  θ | (k, l) => bubbleSortN k l
  σ_decreases
    | (0, _), h => (h rfl).elim
    | (k + 1, _), _ => Nat.lt_succ_self k
  θ_init _ := rfl
  θ_preserved
    | (0, _) => rfl
    | (k + 1, _) => rfl
  θ_final
    | (0, _), _ => rfl
    | (k + 1, _), h => absurd (congrArg Prod.fst h) k.succ_ne_self.symm

def bsortVerified' (orig : List Nat) : {a : List Nat // a = bubbleSort orig} :=
  (bubbleSortMCV' orig).runWithProof ()

#eval (bsortVerified' [5, 1, 4, 2, 8]).val  -- [1, 2, 4, 5, 8]
#guard (bsortVerified' [5, 1, 4, 2, 8]).val = [1, 2, 4, 5, 8]

end Mapcode.Example


/-- `Mapcode` with an invariant `Inv` that holds initially and is maintained by `F`.
Unlike `θ`, it makes no correctness claim. -/
structure MapcodeInv extends Mapcode where
  Inv : X → Prop
  Inv_initial : ∀ i, Inv (ρ i)                      -- initialization
  Inv_preserved : ∀ x, Inv x → Inv (F x)            -- preservation

namespace MapcodeInv
variable (m : MapcodeInv) [DecidableRel m.EQX]

omit [DecidableRel m.EQX] in
/-- `Inv` holds after any number of steps from any initial state. -/
theorem inv_iterate (i : m.I) : ∀ k, m.Inv (Nat.repeat m.F k (m.ρ i))
  | 0 => m.Inv_initial i
  | k + 1 => m.Inv_preserved _ (inv_iterate i k)
#print axioms inv_iterate

def runTillFix (x : m.X) (h : m.Inv x) :
    {xf : m.X // m.Inv xf ∧ m.EQX (m.F xf) xf ∧ m.EQA (m.θ xf) (m.θ x)} :=
  if hx : m.EQX (m.F x) x then
    ⟨x, h, hx, m.EQA_equiv.refl _⟩
  else
    let ⟨xf, hinv, hfix, hθ⟩ := runTillFix (m.F x) (m.Inv_preserved x h)
    ⟨xf, hinv, hfix, calc
      m.EQA (m.θ xf) (m.θ (m.F x)) := hθ
      m.EQA _        (m.θ x)       := m.θ_preserved x⟩
  termination_by m.σ x
  decreasing_by exact m.σ_decreases x hx

/-- The result, together with a fixed point satisfying `Inv` that it is read from. -/
def runWithInv (i : m.I) :
    {a : m.A // m.EQA a (m.f i) ∧ ∃ x, m.Inv x ∧ m.EQX (m.F x) x ∧ a = m.π x} :=
  let ⟨xf, hinv, hfix, hθ⟩ := m.runTillFix (m.ρ i) (m.Inv_initial i)
  ⟨m.π xf, calc
    m.EQA (m.π xf) (m.θ xf)      := m.EQA_equiv.symm (m.θ_final xf hfix)
    m.EQA _        (m.θ (m.ρ i)) := hθ
    m.EQA _        (m.f i)       := m.θ_init i, xf, hinv, hfix, rfl⟩

def runWithProof (i : m.I) : {a : m.A // m.EQA a (m.f i)} :=
  let ⟨a, hθ, _⟩ := m.runWithInv i
  ⟨a, hθ⟩

end MapcodeInv


namespace MapcodeInv.Example

open Mapcode.Example (factorialMCV factorialMCV' fact fact_zero fact_succ)

/-- Factorial with the invariant that the accumulator stays positive. -/
@[reducible]
def factorialMCI : MapcodeInv where
  toMapcode := factorialMCV
  Inv | (_, acc) => 0 < acc
  Inv_initial _ := Nat.one_pos
  Inv_preserved
    | (0, _), h => h
    | (n + 1, _), h => Nat.mul_pos h n.succ_pos

example (n k : Nat) : 0 < (Nat.repeat factorialMCI.F k (factorialMCI.ρ n)).snd :=
  factorialMCI.inv_iterate n k

/-- Counting-up factorial with the invariant `acc = k!`. -/
@[reducible]
def factorialMCI' (n : Nat) : MapcodeInv where
  toMapcode := factorialMCV' n
  Inv | ⟨(k, acc), _⟩ => acc = fact k
  Inv_initial _ := fact_zero.symm
  Inv_preserved
    | ⟨(k, acc), h⟩, hinv => by
      by_cases hk : k < n
      · simp [hk, fact_succ, hinv, Nat.mul_comm]
      · simp [hk, hinv]

end MapcodeInv.Example

/-! ## Bubble sort with the full state

`bubble` is no longer a primitive: one `F` step performs a single compare-and-swap.
The state `(u, j, l)` holds the length `u` of the unsorted prefix, the position `j` of the
next comparison, and the list. -/
namespace Mapcode.BubbleFull

open MapCodeUnverified.Example (bubble)

/-- Compare-and-swap at positions `j`, `j+1` (identity when out of range). -/
def cswap (j : Nat) (l : List Nat) : List Nat :=
  match l.drop j with
  | x :: y :: rest => l.take j ++ (if x ≤ y then [x, y] else [y, x]) ++ rest
  | _ => l

/-- Specification of one pass restricted to the prefix of length `u`. -/
def bubblePrefix (u : Nat) (l : List Nat) : List Nat := bubble (l.take u) ++ l.drop u

/-- Recursive bubble sort with shrinking passes: the specification. -/
def bsU : Nat → List Nat → List Nat
  | u + 2, l => bsU (u + 1) (bubblePrefix (u + 2) l)
  | _, l => l

/-- What remains of the current pass from position `j` within the prefix of length `u`. -/
def finishPass (u j : Nat) (l : List Nat) : List Nat :=
  let j' := min j u
  l.take j' ++ bubble ((l.drop j').take (u - j')) ++ l.drop u

/-! ### One pass as a mapcode -/

@[reducible]
def bubblePassMC : MapCodeUnverified where
  I := List Nat
  A := List Nat
  X := Nat × List Nat
  ρ l := (0, l)
  F | (j, l) => if j + 1 < l.length then (j + 1, cswap j l) else (j, l)
  π := Prod.snd

#guard bubblePassMC.run [5, 1, 4, 2, 8] = bubble [5, 1, 4, 2, 8]

/-! ### Full bubble sort as a mapcode -/

@[reducible]
def bubbleSortMC : MapCodeUnverified where
  I := List Nat
  A := List Nat
  X := Nat × Nat × List Nat
  ρ l := (l.length, 0, l)
  F | (u, j, l) =>
      if u ≤ 1 then (u, j, l)
      else if j + 1 < u then (u, j + 1, cswap j l)
      else (u - 1, 0, l)
  π | (_, _, l) => l

#guard bubbleSortMC.run [5, 1, 4, 2, 8] = [1, 2, 4, 5, 8]
#guard bubbleSortMC.run [4, 3, 1, 2] = [1, 2, 3, 4]
#guard bubbleSortMC.run [] = []

/-! ### Lemmas -/

theorem bubble_short : ∀ l : List Nat, l.length ≤ 1 → bubble l = l
  | [], _ => by unfold bubble; rfl
  | [_], _ => by unfold bubble; rfl
  | _ :: _ :: _, h => by simp at h

theorem cswap_eq (p rest : List Nat) (x y : Nat) :
    cswap p.length (p ++ x :: y :: rest) = p ++ (if x ≤ y then [x, y] else [y, x]) ++ rest := by
  simp [cswap]

theorem length_cswap (j : Nat) (l : List Nat) : (cswap j l).length = l.length := by
  unfold cswap
  split
  · rename_i x y rest h
    have hl := congrArg List.length (List.take_append_drop j l)
    rw [h] at hl
    split <;> simp at hl ⊢ <;> omega
  · rfl

theorem take_mid1 (p t : List Nat) (a : Nat) : (p ++ a :: t).take (p.length + 1) = p ++ [a] := by
  induction p with
  | nil => simp
  | cons h p ih => simp [ih]

theorem drop_mid1 (p t : List Nat) (a : Nat) : (p ++ a :: t).drop (p.length + 1) = t := by
  induction p with
  | nil => simp
  | cons h p ih => simp [ih]

theorem drop_mid2 (p rest : List Nat) (a b k : Nat) :
    (p ++ a :: b :: rest).drop (p.length + 2 + k) = rest.drop k := by
  induction p with
  | nil => simp [Nat.add_comm 2 k]
  | cons h p ih =>
    have : (h :: p).length + 2 + k = (p.length + 2 + k) + 1 := by simp; omega
    rw [this]; simp [ih]

theorem step_core (p rest : List Nat) (x y k : Nat) :
    finishPass (p.length + 2 + k) (p.length + 1) (cswap p.length (p ++ x :: y :: rest))
      = finishPass (p.length + 2 + k) p.length (p ++ x :: y :: rest) := by
  rw [cswap_eq]
  unfold finishPass
  have h1 : min (p.length + 1) (p.length + 2 + k) = p.length + 1 := by omega
  have h0 : min p.length (p.length + 2 + k) = p.length := by omega
  have e1 : p.length + 2 + k - (p.length + 1) = k + 1 := by omega
  have e0 : p.length + 2 + k - p.length = k + 2 := by omega
  simp only [h1, h0, e1, e0]
  by_cases hxy : x ≤ y
  · simp only [hxy, ite_true, List.append_assoc, List.cons_append, List.nil_append]
    rw [take_mid1, drop_mid1, drop_mid2, List.take_left, List.drop_left]
    simp [bubble, hxy]
  · simp only [hxy, ite_false, List.append_assoc, List.cons_append, List.nil_append]
    rw [take_mid1, drop_mid1, drop_mid2, drop_mid2, List.take_left, List.drop_left]
    simp [bubble, hxy]

/-- One compare-and-swap inside the pass does not change the result of finishing the pass. -/
theorem finishPass_step (u j : Nat) (l : List Nat) (hj : j + 1 < u) :
    finishPass u (j + 1) (cswap j l) = finishPass u j l := by
  cases hd : l.drop j with
  | cons x t =>
    cases t with
    | cons y rest =>
      have hl : l = l.take j ++ x :: y :: rest := by rw [← hd, List.take_append_drop]
      have hlen : (l.take j).length = j := by
        have := congrArg List.length hl; simp at this ⊢; omega
      have e := step_core (l.take j) rest x y (u - j - 2)
      rw [hlen, ← hl, show j + 2 + (u - j - 2) = u by omega] at e
      exact e
    | nil =>
      have hc : cswap j l = l := by unfold cswap; rw [hd]
      have hlen : l.length ≤ j + 1 := by
        have := congrArg List.length (List.take_append_drop j l); rw [hd] at this; simp at this; omega
      rw [hc]; unfold finishPass
      have h1 : min (j + 1) u = j + 1 := by omega
      have h0 : min j u = j := by omega
      have e : u - j = (u - j - 1) + 1 := by omega
      simp only [h1, h0]
      rw [List.drop_eq_nil_of_le (show l.length ≤ j + 1 by omega),
        List.drop_eq_nil_of_le (show l.length ≤ u by omega), List.take_of_length_le hlen, hd, e]
      simp only [List.take_succ_cons, List.take_nil, bubble_short [] (by simp),
        bubble_short [x] (by simp), List.append_nil]
      conv => lhs; rw [← List.take_append_drop j l, hd]
  | nil =>
    have hc : cswap j l = l := by unfold cswap; rw [hd]
    have hlen : l.length ≤ j := by
      have := congrArg List.length (List.take_append_drop j l); rw [hd] at this; simp at this; omega
    rw [hc]; unfold finishPass
    have h1 : min (j + 1) u = j + 1 := by omega
    have h0 : min j u = j := by omega
    simp only [h1, h0]
    rw [List.drop_eq_nil_of_le (show l.length ≤ j + 1 by omega),
      List.drop_eq_nil_of_le (show l.length ≤ u by omega), hd,
      List.take_of_length_le (show l.length ≤ j + 1 by omega), List.take_of_length_le hlen]
    simp

/-- At the end of a pass (`u ≤ j + 1`) there is nothing left to do. -/
theorem finishPass_end (u j : Nat) (l : List Nat) (h : u ≤ j + 1) : finishPass u j l = l := by
  unfold finishPass
  by_cases hju : u ≤ j
  · have : min j u = u := by omega
    simp [this, bubble_short [] (by simp)]
  · have : min j u = j := by omega
    simp only [this]
    have e : u - j = 1 := by omega
    rw [e, bubble_short _ (by simp; omega)]
    have : l.drop u = (l.drop j).drop 1 := by rw [List.drop_drop]; congr 1; omega
    rw [this, List.append_assoc, List.take_append_drop, List.take_append_drop]

theorem finishPass_start (u : Nat) (l : List Nat) : finishPass u 0 l = bubblePrefix u l := by
  simp [finishPass, bubblePrefix]

theorem bsU_small (u : Nat) (l : List Nat) (h : u ≤ 1) : bsU u l = l := by
  match u, h with
  | 0, _ => rfl
  | 1, _ => rfl

theorem bsU_step (u : Nat) (l : List Nat) (h : 2 ≤ u) : bsU u l = bsU (u - 1) (bubblePrefix u l) := by
  obtain ⟨v, rfl⟩ : ∃ v, u = v + 2 := ⟨u - 2, by omega⟩
  rfl

/-! ### Verified: one pass computes `bubble` -/

@[reducible]
def bubblePassMCV : Mapcode where
  toMapCodeUnverified := bubblePassMC
  f := bubble
  σ | (j, l) => l.length - j
  θ | (j, l) => finishPass l.length j l
  σ_decreases
    | (j, l), h => by
      dsimp only [bubblePassMC] at h ⊢
      by_cases hj : j + 1 < l.length
      · simp only [hj, ite_true, length_cswap]; omega
      · simp [hj] at h
  θ_init l := by
    show finishPass l.length 0 l = bubble l
    simp [finishPass_start, bubblePrefix]
  θ_preserved
    | (j, l) => by
      dsimp only [bubblePassMC]
      split
      · rename_i hj; simp only [length_cswap]; exact finishPass_step l.length j l hj
      · rfl
  θ_final
    | (j, l), h => by
      dsimp only [bubblePassMC] at h ⊢
      split at h
      · simp at h
      · rename_i hj; exact finishPass_end l.length j l (by omega)

def bubblePass (l : List Nat) : {a : List Nat // a = bubble l} := bubblePassMCV.runWithProof l

#guard (bubblePass [5, 1, 4, 2, 8]).val = [1, 4, 2, 5, 8]

/-! ### Verified: the full-state mapcode computes recursive bubble sort -/

@[reducible]
def bubbleSortMCV : Mapcode where
  toMapCodeUnverified := bubbleSortMC
  f l := bsU l.length l
  -- bound function: comparisons left in this pass, plus a quadratic term in the passes left
  σ | (u, j, _) => u * u + (u - j)
  θ | (u, j, l) => if u ≤ 1 then l else bsU (u - 1) (finishPass u j l)
  σ_decreases
    | (u, j, l), h => by
      dsimp only [bubbleSortMC] at h ⊢
      by_cases hu : u ≤ 1
      · simp [hu] at h
      · by_cases hj : j + 1 < u
        · simp only [hu, hj, ite_true, ite_false]; omega
        · simp only [hu, hj, ite_false]
          obtain ⟨v, rfl⟩ : ∃ v, u = v + 1 := ⟨u - 1, by omega⟩
          have e : (v + 1) * (v + 1) = v * v + 2 * v + 1 := by
            simp only [Nat.add_mul, Nat.mul_add, Nat.mul_one, Nat.one_mul]; omega
          rw [e, Nat.add_sub_cancel]
          generalize v * v = t
          omega
  θ_init l := by
    show (if l.length ≤ 1 then l else bsU (l.length - 1) (finishPass l.length 0 l)) = bsU l.length l
    split
    · rw [bsU_small _ _ (by assumption)]
    · rw [finishPass_start, bsU_step l.length l (by omega)]
  θ_preserved
    | (u, j, l) => by
      dsimp only [bubbleSortMC]
      by_cases hu : u ≤ 1
      · simp [hu]
      · simp only [hu, ite_false]
        by_cases hj : j + 1 < u
        · simp only [hj, ite_true, hu, ite_false]; rw [finishPass_step _ _ _ hj]
        · simp only [hj, ite_false]
          rw [finishPass_end u j l (by omega)]
          by_cases hu2 : u - 1 ≤ 1
          · simp only [hu2, ite_true]; rw [bsU_small _ _ hu2]
          · simp only [hu2, ite_false]; rw [finishPass_start, bsU_step (u - 1) l (by omega)]
  θ_final
    | (u, j, l), h => by
      dsimp only [bubbleSortMC] at h ⊢
      by_cases hu : u ≤ 1
      · simp [hu]
      · simp only [hu, ite_false] at h ⊢
        by_cases hj : j + 1 < u
        · simp [hj] at h
        · simp only [hj, ite_false] at h
          simp at h; omega

def bsortFull (l : List Nat) : {a : List Nat // a = bsU l.length l} := bubbleSortMCV.runWithProof l

#eval (bsortFull [5, 1, 4, 2, 8]).val   -- [1, 2, 4, 5, 8]
#guard (bsortFull [4, 3, 1, 2]).val = [1, 2, 3, 4]
#print axioms bubbleSortMCV

end Mapcode.BubbleFull
