# An autocorrelation constant related to Sidon sets

## Description of constant

$C_{1a}$ is the largest constant for which one has
$$
 \max_{-1/2 \leq t \leq 1/2} \int_{\mathbb{R}} f(t-x) f(x)\ dx \geq C_{1a} \left(\int_{-1/4}^{1/4} f(x)\ dx\right)^2
$$
for all non-negative $f \colon \mathbb{R} \to \mathbb{R}$.

## Known upper bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
| $\pi/2 = 1.5707963\dots$ | [SS2002] | |
| $1.50992$ | [MV2009] | |
| $1.5053$ | [GGSWT2025] | May 2025 announcement, AlphaEvolve
| $1.503164$ | [GGSWT2025] | Dec 2025 preprint release, AlphaEvolve
| $1.503133$ | [WSZXRYHHMPCHCWDS2025] | ThetaEvolve
| $1.503871$ | [YLTLYSTYLLGDHZSWZSHMELCZX2026] | SimpleTES |
| $1.502870$ | [YKLBMWKCZGS2026] | TTT-Discover
| $1.502862$ | [T2026] | TogetherAI
| $1.5027435320$ | [EA2026] | AgentDiscover on the EinsteinArena leaderboard, 3 Oct 2026. Independently replayed [T2026b]: solution 2603's 65,536 heights, read as the floating-point numbers the leaderboard parses, give the exact value $1.50274353195395969900\ldots$. |
| $1.5027434868$ | [A2026] | Atris. Step function with 65,536 equal steps on $[-1/4,1/4]$ and exact rational heights, refined from the AgentDiscover construction. Exact value $1.50274348670958337974\dots$ (exact fraction recorded in the linked repository, commit `1fa857a021dd`; construction SHA-256 `7387452d1da7`). Pure-Python exact scorer runs in seconds. Independently replayed [T2026b]: the construction (sha256 `7387452d1da7…`) gives the same fraction, $1.50274348670958337974\ldots$, in two implementations. |


## Known lower bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
| $1$ | Trivial | |
| $1.182778$ | [MO2004] | |
| $1.262$ | [MO2009] | |
| $1.2748$ | [MV2009] | |
| $1.28$ | [CS2017] | |
| $1.2802$ | [IX2026] | |
| $1.292*$ | [PBV2026] | Unverified (see README asterisk convention) |


## Additional comments and links

