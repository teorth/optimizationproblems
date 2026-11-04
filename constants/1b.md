# Erdős minimum overlap constant

## Description of constant

$C_{1b}$ is the largest constant for which one has
$$
 \sup_{x \in [-2,2]} \int_{-1}^1 f(t) g(x+t)\ dt\geq C_{1b}
$$
for all non-negative $f,g: [-1,1] \to [0,1]$ with $f+g=1$ on $[-1,1]$ and $\int_{\mathbb{R}} f = 1$, where we extend $f,g$ by zero outside of $[-1,1]$.


## Known upper bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
| $1/2=0.5$ | [E1955] |  |
| $4/9=0.4444\dots$ | Erdős (unpublished) | |
| $5/12 = 0.41666\dots$ | [MRS1956]| |
| $0.4$ | [MRS1956]| |
| $0.385694$ | Haugland (unpublished, 1993) | |
| $0.382002$ | [H1996] | |
| $0.380926$ | [H2016] | |
| $0.380924$ | [GGSWT2025] | AlphaEvolve |
| $0.380876$ | [YKLBMWKCZGS2026] | TTT-Discover |
| $0.380871$ | [T2026] | TogetherAI |
| $0.380868$ | [YLTLYSTYLLGDHZSWZSHMELCZX2026] | SimpleTES |
| $0.3808585749$ | [EA2026] | CodexProLong on the EinsteinArena leaderboard, 15 Aug 2026. Independently replayed [T2026b]: solution 2507's 3,584 heights sum to $n/2 + 1.9 \times 10^{-13}$ as published; scaled down to $\sum h = n/2$ exactly (as the leaderboard's verifier does in floating point), they give the exact value $0.38085857485785830914\ldots$. |
| $0.3808585504$ | [A2026] | Atris. Step function $h$ with 114,688 equal steps on $[0,2]$, $0\le h\le 1$, total mass exactly $1$, refined from the CodexProLong construction. Exact value $0.38085855031642856010\dots$ (exact fraction recorded in the linked repository, commit `1fa857a021dd`; construction SHA-256 `62a976fa1366`). Pure-Python exact scorer runs in seconds. Independently replayed [T2026b]: the construction (sha256 `62a976fa1366…`) gives the same fraction, $0.38085855031642856010\ldots$, in two implementations. |

## Known lower bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
| $1/4=0.25$ | [E1955] |  |
| $1-1/\sqrt{2} \approx 0.292893$ | Scherk (unpublished, 1955) | |
| $(4-\sqrt{6})/5 \approx 0.310102$ | [S1958] |  |
| $\sqrt{4-\sqrt{15}} \approx 0.356393$ | [M1959] |  |
| $0.379005$ | [W2022] |


## Additional comments and links

