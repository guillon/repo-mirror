#!/usr/bin/env bash
#
# Copyright (c) STMicroelectronics 2014
#
# This file is part of repo-mirror.
#
# repo-mirror is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License v2.0
# as published by the Free Software Foundation
#
# repo-mirror is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# v2.0 along with repo-mirror. If not, see <http://www.gnu.org/licenses/>.
#

# unitary test

source `dirname $0`/common.sh

TEST_CASE="repo-mirror check error recovery on git lock issues"

# Skip python 3 not supported by repo 1
! is_python3_repo1 || skip "python 3 not supported by repo 1"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1

# Insert some lock file, simulating git behavior with lock issues
# repo-mirror when getting a lock issue in the mirroted repo
# will clean locks an re-attempt sync

mkdir -p test-repo
pushd test-repo
cat >repo-test-git-lock <<EOF
#!/bin/bash
[ "\$1" != sync -o ! -f $PWD/some.lock ] || { echo "unable to create '$PWD/some.lock'" >&2; exit 1; }
repo "\$@"
EOF
chmod +x repo-test-git-lock

touch $PWD/some.lock
$REPO_MIRROR -r $PWD/repo-test-git-lock -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
$REPO_MIRROR -r $PWD/repo-test-git-lock -m "$TMPTEST/repo-mirrors" -d -q -- sync
popd

