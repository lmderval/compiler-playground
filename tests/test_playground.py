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


def test_linearized(binaries_directory: str, testcase: Dict[str, str]):
    basic_test("linearized", binaries_directory, testcase)


def test_typed(binaries_directory: str, testcase: Dict[str, str]):
    basic_test("typed", binaries_directory, testcase)


def test_c_program(
    binaries_directory: str, testcase: Dict[str, str], runtime_directory: str
):
    test_path = testcase['name'].replace('::', '/')

    binary_path = Path(binaries_directory) / "test_c_program.exe"
    input_path = Path(f"{testcase['path']}.plgr")
    output_path = Path(f"{testcase['path']}.out")
    runtime_path = Path(runtime_directory)
    include_path = runtime_path / "include"
    tmp_path = Path("/tmp/files/")
    obj_path = tmp_path / f"{test_path}.o"
    out_path = tmp_path / test_path
    libruntime_path = runtime_path / "libruntime.a"

    if not obj_path.parent.exists():
        obj_path.parent.mkdir(parents=True)

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
    assert stderr == b""

    input = stdout

    compile_proc = Popen(
        args=[
            "gcc",
            "-c",
            "-std=c99",
            f"-I{runtime_path}",
            f"-I{include_path}",
            "-o",
            f"{obj_path}",
            "-xc",
            "-",
        ],
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
    )

    stdout, stderr = compile_proc.communicate(input=input, timeout=10.0)
    assert proc.returncode == 0
    assert stdout == b""
    assert stderr == b""

    link_proc = Popen(
        args=[
            "gcc",
            "-o",
            f"{out_path}",
            f"{obj_path}",
            f"{libruntime_path}",
        ],
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
    )

    stdout, stderr = link_proc.communicate(input=input, timeout=10.0)
    assert proc.returncode == 0
    assert stdout == b""
    assert stderr == b""

    execution_proc = Popen(
        args=[f"{out_path}"],
        stdin=PIPE,
        stdout=PIPE,
        stderr=PIPE,
    )

    stdout, stderr = execution_proc.communicate(input=input, timeout=10.0)
    assert proc.returncode == 0
    assert stdout == output
    assert stderr == b""
