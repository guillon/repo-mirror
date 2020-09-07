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

TEST_CASE="repo-mirror check error on undefined mirror dir"

# Skip python 3 not supported by repo 1
! is_python3_repo1 || skip "python 3 not supported by repo 1"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1

mkdir -p test-repo
# Valid repo init/sync
pushd test-repo
env HOME=$TMPTEST $REPO_MIRROR -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
popd
# Verify that local repo mirror was created
[ -f "$TMPTEST"/.repo-mirror/default/repos/project1.git/HEAD ]

# Invalid HOME dir
pushd test-repo
res=0
env HOME=/invalid $REPO_MIRROR -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null 2>&1 | tee error.log || res=$?
popd
# Verify that creation failed with a meaningfull message
[ "$res" != 0 ] && grep -q "can't create mirror dir" test-repo/error.log

# Undefined HOME dir
pushd test-repo
res=0
(unset HOME; $REPO_MIRROR -d -q -- init -u file://"$TMPTEST"/repos/manifests.git) </dev/null 2>&1 | tee error.log || res=$?
popd
# Verify that creation failed with a meaningfull message
[ "$res" != 0 ] && grep -q "HOME undefined" test-repo/error.log
