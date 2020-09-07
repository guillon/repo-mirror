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

TEST_CASE="repo-mirror repo mirror list and clean test"

# Skip python 3 not supported by repo 1
! is_python3_repo1 || skip "python 3 not supported by repo 1"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1 project2 project1-1:project1/project1-1

# Test empty mirrors
list=$($REPO_MIRROR  -m "$TMPTEST/repo-mirrors" --list | tr '\n' ' ')
[ "$(echo $list)" = "" ]

# Repo init/sync and verify mirror entries list
mkdir -p repo-mirrors
mkdir -p test-repo
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
popd >/dev/null
list=$($REPO_MIRROR  -m "$TMPTEST/repo-mirrors" --list | tr '\n' ' ')
[ "$(echo $list)" = "default" ]
[ -d "$TMPTEST/repo-mirrors/default" ]

# Repo init/sync with a different id and verify mirror entries list
rm -rf test-repo
mkdir -p test-repo
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -i anotherone -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
popd >/dev/null
list=$($REPO_MIRROR  -m "$TMPTEST/repo-mirrors" --list | tr '\n' ' ')
[ "$(echo $list)" = "anotherone default" ]
[ -d "$TMPTEST/repo-mirrors/default" ]
[ -d "$TMPTEST/repo-mirrors/anotherone" ]

# Test clean of one of them
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -i anotherone -d --clean
list=$($REPO_MIRROR  -m "$TMPTEST/repo-mirrors" --list | tr '\n' ' ')
[ "$(echo $list)" = "default" ]
[ -d "$TMPTEST/repo-mirrors/default" ]
[ ! -d "$TMPTEST/repo-mirrors/anotherone" ]

# Recreate again one with a different id and verify mirror entries list
rm -rf test-repo
mkdir -p test-repo
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -i anothertwo -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
popd >/dev/null
list=$($REPO_MIRROR  -m "$TMPTEST/repo-mirrors" --list | tr '\n' ' ')
[ "$(echo $list)" = "anothertwo default" ]
[ -d "$TMPTEST/repo-mirrors/default" ]
[ -d "$TMPTEST/repo-mirrors/anothertwo" ]

# Test clean all
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d --clean-all
list=$($REPO_MIRROR  -m "$TMPTEST/repo-mirrors" --list | tr '\n' ' ')
[ "$(echo $list)" = "" ]
[ ! -d "$TMPTEST/repo-mirrors/default" ]
[ ! -d "$TMPTEST/repo-mirrors/anothertwo" ]
