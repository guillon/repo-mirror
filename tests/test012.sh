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

TEST_CASE="repo-mirror repo mirror with dangling locks"

# Skip python 3 not supported by repo
! is_python3 || skip "python 3 not supported by repo"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1 project2 project1-1:project1/project1-1

# Repo init/sync
mkdir -p repo-mirrors
mkdir -p test-repo
(
    cd test-repo
    $REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
    $REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- sync
)

# Update master branch
(
    cd test-repo/project1
    echo "" >>README
    git -c user.email="anonymous@anon.org" -c user.name="Anonymous" commit -a -m 'Update README'
    git push local HEAD:master
)

# Simulate a git crash by adding a dangling lock
(touch "$TMPTEST"/repo-mirrors/default/repos/project1.git/refs/heads/master.lock)

# Mark this test as expected to fail
xfail "support for dangling lock not implemented"

# Re-execute a mirror init/sync, should fail to sync
(
    cd test-repo
    $REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
)
