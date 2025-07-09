from pathlib import Path
from subprocess import Popen, PIPE


def test_base(binaries_directory: str, testcase: str):
    binary_path = Path(binaries_directory) / "test_base.exe"
    input_path = Path(f"{testcase['path']}.plgr")
    output_path = Path(f"{testcase['path']}-base.out")

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


def test_explicit(binaries_directory: str, testcase: str):
    binary_path = Path(binaries_directory) / "test_explicit.exe"
    input_path = Path(f"{testcase['path']}.plgr")
    output_path = Path(f"{testcase['path']}-explicit.out")

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


def test_renamed(binaries_directory: str, testcase: str):
    binary_path = Path(binaries_directory) / "test_renamed.exe"
    input_path = Path(f"{testcase['path']}.plgr")
    output_path = Path(f"{testcase['path']}-renamed.out")

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
