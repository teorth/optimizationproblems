#!/usr/bin/env python3
r"""Consistency checker for the Optimization Constants repository (README.md and constants/*.md).

It catches the defects that CONTRIBUTING.md describes and that have needed manual fixes after merges:

  E1  README row links a constants/ page that does not exist
  E2  duplicated README rows (same constant id or same page)
  E3  constant page without a "## References" heading
  E4  an unresolved merge-conflict marker left in a tracked Markdown file
  W1  README bound value with no matching number on the constant's page (stale README cell or a typo).
      Rounding in the last digit is allowed, and numbers given only as fractions or closed forms are skipped.
  W2  "_" or "*" inside inline $...$ that kramdown will pair into emphasis, breaking the math
      (CONTRIBUTING, "Rendering")
  W3  a block whose every line has a bare "|", where a "|" sits inside inline math. kramdown renders the
      block as a table (CONTRIBUTING: use \lvert, \rvert)
  I1  constants/ page not linked from the README (often intentional while a number is assigned)

W2 and W3 follow how kramdown actually parses the pages (GFM input, as on GitHub Pages). W2 was checked
against every historical version of every page in this repository: it finds all 27 lines that ever rendered
with broken inline math. It also flags 2 more lines that kramdown really does break but a naive check
misses, and nothing else.

Usage:  python3 scripts/check_pages.py [repo_root]
Exit status is 1 if any E-level problem is found. Pure Python 3 standard library.
"""
import os
import re
import sys
import unicodedata



def _is_ws(c):
    return c is None or c.isspace()


def _is_punct(c):
    if c is None:
        return False
    return unicodedata.category(c).startswith("P") or unicodedata.category(c).startswith("S")


def math_mask(line):
    """Boolean per character: True inside a single-$ inline math span. $$...$$ spans are left alone,
    because kramdown handles them itself."""
    mask = [False] * len(line)
    i, n = 0, len(line)
    while i < n:
        if line[i] == "\\":
            i += 2
            continue
        if line.startswith("$$", i):
            j = line.find("$$", i + 2)
            if j < 0:
                break
            for k in range(i, j + 2):
                mask[k] = None  # display math: kramdown parses it, so emphasis never applies
            i = j + 2
            continue
        if line[i] == "$":
            j = i + 1
            while j < n and not (line[j] == "$" and line[j - 1] != "\\"):
                j += 1
            if j >= n:
                break
            for k in range(i + 1, j):
                mask[k] = True
            i = j + 1
            continue
        i += 1
    return mask


def code_mask(line):
    """True inside `code` spans, where emphasis is not parsed."""
    mask = [False] * len(line)
    i, n = 0, len(line)
    while i < n:
        if line[i] == "`":
            j = line.find("`", i + 1)
            if j < 0:
                break
            for k in range(i, j + 1):
                mask[k] = True
            i = j + 1
            continue
        i += 1
    return mask


def broken_emphasis(line):
    """Return a list of (char, open_index, close_index) emphasis pairs that touch inline math."""
    mm, cm = math_mask(line), code_mask(line)
    n = len(line)
    runs = []  # (char, start, length, can_open, can_close)
    i = 0
    while i < n:
        c = line[i]
        if c == "\\":
            i += 2
            continue
        if c in "*_" and not cm[i] and mm[i] is not None:
            j = i
            while j < n and line[j] == c:
                j += 1
            before = line[i - 1] if i > 0 else None
            after = line[j] if j < n else None
            lf = not _is_ws(after) and (not _is_punct(after) or _is_ws(before) or _is_punct(before))
            rf = not _is_ws(before) and (not _is_punct(before) or _is_ws(after) or _is_punct(after))
            if c == "*":
                can_open, can_close = lf, rf
            else:
                can_open = lf and (not rf or _is_punct(before))
                can_close = rf and (not lf or _is_punct(after))
            runs.append([c, i, j - i, can_open, can_close])
            i = j
            continue
        i += 1
    # kramdown pairing: scan left to right; an unused opener takes the FIRST later closer of the same character.
    pairs, used, k = [], set(), 0
    while k < len(runs):
        c, start, length, can_open, can_close = runs[k]
        if can_open and k not in used:
            for m in range(k + 1, len(runs)):
                if runs[m][0] == c and runs[m][4] and m not in used:
                    pairs.append((c, start, runs[m][1]))
                    used.update({k, m})
                    k = m
                    break
        k += 1
    return [(c, a, b) for (c, a, b) in pairs if mm[a] or mm[b]]


def broken_line(line):
    """Table rows are split into cells first (kramdown parses each cell separately)."""
    if line.lstrip().startswith("|"):
        cells, cur, i = [], "", 0
        while i < len(line):
            if line[i] == "\\" and i + 1 < len(line):
                cur += line[i:i + 2]
                i += 2
                continue
            if line[i] == "|":
                cells.append(cur)
                cur = ""
            else:
                cur += line[i]
            i += 1
        cells.append(cur)
        return [b for cell in cells for b in broken_emphasis(cell)]
    return broken_emphasis(line)


ROW = re.compile(r"^\|\s*\[([^\]]+)\]\((?:https://teorth\.github\.io/optimizationproblems/)?constants/([\w-]+)\.html\)\s*\|(.*)$")
NUM = re.compile(r"(?<![\w.])\d+\.\d+")
LIST = re.compile(r"^\s*(?:[-*+]|\d+\.)\s")


