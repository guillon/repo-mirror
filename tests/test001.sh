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

TEST_CASE="repo-mirror repo creation test"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1 project2 project1-1:project1/project1-1

# Repo init/sync and verify tree
mkdir -p test-repo
cd test-repo
repo init -q -u file://"$TMPTEST"/repos/manifests.git </dev/null
repo sync -q
[ -f project1/README ]
[ -f project2/README ]
[ -f project1/project1-1/README ]

# Verify that objects are actually there
obj=$(env GIT_DIR=project1/.git git rev-parse HEAD)
[ -f project1/.git/objects/${obj::2}/${obj:2} ]
