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

TEST_CASE="repo-mirror rewrite short ssh urls"

# Verify that -u/--manifest-url options are correctly rewritten
$REPO_MIRROR --dry-run -m "$TMPTEST/repo-mirrors"  -- init -u foo@host.com:manifests.git </dev/null 2>test.log
grep -qwc 'repo init -u ssh://foo@host.com/manifests.git' test.log
$REPO_MIRROR --dry-run -m "$TMPTEST/repo-mirrors"  -- init -ufoo@host.com:manifests.git </dev/null 2>test.log
grep -qwc 'repo init -ussh://foo@host.com/manifests.git' test.log
$REPO_MIRROR --dry-run -m "$TMPTEST/repo-mirrors"  -- init --manifest-url foo@host.com:manifests.git </dev/null 2>test.log
grep -qwc 'repo init --manifest-url ssh://foo@host.com/manifests.git' test.log
$REPO_MIRROR --dry-run -m "$TMPTEST/repo-mirrors"  -- init --manifest-url=foo@host.com:manifests.git </dev/null 2>test.log
grep -qwc 'repo init --manifest-url=ssh://foo@host.com/manifests.git' test.log

# Verify that -u options with well formed ssh URI is not rewritten
$REPO_MIRROR --dry-run -m "$TMPTEST/repo-mirrors"  -- init -u ssh://foo@host.com/manifests.git </dev/null 2>test.log
grep -qwc 'repo init -u ssh://foo@host.com/manifests.git' test.log
