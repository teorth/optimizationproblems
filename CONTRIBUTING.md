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
3. **Submit a pull request**

## The constant numbering system

Each constant will be assigned a number $N$, indicating the family of constants it belongs to, and a letter $x$ to indicate its assigned label within that family, with $x$ defaulting to "a"; the constant will then be labeled $C_{Nx}$, and stored in the file `Nx.md`.  If a family has only one constant in it, one can abbreviate $C_{Na}$ as $C_N$, but we will keep the filename as `Na.md` rather than `N.md` so that the filename remains stable in the event that new constants in this family are added to the repository.  This is so that external references to these files remain static.


## LaTeX rendering issues

Due to the way Markdown is converted to HTML on this site, underscores in LaTeX math mode need to be escaped with backslashes (i.e., use `\_` instead of `_`), or else they may be interpreted incorrectly as italicization.  For similar reasons, pipes `|` should be avoided; one can use
`\lvert` and `\rvert` instead.

## AI use policy

Use of AI to help prepare submissions is permitted, so long as this is noted in the submission text, and that all references and other information provided by the AI are reviewed and verified by the human contributor.  Minor uses of AI, such as spellcheck or autocomplete, do not need to be disclosed.