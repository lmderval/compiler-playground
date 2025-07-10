import pytest

from pathlib import Path
from subprocess import Popen, PIPE

from typing import Dict


def basic_test(category: str, binaries_directory: str, testcase: Dict[str, str]):
    binary_path = Path(binaries_directory) / f"test_{category}.exe"
    input_path = Path(f"{testcase['path']}.plgr")
    output_path = Path(f"{testcase['path']}-{category}.out")

    with open(input_path, mode="br") as file:
        input = b"".join(file.readlines())

    with open(output_path, mode="br") as file:
        output = b"".join(file.readlines())

    proc = Popen(
        args=[binary_path],
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
    )

    stdout, stderr = proc.communicate(input=input, timeout=10.0)
    assert proc.returncode == 0
    assert stdout == output
    assert stderr == b""


def test_base(binaries_directory: str, testcase: Dict[str, str]):
    basic_test("base", binaries_directory, testcase)


def test_explicit(binaries_directory: str, testcase: Dict[str, str]):
    basic_test("explicit", binaries_directory, testcase)


def test_renamed(binaries_directory: str, testcase: Dict[str, str]):
    basic_test("renamed", binaries_directory, testcase)
