# Certified upper bound for the bidisc Bohr radius

This directory is the reproducibility package for Shivam Patel's bound

$$
K_2 < \frac{302825279492}{10^{12}} = 0.302825279492.
$$

It proves an upper bound only. It does not determine the exact value of
$K_2$.

## Analytic certificate

Set

$$
L=2500000000,\qquad T=3067398171,\qquad S=10^{15},
$$

and define

$$
\begin{aligned}
U(z,w)&=(1+z)(1-w), & V(z,w)&=1+zw,\\
P(z,w)&=LU(z,w)+iTV(z,w), & Q(z,w)&=LV(z,w)+iTU(z,w),\\
f(z,w)&=\frac{SQ(z,w)-P(z,w)}{SQ(z,w)+P(z,w)}.
\end{aligned}
$$

Direct expansion gives, for all complex $z,w$,

$$
\begin{aligned}
&\lvert SQ+P\rvert^2-\lvert SQ-P\rvert^2\\
&\quad=2S(L^2+T^2)
\left((1-\lvert w\rvert^2)\lvert1+z\rvert^2
+(1-\lvert z\rvert^2)\lvert1-w\rvert^2\right).
\end{aligned}
$$

The right-hand side is strictly positive on the open bidisc. Consequently
$SQ+P$ has no zero there, $f$ is holomorphic there, and $\lvert f\rvert<1$.

## Finite coefficient certificate

Multiply the numerator and denominator of $f$ by the Gaussian-integer
conjugate of the denominator's constant coefficient. The new denominator has
constant coefficient

$$
D=(S+1)^2(L^2+T^2)
=15658931539454176558863078908306140931539454145241.
$$

Write the resulting numerator and denominator as
$p=\sum p_{jk}z^jw^k$ and
$q=D+q_{10}z+q_{01}w+q_{11}zw$. The Taylor coefficients of $f=p/q$ are
$c_{jk}=v_{jk}/D^{j+k+1}$, where coefficients with negative indices vanish
and

$$
v_{jk}=p_{jk}D^{j+k}-q_{10}v_{j-1,k}-q_{01}v_{j,k-1}
-Dq_{11}v_{j-1,k-1}.
$$

For $0\le j,k\le28$, let

$$
n_{jk}=\left\lfloor
\sqrt{(\operatorname{Re}v_{jk})^2+(\operatorname{Im}v_{jk})^2}
\right\rfloor.
$$

With $R=302825279492$, $E=10^{12}$, and $N=28$, exact integer arithmetic
checks

$$
A=\sum_{j,k=0}^{N}n_{jk}R^{j+k}(ED)^{2N-j-k},
\qquad B=D(ED)^{2N},
$$

and

$$
10^{26}A>(10^{26}+1)B.
$$

Thus

$$
\sum_{j,k=0}^{28}\lvert c_{jk}\rvert(R/E)^{j+k}
\ge \frac AB>1+10^{-26}.
$$

The left side is a continuous polynomial in the radius. It is therefore
greater than one at some smaller positive radius. Radial monotonicity then
excludes every larger radius from the admissible set, so its supremum is
strictly below $R/E$.

## Verification

The two Python programs use independent coefficient algorithms. The first
uses the triangular recurrence above; the second extracts coefficients of
$1/q$ by a multinomial formula. They require Python 3.9 or later and only its
standard library.

```text
python verify_gaussian_certificate.py
python verify_multinomial_certificate.py
```

Both programs produce the same frozen certificate digests:

```text
sha256(A)                = f048ac2e8f00f62a2d3958a55f985b2271d9cc8e688cd0869f4df44e0b3f3c67
sha256(B)                = 4bb5937ea8c3cfa784ec421a546a25d979bc67b8689854da1e2227c3b5c69e31
sha256(A-B)              = 41125e30d4d1f11a7351daeb219a4e2f1ff85bd7e3d15382f76b67da2aee28b8
sha256(strict slack)     = 0f0d7efd492c6b1ce53b3ce35a76de04dbfce9901bcb34ed38a8fe133ed2116e
sha256(841 coefficients)= 3951d7ad8a9ce423db03a9ff0a036dac2b636c4e1b32551361b10de13559ca4c
sha256(841 norm floors) = cef41ae7e5e6d82a2aa3f8e699e6fc415af0325596c52f9182579cfa8940de62
```

`FiniteCertificate.lean` verifies the 841 Gaussian-integer recurrences, every
integer-square-root floor, the homogenized weighted sum, and the strict
integer margin. `EndToEnd.lean` then proves the global norm-square identity,
denominator nonvanishing, joint analyticity and the Schur bound; constructs
the actual locally convergent Taylor family; identifies its checked
$29\times29$ rectangle with the finite certificate; proves the finite Bohr
majorant is greater than one; and applies continuity and the supremal
definition of the bidisc Bohr radius.

The final formal statement is

```text
Optim.BohrRadius.bohrRadius_lt_302825279492_div_10pow12 :
  bohrRadius < (302825279492 : ℝ) / 10 ^ 12
```

From this directory, run:

```text
lake exe cache get
lake build
```

The Lean project pins Lean 4.19.0 and Mathlib commit
`c44e0c8ee63ca166450922a373c7409c5d26b00b`. Both files compile without
`sorry`, `admit`, or custom axioms. `#print axioms` reports
`propext`, `Classical.choice`, `Lean.ofReduceBool`, and `Quot.sound` for the
final theorem; `Lean.ofReduceBool` is the explicit trust boundary introduced
by the finite `native_decide` checks.

## AI assistance disclosure

The mathematical construction, proof presentation, verification programs,
Lean certificate, and repository submission were prepared with AI assistance.
Shivam Patel supplied the contribution and reviewed the mathematical claim,
references, and submitted information.
