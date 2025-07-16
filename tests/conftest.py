import glob
from pathlib import Path

BASE_DIR = Path(__file__).parent.resolve()


def pytest_addoption(parser):
    parser.addoption("--binaries-directory", action="store", default=BASE_DIR)
    parser.addoption("--runtime-directory", action="store")


def pytest_generate_tests(metafunc):
    binaries_directory = metafunc.config.option.binaries_directory
    if "binaries_directory" in metafunc.fixturenames and binaries_directory is not None:
        metafunc.parametrize("binaries_directory", [binaries_directory])

    runtime_directory = metafunc.config.option.runtime_directory
    if "runtime_directory" in metafunc.fixturenames and runtime_directory is not None:
        metafunc.parametrize("runtime_directory", [runtime_directory])

    if "testcase" in metafunc.fixturenames:
        files_dir = BASE_DIR / "files"
        testcases = []
        for child in glob.glob(f"{files_dir}/**/*.plgr", recursive=True):
            test_path = child.removesuffix(".plgr")
            test_name = test_path.removeprefix(f"{files_dir}/").replace("/", "::")
            testcases.append({"name": test_name, "path": test_path})

        metafunc.parametrize("testcase", testcases)


def pytest_itemcollected(item):
    item._nodeid = ""

    category = item.originalname.removeprefix("test_")
    testcase = item.callspec.params.get("testcase")

    if testcase:
        item._nodeid = f"{category}::{testcase['name']}"
