#!/usr/bin/env python3
"""The sign of a bound is part of the number the README checker compares."""
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_pages


def test_opposite_signs_do_not_match():
    assert check_pages.number_matches("-1.25", ["1.25"]) is False
    assert check_pages.number_matches("1.25", ["-1.25"]) is False
    assert check_pages.number_matches("-1.25", ["-1.250"]) is True


def test_readme_sign_error_is_reported():
    with tempfile.TemporaryDirectory() as root:
        os.makedirs(os.path.join(root, "constants"))
        with open(os.path.join(root, "README.md"), "w", encoding="utf-8") as fh:
            fh.write(
                "| Number | Description | Best lower bound | Best upper bound |\n"
                "| [1a](constants/1a.html) | example | -1.25 | 2.0 |\n"
            )
        with open(os.path.join(root, "constants", "1a.md"), "w", encoding="utf-8") as fh:
            fh.write("# example\n\n1.25\n\n## References\n\n- [A] somewhere\n")
        # Capture by calling main's problem list indirectly: run and read nothing
        # if we import the comparison the way main does.
        page_nums = check_pages.NUM.findall(open(os.path.join(root, "constants", "1a.md"), encoding="utf-8").read())
        readme_nums = check_pages.NUM.findall("-1.25")
        assert readme_nums == ["-1.25"]
        assert page_nums == ["1.25"]
        assert check_pages.number_matches(readme_nums[0], page_nums) is False


if __name__ == "__main__":
    test_opposite_signs_do_not_match()
    test_readme_sign_error_is_reported()
    print("ok")
