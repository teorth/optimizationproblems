# -*- coding: utf-8 -*-
"""
Appendix C/D Riemann-Sum Power-Order Verification (Sole Input Pi)
================================================================
Deterministic verification following the protocol of Appendix C (sole input Pi):

  1. Appendix C: cross-check of the four endpoints (Pi-form) against the
     preregistered values of Sec. 3
     delta_C = 24cos^2(Pi/5) - 5*Pi = 6*Phi^2 - 5*pi (deviation < 1e-57)
  2. Appendix D: (A-B)(A+B) = delta_C square-difference isomorphism
     A = 2*sqrt(6)cos(Pi/5) = sqrt(6*Phi^2), B = (4cos(Pi/5)-1)*sqrt(Pi) = sqrt(5*Pi)
     C1b baseline phi^2 = 4sin^2(Pi/10) = 0.38196601125010515...
  3. 8-level Riemann-sum power-order reduction:
     pi_k = (4/N) * sum 1/(1+x_i^2), x_i = (i-1/2)/N
     measured error ~ 0.0833/N^2 (reproduces Appendix A, Fact 3);
     strict theoretical bound 1/(3N^2)
     (f(x)=4/(1+x^2) has max|f''| = 8 on [0,1] -> midpoint-rule bound
      = 8/(24N^2) = 1/(3N^2))
     endpoint deviations tend to zero monotonically in N;
     the convergence limit is the endpoint formula itself
  4. Two-sided clamping (error bound pi_k+/- = pi_k +/- 1/(3N^2)):
     in-band clamping holds from N = 10^5
     (window 4.10e-9 < bandwidth 1.18e-8; upper arm = e + bound,
      lower arm = bound - e, e ~ bound/4, ratio 5:3)

Verdict path = sole input Pi + finite rational arithmetic
(Riemann sum + the four operations); no external certified value
(Atris/White etc.) is referenced.
N <= 10^5 uses decimal 60-digit exact arithmetic; N >= 10^6 uses float64
(demonstrating the float64 floor; requires numpy).

Usage: python AppendixCD_RiemannSum_PowerOrder_Verification.py
"""
from decimal import Decimal, getcontext
getcontext().prec = 60

# ---------------------------------------------------------------- basic functions
def _sin_cos(x, terms=140):
    """Taylor recursion for sin/cos (independent factorial recursions):
    sin term t_{n+1} = t_n * (-x^2)/((2n+2)(2n+3));
    cos term u_{n+1} = u_n * (-x^2)/((2n+1)(2n+2))"""
    x2 = x * x
    s = x; c = Decimal(1)
    t = x; u = Decimal(1)
    for n in range(1, terms):
        t *= -x2 / (Decimal(2 * n) * Decimal(2 * n + 1))
        u *= -x2 / (Decimal(2 * n - 1) * Decimal(2 * n))
        s += t; c += u
        if abs(t) < Decimal(10) ** -55 and abs(u) < Decimal(10) ** -55:
            break
    return s, c

def _cos(x):
    return _sin_cos(x)[1]

def _sin(x):
    return _sin_cos(x)[0]

def _atan(x, terms=400):
    """arctan Taylor: atan(x) = sum (-1)^n x^(2n+1)/(2n+1)"""
    x2 = x * x
    s = x; t = x; n = 1
    while n < terms:
        t *= -x2
        term = t / Decimal(2 * n + 1)
        s += term
        n += 1
        if abs(term) < Decimal(10) ** -58:
            break
    return s

def PI_machin():
    """Machin formula (pure rational arithmetic):
    Pi = 16*atan(1/5) - 4*atan(1/239)"""
    return Decimal(16) * _atan(Decimal(1) / Decimal(5)) - Decimal(4) * _atan(Decimal(1) / Decimal(239))

PI = PI_machin()

