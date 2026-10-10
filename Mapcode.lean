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
