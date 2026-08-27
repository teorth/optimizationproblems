import Mathlib.Data.Nat.Sqrt
import Mathlib.Tactic

/-!
Exact finite ARITHMETIC certificate for the rational data at radius
302825279492 / 10^12. This file does not formalize the analytic Schur proof
or the deduction about the bidisc Bohr radius. Those are separate claims.

The computational proofs use native_decide. The axiom audit at the end
records that native-computation trust boundary.
-/

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

namespace BidiscPhaseCertificate

abbrev Gaussian := Int × Int

def gadd (a b : Gaussian) : Gaussian := (a.1 + b.1, a.2 + b.2)
def gneg (a : Gaussian) : Gaussian := (-a.1, -a.2)
def gmul (a b : Gaussian) : Gaussian :=
  (a.1 * b.1 - a.2 * b.2, a.1 * b.2 + a.2 * b.1)
def gscale (n : Int) (a : Gaussian) : Gaussian := (n * a.1, n * a.2)
def gconj (a : Gaussian) : Gaussian := (a.1, -a.2)

def L : Nat := 2500000000
def T : Nat := 3067398171
def S : Nat := 1000000000000000
def R : Nat := 302825279492
def E : Nat := 1000000000000
def side : Nat := 29
def maxDegree : Nat := 56

/-- Coefficients of SQ-P, ordered as 1,z,w,zw. -/
def inputNumerator : Array Gaussian := Id.run do
  let l : Int := L
  let t : Int := T
  let s : Int := S
  return #[((s - 1) * l, (s - 1) * t),
    (-l, s * t), (l, -(s * t)),
    ((s + 1) * l, -((s + 1) * t))]

/-- Coefficients of SQ+P, ordered as 1,z,w,zw. -/
def inputDenominator : Array Gaussian := Id.run do
  let l : Int := L
  let t : Int := T
  let s : Int := S
  return #[((s + 1) * l, (s + 1) * t),
    (l, s * t), (-l, -(s * t)),
    ((s - 1) * l, -((s - 1) * t))]

def conjugateConstant : Gaussian :=
  gconj (inputDenominator.getD 0 (0, 0))

def numerator : Array Gaussian :=
  inputNumerator.map (fun v => gmul v conjugateConstant)

def denominator : Array Gaussian :=
  inputDenominator.map (fun v => gmul v conjugateConstant)

def D : Nat := (S + 1) ^ 2 * (L ^ 2 + T ^ 2)

theorem denominator_constant_correct :
    denominator.getD 0 (0, 0) = ((D : Int), 0) := by
  native_decide

theorem input_parameters_positive :
    0 < D ∧ 0 < R ∧ R < E ∧ 1 < S := by
  native_decide

def rectangle : Array Gaussian := Id.run do
  let q10 := denominator.getD 1 (0, 0)
  let q01 := denominator.getD 2 (0, 0)
  let q11 := denominator.getD 3 (0, 0)
  let d : Int := D
  let mut values := Array.replicate (side * side) ((0, 0) : Gaussian)
  for j in [:side] do
    for k in [:side] do
      let first := if 0 < j then
        gmul q10 (values.getD ((j - 1) * side + k) (0, 0)) else (0, 0)
      let second := if 0 < k then
        gmul q01 (values.getD (j * side + (k - 1)) (0, 0)) else (0, 0)
      let mixed := if 0 < j ∧ 0 < k then
        gscale d (gmul q11
          (values.getD ((j - 1) * side + (k - 1)) (0, 0))) else (0, 0)
      let source := if j < 2 ∧ k < 2 then
        gscale (d ^ (j + k)) (numerator.getD (j + 2 * k) (0, 0)) else (0, 0)
      values := values.set! (j * side + k)
        (gadd source (gneg (gadd first (gadd second mixed))))
  return values

def coefficientNumerator (j k : Nat) : Gaussian :=
  rectangle.getD (j * side + k) (0, 0)

def expected (j k : Nat) : Gaussian :=
  let first := if 0 < j then
    gmul (denominator.getD 1 (0, 0)) (coefficientNumerator (j - 1) k) else (0, 0)
  let second := if 0 < k then
    gmul (denominator.getD 2 (0, 0)) (coefficientNumerator j (k - 1)) else (0, 0)
  let mixed := if 0 < j ∧ 0 < k then
    gscale (D : Int) (gmul (denominator.getD 3 (0, 0))
      (coefficientNumerator (j - 1) (k - 1))) else (0, 0)
  let source := if j < 2 ∧ k < 2 then
    gscale ((D : Int) ^ (j + k)) (numerator.getD (j + 2 * k) (0, 0)) else (0, 0)
  gadd source (gneg (gadd first (gadd second mixed)))

theorem rectangle_recurrence :
    ∀ j k : Fin 29,
      coefficientNumerator j.val k.val = expected j.val k.val := by
  native_decide

def normSquared (v : Gaussian) : Nat := v.1.natAbs ^ 2 + v.2.natAbs ^ 2

def lowerRectangle : Array Nat :=
  rectangle.map (fun v => Nat.sqrt (normSquared v))

def lowerNorm (j k : Nat) : Nat := lowerRectangle.getD (j * side + k) 0

theorem integer_square_roots_correct :
    ∀ j k : Fin 29,
      (lowerNorm j.val k.val) ^ 2 ≤ normSquared (coefficientNumerator j.val k.val) ∧
      normSquared (coefficientNumerator j.val k.val) <
        (lowerNorm j.val k.val + 1) ^ 2 := by
  native_decide

def diagonals : Array Nat := Id.run do
  let mut values := Array.replicate 57 0
  for j in [:side] do
    for k in [:side] do
      values := values.set! (j + k)
        (values.getD (j + k) 0 + lowerNorm j k)
  return values

def homogeneous : Nat × Nat := Id.run do
  let base := E * D
  let mut denominatorPower := 1
  let mut value := diagonals.getD 56 0
  for t in [:56] do
    denominatorPower := denominatorPower * base
    value := value * R + diagonals.getD (55 - t) 0 * denominatorPower
  return (value, D * denominatorPower)

open scoped BigOperators

def weightedIntegerSum : Nat :=
  ∑ j ∈ Finset.range 29, ∑ k ∈ Finset.range 29,
    lowerNorm j k * R ^ (j + k) * (E * D) ^ (56 - (j + k))

theorem weighted_sum_eq_homogeneous :
    weightedIntegerSum = homogeneous.1 := by
  native_decide

theorem homogeneous_denominator_correct :
    homogeneous.2 = D * (E * D) ^ 56 := by
  native_decide

/-- This is only the finite integer comparison, not an analytic Bohr theorem. -/
theorem strict_integer_margin :
    10 ^ 26 * homogeneous.1 > (10 ^ 26 + 1) * homogeneous.2 := by
  native_decide

theorem strict_weighted_integer_margin :
    10 ^ 26 * weightedIntegerSum > (10 ^ 26 + 1) * (D * (E * D) ^ 56) := by
  rw [weighted_sum_eq_homogeneous, ← homogeneous_denominator_correct]
  exact strict_integer_margin

end BidiscPhaseCertificate

#print axioms BidiscPhaseCertificate.rectangle_recurrence
#print axioms BidiscPhaseCertificate.integer_square_roots_correct
#print axioms BidiscPhaseCertificate.strict_weighted_integer_margin