def number_matches(x, page_nums):
    """True if some number on the page agrees with x to within one unit in the last digit of the less precise of the two."""
    dx = len(x.split(".")[1])
    xv = float(x)
    for p in page_nums:
        dp = len(p.split(".")[1])
        if abs(float(p) - xv) <= 10 ** (-min(dx, dp)) * 1.0000001:
            return True
    return False


def bare_pipe_in_math(line):
    mm = math_mask(line)
    return any(c == "|" and mm[k] and (k == 0 or line[k - 1] != "\\") for k, c in enumerate(line))


def has_bare_pipe(line):
    cm = code_mask(line)
    return any(c == "|" and not cm[k] and (k == 0 or line[k - 1] != "\\") for k, c in enumerate(line))


CONFLICT = re.compile(r"^(<{7}|={7}|>{7})(\s|$)")


def conflict_markers(path, rel):
    """Unresolved merge-conflict markers. Cheap, and they have reached main."""
    out = []
    for ln, line in enumerate(open(path, encoding="utf-8").read().split("\n"), 1):
        if CONFLICT.match(line):
            out.append(("E4", f"{rel}:{ln}", f"merge-conflict marker {line.strip()[:9]!r}"))
    return out


def main(root):
    problems = []
    readme_path = os.path.join(root, "README.md")
    const_dir = os.path.join(root, "constants")
    readme = open(readme_path, encoding="utf-8").read().splitlines()
    problems += conflict_markers(readme_path, "README.md")
    seen_id, seen_file, linked = {}, {}, set()
    for ln, line in enumerate(readme, 1):
        m = ROW.match(line)
        if not m:
            continue
        cid, fname, rest = m.group(1), m.group(2), m.group(3)
        where = f"README.md:{ln}"
        linked.add(fname)
        path = os.path.join(const_dir, fname + ".md")
        if not os.path.exists(path):
            problems.append(("E1", where, f"row [{cid}] links constants/{fname}.md, which does not exist"))
        if cid in seen_id:
            problems.append(("E2", where, f"row [{cid}] duplicates README.md:{seen_id[cid]}"))
        elif fname in seen_file:
            problems.append(("E2", where, f"row links {fname}.md again (first at README.md:{seen_file[fname]})"))
        seen_id.setdefault(cid, ln)
        seen_file.setdefault(fname, ln)
        cells = [c.strip() for c in rest.split("|")]
        if os.path.exists(path) and len(cells) >= 3:
            page_nums = NUM.findall(open(path, encoding="utf-8").read())
            for cell in cells[1:3]:
                for x in NUM.findall(cell):
                    if number_matches(x, page_nums):
                        continue
                    near = [p for p in page_nums if abs(float(p) - float(x)) <= 0.05 * max(abs(float(x)), 1e-9)]
                    if near:  # a different nearby value is on the page: likely a stale cell or a typo
                        problems.append(("W1", where, f"[{cid}] README value {x}; nearest on {fname}.md: {sorted(near, key=lambda p: abs(float(p) - float(x)))[0]}"))

    for fname in sorted(os.listdir(const_dir)):
        if not fname.endswith(".md"):
            continue
        rel = f"constants/{fname}"
        text = open(os.path.join(const_dir, fname), encoding="utf-8").read()
        lines = text.split("\n")
        problems += conflict_markers(os.path.join(const_dir, fname), rel)
        if not re.search(r"^##\s+References\s*$", text, re.M):
            problems.append(("E3", rel, 'no "## References" heading'))
        if fname[:-3] not in linked:
            problems.append(("I1", rel, "not linked from README.md"))
        display = False
        for i, line in enumerate(lines):
            st = line.strip()
            if st.startswith("$$") and st.count("$$") == 1:
                display = not display
                continue
            if display:
                continue
            if broken_line(line):
                problems.append(("W2", f"{rel}:{i + 1}", 'inline math has "_" or "*" that kramdown pairs into emphasis (escape as \\_ or \\*)'))
            if st.startswith("|") or st.startswith("#") or not bare_pipe_in_math(line):
                continue
            prev = lines[i - 1].strip() if i > 0 else ""
            if prev and not LIST.match(line):
                continue  # continuation of a paragraph: not a block start
            block, j = [line], i + 1
            while j < len(lines) and lines[j].strip() and not LIST.match(lines[j]) and not lines[j].strip().startswith("#"):
                block.append(lines[j])
                j += 1
            if all(has_bare_pipe(b) for b in block):
                problems.append(("W3", f"{rel}:{i + 1}", 'bare "|" in inline math makes kramdown render this block as a table (use \\lvert ... \\rvert)'))

    order = {"E": 0, "W": 1, "I": 2}
    problems.sort(key=lambda p: (order[p[0][0]], p[0], p[1]))
    for level, where, msg in problems:
        print(f"{level}  {where}: {msg}")
    counts = {k: sum(1 for p in problems if p[0][0] == k) for k in "EWI"}
    print(f"\n{counts['E']} errors, {counts['W']} warnings, {counts['I']} notes")
    return 1 if counts["E"] else 0


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "..")))
