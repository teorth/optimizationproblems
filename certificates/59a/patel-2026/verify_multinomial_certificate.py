#!/usr/bin/env python3
"""Independent multinomial certificate for K_2 < 302825279492 / 10^12."""

from decimal import Decimal, getcontext
from hashlib import sha256
from math import comb, isqrt

L = 2_500_000_000
T = 3_067_398_171
S = 10**15
R = 302_825_279_492
E = 10**12
N = 28

Gaussian = tuple[int, int]


def gadd(x: Gaussian, y: Gaussian) -> Gaussian:
    return x[0] + y[0], x[1] + y[1]


def gmul(x: Gaussian, y: Gaussian) -> Gaussian:
    return x[0] * y[0] - x[1] * y[1], x[0] * y[1] + x[1] * y[0]


def gscale(n: int, x: Gaussian) -> Gaussian:
    return n * x[0], n * x[1]


def gpow(x: Gaussian, n: int) -> Gaussian:
    result = (1, 0)
    base = x
    while n:
        if n & 1:
            result = gmul(result, base)
        base = gmul(base, base)
        n //= 2
    return result


def digest_integer(value: int) -> str:
    return sha256(str(value).encode("ascii")).hexdigest()


def digest_lines(lines: list[str]) -> str:
    return sha256(("\n".join(lines) + "\n").encode("ascii")).hexdigest()


def main() -> None:
    raw_p = [
        ((S - 1) * L, (S - 1) * T),
        (-L, S * T),
        (L, -S * T),
        ((S + 1) * L, -(S + 1) * T),
    ]
    raw_q = [
        ((S + 1) * L, (S + 1) * T),
        (L, S * T),
        (-L, -S * T),
        ((S - 1) * L, -(S - 1) * T),
    ]
    conjugate = raw_q[0][0], -raw_q[0][1]
    p = [gmul(x, conjugate) for x in raw_p]
    q = [gmul(x, conjugate) for x in raw_q]
    d = (S + 1) ** 2 * (L**2 + T**2)
    assert q[0] == (d, 0)
    q10, q01, q11 = q[1], q[2], q[3]

    inverse_scaled: dict[tuple[int, int], Gaussian] = {}
    for j in range(N + 1):
        for k in range(N + 1):
            total = (0, 0)
            for m in range(min(j, k) + 1):
                multinomial = comb(j + k - m, m) * comb(j + k - 2 * m, j - m)
                scalar = (-1) ** (j + k - m) * multinomial * d**m
                term = gmul(gpow(q10, j - m), gpow(q01, k - m))
                term = gmul(term, gpow(q11, m))
                total = gadd(total, gscale(scalar, term))
            inverse_scaled[j, k] = total

    def w(j: int, k: int) -> Gaussian:
        return inverse_scaled.get((j, k), (0, 0))

    coefficients: list[list[Gaussian]] = [[(0, 0) for _ in range(N + 1)] for _ in range(N + 1)]
    for j in range(N + 1):
        for k in range(N + 1):
            value = gmul(p[0], w(j, k))
            value = gadd(value, gscale(d, gmul(p[1], w(j - 1, k))))
            value = gadd(value, gscale(d, gmul(p[2], w(j, k - 1))))
            value = gadd(value, gscale(d**2, gmul(p[3], w(j - 1, k - 1))))
            coefficients[j][k] = value

    lower = [
        [isqrt(coefficients[j][k][0] ** 2 + coefficients[j][k][1] ** 2) for k in range(N + 1)]
        for j in range(N + 1)
    ]
    base = E * d
    a = sum(
        lower[j][k] * R ** (j + k) * base ** (2 * N - j - k)
        for j in range(N + 1)
        for k in range(N + 1)
    )
    b = d * base ** (2 * N)
    assert 10**26 * a > (10**26 + 1) * b
    slack = 10**26 * (a - b) - b
    coefficient_digest = digest_lines(
        [
            f"{j},{k},{coefficients[j][k][0]},{coefficients[j][k][1]}"
            for j in range(N + 1)
            for k in range(N + 1)
        ]
    )
    floor_digest = digest_lines(
        [f"{j},{k},{lower[j][k]}" for j in range(N + 1) for k in range(N + 1)]
    )

    getcontext().prec = 60
    print(f"D = {d}")
    print(f"coefficients = {(N + 1) ** 2}")
    print(f"r = {R}/{E}")
    print(f"A/B - 1 = {Decimal(a - b) / Decimal(b)}")
    print("proved independently by multinomial coefficient extraction")
    print(f"sha256(A) = {digest_integer(a)}")
    print(f"sha256(B) = {digest_integer(b)}")
    print(f"sha256(A-B) = {digest_integer(a - b)}")
    print(f"sha256(slack) = {digest_integer(slack)}")
    print(f"sha256(coefficients.csv) = {coefficient_digest}")
    print(f"sha256(floors.csv) = {floor_digest}")


if __name__ == "__main__":
    main()