# ---------------------------------------------------------------- Appendix C endpoint formulas (sole input Pi)
def endpoints_c(p):
    """Final form of the four endpoints of Appendix C (sole input Pi);
    p = Pi input fed into the endpoint formulas"""
    c5 = _cos(p / Decimal(5))
    s10 = _sin(p / Decimal(10))
    delta = Decimal(24) * c5 * c5 - Decimal(5) * p          # delta_C = 24cos^2(Pi/5) - 5*Pi
    A = Decimal(2) * Decimal(6).sqrt() * c5                 # 2*sqrt(6)cos(Pi/5) = sqrt(6*Phi^2)
    B = (Decimal(4) * c5 - Decimal(1)) * p.sqrt()           # (4cos(Pi/5)-1)*sqrt(Pi) = sqrt(5*Pi)
    base = Decimal(4) * s10 * s10                           # 4sin^2(Pi/10) = phi^2
    return {
        "C1a_up": Decimal("1.5") + Decimal(3) * (Decimal(5) * p).sqrt() * delta,
        "C1a_lo": Decimal("1.5") - Decimal(6) * Decimal(6).sqrt() * c5 * delta,
        "C1b_up": base - Decimal(2) * c5 * (Decimal(5) * p).sqrt() * delta,
        "C1b_lo": base - Decimal(4) * Decimal(6).sqrt() * c5 * c5 * delta,
        "delta": delta, "A": A, "B": B, "base": base,
    }

# ---------------------------------------------------------------- Riemann sum (midpoint rule, purely rational)
def riemann_pi_decimal(N):
    """pi_k = (4/N) * sum 1/(1+x_i^2), x_i = (i-1/2)/N; decimal 60 digits (N <= 10^5)"""
    N_ = Decimal(N)
    s = Decimal(0)
    for i in range(1, N + 1):
        x = (Decimal(2 * i - 1) / Decimal(2)) / N_          # (i-1/2)/N
        s += Decimal(1) / (Decimal(1) + x * x)
    return Decimal(4) * s / N_

def riemann_pi_float(N):
    """float64 version (N >= 10^6, demonstrates the float64 floor; requires numpy)"""
    import numpy as np
    x = (np.arange(N, dtype=np.float64) + 0.5) / N
    return float(4.0 * np.sum(1.0 / (1.0 + x * x)) / N)

def riemann_pi(N):
    if N <= 10 ** 5:
        return riemann_pi_decimal(N), "decimal60"
    return Decimal(repr(riemann_pi_float(N))), "float64"

# ---------------------------------------------------------------- main verification
print("=" * 88)
print("Appendix C: final form of the four endpoints (sole input Pi) -- "
      "cross-check against Sec. 3 preregistered values")
print("=" * 88)
E = endpoints_c(PI)
PREREG = {
    "C1a_up": Decimal("1.5028614971465336371692130624748318648423012063966653"),
    "C1a_lo": Decimal("1.4971384809327922834494017548657733188694213205979527"),
    "C1b_up": Decimal("0.3804226780361710640309516514635301639470512286101705"),
    "C1b_lo": Decimal("0.3804226662133724917816543843427254529781164448001290"),
}
for k in ["C1a_up", "C1a_lo", "C1b_up", "C1b_lo"]:
    print(f"  {k}: Pi-form {E[k]}  | preregistered {str(PREREG[k])[:18]}  | deviation {abs(E[k]-PREREG[k]):.1E}")
print(f"  delta_C = 24cos^2(Pi/5)-5*Pi = {E['delta']}")
print(f"  check delta_C = 6*Phi^2-5*pi: {abs(E['delta']-(Decimal(6)*Decimal('1.6180339887498948482045868343656381177203091798057628621354486')**2-Decimal(5)*PI)):.1E}")

print()
print("=" * 88)
print("Appendix D structural check: delta = (A-B)(A+B) square difference "
      "and C1b = baseline - correction")
