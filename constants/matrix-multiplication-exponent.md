# Matrix multiplication exponent

## Description of constant

$C$, usually denoted by $\omega$, can be defined in terms of ranks of certain tensors or multilinear maps.

Let $U$, $V$, $W$ be vector spaces over a field $k$.
The tensor rank $R(\varphi)$ of a bilinear map $\varphi \colon U \times V \to W$ is the minimal number of summands in the decomposition of the form
$$
\varphi(x, y) = \sum_{k = 1}^r f_k(x) g_k(y) w_k
$$
where $f_1, \dots, f_r \in U^{*}$, $g_1, \dots, g_r \in V^*$, and $w_1, \dots, w_r \in W$.
Equivalently, this is the minimal number of summands in the decomposition of the structure tensor of $\varphi$ in $U^* \otimes V^* \otimes W$ into elementary tensors.

The matrix multiplication exponent is defined as
$$
C = \lim_{n \to \infty} R(MM_n)
$$
where $MM_n$ denotes $n \times n$ matrix multiplication over $\mathbb{C}$.

## Known upper bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
| 3     | Trivial   | |
| $\log_2 7 \approx 2.8074$ | [Str69] | |
| $\log_{70} 143640 \approx 2.7952$ | [Pan78] | |
| $3 \log_{12} 10 \approx 2.7799$ | [BCRL79, Bin80] | |
| $3 \log_{436} 196 \approx 2.6054$ | [Pan79] | |
| $\log_{48} 47216 \approx 2.7802$ | [Pan80] | |
| $3 \log_{110} 52 \approx 2.5219$ | [Sch81] | |
| $\log_{110} 140600 \approx 2.5218006$ | [Sch81] | |
| $2.5161$ | [Pan81] | |
| $2.5166$ | [Rom82] | |
| $2.495548$ | [CW82] | |
| $2.4785$ | [Str87] | |
| $2.375477$ | [CW90] | |
| $2.41$ | [CKSU05] | |
| $2.373689703$ | [Sto10, DS13] | |
| $2.372873$ | [VW12, VW14] | |
| $2.373$ | [Zhd12] | |
| $2.3728639$ | [LG14] | |
| $2.3728596$ | [AW21, AW24] | |
| $2.371866$ | [DWZ23] | |
| $2.371552$ | [WXXZ24] | |
| $2.371339$ | [ADWXXZ25] | |

Results should be arranged in chronological order, and can include bounds that are inferior to the previous bounds.

## Known lower bounds

| Bound | Reference | Comments |
| ----- | --------- | -------- |
| 2     | Trivial   | |

## Additional comments

- Originally defined in the context of theoretical computer science as the minimal number $w$ such that $n \times n$ matrix multiplication can be performed using $O(n^{w + \varepsilon})$ arithmetic operations for every $\varepsilon > 0$.
- The field $\mathbb{C}$ can be replaced by any other field of characterstic $0$. It is known that tensor rank can depend on the base field, but the asymptotic constant $C$ can only depend on the characteristic of the field [Sch81]. All known bounds are valid in every characteristic.

## References

