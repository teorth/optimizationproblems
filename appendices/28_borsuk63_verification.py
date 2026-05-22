from itertools import combinations, product
from collections import deque


"""Exact finite verification for the 63-dimensional Borsuk construction.

The script reconstructs the G_2(4) strongly regular graph from PG(2,16),
checks the partition B_1, B_2, B_3, C used in the proof, and verifies the
clique obstructions that force every smaller-diameter part to have size at most
5. It uses only integer arithmetic and bitsets.
"""


MOD_POLY = 0b10011  # x^4 + x + 1, without the x^4 term for reduction below.


def gf_mul(a, b):
    out = 0
    aa = a
    bb = b
    while bb:
        if bb & 1:
            out ^= aa
        bb >>= 1
        aa <<= 1
        if aa & 0b10000:
            aa ^= MOD_POLY
    return out & 0b1111


def gf_pow(a, e):
    out = 1
    while e:
        if e & 1:
            out = gf_mul(out, a)
        a = gf_mul(a, a)
        e >>= 1
    return out


INV = [0] * 16
for a in range(1, 16):
    INV[a] = gf_pow(a, 14)
    assert gf_mul(a, INV[a]) == 1


def gf_div(a, b):
    return gf_mul(a, INV[b])


def normalize(v):
    for x in v:
        if x:
            inv = INV[x]
            return tuple(gf_mul(inv, y) for y in v)
    raise ValueError("zero vector")


def add(u, v):
    return tuple(x ^ y for x, y in zip(u, v))


def smul(a, v):
    return tuple(gf_mul(a, x) for x in v)


def hermitian(u, w):
    return gf_mul(u[0], gf_pow(w[0], 4)) ^ gf_mul(u[1], gf_pow(w[1], 4)) ^ gf_mul(u[2], gf_pow(w[2], 4))


def line_points(a, b):
    pts = set()
    for lam, mu in product(range(16), repeat=2):
        if lam == 0 and mu == 0:
            continue
        pts.add(normalize(add(smul(lam, a), smul(mu, b))))
    return pts


def bit_count(x):
    return x.bit_count()


def has_clique(adj, vertices, size):
    verts = list(vertices)
    allowed = 0
    for v in verts:
        allowed |= 1 << v

    def expand(cands, depth):
        if depth == size:
            return True
        if bit_count(cands) < size - depth:
            return False
        while cands:
            lsb = cands & -cands
            v = lsb.bit_length() - 1
            cands ^= lsb
            if expand(cands & adj[v], depth + 1):
                return True
        return False

    return expand(allowed, 0)


def clique_witness(adj, vertices, size):
    allowed = 0
    for v in vertices:
        allowed |= 1 << v

    def expand(cands, chosen):
        if len(chosen) == size:
            return chosen
        if bit_count(cands) < size - len(chosen):
            return None
        while cands:
            lsb = cands & -cands
            v = lsb.bit_length() - 1
            cands ^= lsb
            out = expand(cands & adj[v], chosen + [v])
            if out is not None:
                return out
        return None

    return expand(allowed, [])


