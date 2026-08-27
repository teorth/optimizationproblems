import FiniteCertificate
import Mathlib.Analysis.Analytic.Constructions
import Mathlib.Analysis.Analytic.Linear
import Mathlib.Analysis.Complex.AbsMax
import Mathlib.Analysis.Normed.Ring.InfiniteSum
import Mathlib.Analysis.SpecificLimits.Normed
import Mathlib.Tactic.FunProp

/-!
# End-to-end certificate for the bidisc Bohr-radius upper bound

This file closes the analytic and coefficient-identification gaps deliberately
left outside `FiniteCertificate.lean`.  It proves that the Gaussian-integer
rectangle checked there is the Taylor rectangle of an explicit Schur function,
uses its certified norm floors to obtain a strict finite Bohr violation, and
deduces the strict upper bound `K₂ < 302825279492 / 10^12`.
-/

set_option maxRecDepth 10000
set_option maxHeartbeats 8000000

open scoped BigOperators

namespace Optim.BohrRadius

/-- The open unit bidisc. -/
def unitBidisc : Set (ℂ × ℂ) :=
  {p | ‖p.1‖ < 1 ∧ ‖p.2‖ < 1}

/-- Analytic functions from the unit bidisc to the closed unit disc. -/
def IsSchur (f : ℂ × ℂ → ℂ) : Prop :=
  AnalyticOn ℂ f unitBidisc ∧
    ∀ p ∈ unitBidisc, ‖f p‖ ≤ 1

/-- A family is the actual locally convergent Taylor germ of `f` at zero. -/
def HasBidiscCoefficients (f : ℂ × ℂ → ℂ)
    (coeff : ℕ → ℕ → ℂ) : Prop :=
  ∃ radius : ℝ, 0 < radius ∧ radius ≤ 1 ∧
    ∀ z w : ℂ, ‖z‖ < radius → ‖w‖ < radius →
      HasSum (fun i : ℕ × ℕ =>
        coeff i.1 i.2 * z ^ i.1 * w ^ i.2) (f (z, w))

/-- Finite rectangular partial sums of the absolute Bohr series. -/
noncomputable def finiteMajorant
    (coeff : ℕ → ℕ → ℂ) (radius : ℝ) (N : ℕ) : ℝ :=
  ∑ j ∈ Finset.range (N + 1),
    ∑ k ∈ Finset.range (N + 1),
      ‖coeff j k‖ * radius ^ (j + k)

def IsBohrAdmissible (radius : ℝ) : Prop :=
  ∀ (f : ℂ × ℂ → ℂ) (coeff : ℕ → ℕ → ℂ),
    IsSchur f → HasBidiscCoefficients f coeff →
      ∀ N : ℕ, finiteMajorant coeff radius N ≤ 1

/-- The bidisc Bohr radius, as the supremum of universally admissible radii. -/
noncomputable def bohrRadius : ℝ :=
  sSup (insert 0 {radius : ℝ | 0 < radius ∧ IsBohrAdmissible radius})

theorem finiteMajorant_mono
    (coeff : ℕ → ℕ → ℂ) (N : ℕ)
    {r s : ℝ} (hr : 0 ≤ r) (hrs : r ≤ s) :
    finiteMajorant coeff r N ≤ finiteMajorant coeff s N := by
  unfold finiteMajorant
  apply Finset.sum_le_sum
  intro j hj
  apply Finset.sum_le_sum
  intro k hk
  exact mul_le_mul_of_nonneg_left
    (pow_le_pow_left₀ hr hrs (j + k)) (norm_nonneg (coeff j k))

theorem bohrRadius_le_of_finite_violation
    {f : ℂ × ℂ → ℂ} {coeff : ℕ → ℕ → ℂ}
    {radius : ℝ} {N : ℕ}
    (hr : 0 ≤ radius)
    (hf : IsSchur f)
    (hcoeff : HasBidiscCoefficients f coeff)
    (hviolation : 1 < finiteMajorant coeff radius N) :
    bohrRadius ≤ radius := by
  unfold bohrRadius
  refine csSup_le ⟨0, Set.mem_insert _ _⟩ ?_
  intro s hs
  rcases (Set.mem_insert_iff.mp hs) with hzero | hs
  · simpa [hzero] using hr
  · change 0 < s ∧ IsBohrAdmissible s at hs
    by_contra hnot
    have hrs : radius ≤ s := (lt_of_not_ge hnot).le
    have hmono := finiteMajorant_mono coeff N hr hrs
    have hadmissible := hs.2 f coeff hf hcoeff N
    linarith

theorem continuous_finiteMajorant (coeff : ℕ → ℕ → ℂ) (N : ℕ) :
    Continuous (fun radius : ℝ => finiteMajorant coeff radius N) := by
  unfold finiteMajorant
  fun_prop

/-- A strict finite violation gives a strict upper bound: continuity moves the
violation to a slightly smaller positive radius. -/
theorem bohrRadius_lt_of_finite_violation
    {f : ℂ × ℂ → ℂ} {coeff : ℕ → ℕ → ℂ}
    {radius : ℝ} {N : ℕ}
    (hr : 0 < radius)
    (hf : IsSchur f)
    (hcoeff : HasBidiscCoefficients f coeff)
    (hviolation : 1 < finiteMajorant coeff radius N) :
    bohrRadius < radius := by
  have hopen : IsOpen {s : ℝ | 1 < finiteMajorant coeff s N} :=
    isOpen_lt continuous_const (continuous_finiteMajorant coeff N)
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.mp hopen radius hviolation
  let δ : ℝ := min (radius / 2) (ε / 2)
  have hδ : 0 < δ := lt_min (half_pos hr) (half_pos hε)
  have hδr : δ < radius := lt_of_le_of_lt (min_le_left _ _) (half_lt_self hr)
  have hδε : δ < ε := lt_of_le_of_lt (min_le_right _ _) (half_lt_self hε)
  have hmem : radius - δ ∈ {s : ℝ | 1 < finiteMajorant coeff s N} := by
    apply hball
    rw [Metric.mem_ball, Real.dist_eq]
    simp only [sub_sub_cancel_left, abs_neg, abs_of_pos hδ]
    exact hδε
  have hle := bohrRadius_le_of_finite_violation
    (f := f) (coeff := coeff) (radius := radius - δ) (N := N)
    (sub_nonneg.mpr hδr.le) hf hcoeff hmem
  linarith

end Optim.BohrRadius

namespace Optim.BohrRadius

/-- Taylor recurrence for a general bidegree-`(1,1)` rational function. -/
noncomputable def recurrentCoefficient
    (a c d e₀₀ e₁₀ e₀₁ e₁₁ : ℂ) : ℕ → ℕ → ℂ
  | 0, 0 => e₀₀
  | j + 1, 0 =>
      a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j 0 +
        if j = 0 then e₁₀ else 0
  | 0, k + 1 =>
      c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ 0 k +
        if k = 0 then e₀₁ else 0
  | j + 1, k + 1 =>
      a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1) +
        c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k -
        d * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k +
        if j = 0 ∧ k = 0 then e₁₁ else 0
termination_by j k => j + k
decreasing_by all_goals omega