- [Str69] V. Strassen. Gaussian elimination is not optimal. *Numer. Math.* 13:354–356 (1969).
- [Pan78] V. Y. Pan. Strassen's algorithm is not optimal: Trilinear technique of aggregating, uniting and canceling for constructing fast algorithms for matrix operations. In *19th Annual Symposium on Foundations of Computer Science*, 166–176 (1978).
- [Pan79] V. Y. Pan. Field extension and trilinear aggregating, uniting and canceling for the acceleration of matrix multiplication. In *20th Annual Symposium on Foundations of Computer Science*, 28–38 (1979).
- [BCRL79] D. Bini, M. Capovani, F. Romani, and G. Lotti. $O(n^{2.7799})$ complexity for $n \times n$ approximate matrix multiplication. *Inf. Proc. Lett.* 8:234–235 (1979).
- [Bin80] D. Bini. Relations between exact and approximate bilinear algorithms. Applications. *Calcolo* 17:87–97 (1980).
- [Pan80] V. Y. Pan. New fast algorithms for matrix operations. *SIAM J. Comput.* 9:321–342 (1980).
- [Sch81] A. Schönhage. Partial and total matrix multiplication. *SIAM J. Comput.* 10:434–455 (1981).
- [Pan81] V. Y. Pan. New combinations of methods for the acceleration of matrix multiplication. *Computers Math. Appl.* 7:73–125 (1981).
- [Rom82] F. Romani. Some properties of disjoint sums of tensors related to matrix multiplication. *SIAM J. Comput.* 11:263–267 (1982).
- [CW82] D. Coppersmith and S. Winograd. On the asymptotic complexity of matrix multiplication. *SIAM J. Comput.* 11:472–492 (1982).
- [Str87] V. Strassen. Relative bilinear complexity and matrix multiplication. *J. reine angew. Math.* 375/376:406–443 (1987).
- [CW90] D. Coppersmith and S. Winograd. Matrix multiplication via arithmetic progressions. *J. Symb. Comput.* 9:251–280 (1990).
- [CKSU05] H. Cohn, R. Kleinberg, B. Szegedy, and C. Umans. Group-theoretic algorithms for matrix multiplication. In *46th Annual Symposium on Foundations of Computer Science*, 379–388 (2005).
- [Sto10] A. J. Stothers. *On the complexity of matrix multiplication*. PhD thesis, University of Edinburgh (2010).
- [VW12] V. Vassilevska Williams. Multiplying matrices faster than Coppersmith—Winograd. In *STOC'12: Proceedings of the 2012 ACM Symposium on Theory of Computing*, 887–898 (2012).
- [Zhd12] D. V. Zhdanovich. The matrix capacity of a tensor. *J. Math. Sci.* 186:599–643 (2012).
- [DS13] A. M. Davie and A. J. Stothers. Improved bound for complexity of matrix multiplication. *Proc. R. Soc. Edinburgh* 143A:351–369 (2013).
- [VW14] V. Vassilevska Williams. Multiplying matrices in $O(n^{2.373})$ time. Unpublished note (2014). Available at [https://theory.stanford.edu/~virgi/matrixmult-f.pdf](https://theory.stanford.edu/~virgi/matrixmult-f.pdf).
- [LG14] F. Le Gall. Powers of tensors and fast matrix multiplication. In *ISSAC 2014: Proceedings of the 39th International Symposium on Symbolic and Algebraic Computation*, 296–303 (2014).
- [AW21] J. Alman and V. Vassilevska Williams. A refined laser method and faster matrix multiplication. In *Proceedings of the 2021 ACM-SIAM Symposium on Discrete Algorithms (SODA)*, 522–539 (2021).
- [DWZ23] R. Duan, H. Wu, and R. Zhou. Faster matrix multiplication via asymmetric hashing. In *2023 IEEE 64th Annual Symposium on Foundations of Computer Science, FOCS 2023*, 2129–2138 (2023).
- [AW24] J. Alman and V. Vassilevska Williams. A refined laser method and faster matrix multiplication. *TheoretiCS* 3:21 (2024).
- [WXXZ24] V. Vassilevska Williams, Y. Xu, Z. Xu, and R. Zhou. New bounds for matrix multiplication: from Alpha to Omega. In *Proceedings of the 2024 ACM-SIAM Symposium on Discrete Algorithms (SODA)*, 3792–3835 (2024).
- [ADWXXZ25] J. Alman, R. Duan, V. Vassilevska Williams, Y. Xu, Z. Xu, and R. Zhou. More asymmetry yields faster matrix multiplication. In *Proceedings of the 2025 ACM-SIAM Symposium on Discrete Algorithms (SODA)*, 2005–2039 (2025).
