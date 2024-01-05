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

import pathlib
import glob
import os
import shutil
import re

PKG_NAME = os.environ["PKG_NAME"]
target_platform = os.environ["target_platform"]
PREFIX = pathlib.Path(os.environ["PREFIX"])
STAGE = pathlib.Path(os.environ["SRC_DIR"]) / "stage"
basename = "avif"

if target_platform[:3] == "win":
    PREFIX = PREFIX / "Library"


def glob_install(
    include: str,
    exclude: str = "",
):
    included = set(glob.glob(str(STAGE / pathlib.Path(include))))
    excluded = set(glob.glob(str(STAGE / pathlib.Path(exclude))))
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


if __name__ == "__main__":
    print(f"Installing {PKG_NAME} to {PREFIX} for {target_platform}")

    if re.match(r"^[a-z]+\-split$", PKG_NAME):
        raise ValueError("The top level package should not run this script.")

    # libfoo OR foo-dev OR libfoo-dev
    if re.match(r"^lib[a-z]+$", PKG_NAME) or re.match(r"^[a-z]+\-dev$", PKG_NAME):
        glob_install("include")
        glob_install("lib/*.lib")
        glob_install("lib/cmake")
        glob_install("lib/pkgconfig")
        glob_install(f"lib/lib{basename}.dylib")
        glob_install(f"lib/lib{basename}.so")

    # libfoo1
    if re.match(r"^lib[a-z]+[0-9]+$", PKG_NAME):
        glob_install("bin/*.dll")
        glob_install(f"lib/lib{basename}.*.dylib")
        glob_install(f"lib/lib{basename}.so.*")

    # foo
    if re.match(f"^{basename}$", PKG_NAME):
        glob_install("bin", exclude="bin/*.dll")
        glob_install("doc")
        glob_install("share")

    # libfoo-static
    if re.match(r"^lib[a-z]+\-static$", PKG_NAME):
        glob_install(f"lib/lib{basename}.a")
        # FIXME: Add static library files here; exclude above