theorem recurrentCoefficient_norm_le
    {a c d e₀₀ e₁₀ e₀₁ e₁₁ : ℂ}
    (ha : ‖a‖ ≤ 1) (hc : ‖c‖ ≤ 1) (hd : ‖d‖ ≤ 1)
    (he₀₀ : ‖e₀₀‖ ≤ 1) (he₁₀ : ‖e₁₀‖ ≤ 1)
    (he₀₁ : ‖e₀₁‖ ≤ 1) (he₁₁ : ‖e₁₁‖ ≤ 1)
    (j k : ℕ) :
    ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k‖ ≤
      (8 : ℝ) ^ (j + k) := by
  have main : ∀ n : ℕ, ∀ j k : ℕ, j + k = n →
      ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k‖ ≤
        (8 : ℝ) ^ (j + k) := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro j k hjk
      cases j with
      | zero =>
        cases k with
        | zero => simpa [recurrentCoefficient] using he₀₀
        | succ k =>
          have hk := ih k (by omega) 0 k (by omega)
          have hk' :
              ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ 0 k‖ ≤
                (8 : ℝ) ^ k := by simpa using hk
          have hs : ‖if k = 0 then e₀₁ else 0‖ ≤ 1 := by
            split_ifs <;> simp_all
          have hm :
              ‖c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ 0 k‖ ≤
                (8 : ℝ) ^ k := by
            rw [norm_mul]
            calc
              ‖c‖ * ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ 0 k‖
                  ≤ 1 * (8 : ℝ) ^ k := by gcongr
              _ = (8 : ℝ) ^ k := one_mul _
          rw [recurrentCoefficient]
          change
            ‖c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ 0 k +
              (if k = 0 then e₀₁ else 0)‖ ≤ (8 : ℝ) ^ (0 + (k + 1))
          have htriangle := norm_add_le
            (c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ 0 k)
            (if k = 0 then e₀₁ else 0)
          have hp : 1 ≤ (8 : ℝ) ^ k := one_le_pow₀ (by norm_num)
          simp only [zero_add, pow_succ]
          nlinarith
      | succ j =>
        cases k with
        | zero =>
          have hj := ih j (by omega) j 0 (by omega)
          have hj' :
              ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j 0‖ ≤
                (8 : ℝ) ^ j := by simpa using hj
          have hs : ‖if j = 0 then e₁₀ else 0‖ ≤ 1 := by
            split_ifs <;> simp_all
          have hm :
              ‖a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j 0‖ ≤
                (8 : ℝ) ^ j := by
            rw [norm_mul]
            calc
              ‖a‖ * ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j 0‖
                  ≤ 1 * (8 : ℝ) ^ j := by gcongr
              _ = (8 : ℝ) ^ j := one_mul _
          rw [recurrentCoefficient]
          change
            ‖a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j 0 +
              (if j = 0 then e₁₀ else 0)‖ ≤ (8 : ℝ) ^ (j + 1 + 0)
          have htriangle := norm_add_le
            (a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j 0)
            (if j = 0 then e₁₀ else 0)
          have hp : 1 ≤ (8 : ℝ) ^ j := one_le_pow₀ (by norm_num)
          simp only [add_zero, pow_succ]
          nlinarith
        | succ k =>
          have h₁ := ih (j + (k + 1)) (by omega) j (k + 1) rfl
          have h₂ := ih ((j + 1) + k) (by omega) (j + 1) k rfl
          have h₃ := ih (j + k) (by omega) j k rfl
          have hs : ‖if j = 0 ∧ k = 0 then e₁₁ else 0‖ ≤ 1 := by
            split_ifs <;> simp_all
          have hm₁ :
              ‖a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1)‖ ≤
                (8 : ℝ) ^ (j + k + 1) := by
            rw [norm_mul]
            calc
              ‖a‖ * ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1)‖
                  ≤ 1 * (8 : ℝ) ^ (j + (k + 1)) := by gcongr
              _ = (8 : ℝ) ^ (j + k + 1) := by simp [add_assoc]
          have hm₂ :
              ‖c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k‖ ≤
                (8 : ℝ) ^ (j + k + 1) := by
            rw [norm_mul]
            calc
              ‖c‖ * ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k‖
                  ≤ 1 * (8 : ℝ) ^ ((j + 1) + k) := by gcongr
              _ = (8 : ℝ) ^ (j + k + 1) := by
                simp [add_assoc, add_left_comm, add_comm]
          have hm₃ :
              ‖d * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k‖ ≤
                (8 : ℝ) ^ (j + k) := by
            rw [norm_mul]
            calc
              ‖d‖ * ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k‖
                  ≤ 1 * (8 : ℝ) ^ (j + k) := by gcongr
              _ = (8 : ℝ) ^ (j + k) := one_mul _
          rw [recurrentCoefficient]
          change
            ‖a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1) +
              c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k -
              d * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k +
              (if j = 0 ∧ k = 0 then e₁₁ else 0)‖ ≤
              (8 : ℝ) ^ ((j + 1) + (k + 1))
          have ht₁ := norm_add_le
            (a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1))
            (c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k)
          have ht₂ := norm_sub_le
            (a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1) +
              c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k)
            (d * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k)
          have ht₃ := norm_add_le
            (a * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j (k + 1) +
              c * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ (j + 1) k -
              d * recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ j k)
            (if j = 0 ∧ k = 0 then e₁₁ else 0)
          have hp : 1 ≤ (8 : ℝ) ^ (j + k) := one_le_pow₀ (by norm_num)
          have hp₁ : (8 : ℝ) ^ (j + k + 1) =
              (8 : ℝ) ^ (j + k) * 8 := by rw [pow_succ]
          have hp₂ : (8 : ℝ) ^ ((j + 1) + (k + 1)) =
              (8 : ℝ) ^ (j + k) * 8 * 8 := by
            rw [show (j + 1) + (k + 1) = (j + k + 1) + 1 by omega,
              pow_succ, pow_succ]
          nlinarith
  exact main (j + k) j k rfl

theorem recurrentCoefficient_summable
    {a c d e₀₀ e₁₀ e₀₁ e₁₁ : ℂ}
    (ha : ‖a‖ ≤ 1) (hc : ‖c‖ ≤ 1) (hd : ‖d‖ ≤ 1)
    (he₀₀ : ‖e₀₀‖ ≤ 1) (he₁₀ : ‖e₁₀‖ ≤ 1)
    (he₀₁ : ‖e₀₁‖ ≤ 1) (he₁₁ : ‖e₁₁‖ ≤ 1)
    {z w : ℂ} (hz : ‖z‖ < (1 / 8 : ℝ)) (hw : ‖w‖ < (1 / 8 : ℝ)) :
    Summable (fun i : ℕ × ℕ =>
      recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ i.1 i.2 *
        z ^ i.1 * w ^ i.2) := by
  have hz₀ : 0 ≤ 8 * ‖z‖ := mul_nonneg (by norm_num) (norm_nonneg z)
  have hw₀ : 0 ≤ 8 * ‖w‖ := mul_nonneg (by norm_num) (norm_nonneg w)
  have hz₁ : 8 * ‖z‖ < 1 := by norm_num at hz ⊢; linarith
  have hw₁ : 8 * ‖w‖ < 1 := by norm_num at hw ⊢; linarith
  have hzg : Summable (fun j : ℕ => (8 * ‖z‖) ^ j) :=
    summable_geometric_of_lt_one hz₀ hz₁
  have hwg : Summable (fun k : ℕ => (8 * ‖w‖) ^ k) :=
    summable_geometric_of_lt_one hw₀ hw₁
  have hbound : Summable
      (fun i : ℕ × ℕ => (8 * ‖z‖) ^ i.1 * (8 * ‖w‖) ^ i.2) :=
    hzg.mul_of_nonneg hwg
      (fun _ => pow_nonneg hz₀ _) (fun _ => pow_nonneg hw₀ _)
  refine Summable.of_norm_bounded _ hbound ?_
  intro i
  rw [norm_mul, norm_mul, norm_pow, norm_pow]
  calc
    ‖recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ i.1 i.2‖ *
        ‖z‖ ^ i.1 * ‖w‖ ^ i.2 ≤
      (8 : ℝ) ^ (i.1 + i.2) * ‖z‖ ^ i.1 * ‖w‖ ^ i.2 := by
        gcongr
        exact recurrentCoefficient_norm_le ha hc hd he₀₀ he₁₀ he₀₁ he₁₁ _ _
    _ = (8 * ‖z‖) ^ i.1 * (8 * ‖w‖) ^ i.2 := by
      rw [pow_add, mul_pow, mul_pow]
      ring

noncomputable def shiftFirstSeries (A : ℂ) (f : ℕ × ℕ → ℂ)
    (i : ℕ × ℕ) : ℂ :=
  if i.1 = 0 then 0 else A * f (i.1 - 1, i.2)

noncomputable def shiftSecondSeries (A : ℂ) (f : ℕ × ℕ → ℂ)
    (i : ℕ × ℕ) : ℂ :=
  if i.2 = 0 then 0 else A * f (i.1, i.2 - 1)

theorem hasSum_shiftFirstSeries
    {f : ℕ × ℕ → ℂ} {s : ℂ} (hf : HasSum f s) (A : ℂ) :
    HasSum (shiftFirstSeries A f) (A * s) := by
  let emb : ℕ × ℕ → ℕ × ℕ := fun i => (i.1 + 1, i.2)
  have hinj : Function.Injective emb := by
    intro i j h
    simpa [emb, Prod.ext_iff] using h
  have hout : ∀ i : ℕ × ℕ, i ∉ Set.range emb →
      shiftFirstSeries A f i = 0 := by
    rintro ⟨j, k⟩ hnot
    by_cases hj : j = 0
    · simp [shiftFirstSeries, hj]
    · exfalso
      apply hnot
      refine ⟨(j - 1, k), ?_⟩
      simp [emb, Nat.sub_add_cancel (Nat.one_le_iff_ne_zero.mpr hj)]
  apply (hinj.hasSum_iff hout).mp
  refine (hf.mul_left A).congr_fun ?_
  intro i
  simp [Function.comp_def, emb, shiftFirstSeries]

theorem hasSum_shiftSecondSeries
    {f : ℕ × ℕ → ℂ} {s : ℂ} (hf : HasSum f s) (A : ℂ) :
    HasSum (shiftSecondSeries A f) (A * s) := by
  let emb : ℕ × ℕ → ℕ × ℕ := fun i => (i.1, i.2 + 1)
  have hinj : Function.Injective emb := by
    intro i j h
    simpa [emb, Prod.ext_iff] using h
  have hout : ∀ i : ℕ × ℕ, i ∉ Set.range emb →
      shiftSecondSeries A f i = 0 := by
    rintro ⟨j, k⟩ hnot
    by_cases hk : k = 0
    · simp [shiftSecondSeries, hk]
    · exfalso
      apply hnot
      refine ⟨(j, k - 1), ?_⟩
      simp [emb, Nat.sub_add_cancel (Nat.one_le_iff_ne_zero.mpr hk)]
  apply (hinj.hasSum_iff hout).mp
  refine (hf.mul_left A).congr_fun ?_
  intro i
  simp [Function.comp_def, emb, shiftSecondSeries]

noncomputable def recurrentTerm
    (a c d e₀₀ e₁₀ e₀₁ e₁₁ z w : ℂ) (i : ℕ × ℕ) : ℂ :=
  recurrentCoefficient a c d e₀₀ e₁₀ e₀₁ e₁₁ i.1 i.2 *
    z ^ i.1 * w ^ i.2

noncomputable def recurrentSourceSeries
    (e₀₀ e₁₀ e₀₁ e₁₁ z w : ℂ) (i : ℕ × ℕ) : ℂ :=
  (if i = (0, 0) then e₀₀ else 0) +
    (if i = (1, 0) then e₁₀ * z else 0) +
    (if i = (0, 1) then e₀₁ * w else 0) +
    (if i = (1, 1) then e₁₁ * z * w else 0)

theorem recurrent_shift_equation
    (a c d e₀₀ e₁₀ e₀₁ e₁₁ z w : ℂ) (i : ℕ × ℕ) :
    recurrentTerm a c d e₀₀ e₁₀ e₀₁ e₁₁ z w i -
        shiftFirstSeries (a * z)
          (recurrentTerm a c d e₀₀ e₁₀ e₀₁ e₁₁ z w) i -
        shiftSecondSeries (c * w)
          (recurrentTerm a c d e₀₀ e₁₀ e₀₁ e₁₁ z w) i +
        shiftFirstSeries 1
          (shiftSecondSeries (d * z * w)
            (recurrentTerm a c d e₀₀ e₁₀ e₀₁ e₁₁ z w)) i =
      recurrentSourceSeries e₀₀ e₁₀ e₀₁ e₁₁ z w i := by
  rcases i with ⟨j, k⟩
  cases j with
  | zero =>
    cases k with
    | zero => simp [recurrentTerm, recurrentCoefficient,
        shiftFirstSeries, shiftSecondSeries, recurrentSourceSeries,
        Prod.ext_iff]
    | succ k =>
      simp [recurrentTerm, recurrentCoefficient, shiftFirstSeries,
        shiftSecondSeries, recurrentSourceSeries, pow_succ, Prod.ext_iff]
      split_ifs <;> simp_all <;> ring
  | succ j =>
    cases k with
    | zero =>
      simp [recurrentTerm, recurrentCoefficient, shiftFirstSeries,
        shiftSecondSeries, recurrentSourceSeries, pow_succ, Prod.ext_iff]
      split_ifs <;> simp_all <;> ring
    | succ k =>
      simp [recurrentTerm, recurrentCoefficient, shiftFirstSeries,
        shiftSecondSeries, recurrentSourceSeries, pow_succ, Prod.ext_iff]
      split_ifs <;> simp_all <;> ring