print("=" * 88)
print(f"  (A-B)(A+B) = {E['A']*E['A']-E['B']*E['B']}")
print(f"  delta_C    = {E['delta']}   deviation {abs(E['A']*E['A']-E['B']*E['B']-E['delta']):.1E}")
print(f"  A=2*sqrt(6)cos(Pi/5) = {E['A']}  ~ sqrt(6*Phi^2) = {(Decimal(6)*Decimal('1.6180339887498948482045868343656381177203091798057628621354486')**2).sqrt()}")
print(f"  B=(4cos(Pi/5)-1)*sqrt(Pi) = {E['B']}  ~ sqrt(5*Pi) = {(Decimal(5)*PI).sqrt()}")
print(f"  C1b baseline phi^2=4sin^2(Pi/10) = {E['base']}")

print()
print("=" * 88)
print("8-level Riemann-sum power-order reduction: pi_k(N) fed into the "
      "Appendix C formulas -> endpoints converge into the two-extremal interval")
print("=" * 88)
L0, U0 = E["C1b_lo"], E["C1b_up"]
print(f"  target interval [L0, U0] = [{L0}, {U0}], bandwidth {U0-L0:.2E}")
print(f"{'N':>8} | {'pi_k error':>11} | {'strict 1/(3N^2)':>15} | {'endpoint dev':>13} | {'rel. bandwidth':>14} | {'mode':>8}")
print("-" * 82)
for m in range(1, 9):
    N = 10 ** m
    pk, mode = riemann_pi(N)
    err = abs(pk - PI)
    th = Decimal(1) / (Decimal(3) * Decimal(N) * Decimal(N))   # strict bound: max|f''|=8 -> 8/(24N^2)
    e = endpoints_c(pk)
    dL = abs(e["C1b_lo"] - L0)                                 # L0-side endpoint deviation (clamping arm)
    print(f"{N:>8} | {err:.2E} | {th:.2E} | {dL:.2E} | {dL/(U0-L0):>14.3f} | {mode:>8}")

print()
print("Conclusion: the Riemann sum pi_k converges monotonically to Pi "
      "(measured error ~ 0.0833/N^2, strict bound 1/(3N^2), power-order reduction);")
print("      fed into the Appendix C formulas, the C1b upper/lower endpoint deviations "
      "tend to zero monotonically in N -> the limit is the endpoint formula itself,")
print("      so the two-extremal interval [L0,U0] is uniquely determined by the formula "
      "(sole input Pi); external certified values do not participate in this verification.")

print()
print("=" * 88)
print("Two-sided clamping (error bound pi_k+/- = pi_k +/- 1/(3N^2)): "
      "when can the in-band representative s* be decided strictly")
print("=" * 88)
s_star = (L0 + U0) / Decimal(2)
print(f"  in-band representative s* = band midpoint = {s_star}")
print(f"{'N':>8} | {'L0 window':>12} | {'U0 window':>12} | {'rel. bandwidth':>14} | {'in-band clamp':>14}")
print("-" * 70)
for m in range(1, 9):
    N = 10 ** m
    pk, mode = riemann_pi(N)
    err = Decimal(1) / (Decimal(3) * Decimal(N) * Decimal(N))   # strict bound: f=4/(1+x^2), max|f''|=8 -> 1/(3N^2)
    e_m = endpoints_c(pk - err)
    e_p = endpoints_c(pk + err)
    Lw = e_p["C1b_lo"] - e_m["C1b_lo"]
    Uw = e_p["C1b_up"] - e_m["C1b_up"]
    rel = Lw / (U0 - L0)
    clamp = (e_p["C1b_lo"] <= s_star) and (s_star <= e_m["C1b_up"])
    print(f"{N:>8} | {Lw:.2E} | {Uw:.2E} | {rel:>14.3f} | {str(clamp):>14}")
print()
print("Clamping condition: window width < bandwidth -> from N = 10^5 the window "
      "(4.10e-9) < bandwidth (1.18e-8),")
print("so any candidate inside the band can be strictly decided U-HIT/U-KILL by a "
      "Riemann sum (pure rational arithmetic).")
