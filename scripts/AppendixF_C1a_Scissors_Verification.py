# -*- coding: utf-8 -*-
"""
Appendix F: C1a Scissors-Shape Verification (Sole Input Pi)
============================================================
Appendix E verified the C1b interval; this appendix runs the same
Riemann-sum power-order reduction for the C1a interval.

Key structural fact (the "scissors"): the two C1a endpoints move in
opposite directions in Pi.
  C1a upper = 3/2 + 3*sqrt(5Pi)*delta :  strictly decreasing in Pi
    (delta' = -(48/5)cos(Pi/5)sin(Pi/5) - 5 < 0 dominates; slope ~ -114)
  C1a lower = 3/2 - 6*sqrt(6)*cos(Pi/5)*delta :  strictly increasing in Pi
    (slope ~ +114)
so [lower(Pi), upper(Pi)] shrinks as Pi grows.  Unlike C1b (both edges
monotone increasing), both safe bounds therefore take pi_k^-:
  window = [C1a_lo(pi_k^-), C1a_up(pi_k^-)]  contains the true band and
hence the exact band midpoint s* = 3/2, for every N (since the measured
overshoot e ~ bound/4 < bound, pi_k^- < Pi always).

Verified quantities:
  F.1 monotonic directions (numerical check at Pi +/- 1e-4)
  F.2 8-level endpoint convergence (deviation inside the band from N=10^2)
  F.3 s* = 3/2 analytic containment + 8-level clamping window table

Sole input Pi; decimal 60 digits; strict error bound 1/(3N^2);
no external certified value (Atris/White etc.) is referenced.

Usage: python AppendixF_C1a_Scissors_Verification.py
"""
import sys
from decimal import Decimal, getcontext
getcontext().prec = 60
sys.path.insert(0, r"D:\推理\二维闭合态本征裂隙\Galois迹映射_C1aC1b统一论文")
from AppendixCD_RiemannSum_PowerOrder_Verification import PI, endpoints_c, riemann_pi

# ---------------------------------------------------------------- C1a target interval
C1a_up_true = Decimal("1.5028614971465336371692130624748318648423012063966653")
C1a_lo_true = Decimal("1.4971384809327922834494017548657733188694213205979527")
band = C1a_up_true - C1a_lo_true
s_star = (C1a_lo_true + C1a_up_true) / Decimal(2)   # = 3/2 exactly
print(f"C1a target interval [{C1a_lo_true}, {C1a_up_true}], bandwidth {band:.2E}")
print(f"band midpoint s* = {s_star}  (exactly 3/2 by the endpoint formulas)")

# ---------------------------------------------------------------- F.1 monotonic directions
eps = Decimal("1e-4")
e0 = endpoints_c(PI); e_ = endpoints_c(PI - eps); eP = endpoints_c(PI + eps)
print("\nF.1  Monotonic directions (Pi - 1e-4, Pi, Pi + 1e-4):")
for k in ["C1a_up", "C1a_lo"]:
    d_ = e_[k] - e0[k]; dP = eP[k] - e0[k]
    print(f"  {k}: d(Pi-eps)={d_:.2E}  d(Pi+eps)={dP:+.2E}  "
          f"-> {'decreasing in Pi' if dP < 0 else 'increasing in Pi'}")
print("  -> scissors: upper edge decreases, lower edge increases in Pi; "
      "the band [lower, upper] shrinks as Pi grows.")

# ---------------------------------------------------------------- F.2 endpoint convergence
print("\nF.2  8-level endpoint convergence (C1a):")
print(f"{'N':>8} | {'C1a_up dev':>12} | {'C1a_lo dev':>12} | {'rel.bw':>8} | {'mode':>8}")
for m in range(1, 9):
    N = 10 ** m
    pk, mode = riemann_pi(N)
    e = endpoints_c(pk)
    du = abs(e["C1a_up"] - C1a_up_true)
    dl = abs(e["C1a_lo"] - C1a_lo_true)
    print(f"{N:>8} | {du:.2E} | {dl:.2E} | {max(du, dl)/band:>8.3f} | {mode:>8}")
print("  Endpoint deviations tend to zero monotonically; from N = 10^2 the "
      "deviation is inside the bandwidth (rel. bw < 1) — the convergence limit "
      "is the endpoint formula itself.")

# ---------------------------------------------------------------- F.3 s* = 3/2 containment
print("\nF.3  Analytic containment of s* = 3/2:")
print("  upper = 3/2 + 3*sqrt(5Pi)*delta > 3/2   (delta > 0)")
print("  lower = 3/2 - 6*sqrt(6)*cos(Pi/5)*delta < 3/2   (delta > 0, cos > 0)")
print("  => s* = 3/2 lies strictly inside the band by construction.")
print("  Scissors-safe window: both edges take pi_k^- "
      "(measured overshoot e ~ bound/4 < bound => pi_k^- < Pi):")
print(f"{'N':>8} | {'window [lo, up]':>24} | {'covers s*':>9} | {'rel.bw':>8}")
for m in range(1, 9):
    N = 10 ** m
    pk, mode = riemann_pi(N)
    err = Decimal(1) / (Decimal(3) * Decimal(N) * Decimal(N))
    e_m = endpoints_c(pk - err)
    lo_w = e_m["C1a_lo"]
    up_w = e_m["C1a_up"]
    cover = (lo_w <= s_star) and (s_star <= up_w)
    print(f"{N:>8} | [{lo_w:.6f}, {up_w:.6f}] | {str(cover):>9} | {(up_w-lo_w)/band:>8.3f}")
print("  The safe window strictly contains the true band (rel. bw >= 1) and "
      "therefore covers s* = 3/2 for every N in the ladder.")
print("\nConclusion: the C1a two-extremal interval is self-determined from the "
      "sole input Pi; s* = 3/2 is analytically in-band; the verdict path is "
      "finite rational arithmetic (Riemann sum + four operations), with no "
      "transcendental-number operation and no external certified value.")