theorem recurrentSourceSeries_hasSum
    (e₀₀ e₁₀ e₀₁ e₁₁ z w : ℂ) :
    HasSum (recurrentSourceSeries e₀₀ e₁₀ e₀₁ e₁₁ z w)
      (e₀₀ + e₁₀ * z + e₀₁ * w + e₁₁ * z * w) := by
  have h₀₀ := hasSum_ite_eq ((0, 0) : ℕ × ℕ) e₀₀
  have h₁₀ := hasSum_ite_eq ((1, 0) : ℕ × ℕ) (e₁₀ * z)
  have h₀₁ := hasSum_ite_eq ((0, 1) : ℕ × ℕ) (e₀₁ * w)
  have h₁₁ := hasSum_ite_eq ((1, 1) : ℕ × ℕ) (e₁₁ * z * w)
  exact ((h₀₀.add h₁₀).add h₀₁).add h₁₁

theorem recurrentCoefficient_generating_identity
    {a c d e₀₀ e₁₀ e₀₁ e₁₁ : ℂ}
    (ha : ‖a‖ ≤ 1) (hc : ‖c‖ ≤ 1) (hd : ‖d‖ ≤ 1)
    (he₀₀ : ‖e₀₀‖ ≤ 1) (he₁₀ : ‖e₁₀‖ ≤ 1)
    (he₀₁ : ‖e₀₁‖ ≤ 1) (he₁₁ : ‖e₁₁‖ ≤ 1)
    {z w : ℂ} (hz : ‖z‖ < (1 / 8 : ℝ)) (hw : ‖w‖ < (1 / 8 : ℝ)) :
    (1 - a * z - c * w + d * z * w) *
        (∑' i : ℕ × ℕ,
          recurrentTerm a c d e₀₀ e₁₀ e₀₁ e₁₁ z w i) =
      e₀₀ + e₁₀ * z + e₀₁ * w + e₁₁ * z * w := by
  let f := recurrentTerm a c d e₀₀ e₁₀ e₀₁ e₁₁ z w
  have hs : Summable f := recurrentCoefficient_summable
    ha hc hd he₀₀ he₁₀ he₀₁ he₁₁ hz hw
  have hbase : HasSum f (∑' i : ℕ × ℕ, f i) := hs.hasSum
  have hfirst := hasSum_shiftFirstSeries hbase (a * z)
  have hsecond := hasSum_shiftSecondSeries hbase (c * w)
  have hmixed :
      HasSum (shiftFirstSeries 1 (shiftSecondSeries (d * z * w) f))
        ((d * z * w) * (∑' i : ℕ × ℕ, f i)) := by
    simpa using hasSum_shiftFirstSeries
      (hasSum_shiftSecondSeries hbase (d * z * w)) 1
  have hcombined := ((hbase.sub hfirst).sub hsecond).add hmixed
  have hsource := recurrentSourceSeries_hasSum e₀₀ e₁₀ e₀₁ e₁₁ z w
  have hpoint : ∀ i : ℕ × ℕ,
      recurrentSourceSeries e₀₀ e₁₀ e₀₁ e₁₁ z w i =
        f i - shiftFirstSeries (a * z) f i -
          shiftSecondSeries (c * w) f i +
          shiftFirstSeries 1 (shiftSecondSeries (d * z * w) f) i := by
    intro i
    exact (recurrent_shift_equation a c d e₀₀ e₁₀ e₀₁ e₁₁ z w i).symm
  have hidentity := hcombined.unique
    (hsource.congr_fun (fun i => (hpoint i).symm))
  change
    (1 - a * z - c * w + d * z * w) * (∑' i : ℕ × ℕ, f i) =
      e₀₀ + e₁₀ * z + e₀₁ * w + e₁₁ * z * w
  linear_combination hidentity

end Optim.BohrRadius

namespace BidiscPhaseCertificate

/-- The two bilinear forms used by the certified witness. -/
def analyticU (z w : ℂ) : ℂ := (1 + z) * (1 - w)

def analyticV (z w : ℂ) : ℂ := 1 + z * w

def analyticP (l t : ℝ) (z w : ℂ) : ℂ :=
  (l : ℂ) * analyticU z w + Complex.I * (t : ℂ) * analyticV z w

def analyticQ (l t : ℝ) (z w : ℂ) : ℂ :=
  (l : ℂ) * analyticV z w + Complex.I * (t : ℂ) * analyticU z w

def analyticNumerator (l t s : ℝ) (z w : ℂ) : ℂ :=
  (s : ℂ) * analyticQ l t z w - analyticP l t z w

def analyticDenominator (l t s : ℝ) (z w : ℂ) : ℂ :=
  (s : ℂ) * analyticQ l t z w + analyticP l t z w

noncomputable def analyticWitness (l t s : ℝ) (z w : ℂ) : ℂ :=
  analyticNumerator l t s z w / analyticDenominator l t s z w

/-- Exact global squared-norm identity underlying the Schur estimate. -/
theorem analytic_normSq_gap (l t s : ℝ) (z w : ℂ) :
    Complex.normSq (analyticDenominator l t s z w) -
        Complex.normSq (analyticNumerator l t s z w) =
      2 * s * (l ^ 2 + t ^ 2) *
        ((1 - Complex.normSq w) * Complex.normSq (1 + z) +
          (1 - Complex.normSq z) * Complex.normSq (1 - w)) := by
  simp [analyticDenominator, analyticNumerator, analyticP, analyticQ,
    analyticU, analyticV, Complex.normSq_apply]
  ring

theorem analytic_normSq_gap_pos {l t s : ℝ}
    (hs : 0 < s) (hlt : 0 < l ^ 2 + t ^ 2)
    {z w : ℂ} (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    0 < Complex.normSq (analyticDenominator l t s z w) -
      Complex.normSq (analyticNumerator l t s z w) := by
  rw [analytic_normSq_gap]
  have hz_sq : 0 < 1 - Complex.normSq z := by
    rw [Complex.normSq_eq_norm_sq]
    nlinarith [norm_nonneg z]
  have hw_sq : 0 < 1 - Complex.normSq w := by
    rw [Complex.normSq_eq_norm_sq]
    nlinarith [norm_nonneg w]
  have hz_add_ne : 1 + z ≠ 0 := by
    intro hzero
    have hzneg : z = -1 := by linear_combination hzero
    rw [hzneg] at hz
    norm_num at hz
  have hfirst :
      0 < (1 - Complex.normSq w) * Complex.normSq (1 + z) :=
    mul_pos hw_sq (Complex.normSq_pos.mpr hz_add_ne)
  have hsecond :
      0 ≤ (1 - Complex.normSq z) * Complex.normSq (1 - w) :=
    mul_nonneg hz_sq.le (Complex.normSq_nonneg _)
  have hbracket :
      0 < (1 - Complex.normSq w) * Complex.normSq (1 + z) +
        (1 - Complex.normSq z) * Complex.normSq (1 - w) :=
    add_pos_of_pos_of_nonneg hfirst hsecond
  positivity

theorem analyticDenominator_ne_zero {l t s : ℝ}
    (hs : 0 < s) (hlt : 0 < l ^ 2 + t ^ 2)
    {z w : ℂ} (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    analyticDenominator l t s z w ≠ 0 := by
  intro hzero
  have hgap := analytic_normSq_gap_pos hs hlt hz hw
  rw [hzero, Complex.normSq_zero] at hgap
  nlinarith [Complex.normSq_nonneg (analyticNumerator l t s z w)]

theorem analyticWitness_norm_lt_one {l t s : ℝ}
    (hs : 0 < s) (hlt : 0 < l ^ 2 + t ^ 2)
    {z w : ℂ} (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    ‖analyticWitness l t s z w‖ < 1 := by
  have hgap := analytic_normSq_gap_pos hs hlt hz hw
  have hnorm :
      ‖analyticNumerator l t s z w‖ <
        ‖analyticDenominator l t s z w‖ := by
    rw [Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq] at hgap
    nlinarith [norm_nonneg (analyticNumerator l t s z w),
      norm_nonneg (analyticDenominator l t s z w)]
  have hden := analyticDenominator_ne_zero hs hlt hz hw
  rw [analyticWitness, Complex.norm_div]
  exact (div_lt_one (norm_pos_iff.mpr hden)).mpr hnorm

theorem analyticWitness_analyticOn {l t s : ℝ}
    (hs : 0 < s) (hlt : 0 < l ^ 2 + t ^ 2) :
    AnalyticOn ℂ (fun p : ℂ × ℂ => analyticWitness l t s p.1 p.2)
      Optim.BohrRadius.unitBidisc := by
  intro p hp
  change ‖p.1‖ < 1 ∧ ‖p.2‖ < 1 at hp
  have hfirst : AnalyticAt ℂ (fun v : ℂ × ℂ => v.1) p := analyticAt_fst
  have hsecond : AnalyticAt ℂ (fun v : ℂ × ℂ => v.2) p := analyticAt_snd
  have hu : AnalyticAt ℂ
      (fun v : ℂ × ℂ => analyticU v.1 v.2) p := by
    unfold analyticU
    exact ((analyticAt_const (v := (1 : ℂ))).fun_add hfirst).fun_mul
      ((analyticAt_const (v := (1 : ℂ))).fun_sub hsecond)
  have hv : AnalyticAt ℂ
      (fun v : ℂ × ℂ => analyticV v.1 v.2) p := by
    unfold analyticV
    exact (analyticAt_const (v := (1 : ℂ))).fun_add (hfirst.fun_mul hsecond)
  have hP : AnalyticAt ℂ
      (fun v : ℂ × ℂ => analyticP l t v.1 v.2) p := by
    unfold analyticP
    exact ((analyticAt_const (v := (l : ℂ))).fun_mul hu).fun_add
      ((analyticAt_const (v := Complex.I * (t : ℂ))).fun_mul hv)
  have hQ : AnalyticAt ℂ
      (fun v : ℂ × ℂ => analyticQ l t v.1 v.2) p := by
    unfold analyticQ
    exact ((analyticAt_const (v := (l : ℂ))).fun_mul hv).fun_add
      ((analyticAt_const (v := Complex.I * (t : ℂ))).fun_mul hu)
  have hn : AnalyticAt ℂ
      (fun v : ℂ × ℂ => analyticNumerator l t s v.1 v.2) p := by
    unfold analyticNumerator
    exact ((analyticAt_const (v := (s : ℂ))).fun_mul hQ).fun_sub hP
  have hd : AnalyticAt ℂ
      (fun v : ℂ × ℂ => analyticDenominator l t s v.1 v.2) p := by
    unfold analyticDenominator
    exact ((analyticAt_const (v := (s : ℂ))).fun_mul hQ).fun_add hP
  exact (hn.fun_div hd
    (analyticDenominator_ne_zero hs hlt hp.1 hp.2)).analyticWithinAt

/-- The concrete rational function used by the certificate. -/
noncomputable def certifiedWitness (p : ℂ × ℂ) : ℂ :=
  analyticWitness (L : ℝ) (T : ℝ) (S : ℝ) p.1 p.2

theorem certifiedWitness_isSchur :
    Optim.BohrRadius.IsSchur certifiedWitness := by
  have hs : (0 : ℝ) < (S : ℝ) := by norm_num [S]
  have hlt : (0 : ℝ) < (L : ℝ) ^ 2 + (T : ℝ) ^ 2 := by
    norm_num [L, T]
  refine ⟨analyticWitness_analyticOn hs hlt, ?_⟩
  intro p hp
  exact (analyticWitness_norm_lt_one hs hlt hp.1 hp.2).le

end BidiscPhaseCertificate



namespace Optim.BohrRadius

/-- A normalized complex bidegree-`(1,1)` rational function. -/
noncomputable def complexBidegreeRational
    (q₁₀ q₀₁ q₁₁ p₀₀ p₁₀ p₀₁ p₁₁ : ℂ)
    (x : ℂ × ℂ) : ℂ :=
  (p₀₀ + p₁₀ * x.1 + p₀₁ * x.2 + p₁₁ * x.1 * x.2) /
    (1 + q₁₀ * x.1 + q₀₁ * x.2 + q₁₁ * x.1 * x.2)

/-- The recurrence is the actual Taylor germ of the normalized rational
function, not merely a formal or finite recurrence. -/
theorem complexBidegreeRational_recurrent_hasBidiscCoefficients
    {q₁₀ q₀₁ q₁₁ p₀₀ p₁₀ p₀₁ p₁₁ : ℂ}
    (hq₁₀ : ‖q₁₀‖ ≤ 1) (hq₀₁ : ‖q₀₁‖ ≤ 1) (hq₁₁ : ‖q₁₁‖ ≤ 1)
    (hp₀₀ : ‖p₀₀‖ ≤ 1) (hp₁₀ : ‖p₁₀‖ ≤ 1)
    (hp₀₁ : ‖p₀₁‖ ≤ 1) (hp₁₁ : ‖p₁₁‖ ≤ 1)
    (hden : ∀ z w : ℂ, ‖z‖ < (1 / 8 : ℝ) → ‖w‖ < (1 / 8 : ℝ) →
      1 + q₁₀ * z + q₀₁ * w + q₁₁ * z * w ≠ 0) :
    HasBidiscCoefficients
      (complexBidegreeRational q₁₀ q₀₁ q₁₁ p₀₀ p₁₀ p₀₁ p₁₁)
      (recurrentCoefficient (-q₁₀) (-q₀₁) q₁₁ p₀₀ p₁₀ p₀₁ p₁₁) := by
  refine ⟨(1 / 8 : ℝ), by norm_num, by norm_num, ?_⟩
  intro z w hz hw
  have hmq₁₀ : ‖-q₁₀‖ ≤ 1 := by simpa using hq₁₀
  have hmq₀₁ : ‖-q₀₁‖ ≤ 1 := by simpa using hq₀₁
  have hs := recurrentCoefficient_summable
    hmq₁₀ hmq₀₁ hq₁₁ hp₀₀ hp₁₀ hp₀₁ hp₁₁ hz hw
  have hgen := recurrentCoefficient_generating_identity
    hmq₁₀ hmq₀₁ hq₁₁ hp₀₀ hp₁₀ hp₀₁ hp₁₁ hz hw
  have hvalue :
      (∑' i : ℕ × ℕ,
        recurrentTerm (-q₁₀) (-q₀₁) q₁₁
          p₀₀ p₁₀ p₀₁ p₁₁ z w i) =
        complexBidegreeRational q₁₀ q₀₁ q₁₁ p₀₀ p₁₀ p₀₁ p₁₁ (z, w) := by
    unfold complexBidegreeRational
    apply (eq_div_iff (hden z w hz hw)).2
    linear_combination hgen
  simp only [recurrentTerm] at hvalue
  have hsum := hs.hasSum
  rw [hvalue] at hsum
  simpa using hsum

noncomputable def complexBidegreeRecurrenceValue
    (a c d p₀₀ p₁₀ p₀₁ p₁₁ : ℂ)
    (v : ℕ → ℕ → ℂ) (j k : ℕ) : ℂ :=
  (if 0 < j then a * v (j - 1) k else 0) +
    (if 0 < k then c * v j (k - 1) else 0) -
    (if 0 < j ∧ 0 < k then d * v (j - 1) (k - 1) else 0) +
    (if j = 0 ∧ k = 0 then p₀₀
      else if j = 1 ∧ k = 0 then p₁₀
      else if j = 0 ∧ k = 1 then p₀₁
      else if j = 1 ∧ k = 1 then p₁₁
      else 0)

theorem recurrentCoefficient_eq_complexBidegreeRecurrenceValue
    (a c d p₀₀ p₁₀ p₀₁ p₁₁ : ℂ) (j k : ℕ) :
    recurrentCoefficient a c d p₀₀ p₁₀ p₀₁ p₁₁ j k =
      complexBidegreeRecurrenceValue a c d p₀₀ p₁₀ p₀₁ p₁₁
        (recurrentCoefficient a c d p₀₀ p₁₀ p₀₁ p₁₁) j k := by
  cases j with
  | zero =>
      cases k with
      | zero => simp [recurrentCoefficient, complexBidegreeRecurrenceValue]
      | succ k => simp [recurrentCoefficient, complexBidegreeRecurrenceValue]
  | succ j =>
      cases k with
      | zero => simp [recurrentCoefficient, complexBidegreeRecurrenceValue]
      | succ k => simp [recurrentCoefficient, complexBidegreeRecurrenceValue]

theorem complexBidegreeRecurrence_unique_on_rectangle
    (a c d p₀₀ p₁₀ p₀₁ p₁₁ : ℂ) (N : ℕ)
    (v₁ v₂ : ℕ → ℕ → ℂ)
    (h₁ : ∀ j k : ℕ, j < N → k < N →
      v₁ j k = complexBidegreeRecurrenceValue a c d p₀₀ p₁₀ p₀₁ p₁₁ v₁ j k)
    (h₂ : ∀ j k : ℕ, j < N → k < N →
      v₂ j k = complexBidegreeRecurrenceValue a c d p₀₀ p₁₀ p₀₁ p₁₁ v₂ j k) :
    ∀ j k : ℕ, j < N → k < N → v₁ j k = v₂ j k := by
  intro j k hj hk
  have hgeneral : ∀ n : ℕ, ∀ j k : ℕ,
      j + k = n → j < N → k < N → v₁ j k = v₂ j k := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro j k hn hj hk
      rw [h₁ j k hj hk, h₂ j k hj hk]
      unfold complexBidegreeRecurrenceValue
      have hfirst :
          (if 0 < j then a * v₁ (j - 1) k else 0) =
            (if 0 < j then a * v₂ (j - 1) k else 0) := by
        split_ifs with hpos
        · congr 1
          apply ih ((j - 1) + k) (by omega) (j - 1) k rfl (by omega) hk
        · rfl
      have hsecond :
          (if 0 < k then c * v₁ j (k - 1) else 0) =
            (if 0 < k then c * v₂ j (k - 1) else 0) := by
        split_ifs with hpos
        · congr 1
          apply ih (j + (k - 1)) (by omega) j (k - 1) rfl hj (by omega)
        · rfl
      have hmixed :
          (if 0 < j ∧ 0 < k then d * v₁ (j - 1) (k - 1) else 0) =
            (if 0 < j ∧ 0 < k then d * v₂ (j - 1) (k - 1) else 0) := by
        split_ifs with hpos
        · congr 1
          apply ih ((j - 1) + (k - 1)) (by omega)
            (j - 1) (k - 1) rfl (by omega) (by omega)
        · rfl
      rw [hfirst, hsecond, hmixed]
  exact hgeneral (j + k) j k rfl hj hk

end Optim.BohrRadius

namespace BidiscPhaseCertificate

/-- Canonical embedding of the arithmetic certificate's Gaussian integers. -/
noncomputable def gaussianCast (v : Gaussian) : ℂ :=
  (v.1 : ℂ) + (v.2 : ℂ) * Complex.I

@[simp] theorem gaussianCast_zero : gaussianCast (0, 0) = 0 := by
  simp [gaussianCast]

@[simp] theorem gaussianCast_ofNat_zero : gaussianCast (0 : Gaussian) = 0 := by
  change gaussianCast (0, 0) = 0
  exact gaussianCast_zero

@[simp] theorem gaussianCast_gadd (a b : Gaussian) :
    gaussianCast (gadd a b) = gaussianCast a + gaussianCast b := by
  apply Complex.ext <;> simp [gaussianCast, gadd]

@[simp] theorem gaussianCast_gneg (a : Gaussian) :
    gaussianCast (gneg a) = -gaussianCast a := by
  apply Complex.ext <;> simp [gaussianCast, gneg]

@[simp] theorem gaussianCast_gmul (a b : Gaussian) :
    gaussianCast (gmul a b) = gaussianCast a * gaussianCast b := by
  apply Complex.ext <;> simp [gaussianCast, gmul]

@[simp] theorem gaussianCast_gscale (n : Int) (a : Gaussian) :
    gaussianCast (gscale n a) = (n : ℂ) * gaussianCast a := by
  apply Complex.ext <;> simp [gaussianCast, gscale]

theorem natAbs_sq_cast_real (z : Int) :
    ((z.natAbs : ℕ) : ℝ) ^ 2 = (z : ℝ) ^ 2 := by
  have hz : |(z : ℝ)| = (z.natAbs : ℝ) := by
    calc
      |(z : ℝ)| = ((|z| : Int) : ℝ) := Int.cast_abs.symm
      _ = (z.natAbs : ℝ) := (Nat.cast_natAbs z).symm
  rw [← hz, sq_abs]

/-- Every checked integer square-root is a lower bound for the true complex
coefficient numerator norm. -/
theorem lowerNorm_le_norm_gaussianCast
    (j k : ℕ)
    (hsq : (lowerNorm j k) ^ 2 ≤ normSquared (coefficientNumerator j k)) :
    (lowerNorm j k : ℝ) ≤ ‖gaussianCast (coefficientNumerator j k)‖ := by
  have hsq' :
      (lowerNorm j k : ℝ) ^ 2 ≤
        ((coefficientNumerator j k).1.natAbs : ℝ) ^ 2 +
          ((coefficientNumerator j k).2.natAbs : ℝ) ^ 2 := by
    exact_mod_cast hsq
  rw [natAbs_sq_cast_real, natAbs_sq_cast_real] at hsq'
  have hnorm :
      ‖gaussianCast (coefficientNumerator j k)‖ ^ 2 =
        ((coefficientNumerator j k).1 : ℝ) ^ 2 +
          ((coefficientNumerator j k).2 : ℝ) ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq]
    simp [gaussianCast, Complex.normSq_apply]
    ring
  rw [← hnorm] at hsq'
  have hlower : 0 ≤ (lowerNorm j k : ℝ) := by positivity
  nlinarith [norm_nonneg (gaussianCast (coefficientNumerator j k))]

end BidiscPhaseCertificate

namespace BidiscPhaseCertificate

noncomputable def q10 : ℂ :=
  gaussianCast (denominator.getD 1 (0, 0)) / (D : ℂ)
noncomputable def q01 : ℂ :=
  gaussianCast (denominator.getD 2 (0, 0)) / (D : ℂ)
noncomputable def q11 : ℂ :=
  gaussianCast (denominator.getD 3 (0, 0)) / (D : ℂ)
noncomputable def p00 : ℂ :=
  gaussianCast (numerator.getD 0 (0, 0)) / (D : ℂ)
noncomputable def p10 : ℂ :=
  gaussianCast (numerator.getD 1 (0, 0)) / (D : ℂ)
noncomputable def p01 : ℂ :=
  gaussianCast (numerator.getD 2 (0, 0)) / (D : ℂ)
noncomputable def p11 : ℂ :=
  gaussianCast (numerator.getD 3 (0, 0)) / (D : ℂ)

noncomputable def certificateRational : ℂ × ℂ → ℂ :=
  Optim.BohrRadius.complexBidegreeRational
    q10 q01 q11 p00 p10 p01 p11

/-- The all-orders Taylor family belonging to the normalized certified
rational function. -/
noncomputable def certifiedTaylorCoefficient : ℕ → ℕ → ℂ :=
  Optim.BohrRadius.recurrentCoefficient
    (-q10) (-q01) q11 p00 p10 p01 p11

/-- Closed scaled form represented by the checked Gaussian rectangle. -/
noncomputable def closedCoefficient (j k : ℕ) : ℂ :=
  gaussianCast (coefficientNumerator j k) / (D : ℂ) ^ (j + k + 1)

/-- The mapped coefficient arrays really are multiplication by the recorded
conjugate constant. -/
theorem numerator_entry_mul_conjugate (i : Fin 4) :
    numerator.getD i.val (0, 0) =
      gmul (inputNumerator.getD i.val (0, 0)) conjugateConstant := by
  fin_cases i <;> native_decide

theorem denominator_entry_mul_conjugate (i : Fin 4) :
    denominator.getD i.val (0, 0) =
      gmul (inputDenominator.getD i.val (0, 0)) conjugateConstant := by
  fin_cases i <;> native_decide

theorem inputNumerator_entries :
    inputNumerator.getD 0 (0, 0) =
        (((S : Int) - 1) * (L : Int), ((S : Int) - 1) * (T : Int)) ∧
    inputNumerator.getD 1 (0, 0) =
        (-(L : Int), (S : Int) * (T : Int)) ∧
    inputNumerator.getD 2 (0, 0) =
        ((L : Int), -((S : Int) * (T : Int))) ∧
    inputNumerator.getD 3 (0, 0) =
        (((S : Int) + 1) * (L : Int), -((S : Int) + 1) * (T : Int)) := by
  native_decide

theorem inputDenominator_entries :
    inputDenominator.getD 0 (0, 0) =
        (((S : Int) + 1) * (L : Int), ((S : Int) + 1) * (T : Int)) ∧
    inputDenominator.getD 1 (0, 0) =
        ((L : Int), (S : Int) * (T : Int)) ∧
    inputDenominator.getD 2 (0, 0) =
        (-(L : Int), -((S : Int) * (T : Int))) ∧
    inputDenominator.getD 3 (0, 0) =
        (((S : Int) - 1) * (L : Int), -((S : Int) - 1) * (T : Int)) := by
  native_decide

theorem inputNumerator_polynomial (z w : ℂ) :
    gaussianCast (inputNumerator.getD 0 (0, 0)) +
        gaussianCast (inputNumerator.getD 1 (0, 0)) * z +
        gaussianCast (inputNumerator.getD 2 (0, 0)) * w +
        gaussianCast (inputNumerator.getD 3 (0, 0)) * z * w =
      analyticNumerator (L : ℝ) (T : ℝ) (S : ℝ) z w := by
  rw [inputNumerator_entries.1, inputNumerator_entries.2.1,
    inputNumerator_entries.2.2.1, inputNumerator_entries.2.2.2]
  simp [gaussianCast, analyticNumerator,
    analyticP, analyticQ, analyticU, analyticV]
  ring

theorem inputDenominator_polynomial (z w : ℂ) :
    gaussianCast (inputDenominator.getD 0 (0, 0)) +
        gaussianCast (inputDenominator.getD 1 (0, 0)) * z +
        gaussianCast (inputDenominator.getD 2 (0, 0)) * w +
        gaussianCast (inputDenominator.getD 3 (0, 0)) * z * w =
      analyticDenominator (L : ℝ) (T : ℝ) (S : ℝ) z w := by
  rw [inputDenominator_entries.1, inputDenominator_entries.2.1,
    inputDenominator_entries.2.2.1, inputDenominator_entries.2.2.2]
  simp [gaussianCast, analyticDenominator,
    analyticP, analyticQ, analyticU, analyticV]
  ring

theorem div_common_nonzero (N Q c d : ℂ) (hc : c ≠ 0) (hd : d ≠ 0) :
    (N * c / d) / (Q * c / d) = N / Q := by
  simp only [div_eq_mul_inv, mul_inv_rev, inv_inv]
  calc
    N * c * d⁻¹ * (d * (c⁻¹ * Q⁻¹)) =
        N * (c * c⁻¹) * (d⁻¹ * d) * Q⁻¹ := by ring
    _ = N * Q⁻¹ := by simp [hc, hd]

/-- Multiplying numerator and denominator by the conjugate constant does not
change the rational witness. -/
theorem certificateRational_eq_certifiedWitness :
    certificateRational = certifiedWitness := by
  funext x
  rcases x with ⟨z, w⟩
  have hn0 := numerator_entry_mul_conjugate (⟨0, by omega⟩ : Fin 4)
  have hn1 := numerator_entry_mul_conjugate (⟨1, by omega⟩ : Fin 4)
  have hn2 := numerator_entry_mul_conjugate (⟨2, by omega⟩ : Fin 4)
  have hn3 := numerator_entry_mul_conjugate (⟨3, by omega⟩ : Fin 4)
  have hd0 := denominator_entry_mul_conjugate (⟨0, by omega⟩ : Fin 4)
  have hd1 := denominator_entry_mul_conjugate (⟨1, by omega⟩ : Fin 4)
  have hd2 := denominator_entry_mul_conjugate (⟨2, by omega⟩ : Fin 4)
  have hd3 := denominator_entry_mul_conjugate (⟨3, by omega⟩ : Fin 4)
  simp only [Fin.isValue] at hn0 hn1 hn2 hn3 hd0 hd1 hd2 hd3
  have hc : gaussianCast conjugateConstant ≠ 0 := by
    intro hzero
    have hre := congrArg Complex.re hzero
    rw [show conjugateConstant =
        gconj (inputDenominator.getD 0 (0, 0)) by rfl,
      inputDenominator_entries.1] at hre
    norm_num [gaussianCast, gconj, L, S] at hre
  have hD : (D : ℂ) ≠ 0 := by
    exact_mod_cast (show D ≠ 0 by native_decide)
  unfold certificateRational Optim.BohrRadius.complexBidegreeRational
  unfold q10 q01 q11 p00 p10 p01 p11 certifiedWitness analyticWitness
  rw [hn0, hn1, hn2, hn3, hd1, hd2, hd3]
  simp only [gaussianCast_gmul]
  have hnpoly := inputNumerator_polynomial z w
  have hdpoly := inputDenominator_polynomial z w
  have hd0cast :
      gaussianCast (inputDenominator.getD 0 (0, 0)) *
          gaussianCast conjugateConstant = (D : ℂ) := by
    rw [← gaussianCast_gmul, ← hd0, denominator_constant_correct]
    simp [gaussianCast]
  have hnscaled :
      gaussianCast (inputNumerator.getD 0 (0, 0)) *
            gaussianCast conjugateConstant / (D : ℂ) +
          gaussianCast (inputNumerator.getD 1 (0, 0)) *
              gaussianCast conjugateConstant / (D : ℂ) * z +
          gaussianCast (inputNumerator.getD 2 (0, 0)) *
              gaussianCast conjugateConstant / (D : ℂ) * w +
          gaussianCast (inputNumerator.getD 3 (0, 0)) *
              gaussianCast conjugateConstant / (D : ℂ) * z * w =
        analyticNumerator (L : ℝ) (T : ℝ) (S : ℝ) z w *
          gaussianCast conjugateConstant / (D : ℂ) := by
    calc
      _ = (gaussianCast (inputNumerator.getD 0 (0, 0)) +
              gaussianCast (inputNumerator.getD 1 (0, 0)) * z +
              gaussianCast (inputNumerator.getD 2 (0, 0)) * w +
              gaussianCast (inputNumerator.getD 3 (0, 0)) * z * w) *
            gaussianCast conjugateConstant / (D : ℂ) := by ring
      _ = _ := by rw [hnpoly]
  have hdscaled :
      1 + gaussianCast (inputDenominator.getD 1 (0, 0)) *
              gaussianCast conjugateConstant / (D : ℂ) * z +
          gaussianCast (inputDenominator.getD 2 (0, 0)) *
              gaussianCast conjugateConstant / (D : ℂ) * w +
          gaussianCast (inputDenominator.getD 3 (0, 0)) *
              gaussianCast conjugateConstant / (D : ℂ) * z * w =
        analyticDenominator (L : ℝ) (T : ℝ) (S : ℝ) z w *
          gaussianCast conjugateConstant / (D : ℂ) := by
    have hone : (1 : ℂ) =
        gaussianCast (inputDenominator.getD 0 (0, 0)) *
          gaussianCast conjugateConstant / (D : ℂ) := by
      rw [hd0cast]
      exact (div_self hD).symm
    rw [hone]
    calc
      _ = (gaussianCast (inputDenominator.getD 0 (0, 0)) +
              gaussianCast (inputDenominator.getD 1 (0, 0)) * z +
              gaussianCast (inputDenominator.getD 2 (0, 0)) * w +
              gaussianCast (inputDenominator.getD 3 (0, 0)) * z * w) *
            gaussianCast conjugateConstant / (D : ℂ) := by ring
      _ = _ := by rw [hdpoly]
  rw [hnscaled, hdscaled]
  exact div_common_nonzero _ _ _ _ hc hD

end BidiscPhaseCertificate

namespace BidiscPhaseCertificate

/-! The certificate-specific normalized complex data. -/

noncomputable def q₁₀C : ℂ :=
  gaussianCast (denominator.getD 1 (0, 0)) / (D : ℂ)

noncomputable def q₀₁C : ℂ :=
  gaussianCast (denominator.getD 2 (0, 0)) / (D : ℂ)

noncomputable def q₁₁C : ℂ :=
  gaussianCast (denominator.getD 3 (0, 0)) / (D : ℂ)

noncomputable def p₀₀C : ℂ :=
  gaussianCast (numerator.getD 0 (0, 0)) / (D : ℂ)

noncomputable def p₁₀C : ℂ :=
  gaussianCast (numerator.getD 1 (0, 0)) / (D : ℂ)

noncomputable def p₀₁C : ℂ :=
  gaussianCast (numerator.getD 2 (0, 0)) / (D : ℂ)

noncomputable def p₁₁C : ℂ :=
  gaussianCast (numerator.getD 3 (0, 0)) / (D : ℂ)

/-- The all-orders analytic coefficient family corresponding to the normalized
Gaussian numerator and denominator. -/
noncomputable def actualCoefficient (j k : ℕ) : ℂ :=
  Optim.BohrRadius.recurrentCoefficient
    (-q₁₀C) (-q₀₁C) q₁₁C p₀₀C p₁₀C p₀₁C p₁₁C j k

/-- The finite coefficient obtained from the checked scaled Gaussian recurrence. -/
noncomputable def scaledCertificateCoefficient (j k : ℕ) : ℂ :=
  gaussianCast (coefficientNumerator j k) / (D : ℂ) ^ (j + k + 1)

theorem D_cast_ne_zero : (D : ℂ) ≠ 0 := by
  exact_mod_cast input_parameters_positive.1.ne'

/-- Algebraic normalization for a boundary row or column of the scaled recurrence. -/
theorem normalize_scaled_axis
    (d q v vprev p : ℂ) (n : ℕ) (hd : d ≠ 0)
    (h : v = d ^ (n + 1) * p - q * vprev) :
    v / d ^ (n + 2) =
      -(q / d) * (vprev / d ^ (n + 1)) + p / d := by
  rw [h]
  field_simp [hd]
  simp [pow_add, pow_succ]
  ring

/-- Algebraic normalization for an interior entry of the scaled recurrence. -/
theorem normalize_scaled_interior
    (d q₁₀ q₀₁ q₁₁ v vh vv vdiag p : ℂ) (n : ℕ) (hd : d ≠ 0)
    (h : v = d ^ (n + 2) * p +
      (-(d * q₁₁ * vdiag) - q₀₁ * vv - q₁₀ * vh)) :
    v / d ^ (n + 3) =
      -(q₁₀ / d) * (vh / d ^ (n + 2)) +
      -(q₀₁ / d) * (vv / d ^ (n + 2)) -
      (q₁₁ / d) * (vdiag / d ^ (n + 1)) + p / d := by
  rw [h]
  rw [add_div, sub_div, sub_div]
  rw [neg_div]
  rw [show d ^ (n + 2) * p / d ^ (n + 3) = p / d by
    field_simp [hd]
    simp [pow_add, pow_succ]
    ring]
  rw [show d * q₁₁ * vdiag / d ^ (n + 3) =
      (q₁₁ / d) * (vdiag / d ^ (n + 1)) by
    field_simp [hd]
    simp [pow_add, pow_succ]
    ring]
  rw [show q₀₁ * vv / d ^ (n + 3) =
      (q₀₁ / d) * (vv / d ^ (n + 2)) by
    field_simp [hd]
    simp [pow_add, pow_succ]
    ring; simp]
  rw [show q₁₀ * vh / d ^ (n + 3) =
      (q₁₀ / d) * (vh / d ^ (n + 2)) by
    field_simp [hd]
    simp [pow_add, pow_succ]
    ring; simp]
  ring

/-- The checked Gaussian recurrence, after normalization by
`D^(j+k+1)`, obeys the same complex Taylor recurrence. -/
theorem scaledCertificateCoefficient_recurrence
    (j k : ℕ) (hj : j < 29) (hk : k < 29) :
    scaledCertificateCoefficient j k =
      Optim.BohrRadius.complexBidegreeRecurrenceValue
        (-q₁₀C) (-q₀₁C) q₁₁C p₀₀C p₁₀C p₀₁C p₁₁C
        scaledCertificateCoefficient j k := by
  have hraw := rectangle_recurrence (⟨j, hj⟩ : Fin 29) (⟨k, hk⟩ : Fin 29)
  have hcast := congrArg gaussianCast hraw
  cases j with
  | zero =>
      cases k with
      | zero =>
          simp [scaledCertificateCoefficient,
            Optim.BohrRadius.complexBidegreeRecurrenceValue,
            expected, p₀₀C] at hcast ⊢
          rw [hcast]
      | succ k =>
          by_cases hk0 : k = 0
          · subst k
            simp [scaledCertificateCoefficient,
              Optim.BohrRadius.complexBidegreeRecurrenceValue,
              expected, q₀₁C, p₀₁C, p₁₁C] at hcast ⊢
            have hcast' :
                gaussianCast (coefficientNumerator 0 1) =
                  (D : ℂ) ^ (0 + 1) * gaussianCast (numerator.getD 2 (0, 0)) -
                    gaussianCast (denominator.getD 2 (0, 0)) *
                      gaussianCast (coefficientNumerator 0 0) := by
              simpa [pow_succ] using hcast
            simpa using normalize_scaled_axis (D : ℂ)
              (gaussianCast (denominator.getD 2 (0, 0)))
              (gaussianCast (coefficientNumerator 0 1))
              (gaussianCast (coefficientNumerator 0 0))
              (gaussianCast (numerator.getD 2 (0, 0))) 0 D_cast_ne_zero hcast'
          · have hk2 : ¬ k + 1 < 2 := by omega
            simp [scaledCertificateCoefficient,
              Optim.BohrRadius.complexBidegreeRecurrenceValue,
              expected, q₀₁C, p₀₁C, p₁₁C, hk0, hk2] at hcast ⊢
            have hcast' :
                gaussianCast (coefficientNumerator 0 (k + 1)) =
                  (D : ℂ) ^ (k + 1) * 0 -
                    gaussianCast (denominator.getD 2 (0, 0)) *
                      gaussianCast (coefficientNumerator 0 k) := by
              simpa using hcast
            simpa [pow_add, pow_succ] using normalize_scaled_axis (D : ℂ)
              (gaussianCast (denominator.getD 2 (0, 0)))
              (gaussianCast (coefficientNumerator 0 (k + 1)))
              (gaussianCast (coefficientNumerator 0 k)) 0 k D_cast_ne_zero hcast'
  | succ j =>
      cases k with
      | zero =>
          by_cases hj0 : j = 0
          · subst j
            simp [scaledCertificateCoefficient,
              Optim.BohrRadius.complexBidegreeRecurrenceValue,
              expected, q₁₀C, p₁₀C, p₁₁C] at hcast ⊢
            have hcast' :
                gaussianCast (coefficientNumerator 1 0) =
                  (D : ℂ) ^ (0 + 1) * gaussianCast (numerator.getD 1 (0, 0)) -
                    gaussianCast (denominator.getD 1 (0, 0)) *
                      gaussianCast (coefficientNumerator 0 0) := by
              simpa [pow_succ] using hcast
            simpa using normalize_scaled_axis (D : ℂ)
              (gaussianCast (denominator.getD 1 (0, 0)))
              (gaussianCast (coefficientNumerator 1 0))
              (gaussianCast (coefficientNumerator 0 0))
              (gaussianCast (numerator.getD 1 (0, 0))) 0 D_cast_ne_zero hcast'
          · have hj2 : ¬ j + 1 < 2 := by omega
            simp [scaledCertificateCoefficient,
              Optim.BohrRadius.complexBidegreeRecurrenceValue,
              expected, q₁₀C, p₁₀C, p₁₁C, hj0, hj2] at hcast ⊢
            have hcast' :
                gaussianCast (coefficientNumerator (j + 1) 0) =
                  (D : ℂ) ^ (j + 1) * 0 -
                    gaussianCast (denominator.getD 1 (0, 0)) *
                      gaussianCast (coefficientNumerator j 0) := by
              simpa using hcast
            simpa [pow_add, pow_succ] using normalize_scaled_axis (D : ℂ)
              (gaussianCast (denominator.getD 1 (0, 0)))
              (gaussianCast (coefficientNumerator (j + 1) 0))
              (gaussianCast (coefficientNumerator j 0)) 0 j D_cast_ne_zero hcast'
      | succ k =>
          by_cases hjk0 : j = 0 ∧ k = 0
          · rcases hjk0 with ⟨rfl, rfl⟩
            simp [scaledCertificateCoefficient,
              Optim.BohrRadius.complexBidegreeRecurrenceValue,
              expected, q₁₀C, q₀₁C, q₁₁C, p₁₁C] at hcast ⊢
            have hcast' :
                gaussianCast (coefficientNumerator 1 1) =
                  (D : ℂ) ^ (0 + 2) * gaussianCast (numerator.getD 3 (0, 0)) +
                    (-((D : ℂ) * gaussianCast (denominator.getD 3 (0, 0)) *
                        gaussianCast (coefficientNumerator 0 0)) -
                      gaussianCast (denominator.getD 2 (0, 0)) *
                        gaussianCast (coefficientNumerator 1 0) -
                      gaussianCast (denominator.getD 1 (0, 0)) *
                        gaussianCast (coefficientNumerator 0 1)) := by
              simpa [pow_succ, mul_assoc, sub_eq_add_neg, add_assoc] using hcast
            simpa using normalize_scaled_interior (D : ℂ)
              (gaussianCast (denominator.getD 1 (0, 0)))
              (gaussianCast (denominator.getD 2 (0, 0)))
              (gaussianCast (denominator.getD 3 (0, 0)))
              (gaussianCast (coefficientNumerator 1 1))
              (gaussianCast (coefficientNumerator 0 1))
              (gaussianCast (coefficientNumerator 1 0))
              (gaussianCast (coefficientNumerator 0 0))
              (gaussianCast (numerator.getD 3 (0, 0))) 0 D_cast_ne_zero hcast'
          · have hsource : ¬ (j + 1 < 2 ∧ k + 1 < 2) := by omega
            simp [scaledCertificateCoefficient,
              Optim.BohrRadius.complexBidegreeRecurrenceValue,
              expected, q₁₀C, q₀₁C, q₁₁C, p₁₁C,
              hjk0, hsource] at hcast ⊢
            have hcast' :
                gaussianCast (coefficientNumerator (j + 1) (k + 1)) =
                  (D : ℂ) ^ (j + k + 2) * 0 +
                    (-((D : ℂ) * gaussianCast (denominator.getD 3 (0, 0)) *
                        gaussianCast (coefficientNumerator j k)) -
                      gaussianCast (denominator.getD 2 (0, 0)) *
                        gaussianCast (coefficientNumerator (j + 1) k) -
                      gaussianCast (denominator.getD 1 (0, 0)) *
                        gaussianCast (coefficientNumerator j (k + 1))) := by
              simpa [mul_assoc, sub_eq_add_neg, add_assoc] using hcast
            simpa [pow_add, pow_succ, add_assoc, add_left_comm, add_comm] using
              normalize_scaled_interior (D : ℂ)
                (gaussianCast (denominator.getD 1 (0, 0)))
                (gaussianCast (denominator.getD 2 (0, 0)))
                (gaussianCast (denominator.getD 3 (0, 0)))
                (gaussianCast (coefficientNumerator (j + 1) (k + 1)))
                (gaussianCast (coefficientNumerator j (k + 1)))
                (gaussianCast (coefficientNumerator (j + 1) k))
                (gaussianCast (coefficientNumerator j k)) 0 (j + k) D_cast_ne_zero hcast'

/-- The finite checked rectangle is exactly the corresponding rectangle of
the all-orders analytic Taylor family. -/
theorem actualCoefficient_eq_scaledCertificateCoefficient
    (j k : ℕ) (hj : j < 29) (hk : k < 29) :
    actualCoefficient j k = scaledCertificateCoefficient j k := by
  apply Optim.BohrRadius.complexBidegreeRecurrence_unique_on_rectangle
    (-q₁₀C) (-q₀₁C) q₁₁C p₀₀C p₁₀C p₀₁C p₁₁C 29
    actualCoefficient scaledCertificateCoefficient
    (fun m n _ _ => by
      exact Optim.BohrRadius.recurrentCoefficient_eq_complexBidegreeRecurrenceValue
        (-q₁₀C) (-q₀₁C) q₁₁C p₀₀C p₁₀C p₀₁C p₁₁C m n)
    (fun m n hm hn => scaledCertificateCoefficient_recurrence m n hm hn)
    j k hj hk

end BidiscPhaseCertificate

namespace BidiscPhaseCertificate

/-- Exact upper norm-square checks for all seven normalized coefficients. -/
theorem parameter_normSquares_le :
    normSquared (denominator.getD 1 (0, 0)) ≤ D ^ 2 ∧
    normSquared (denominator.getD 2 (0, 0)) ≤ D ^ 2 ∧
    normSquared (denominator.getD 3 (0, 0)) ≤ D ^ 2 ∧
    normSquared (numerator.getD 0 (0, 0)) ≤ D ^ 2 ∧
    normSquared (numerator.getD 1 (0, 0)) ≤ D ^ 2 ∧
    normSquared (numerator.getD 2 (0, 0)) ≤ D ^ 2 ∧
    normSquared (numerator.getD 3 (0, 0)) ≤ D ^ 2 := by
  native_decide

theorem norm_gaussianCast_le_D (v : Gaussian)
    (hsq : normSquared v ≤ D ^ 2) :
    ‖gaussianCast v‖ ≤ (D : ℝ) := by
  have hsq' :
      ((v.1.natAbs : ℕ) : ℝ) ^ 2 + ((v.2.natAbs : ℕ) : ℝ) ^ 2 ≤
        (D : ℝ) ^ 2 := by
    exact_mod_cast hsq
  rw [natAbs_sq_cast_real, natAbs_sq_cast_real] at hsq'
  have hnorm : ‖gaussianCast v‖ ^ 2 = (v.1 : ℝ) ^ 2 + (v.2 : ℝ) ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq]
    simp [gaussianCast, Complex.normSq_apply]
    ring
  rw [← hnorm] at hsq'
  have hDnonneg : (0 : ℝ) ≤ (D : ℝ) := by positivity
  nlinarith [norm_nonneg (gaussianCast v)]

theorem normalized_gaussian_norm_le_one (v : Gaussian)
    (hsq : normSquared v ≤ D ^ 2) :
    ‖gaussianCast v / (D : ℂ)‖ ≤ 1 := by
  rw [norm_div]
  have hDpos : (0 : ℝ) < ‖(D : ℂ)‖ := norm_pos_iff.mpr D_cast_ne_zero
  apply (div_le_one hDpos).2
  simpa using norm_gaussianCast_le_D v hsq

theorem q₁₀C_norm_le_one : ‖q₁₀C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.1

theorem q₀₁C_norm_le_one : ‖q₀₁C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.2.1

theorem q₁₁C_norm_le_one : ‖q₁₁C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.2.2.1

theorem p₀₀C_norm_le_one : ‖p₀₀C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.2.2.2.1

theorem p₁₀C_norm_le_one : ‖p₁₀C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.2.2.2.2.1

theorem p₀₁C_norm_le_one : ‖p₀₁C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.2.2.2.2.2.1

theorem p₁₁C_norm_le_one : ‖p₁₁C‖ ≤ 1 := by
  exact normalized_gaussian_norm_le_one _ parameter_normSquares_le.2.2.2.2.2.2

theorem normalizedDenominator_ne_zero
    (z w : ℂ) (hz : ‖z‖ < (1 / 8 : ℝ)) (hw : ‖w‖ < (1 / 8 : ℝ)) :
    1 + q₁₀C * z + q₀₁C * w + q₁₁C * z * w ≠ 0 := by
  have h10 : ‖q₁₀C * z‖ < (1 / 8 : ℝ) := by
    rw [norm_mul]
    calc
      ‖q₁₀C‖ * ‖z‖ ≤ 1 * ‖z‖ :=
        mul_le_mul_of_nonneg_right q₁₀C_norm_le_one (norm_nonneg z)
      _ < 1 / 8 := by simpa using hz
  have h01 : ‖q₀₁C * w‖ < (1 / 8 : ℝ) := by
    rw [norm_mul]
    calc
      ‖q₀₁C‖ * ‖w‖ ≤ 1 * ‖w‖ :=
        mul_le_mul_of_nonneg_right q₀₁C_norm_le_one (norm_nonneg w)
      _ < 1 / 8 := by simpa using hw
  have h11 : ‖q₁₁C * z * w‖ < (1 / 64 : ℝ) := by
    rw [norm_mul, norm_mul]
    have hprod : ‖z‖ * ‖w‖ < (1 / 64 : ℝ) := by
      by_cases hwzero : ‖w‖ = 0
      · simp [hwzero]
      · have hwpos : 0 < ‖w‖ := lt_of_le_of_ne (norm_nonneg w) (Ne.symm hwzero)
        calc
          ‖z‖ * ‖w‖ < (1 / 8 : ℝ) * ‖w‖ :=
            mul_lt_mul_of_pos_right hz hwpos
          _ < (1 / 8 : ℝ) * (1 / 8 : ℝ) :=
            mul_lt_mul_of_pos_left hw (by norm_num)
          _ = 1 / 64 := by norm_num
    calc
      ‖q₁₁C‖ * ‖z‖ * ‖w‖ ≤ 1 * ‖z‖ * ‖w‖ := by
        gcongr
        exact q₁₁C_norm_le_one
      _ = ‖z‖ * ‖w‖ := by ring
      _ < 1 / 64 := hprod
  have hsum : ‖q₁₀C * z + q₀₁C * w + q₁₁C * z * w‖ < 1 := by
    calc
      ‖q₁₀C * z + q₀₁C * w + q₁₁C * z * w‖ ≤
          ‖q₁₀C * z‖ + ‖q₀₁C * w‖ + ‖q₁₁C * z * w‖ := by
        exact (norm_add_le _ _).trans (add_le_add_right (norm_add_le _ _) _)
      _ < 1 := by linarith
  intro hzero
  have hone : (1 : ℂ) = -(q₁₀C * z + q₀₁C * w + q₁₁C * z * w) := by
    linear_combination hzero
  have heq : (1 : ℝ) = ‖q₁₀C * z + q₀₁C * w + q₁₁C * z * w‖ := by
    calc
      (1 : ℝ) = ‖(1 : ℂ)‖ := by norm_num
      _ = ‖-(q₁₀C * z + q₀₁C * w + q₁₁C * z * w)‖ := by rw [hone]
      _ = _ := norm_neg _
  linarith

/-- The recurrence family is the genuine Taylor family of the same concrete
Schur witness used in the analytic proof. -/
theorem actualCoefficient_hasBidiscCoefficients :
    Optim.BohrRadius.HasBidiscCoefficients certifiedWitness actualCoefficient := by
  have h := Optim.BohrRadius.complexBidegreeRational_recurrent_hasBidiscCoefficients
    q₁₀C_norm_le_one q₀₁C_norm_le_one q₁₁C_norm_le_one
    p₀₀C_norm_le_one p₁₀C_norm_le_one p₀₁C_norm_le_one p₁₁C_norm_le_one
    normalizedDenominator_ne_zero
  rw [← certificateRational_eq_certifiedWitness]
  simpa [certificateRational, q10, q01, q11, p00, p10, p01, p11,
    q₁₀C, q₀₁C, q₁₁C, p₀₀C, p₁₀C, p₀₁C, p₁₁C,
    actualCoefficient] using h

end BidiscPhaseCertificate

namespace BidiscPhaseCertificate

/-- The exact lower majorant obtained from the certified integer norm floors. -/
noncomputable def certifiedLowerMajorant : ℝ :=
  ∑ j ∈ Finset.range 29, ∑ k ∈ Finset.range 29,
    (lowerNorm j k : ℝ) / (D : ℝ) ^ (j + k + 1) *
      ((R : ℝ) / (E : ℝ)) ^ (j + k)

def commonDenominator : Nat := D * (E * D) ^ 56

/-- Universal denominator-clearing identity for one lower-majorant term. -/
theorem homogeneous_lower_term
    (v rn rd scale t N : ℕ)
    (hrd : (rd : ℝ) ≠ 0) (hscale : (scale : ℝ) ≠ 0)
    (ht : t ≤ N) :
    (v : ℝ) / (scale : ℝ) ^ (t + 1) *
        ((rn : ℝ) / (rd : ℝ)) ^ t *
        ((scale : ℝ) * ((rd : ℝ) * (scale : ℝ)) ^ N) =
      (v : ℝ) * (rn : ℝ) ^ t *
        ((rd : ℝ) * (scale : ℝ)) ^ (N - t) := by
  have hdecomp :
      ((rd : ℝ) * (scale : ℝ)) ^ N =
        ((rd : ℝ) * (scale : ℝ)) ^ (N - t) *
          ((rd : ℝ) * (scale : ℝ)) ^ t := by
    rw [← pow_add, Nat.sub_add_cancel ht]
  rw [hdecomp, div_pow]
  field_simp [hrd, hscale]
  simp [mul_pow, pow_add, pow_succ]
  ring

theorem certifiedLowerMajorant_mul_commonDenominator :
    certifiedLowerMajorant * (commonDenominator : ℝ) =
      (weightedIntegerSum : ℝ) := by
  unfold certifiedLowerMajorant commonDenominator weightedIntegerSum
  push_cast
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro j hj
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro k hk
  have hj' : j < 29 := Finset.mem_range.mp hj
  have hk' : k < 29 := Finset.mem_range.mp hk
  apply homogeneous_lower_term
  · exact_mod_cast (show E ≠ 0 by native_decide)
  · exact_mod_cast input_parameters_positive.1.ne'
  · omega

theorem weightedIntegerSum_gt_commonDenominator :
    commonDenominator < weightedIntegerSum := by
  have hmargin := strict_weighted_integer_margin
  have hscale : 0 < 10 ^ 26 := by positivity
  unfold commonDenominator
  omega

theorem certifiedLowerMajorant_exceeds_one :
    1 < certifiedLowerMajorant := by
  have hcast : (commonDenominator : ℝ) < (weightedIntegerSum : ℝ) := by
    exact_mod_cast weightedIntegerSum_gt_commonDenominator
  have hcommonNat : 0 < commonDenominator := by
    unfold commonDenominator
    exact Nat.mul_pos input_parameters_positive.1
      (pow_pos (Nat.mul_pos (by native_decide) input_parameters_positive.1) _)
  have hcommon : (0 : ℝ) < (commonDenominator : ℝ) := by exact_mod_cast hcommonNat
  have hid := certifiedLowerMajorant_mul_commonDenominator
  nlinarith

/-- Every lower norm floor contributes no more than the corresponding true
Taylor coefficient norm. -/
theorem certifiedLowerMajorant_le_finiteMajorant :
    certifiedLowerMajorant ≤
      Optim.BohrRadius.finiteMajorant actualCoefficient
        ((R : ℝ) / (E : ℝ)) 28 := by
  unfold certifiedLowerMajorant Optim.BohrRadius.finiteMajorant
  apply Finset.sum_le_sum
  intro j hj
  apply Finset.sum_le_sum
  intro k hk
  have hj29 : j < 29 := by
    have := Finset.mem_range.mp hj
    omega
  have hk29 : k < 29 := by
    have := Finset.mem_range.mp hk
    omega
  have hsq := (integer_square_roots_correct
    (⟨j, hj29⟩ : Fin 29) (⟨k, hk29⟩ : Fin 29)).1
  have hfloor := lowerNorm_le_norm_gaussianCast j k hsq
  have hcoefficient :
      (lowerNorm j k : ℝ) / (D : ℝ) ^ (j + k + 1) ≤
        ‖actualCoefficient j k‖ := by
    rw [actualCoefficient_eq_scaledCertificateCoefficient j k hj29 hk29,
      scaledCertificateCoefficient, norm_div, norm_pow]
    have hnormD : ‖(D : ℂ)‖ = (D : ℝ) := by simp
    rw [hnormD]
    exact div_le_div_of_nonneg_right hfloor (by positivity)
  have hrnonneg : (0 : ℝ) ≤ (R : ℝ) / (E : ℝ) := by positivity
  exact mul_le_mul_of_nonneg_right hcoefficient (pow_nonneg hrnonneg _)

theorem actualCoefficient_finiteMajorant_exceeds_one :
    1 < Optim.BohrRadius.finiteMajorant actualCoefficient
      ((R : ℝ) / (E : ℝ)) 28 :=
  lt_of_lt_of_le certifiedLowerMajorant_exceeds_one
    certifiedLowerMajorant_le_finiteMajorant

end BidiscPhaseCertificate

namespace Optim.BohrRadius

/-- End-to-end strict upper bound certified by Shivam Patel's 2026 Gaussian
phase witness.  The theorem uses the genuine analytic Schur class, the actual
locally convergent Taylor family, and the supremal definition of the bidisc
Bohr radius. -/
theorem bohrRadius_lt_patel2026 :
    bohrRadius <
      (BidiscPhaseCertificate.R : ℝ) / (BidiscPhaseCertificate.E : ℝ) := by
  exact bohrRadius_lt_of_finite_violation
    (by norm_num [BidiscPhaseCertificate.R, BidiscPhaseCertificate.E])
    BidiscPhaseCertificate.certifiedWitness_isSchur
    BidiscPhaseCertificate.actualCoefficient_hasBidiscCoefficients
    BidiscPhaseCertificate.actualCoefficient_finiteMajorant_exceeds_one

/-- Decimal form of the new strict world-record upper bound. -/
theorem bohrRadius_lt_302825279492_div_10pow12 :
    bohrRadius < (302825279492 : ℝ) / 10 ^ 12 := by
  convert bohrRadius_lt_patel2026 using 1
  norm_num [BidiscPhaseCertificate.R, BidiscPhaseCertificate.E]

end Optim.BohrRadius

#print axioms BidiscPhaseCertificate.certifiedWitness_isSchur
#print axioms BidiscPhaseCertificate.actualCoefficient_hasBidiscCoefficients
#print axioms BidiscPhaseCertificate.actualCoefficient_eq_scaledCertificateCoefficient
#print axioms BidiscPhaseCertificate.actualCoefficient_finiteMajorant_exceeds_one
#print axioms Optim.BohrRadius.bohrRadius_lt_302825279492_div_10pow12