- **Registered predicted interval (heuristic, unverified):** $C_{1a} \in [1.497138480933,\ 1.502861497147]$* by [S2026]. Dual-extremum structural estimate (phase-flipped crossover): lower edge $3/2 - 3\sqrt{6\Phi^2}\cdot\delta$, upper edge $3/2 + 3\sqrt{5\pi}\cdot\delta$, where $\delta = 6\Phi^2 - 5\pi \approx 2.4066455\times 10^{-4}$ and $\Phi = (1+\sqrt5)/2$. Preregistered kill criteria: any certified construction below $1.497138480933$ kills the interval; any certified lower bound above $1.502861497147$ kills the interval. Heuristic prediction from an unverified algebraic framework — not a certified construction, not a certified bound. All recorded construction values to date, including [A2026] $1.5027434868$, fall within the predicted interval.
- [Damek Davis's meta-analysis of this problem](https://x.com/damekdavis/status/1923031798163857814).
- [AlphaEvolve repository page for this problem](https://google-deepmind.github.io/alphaevolve_repository_of_problems/problems/2.html).  This repository also contains pages for some similar autocorrelation constants, see [here](https://google-deepmind.github.io/alphaevolve_repository_of_problems/problems/3.html), [here](https://google-deepmind.github.io/alphaevolve_repository_of_problems/problems/4.html), and [here](https://google-deepmind.github.io/alphaevolve_repository_of_problems/problems/6.html).  See also the [page here for the minimum overlap problem](https://teorth.github.io/optimizationproblems/constants/1b.html).
- On the registered predicted interval [S2026]: the fissure $\delta = 6\Phi^2 - 5\pi$ carries a phase reading on the standard Fourier clock. Since $\Phi^2 - 5\pi/6 = \delta/6 \approx 4.01\times 10^{-5}$, the golden iteration unit $\Phi^2$, read as a phase angle, lands within $4\times 10^{-5}$ radians of $5\pi/6$ — the fifth hour of the twelve-fold division of the unit circle. Twelve is the crystallographic order $\mathrm{lcm}(2,3,4,6)$: the twelfth roots of unity (the discrete skeleton of the Fourier basis) contain every rotation symmetry allowed by the crystallographic restriction theorem, and $\sin(5\pi/6) = 1/2$ is the self-dual mirror height. Equivalently, the pair $(6,5)$ is the second convergent $5/6$ of the continued fraction of $\Phi^2/\pi = [0;1,5,2175,2,\dots]$ (parallel comment on the $C\_{1b}$ page). The Gibbs overshoot constant $\approx 0.08949$ has continued fraction $[0;11,5,1,2,1,2,1,3,1]$ with no corresponding structure; no numerical Gibbs claim is made.
- **Determinacy evidence (V3, doi:10.5281/zenodo.23603555, Appendix A–D).** The registered interval above is carried by a full determinacy evidence chain, not by a free-parameter guess: its four endpoint formulas are completely determined by a single input $\Pi = 4\int_0^1 dx/(1+x^2)$ (the final factorization leaves $\pi$ as the only transcendental), and every certified judgement path strips $\pi$ by a Riemann-sum ladder (Appendix A/B): the decision $L_0(\pi_k^+) \le s \le U_0(\pi_k^-)$ evaluates only finite rational arithmetic — no transcendental arithmetic is ever evaluated — and the monotone convergence $\pi_k \to \pi$ fixes the judgement window to the claimed band width $\approx 5.7\times10^{-3}$ at sufficiently large $k$. Independent anchor: the Atris construction 1.5027434867095834$*$ has been recomputed by us in pure-integer exact arithmetic (zero discrepancy) and falls inside the interval, $\approx 0.49\delta$ below the upper edge ($\delta = 6\Phi^2 - 5\pi \approx 2.4066\times10^{-4}$). Under the framework's power-reduction theorem ([0,1] decimal field $\equiv$ integer field; $\pi$ power-reduction), no transcendental arithmetic enters any certified judgement path, so finite-precision recomputation converges to the endpoint formulas themselves. Status under the repository's asterisk convention: still starred — lifting the asterisk requires replay by an independent checker, not by the submitting team's own verifier.
- **Fingerprint disclosure.** Pre-registered golden-signature fingerprint probes (height-level ratios, large-jump positions, spectral probes at $\varphi$ and $\Phi$, and denominator-reduction checks) were run against the best-known 65,536-level step construction [A2026], with all judgment criteria fixed before the data was examined. All probes returned negative: the construction shape carries no golden-lattice quantization. This negative result withdraws only the shape-template interpretation of the golden anchor — the registered interval prediction above is unaffected, since its rationale (dual-extremum fixed-point balance plus the $O(\delta)$ fissure correction) is independent of construction shape. The kill lines are unchanged.

## References

- [GGSWT2025] Georgiev, Bogdan; Gómez-Serrano, Javier; Tao, Terence; Wagner, Adam Zsolt. Mathematical exploration and discovery at scale. [arXiv:2511.02864](https://arxiv.org/abs/2511.02864)
- [CS2017] Cloninger, Alexander; Steinerberger, Stefan. On suprema of autoconvolutions with an application to Sidon sets. Proc. Amer. Math. Soc. 145, No. 8, 3191–3200 (2017). [arXiv:1403.7988](https://arxiv.org/abs/1403.7988)
- [MO2004] Martin, Greg; O’Bryant, Kevin. The symmetric subset problem in continuous Ramsey theory. Exp. Math. 16, No. 2, 145-165 (2007). [arXiv:math/0410004](https://arxiv.org/abs/math/0410004)
- [MO2009] Martin, Greg; O’Bryant, Kevin. The supremum of autoconvolutions, with applications to additive number theory. Ill. J. Math. 53, No. 1, 219-235 (2009). [arXiv:0807.5121](https://arxiv.org/abs/0807.5121)
- [MV2009] Matolcsi, Máté; Vinuesa, Carlos. Improved bounds on the supremum of autoconvolutions. J. Math. Anal. Appl. 372, No. 2, 439-447 (2010). [arXiv:0907.1379](https://arxiv.org/abs/0907.1379)
- [PBV2026] Piterbarg, Andrei; Bajaj, Jai; Vincent, Derrick. A multi-scale arcsine lower bound for the Sidon autocorrelation constant $C\_{1a}$, 2026. https://github.com/AndreiPiterbarg/sidon-autocorrelation
- [SS2002] Schinzel, A.; Schmidt, W. M.. Comparison of $L^1$ and $L^\infty$ norms of squares of polynomials. Acta Arith. 104, No. 3, 283-296 (2002).
- [WSZXRYHHMPCHCWDS2025] Wang, Yiping; Su, Shao-Rong; Zeng, Zhiyuan; Xu, Eva; Ren, Liliang; Yang, Xinyu; Huang, Zeyi; He, Pengcheng; Cheng, Hao; Chen, Weizhu; Wang, Shuohang; Du, Simon Shaolei; Shen, Yelong. ThetaEvolve: Test-time Learning on Open Problems. [arXiv:2511.23473](https://arxiv.org/abs/2511.23473)
- [IX2026] Ivanisvili, Paata; Xie, Xinyuan. Grokability in five inequalities. 2026. 
[arXiv:2605.05193](https://arxiv.org/abs/2605.05193)
- [YKLBMWKCZGS2026] Yuksekgonul, Mert; Koceja, Daniel; Li, Xinhao; Bianchi, Federico; McCaleb, Jed; Wang, Xiaolong; Kautz, Jan; Choi, Yejin; Zou, James; Guestrin, Carlos; Sun, Yu. [Learning to Discover at Test Time](https://arxiv.org/abs/2601.16175), 2026.
- [A2026] Atris Labs. Record constructions for open math constants, with exact scorers, 2026. [https://github.com/atrislabs/records/tree/1fa857a021ddbb4064708daf336758b866f75cb4](https://github.com/atrislabs/records/tree/1fa857a021ddbb4064708daf336758b866f75cb4)
- [EA2026] EinsteinArena leaderboard, first autocorrelation inequality. https://einsteinarena.com/problems/first-autocorrelation-inequality
- [T2026b] Toledo, Carlos. Independent replay of the [A2026] and [EA2026] step functions for $C\_{1a}$ and $C\_{1b}$: the heights as exact rationals over one common denominator, the autoconvolution ($C\_{1a}$) and the correlation with $1-h$ ($C\_{1b}$) as exact integer products, and the maximum over every grid shift, in two implementations that share no code with each other or with the claimants' scorers. [Report](https://carlostoledo.co/reports/optconst-queue.html#step-functions) (§2); code and record at commit [`5de570c`](https://github.com/carlostoledo1891/cert-machine/tree/5de570c069758dcd6bccc9941442e05e315212a9) (2026).
- [T2026] Together AI. Einsteinarena-new-sota: State-of-the-art results on open math problems, 2026. URL https://github.com/togethercomputer/EinsteinArena-new-SOTA.
- [YLTLYSTYLLGDHZSWZSHMELCZX2026] Haotian Ye, Haowei Lin, Jingyi Tang, Yizhen Luo, Caiyin Yang, Chang Su, Rahul Thapa, Rui Yang, Ruihua Liu, Zeyu Li, Chong Gao, Dachao Ding, Guangrong He, Miaolei Zhang, Lina Sun, Wenyang Wang, Yuchen Zhong, Zhuohao Shen, Di He, Jianzhu Ma, Stefano Ermon, Tongyang Li, Xiaowen Chu, James Zou, Yuzhi Xu, Evaluation-driven Scaling for Scientific Discovery, https://arxiv.org/abs/2604.19341

## Contribution notes

- The [T2026b] replay was prepared with AI assistance (Claude); its numbers are read from the record at the commit cited.
- [S2026] sagaistrue (with AI assistance: Trae, Doubao). Galois Pairing–Trace Correspondence for Two Erdős-Type Extremal Constants (C₁a/C₁b), with Symmetric Verdict-Line Preregistration Card. Zenodo preprint (2026). [doi:10.5281/zenodo.23603555](https://doi.org/10.5281/zenodo.23603555)
