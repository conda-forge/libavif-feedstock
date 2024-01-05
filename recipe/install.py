"""A python install script for conda-build recipes with multiple outputs

Used in outputs/script to split the files of a top-level package into multiple
outputs instead of using the outputs/files dictionary of globs. The advantage
of this approach is that you don't need to choose glob expressions that include
files installed by this package while excluding files installed by the host
dependencies. For example, this script just globs "include", whereas using
outputs/files, you would need to glob "include/foo.h", "include/foo" and
possibly others in order to exclude the headers from dependencies.

To use this script, set your install prefix in your build script to a new
directory named `$SRC_DIR / stage`. Change `basename` to the basename of the
package.

https://gist.github.com/carterbox/188ac74647e703cfa6700b58b076d712
"""

import glob
import os
import pathlib
import re
import shutil
import typing
import itertools

target_platform = os.environ["target_platform"]
STAGE = pathlib.Path(os.environ["SRC_DIR"]) / "stage"
PREFIX = pathlib.Path(os.environ["PREFIX"])
if target_platform[:3] == "win":
    PREFIX = PREFIX / "Library"


def glob_install(
    include: typing.List[str],
    exclude: typing.List[str] = [],
):
    included = set(
        itertools.chain(
            *(
                glob.glob(
                    str(STAGE / pathlib.Path(item)),
                    recursive=True,
                )
                for item in include
            )
        )
    )
    excluded = set(
        itertools.chain(
            *(
                glob.glob(
                    str(STAGE / pathlib.Path(item)),
                    recursive=True,
                )
                for item in exclude
            )
        )
    )
    for match in included - excluded:
        match = pathlib.Path(match)
        relative = match.relative_to(STAGE)
        print(relative)
        if match.is_dir():
            shutil.copytree(
                match,
                PREFIX / relative,
                symlinks=True,
                ignore_dangling_symlinks=True,
                dirs_exist_ok=True,
            )
        else:
            shutil.copy(
                match,
                PREFIX / relative,
                follow_symlinks=False,
            )


def sort_artifacts_based_on_name(basename):
    PKG_NAME = os.environ["PKG_NAME"]

    print(f"Installing {PKG_NAME} to {PREFIX} for {target_platform}")
    print("Based on the package name, ", end="")

    if re.match(r"^[a-z]+\-split$", PKG_NAME):
        raise ValueError("The top level package should not run this script.")

    # libfoo OR foo-dev OR libfoo-dev
    if re.match(r"^lib[a-z]+$", PKG_NAME) or re.match(r"^[a-z]+\-dev$", PKG_NAME):
        print("this package is needed for compiling/linking.")
        glob_install(
            include=[
                "include",
                "lib",
            ],
            exclude=[
                "lib/lib*.*.dylib",
                "lib/lib*.so.*",
                "lib/lib*.a",
                "lib/*.a.lib",
                "lib/*static.lib",
                "lib/**/*static*",
            ],
        )
        return

    # libfoo1
    if re.match(r"^lib[a-z]+[0-9]+$", PKG_NAME):
        print("this package is versioned so/dylib, dlls.")
        glob_install(
            include=[
                "bin/*.dll",
                "lib/lib*.*.dylib",
                "lib/lib*.so.*",
            ]
        )
        return

    # foo
    if re.match(f"^{basename}$", PKG_NAME):
        print("this package is tools, docs, and misc files needed for tools.")
        glob_install(
            include=[
                "bin",
                "doc",
                "share",
            ],
            exclude=[
                "bin/**/*.dll",
            ],
        )
        return

    # libfoo-static
    if re.match(r"^lib[a-z]+\-static$", PKG_NAME):
        print("this package is anything needed for static linking.")
        glob_install(
            include=[
                "lib/lib*.a",
                "lib/*.a.lib",
                "lib/*static.lib",
                "lib/**/*static*",
            ]
        )
        # FIXME: Add static library files here; exclude above
        return


if __name__ == "__main__":
    sort_artifacts_based_on_name(basename="avif")
