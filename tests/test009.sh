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

TEST_CASE="repo-mirror repo-mirror prune local branches"

# Skip python 3 not supported by repo
! is_python3 || skip "python 3 not supported by repo"

# Generate a repo/git structure
$SRCDIR/tests/scripts/generate_repo.sh repos project1

# Repo init/sync and verify tree with repo-mirror
mkdir -p repo-mirrors
mkdir -p test-repo
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- sync
[ -f project1/README ]
popd >/dev/null

# Clone project1 and add a branch
git clone $TMPTEST/repos/project1.git
pushd project1 >/dev/null
git push origin HEAD:iso/dev
popd >/dev/null

# Re-execute the mirror init/sync with new branch iso/dev
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
# Skip local repo sync as pruning is not supported by repo itself
#$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- sync
popd >/dev/null

# Delete iso/dev and push iso/dev/user
pushd project1 >/dev/null
git push --force origin :iso/dev
git push --force origin HEAD:iso/dev/user
popd >/dev/null

# Re-execute the mirror init/sync with new branch iso/dev/user
# This generate a local branch conflict (dir->file) unless fetch with prune is used
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
# Skip local repo sync as pruning is not supported by repo itself
#$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- sync
popd >/dev/null

# Delete iso/dev/user and push iso/dev
pushd project1 >/dev/null
git push --force origin :iso/dev/user
git push --force origin HEAD:iso/dev
popd >/dev/null

# Re-execute the mirror init/sync with new branch iso/dev
# This generate a local branch conflict (file->dir) unless fetch with prune is used
pushd test-repo >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- init -u file://"$TMPTEST"/repos/manifests.git </dev/null
# Skip local repo sync as pruning is not supported by repo itself
#$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -- sync
popd >/dev/null
