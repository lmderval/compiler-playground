import pytest

from pathlib import Path
from subprocess import Popen, PIPE


@pytest.mark.parametrize("category", ["base", "explicit", "renamed"])
def test_output_only(category: str, binaries_directory: str, testcase: str):
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
