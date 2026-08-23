# Contributing Guidelines

## What constants are appropriate to record here?

There are of course an infinite number of optimization problems one could pose in mathematics.  To avoid proliferation, one should preferably focus on constants that

- have a significant existing mathematical literature, including incremental improvements on bounds;
- are still actively being researched;
- are at least somewhat amenable to computational approaches for either upper or lower bounds; and
- do not depend on additional parameters (such as dimension, or number of objects in a configuration), or have such parameters set to "canonical" or particularly well studied choices for which significant literature exists.

However, exceptions could be made for constants of particular mathematical interest for reasons other than those listed above.  There is no restriction on the field of mathematics from which the constant arises.

If a constant has a large number of variants, I would prefer that a single page be created for a "quintessential" representative of this family of constants (which will most likely be the one with the most existing literature), with brief mention of the variants in the "Additional comments and links" section.  In some cases, if there are two equally important members of the family, it may be appropriate to create two separate entries.

If a constant has been worked out exactly, this site may not be the most appropriate place to record it, unless the accomplishment of this exact value was a recent achievement preceded by a succession of previous upper and lower bounds.  One can consider instead contributing such a constant to the [OEIS](https://oeis.org/) (using the decimal expansion of the constant as the sequence) or to Wikipedia's [list of mathematical constants](https://en.wikipedia.org/wiki/List_of_mathematical_constants).

## How to Contribute

### Adding a New Constant

1. **Fork the repository** and create a new branch for your contribution.
2. **Create a new file** in the `constants/` directory as `Nx.md`, where `N` and `x` are selected as follows:
    - If the constant does not belong to any existing family of constants already recorded in the repository, set `N` to be the smallest positive integer not yet used for any constant in the repository, and `x` to be `a`.  For instance, if the largest existing constant is $C_{19d}$, set `N=20` and use the file `20a.md`; the constant can be referred to as $C_{20}$.
    - If the constant is part of an existing family associated to the number `N`, set `N` to be this number, and `x` to be the first unclaimed letter.  For instance, if the constant is in the `N=3` family, and the existing constants in that family are $C_{3a}$ and $C_{3b}$, set `x=c` and use the file `3c.md`; the constant should be referred to as $C_{3c}$.
    - In the event of a collision due to near-simultaneous updates, I will ask for `Nx` to be updated and the file to be renamed.
3. **Use the template**: Copy the structure from [template.md](template.md).
4. **Fill in sections**:
   - Provide a clear definition of the constant (call it $C_{Nx}$, or $C_N$ if $x=a$, but you can also note other common names for it in the literature).
   - Include the current best known bounds with citations.
   - Incomplete submissions are welcome; just provide as much information as you have.
5. **Submit a pull request**
6. If approved, I will assign it a number and link to it from the main README.

### Updating Existing Bounds

1. **Fork the repository** and create a new branch.
2. **Edit the relevant constant file**:
   - Update the bounds section with new values, with at least one citation or reference.
3. **Also update the corresponding cell of the table in [README.md](README.md)**, and add a line to its "Recent progress" section.  A pull request that improves a bound on a constant page but leaves the README showing the old value is the most common defect in submissions here.
4. **Submit a pull request**

## Recording bounds

- **The bound tables are histories, not just leaderboards.**  Rows are listed in chronological order and superseded rows are kept, including bounds that are inferior to ones already recorded.  When several pull requests improve the same constant they will all append to the same table; they are merged in chronological order of the claims, with every row retained and the README cell updated once, to the best value.
- **Record the certified value in the Bound column, and the limit in the Comments column.**  Many constructions produce both a value that a third party can recompute directly — an exact count at a given depth, say — and a larger limiting value obtained by extrapolation or by an asymptotic analysis of the same family.  Both are usually valid bounds, but the recorded value should be the one that can be checked by direct computation; state the limit, and the argument for it, in the comments.  If you submit such a construction, please give both numbers explicitly, and say which is which.
- Give enough data in the Comments column for a reader to reproduce the number without downloading anything: the set, the parameters, the intermediate cardinalities.  Several entries in this repository have been checked, and one found not to reproduce, purely from what was recorded in that column.

## The constant numbering system

Each constant will be assigned a number $N$, indicating the family of constants it belongs to, and a letter $x$ to indicate its assigned label within that family, with $x$ defaulting to "a"; the constant will then be labeled $C_{Nx}$, and stored in the file `Nx.md`.  If a family has only one constant in it, one can abbreviate $C_{Na}$ as $C_N$, but we will keep the filename as `Na.md` rather than `N.md` so that the filename remains stable in the event that new constants in this family are added to the repository.  This is so that external references to these files remain static.


## Rendering

Pages are served by GitHub Pages, which converts this Markdown to HTML with kramdown; the resulting page then loads MathJax 3, configured in `_layouts/default.html`.  Nearly every rendering defect reported here follows from one fact about that pipeline:

- **`$$…$$` is handled by kramdown.**  It recognises the delimiters and passes everything between them through to MathJax verbatim.
- **`$…$` is not.**  kramdown has no notion of single-dollar math, so that text is ordinary Markdown; it is only MathJax, running in the browser afterwards, that turns it into mathematics.

Inline math is therefore parsed as Markdown *first*, and anything Markdown finds meaningful inside it — underscores, asterisks, braces, pipes — is consumed before MathJax ever sees it.  **The escaping rule is thus the opposite in the two contexts:**

| | inline `$…$` | display `$$…$$` |
| --- | --- | --- |
| subscript | `C\_{86}` | `C_{86}` |
| superscript star | `W^\*` | `W^*` |
| set braces | `\\{ x \\}` | `\{ x \}` |
| absolute value | `\lvert x \rvert` | `\lvert x \rvert` or `\|x\|` |

In inline math the backslash is eaten by kramdown and MathJax receives the bare character, which is what you want.  **Do not escape inside `$$…$$`**: there the backslash survives, so `\_` reaches MathJax as a literal underscore instead of a subscript, and `\\{` as a line break followed by a brace.

Two symbols account for most of the breakage:

- **Underscores.**  Two unescaped `_` on one line of inline math pair into an `<em>` span and the math breaks.  A lone `_` with no partner usually survives, which is why plenty of pages get away with `$B_u$` — but escape it anyway.  It always works, and the next edit may supply the partner.
- **Asterisks.**  Exactly the same failure, and easier to miss, because `$C^*$`, `$d^*(G)$` and this repository's own `*` marker for unverified bounds all look harmless.  A lone `$*$` will even pair with the next `*emphasis*` later in the line.

Avoid a bare `|` in inline math as well: inside a table it ends the cell.  Write `\lvert` and `\rvert`.

### Look at the rendered page

Source that reads correctly can still render wrong, so check the output rather than only the diff.  Once a page is live:

```
curl -s https://teorth.github.io/optimizationproblems/constants/86a.html | grep '<em>'
```

An `<em>` or `<strong>` sitting between two `$` on the same line is math that kramdown has eaten.  Before that, the cheap local checks are table arity — constant pages have three columns, so four `|` per row, while the README has four columns and five — and a look at each `$$` block for stray `\_` or `\\{`.

### The README table is rendered twice

The README is rendered by kramdown with MathJax on the site, and separately by GitHub's own Markdown renderer on the repository front page.  GitHub's inline-math extension will not open a `$` span when a word character immediately precedes the dollar sign, so `degree-$d$` renders as literal `degree-$d$` there while rendering correctly on the site.  Leave a space before the opening `$`, or reword — `Boolean functions of degree $d$` — rather than leaving a hyphen adjacent to it.

## AI use policy

Use of AI to help prepare submissions is permitted, so long as this is noted in the submission text, and that all references and other information provided by the AI are reviewed and verified by the human contributor.  Minor uses of AI, such as spellcheck or autocomplete, do not need to be disclosed.