def main():
    assert all(gf_mul(a, b) == gf_mul(b, a) for a in range(16) for b in range(16))

    points = []
    seen = set()
    for v in product(range(16), repeat=3):
        if v == (0, 0, 0):
            continue
        p = normalize(v)
        if p not in seen:
            seen.add(p)
            points.append(p)
    points.sort()
    print("projective points", len(points))
    assert len(points) == 273

    isotropic = [p for p in points if hermitian(p, p) == 0]
    nonisotropic = [p for p in points if hermitian(p, p) != 0]
    print("isotropic", len(isotropic), "nonisotropic", len(nonisotropic))
    assert len(isotropic) == 65
    assert len(nonisotropic) == 208

    iso_index = {p: i for i, p in enumerate(isotropic)}
    noniso_index = {p: i for i, p in enumerate(nonisotropic)}

    orth = [[False] * len(nonisotropic) for _ in nonisotropic]
    for i, a in enumerate(nonisotropic):
        for j in range(i + 1, len(nonisotropic)):
            if hermitian(a, nonisotropic[j]) == 0:
                orth[i][j] = orth[j][i] = True

    vertices = []
    for i, j, k in combinations(range(len(nonisotropic)), 3):
        if orth[i][j] and orth[i][k] and orth[j][k]:
            vertices.append((i, j, k))
    print("vertices", len(vertices))
    assert len(vertices) == 416

    triangles = []
    for tri in vertices:
        pts = set()
        for i, j in combinations(tri, 2):
            pts |= {p for p in line_points(nonisotropic[i], nonisotropic[j]) if p in iso_index}
        assert len(pts) == 15
        mask = 0
        for p in pts:
            mask |= 1 << iso_index[p]
        triangles.append(mask)

    n = len(vertices)
    adj = [0] * n
    edge_count = 0
    for i in range(n):
        ti = triangles[i]
        for j in range(i + 1, n):
            if bit_count(ti & triangles[j]) == 3:
                adj[i] |= 1 << j
                adj[j] |= 1 << i
                edge_count += 1
    degrees = sorted(set(bit_count(a) for a in adj))
    print("degrees", degrees, "edges", edge_count)
    assert degrees == [100]
    assert edge_count == 20800

    lambdas = set()
    mus = set()
    for i in range(n):
        ai = adj[i]
        for j in range(i + 1, n):
            common = bit_count(ai & adj[j])
            if (ai >> j) & 1:
                lambdas.add(common)
            else:
                mus.add(common)
    print("lambda", sorted(lambdas), "mu", sorted(mus))
    assert lambdas == {36}
    assert mus == {20}

    q0 = isotropic[0]
    B = []
    for idx, tri in enumerate(vertices):
        if any(hermitian(nonisotropic[i], q0) == 0 for i in tri):
            B.append(idx)
    Bset = set(B)
    C = [i for i in range(n) if i not in Bset]
    print("B size", len(B), "C size", len(C))
    assert len(B) == 96
    assert len(C) == 320

    Bmask = sum(1 << i for i in B)
    seen_b = set()
    comps = []
    for start in B:
        if start in seen_b:
            continue
        q = deque([start])
        seen_b.add(start)
        comp = []
        while q:
            v = q.popleft()
            comp.append(v)
            nb = adj[v] & Bmask
            while nb:
                lsb = nb & -nb
                w = lsb.bit_length() - 1
                nb ^= lsb
                if w not in seen_b:
                    seen_b.add(w)
                    q.append(w)
        comps.append(sorted(comp))
    comps.sort(key=lambda x: (len(x), x[0]))
    print("B component sizes", [len(c) for c in comps])
    assert [len(c) for c in comps] == [32, 32, 32]
    B1, B2, B3 = comps
    masks = [sum(1 << i for i in comp) for comp in comps]
    Cmask = sum(1 << i for i in C)
    for a, comp in enumerate(comps):
        internal = sorted(set(bit_count(adj[v] & masks[a]) for v in comp))
        print(f"B{a+1} internal", internal)
        assert internal == [20]
        for b, mask in enumerate(masks):
            if a != b:
                cross = sorted(set(bit_count(adj[v] & mask) for v in comp))
                print(f"B{a+1} to B{b+1}", cross)
                assert cross == [0]
        to_c = sorted(set(bit_count(adj[v] & Cmask) for v in comp))
        print(f"B{a+1} to C", to_c)
        assert to_c == [80]
    for a, mask in enumerate(masks):
        c_to_b = sorted(set(bit_count(adj[v] & mask) for v in C))
        print(f"C to B{a+1}", c_to_b)
        assert c_to_b == [8]
    c_internal = sorted(set(bit_count(adj[v] & Cmask) for v in C))
    print("C internal", c_internal)
    assert c_internal == [76]

    all_vertices = list(range(n))
    k5 = clique_witness(adj, all_vertices, 5)
    has_k6 = has_clique(adj, all_vertices, 6)
    has_k6_c = has_clique(adj, C, 6)
    print("K5 full witness", k5)
    print("has K6 full", has_k6)
    print("has K6 on C", has_k6_c)
    assert k5 is not None
    assert not has_k6
    assert not has_k6_c
    b = B1[0]
    NbC = [v for v in C if (adj[b] >> v) & 1]
    has_k5_nbc = has_clique(adj, NbC, 5)
    print("b", b, "NbC size", len(NbC), "has K5 on NbC", has_k5_nbc)
    assert len(NbC) == 80
    assert not has_k5_nbc
    print("all exact verification checks passed")


if __name__ == "__main__":
    main()
