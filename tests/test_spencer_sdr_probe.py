#!/usr/bin/env python3
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from spencer_sdr_probe import hadamard_analytic_lower_bound

def test_hadamard_bound():
    assert hadamard_analytic_lower_bound() == 0.5

if __name__ == "__main__":
    test_hadamard_bound(); print("ok - spencer sdr probe")
