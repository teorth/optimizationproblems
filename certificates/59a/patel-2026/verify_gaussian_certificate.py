#!/usr/bin/env python3
"""Exact recurrence certificate for K_2 < 302825279492 / 10^12."""

from decimal import Decimal, getcontext
from hashlib import sha256
from math import isqrt

L = 2_500_000_000
T = 3_067_398_171
S = 10**15
R = 302_825_279_492
E = 10**12
N = 28
MARGIN_POWER = 26

Gaussian = tuple[int, int]


def add(a: Gaussian, b: Gaussian) -> Gaussian:
    return a[0] + b[0], a[1] + b[1]


def neg(a: Gaussian) -> Gaussian:
    return -a[0], -a[1]


def mul(a: Gaussian, b: Gaussian) -> Gaussian:
    return a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0]


def scale(n: int, a: Gaussian) -> Gaussian:
    return n * a[0], n * a[1]


def digest_integer(value: int) -> str:
    return sha256(str(value).encode("ascii")).hexdigest()


def digest_lines(lines: list[str]) -> str:
    return sha256(("\n".join(lines) + "\n").encode("ascii")).hexdigest()


def main() -> None:
    input_numerator = [
        ((S - 1) * L, (S - 1) * T),
        (-L, S * T),
        (L, -(S * T)),
        ((S + 1) * L, -((S + 1) * T)),
    ]
    input_denominator = [
        ((S + 1) * L, (S + 1) * T),
        (L, S * T),
        (-L, -(S * T)),
        ((S - 1) * L, -((S - 1) * T)),
    ]
    conjugate_constant = (
        input_denominator[0][0],
        -input_denominator[0][1],
    )
    numerator = [mul(v, conjugate_constant) for v in input_numerator]
    denominator = [mul(v, conjugate_constant) for v in input_denominator]
    d = (S + 1) ** 2 * (L**2 + T**2)
    assert denominator[0] == (d, 0)
    assert 0 < R < E and 1 < S

    values: list[list[Gaussian]] = [[(0, 0) for _ in range(N + 1)] for _ in range(N + 1)]
    for j in range(N + 1):
        for k in range(N + 1):
            value = (0, 0)
            if j < 2 and k < 2:
                value = scale(d ** (j + k), numerator[j + 2 * k])
            if j:
                value = add(value, neg(mul(denominator[1], values[j - 1][k])))
            if k:
                value = add(value, neg(mul(denominator[2], values[j][k - 1])))
            if j and k:
                value = add(
                    value,
                    neg(scale(d, mul(denominator[3], values[j - 1][k - 1]))),
                )
            values[j][k] = value

    lower_norms = [
        [isqrt(values[j][k][0] ** 2 + values[j][k][1] ** 2) for k in range(N + 1)]
        for j in range(N + 1)
    ]
    for j in range(N + 1):
        for k in range(N + 1):
            squared_norm = values[j][k][0] ** 2 + values[j][k][1] ** 2
            lower = lower_norms[j][k]
            assert lower**2 <= squared_norm < (lower + 1) ** 2

    base = E * d
    a = sum(
        lower_norms[j][k] * R ** (j + k) * base ** (2 * N - j - k)
        for j in range(N + 1)
        for k in range(N + 1)
    )
    b = d * base ** (2 * N)
    margin = 10**MARGIN_POWER
    assert margin * a > (margin + 1) * b
    slack = margin * (a - b) - b
    coefficient_digest = digest_lines(
        [f"{j},{k},{values[j][k][0]},{values[j][k][1]}" for j in range(N + 1) for k in range(N + 1)]
    )
    floor_digest = digest_lines(
        [f"{j},{k},{lower_norms[j][k]}" for j in range(N + 1) for k in range(N + 1)]
    )

    getcontext().prec = 60
    excess = Decimal(a - b) / Decimal(b)
    print(f"D = {d}")
    print(f"coefficients = {(N + 1) ** 2}")
    print(f"r = {R}/{E}")
    print(f"A/B - 1 = {excess}")
    print(f"proved: 10^{MARGIN_POWER} A > (10^{MARGIN_POWER} + 1) B")
    print(f"sha256(A) = {digest_integer(a)}")
    print(f"sha256(B) = {digest_integer(b)}")
    print(f"sha256(A-B) = {digest_integer(a - b)}")
    print(f"sha256(slack) = {digest_integer(slack)}")
    print(f"sha256(coefficients.csv) = {coefficient_digest}")
    print(f"sha256(floors.csv) = {floor_digest}")


if __name__ == "__main__":
    main()
