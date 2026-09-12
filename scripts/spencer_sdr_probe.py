#!/usr/bin/env python3
"""SDP probe for Spencer discrepancy C_10c (issue #67)."""
from __future__ import annotations

import argparse
import math


def hadamard_analytic_lower_bound() -> float:
    return 0.5


def try_sdp(n: int, kind: str) -> float | None:
    try:
        import numpy as np
        import cvxpy as cp
    except ImportError:
        return None

    rng = np.random.default_rng(0)
    if kind == "hadamard":
        if n & (n - 1) != 0:
            raise ValueError("Hadamard probe needs n a power of 2")
        H = np.array([[1.0]])
        while H.shape[0] < n:
            H = np.block([[H, H], [H, -H]])
        A = H
    else:
        A = rng.choice([-1.0, 1.0], size=(n, n))

    X = cp.Variable((n, n), PSD=True)
    t = cp.Variable()
    constraints = [cp.diag(X) == 1]
    AXA = A @ X @ A.T
    for i in range(n):
        constraints.append(AXA[i, i] <= t)
    prob = cp.Problem(cp.Minimize(t), constraints)
    prob.solve(solver=cp.SCS, verbose=False)
    if t.value is None:
        return None
    return float(t.value) / math.sqrt(n)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=32)
    ap.add_argument("--kind", choices=["hadamard", "bernoulli"], default="hadamard")
    args = ap.parse_args()
    print("analytic_hadamard_lower_bound", hadamard_analytic_lower_bound())
    val = try_sdp(args.n, args.kind)
    if val is None:
        print("sdp_skipped (install cvxpy+scs to run the relaxation)")
    else:
        print(f"sdp_{args.kind}_n{args.n}", val)


if __name__ == "__main__":
    main()
