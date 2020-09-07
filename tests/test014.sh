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

TEST_CASE="repo-mirror with bogus HEAD"

# Skip python 3 not supported by repo 1
! is_python3_repo1 || skip "python 3 not supported by repo 1"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1::HEAD

# Run a first repo-mirror init
mkdir test-1
pushd test-1
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
popd

# Corrupt HEAD on the mirror, has it may happend when a manifest contains
# incorrect revisions or repo init is interrupted
echo "da39a3ee5e6b4b0d3255bfef95601890afd80709X" | tee repo-mirrors/default/repos/project1.git/HEAD

# Run a second repo-mirror init, repo may fail to init on Invalid HEAD
# repo-mirror corrects this error by setting a well formed HEAD reference before mirror sync
mkdir test-2
pushd test-2
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
popd

# Remove HEAD completly, this is invalid, though in this case, repo-mirror
# does not attempt any recovery
rm repo-mirrors/default/repos/project1.git/HEAD
mkdir test-3
pushd test-3
res=0
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null 2>&1 | tee error.log || res=$?
popd
# In this case normally repo should fail to recognize the mirrored repo as a git repository
[ "$res" != 0 ] && grep -i -w -q "Not a git repository" test-3/error.log
