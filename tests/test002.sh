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

TEST_CASE="repo-mirror repo mirror creation test"

# Skip python 3 not supported by repo
! is_python3 || skip "python 3 not supported by repo"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1 project2 project1-1:project1/project1-1

# Repo init/sync and verify tree with repo-mirror
mkdir -p repo-mirrors
mkdir -p test-repo
cd test-repo
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- sync 
[ -f project1/README ]
[ -f project2/README ]
[ -f project1/project1-1/README ]

# Verify that all projects have an alternate pointing to default mirror
# and empty object pack
[ -f project1/.git/objects/info/alternates ]
[ "$(<project1/.git/objects/info/alternates)" = "$TMPTEST/repo-mirrors/default/repos/project1.git/objects" ]
[ -f project2/.git/objects/info/alternates ]
[ "$(<project2/.git/objects/info/alternates)" = "$TMPTEST/repo-mirrors/default/repos/project2.git/objects" ]
[ -f project1/project1-1/.git/objects/info/alternates ]
[ "$(<project1/project1-1/.git/objects/info/alternates)" = "$TMPTEST/repo-mirrors/default/repos/project1-1.git/objects" ]

# Verify that objects are not there but in the mirror actually
obj=$(env GIT_DIR=project1/.git git rev-parse HEAD)
[ ! -f project1/.git/objects/${obj::2}/${obj:2} ]
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1.git/objects/${obj::2}/${obj:2} ]
obj=$(env GIT_DIR=project2/.git git rev-parse HEAD)
[ ! -f project2/.git/objects/${obj::2}/${obj:2} ]
[ -f "$TMPTEST"/repo-mirrors/default/repos/project2.git/objects/${obj::2}/${obj:2} ]
obj=$(env GIT_DIR=project1/project1-1/.git git rev-parse HEAD)
[ ! -f project1/project1-1/.git/objects/${obj::2}/${obj:2} ]
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1-1.git/objects/${obj::2}/${obj:2} ]