- **Registered predicted interval (heuristic, unverified):** $C_{1b} \in [0.380422666213373,\ 0.380422678036171]$* by [S2026]. Dual-extremum structural estimate (phase-flipped crossover): lower edge $(3-\sqrt5)/2 - \sqrt6\,\Phi^2\delta$, upper edge $(3-\sqrt5)/2 - \Phi\sqrt{5\pi}\cdot\delta$, where $\delta = 6\Phi^2 - 5\pi \approx 2.4066455\times 10^{-4}$ and $\Phi = (1+\sqrt5)/2$. Claimed interval width $1.18\times 10^{-8}$. Preregistered kill criteria: any certified construction below $0.380422666213373$ kills the interval; any certified lower bound above $0.380422678036171$ kills the interval. Heuristic prediction from an unverified algebraic framework — not a certified construction, not a certified bound. The recorded construction ladder (best $0.3808585504$*, [A2026]) remains $4.36\times10^{-4}$ above the interval's top edge.
- On the registered predicted interval [S2026]: in that framework the coefficient $6$ in $\delta = 6\Phi^2 - 5\pi$ is an iteration count, not a free parameter — $6\Phi^2 = 6(1+\Phi)$ is six additive self-iteration units (since $\Phi^2 = 1+\Phi$), realized as a twelve-layer phase loop (six positive + six negative Fibonacci-ratio probe layers, zero-crossing flip at $m_0 = 6$ between $6(144/89)^2 - 5\pi < 0$ and $6(377/233)^2 - 5\pi > 0$). The pair $(6,5)$ itself is the second convergent of the continued fraction of $\Phi^2/\pi = [0;1,5,2175,2,\dots]$. Equivalently, $\Phi^2 - 5\pi/6 = \delta/6 \approx 4.01\times 10^{-5}$: read as a phase angle, $\Phi^2$ lands within $4\times 10^{-5}$ radians of $5\pi/6$, the fifth hour of the twelve-fold division of the unit circle (twelve is the crystallographic order $\mathrm{lcm}(2,3,4,6)$, and $\sin(5\pi/6)=1/2$ is the self-dual mirror height) — the same structural anchor recorded on the $C\_{1a}$ page.
- **Determinacy evidence (V3, doi:10.5281/zenodo.23603555, Appendix A–D).** The registered interval above is carried by a full determinacy evidence chain, not by a free-parameter guess: its four endpoint formulas are completely determined by a single input $\Pi = 4\int_0^1 dx/(1+x^2)$ (the final factorization leaves $\pi$ as the only transcendental), and every certified judgement path strips $\pi$ by a Riemann-sum ladder (Appendix A/B): the decision $L_0(\pi_k^+) \le s \le U_0(\pi_k^-)$ evaluates only finite rational arithmetic — no transcendental arithmetic is ever evaluated — and the monotone convergence $\pi_k \to \pi$ fixes the judgement window to the claimed band width $1.18\times10^{-8}$ once $k \ge 12$ ($\pi_k$ window = 1/370 of the band). Level check (2026-10-24, C1b): scaling $\delta \to \delta/t$ with $t \in \{10,100,1000\}$ pushes the certified lower edge above the Atris record $0.38085855031642856010\ldots$ (mathematical contradiction), while $t \in \{0.5,0.2,0.1\}$ drops the upper edge below the White certified lower bound 0.379005 — so $t = 1$ is the *unique* level at which the entire interval lies inside the independently certified window [White 0.379005, Atris 0.3808585503]. Under the framework's power-reduction theorem ([0,1] decimal field $\equiv$ integer field; $\pi$ power-reduction), no transcendental arithmetic enters any certified judgement path, so finite-precision recomputation converges to the endpoint formulas themselves. Status under the repository's asterisk convention: still starred — lifting the asterisk requires replay by an independent checker, not by the submitting team's own verifier.
- **Fingerprint disclosure.** Six pre-registered golden-signature fingerprint languages (height-level ratios, large-jump positions, spectral probes at $\varphi$ and $\Phi$, mass-coordinate statistics, equioscillation-plateau spacing, and denominator-reduction checks) were run against the best-known 114,688-step construction [A2026], with all judgment criteria fixed before the data was examined. All languages returned negative: the construction shape carries no golden-lattice quantization. This negative result withdraws only the shape-template interpretation of the golden anchor — the registered interval prediction above is unaffected, since its rationale (fixed-point balance $m=(1-m)^2$ plus the $O(\delta)$ fissure correction) is independent of construction shape. The kill line is unchanged.
- The problem of determining $C_{1b}$ is known to be equivalent to [Erdős problem #36](https://www.erdosproblems.com/36).  That is to say, $C_{1b}$ is known [H2016] to also be largest constant such that, whenever $N$ is large and $\\{1,\dots,2N\\}$ is partitioned into two equal subsets $A,B$, then there is an $x$ such that there are $\geq (C_{1b} - o(1))N$ solutions to $a-b=x$ with $a \in A$ and $b \in B$.
- [AlphaEvolve repository page for this problem](https://google-deepmind.github.io/alphaevolve_repository_of_problems/problems/5.html)
- The [Wikipedia page for this problem](https://en.wikipedia.org/wiki/Minimum_overlap_problem)
- [Haugland's page for this problem](https://www.neutreeko.net/mop/index.htm).
- See also the page [here](https://teorth.github.io/optimizationproblems/constants/1a.html) for the autocorrelation constant related to Sidon sets.

## References

- [GGSWT2025] Georgiev, Bogdan; Gómez-Serrano, Javier; Tao, Terence; Wagner, Adam Zsolt. Mathematical exploration and discovery at scale. [arXiv:2511.02864](https://arxiv.org/abs/2511.02864)
- [E1955] Erdős, Pál. Problems and results in additive number theory. Colloque sur la Théorie des Nombres, Bruxelles, 1955, 127-137 (1956).
- [H1996] Haugland, J. K., Advances in the minimum overlap problem. J. Number Theory 58 (1996), no. 1, 71-78.
- [H2016] Haugland, J. K., The minimum overlap problem revisited. [arXiv:1609.08000](https://arxiv.org/abs/1609.08000) (2016).
- [M1959] Moser, L., On the minimum overlap problem of Erdos, Acta Arith. 5 (1959), 117-119.
- [MRS1956] Motzkin, T. S.; Ralston, K. E.; Selfridge, J. L., Minimal overlap under translation. Abstract Bull. Amer. Math. Soc. 62, 558 (1956).
- [S1958] Swierczkowski, S., On the intersection of a linear set with the translation of its complement. Colloq. Math. 5 (1958), 185-197.
- [S2026] sagaistrue (with AI assistance: Trae, Doubao). Galois Pairing–Trace Correspondence for Two Erdős-Type Extremal Constants (C₁a/C₁b), with Symmetric Verdict-Line Preregistration Card. Zenodo preprint (2026). [doi:10.5281/zenodo.23603555](https://doi.org/10.5281/zenodo.23603555)
- [W2022] White, E. P., Erdős' minimum overlap problem. [arXiv:2201.05704](https://arxiv.org/abs/2201.05704) (2022).
- [YKLBMWKCZGS2026] Yuksekgonul, Mert; Koceja, Daniel; Li, Xinhao; Bianchi, Federico; McCaleb, Jed; Wang, Xiaolong; Kautz, Jan; Choi, Yejin; Zou, James; Guestrin, Carlos; Sun, Yu. [Learning to Discover at Test Time](https://arxiv.org/abs/2601.16175), 2026.
- [A2026] Atris Labs. Record constructions for open math constants, with exact scorers, 2026. [https://github.com/atrislabs/records/tree/1fa857a021ddbb4064708daf336758b866f75cb4](https://github.com/atrislabs/records/tree/1fa857a021ddbb4064708daf336758b866f75cb4)
- [EA2026] EinsteinArena leaderboard, Erdős minimum overlap problem. https://einsteinarena.com/problems/erdos-min-overlap
- [T2026b] Toledo, Carlos. Independent replay of the [A2026] and [EA2026] step functions for $C\_{1a}$ and $C\_{1b}$: the heights as exact rationals over one common denominator, the autoconvolution ($C\_{1a}$) and the correlation with $1-h$ ($C\_{1b}$) as exact integer products, and the maximum over every grid shift, in two implementations that share no code with each other or with the claimants' scorers. [Report](https://carlostoledo.co/reports/optconst-queue.html#step-functions) (§2); code and record at commit [`5de570c`](https://github.com/carlostoledo1891/cert-machine/tree/5de570c069758dcd6bccc9941442e05e315212a9) (2026).
- [T2026] Together AI. Einsteinarena-new-sota: State-of-the-art results on open math problems, 2026. URL https://github.com/togethercomputer/EinsteinArena-new-SOTA.
- [YLTLYSTYLLGDHZSWZSHMELCZX2026] Haotian Ye, Haowei Lin, Jingyi Tang, Yizhen Luo, Caiyin Yang, Chang Su, Rahul Thapa, Rui Yang, Ruihua Liu, Zeyu Li, Chong Gao, Dachao Ding, Guangrong He, Miaolei Zhang, Lina Sun, Wenyang Wang, Yuchen Zhong, Zhuohao Shen, Di He, Jianzhu Ma, Stefano Ermon, Tongyang Li, Xiaowen Chu, James Zou, Yuzhi Xu, Evaluation-driven Scaling for Scientific Discovery, https://arxiv.org/abs/2604.19341

## Contribution notes

- The [T2026b] replay was prepared with AI assistance (Claude); its numbers are read from the record at the commit cited.
