# Tight alternating knot constant

## Description of constant

$C_{22b} = b_{o}$ is the largest constant for which one has an inequality
$$ L \geq b_{o} C $$
for all knots that admit an [alternating](https://en.wikipedia.org/wiki/Alternating_knot) diagram, where $L$ is the ropelength of a knot (or link) with [crossing number](https://en.wikipedia.org/wiki/Crossing_number_(knot_theory)) $C$.
The _ropelength_ $L$ is the infimum over all embeddings of the knot (or link) of the ratio of the contour length of the knot to its thickness. The _thickness_ is defined as the radius of the smallest circle that passes through any three points on the knot (where collinear points yield an infinite radius). Colloquially, the ropelength is the least amount of rope required to tie a specific knot in a rope of unit radius. See [CKS2002] for the full definition.

## Known upper bounds

Upper bounds are typically found by constructing alternating torus knots or links and minimizing the parameters of their construction.

| Bound | Reference | Comments |
| ----- | --------- | -------- |
|$2\pi+2\approx 8.28$ | Trivial | Hopf chain link of stadium curves
| 8.50| [Olsen2013] | Double helix |
| 7.63| [Huh2018] | Four-strand superhelix |
| $1+\pi\sqrt{4+\frac{1}{\pi^2}}\approx 7.36$| [Klotz2021] | Wrapped circle |
| 7.31|  [Kim2024] | Asymmetric double helix |
| $7.2012719$* | [Claude2026] | Coaxial double helix with unequal radii, optimised under all thickness constraints (including curvature): outer radius $a\_1=1.934060$, inner radius $a\_2=0.075486$, rise $2\pi b$ with $b=0.322721$ per turn, costing $c^\* = 7.2012609899\ldots$ per crossing in the limit. For every odd $n \geq 59$ an explicit $C^{1,1}$ conformation of $T(2,n)$ (two straight double-helical columns joined by two caps, one of which swaps the radii) is shown by interval arithmetic to have thickness at least $1$, giving $L(T(2,n)) \leq 7.2012719\,n + 19.649$; since $C(T(2,n)) = n$, letting $n \to \infty$ gives the bound. Computer-assisted (about 40 seconds on one core); code, parameters and verification log at pinned commit [`debf7c9`](https://github.com/YouhuaLi/tight-alternating-knot-constant/tree/debf7c92f93bae64486e6302e565a2d3b1290f9c). Unverified. |

## Known lower bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
|$\frac{1}{59.5}\approx 0.017$ | [Diao2024] | First proof of positivity

## Additional comments

- There is also a convention where the ropelength is defined relative to a unit-diameter rope, but unit-radius is more common.
- [Claude2026] reports that the conformation used for the 7.31 bound of [Kim2024] violates the curvature constraint (the inner strand has radius of curvature $0.875 < 1$, so the true thickness is $0.8753$ and the ropelength per crossing $8.359$), and that re-optimising that pattern with the curvature constraint included leads, up to scaling, to the helix of [Claude2026].
- Non-alternating knots have a three-quarter power lower bound, discussed in [22a](https://teorth.github.io/optimizationproblems/constants/22a.html).

## References

- [CKS2002] Cantarella, Jason; Kusner, Robert B.; Sullivan, John M. On the minimum ropelength of knots and links. Invent. Math. 150, No. 2, 257-286 (2002).
- [Diao2024] Diao, Yuanan. The ropelength conjecture of alternating knots. Mathematical Proceedings of the Cambridge Philosophical Society. Vol. 177. No. 2. Cambridge University Press, 2024.
- [Olsen2013] Olsen, Kasper W., and Jakob Bohr. A principle for ideal torus knots. Europhysics Letters 103.3 (2013): 30002.
- [Huh2018] Huh, Youngsik, Hyoungjun Kim, and Seungsang Oh. Ropelength of superhelices and (2, n)-torus knots. Journal of Physics A: Mathematical and Theoretical 51.48 (2018): 485203.
- [Klotz2021] Klotz, Alexander R., and Matthew Maldonado. The ropelength of complex knots. Journal of Physics A: Mathematical and Theoretical 54.44 (2021): 445201.
- [Kim2024] Kim, Hyoungjun, Seungsang Oh, and Youngsik Huh. Efficiency of non-identical double helix patterns in minimizing ropelength of torus knots. Physica Scripta 99.7 (2024): 075240.
- [Claude2026] Claude Opus 5.5. The ropelength of $(2,n)$-torus knots is at most $7.2013\,n+O(1)$: an optimal unequal double helix and a computer-assisted proof. October 2026. [Paper and code](https://github.com/YouhuaLi/tight-alternating-knot-constant/tree/debf7c92f93bae64486e6302e565a2d3b1290f9c).
