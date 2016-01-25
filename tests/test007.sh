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

TEST_CASE="repo-mirror command line interface"

# Version check
$REPO_MIRROR --version | tee version.out
head -n1 <version.out | grep -qc '^repo-mirror version '

# Help check
$REPO_MIRROR --help | tee help.out
head -n1 <help.out | grep -qc '^Usage: repo-mirror '

# Dry run check
$REPO_MIRROR --mirror-dir=$PWD/undef --dry-run -- init -u ssh://undef/undef -m undef.xml -- 2>&1 | tee dry-run.out
grep '^INFO: ' dry-run.out | grep -qwc 'repo init .* --mirror --'
[ ! -d $PWD/undef ] # must not be created

# Repo option. Check that the repo executable passed is actually used.
$REPO_MIRROR --repo=echo -- hello | tee repo.out
head -n1 <repo.out | grep -qc '^hello$'

# Check reporting of bad arguments options. Fake repo tool for these.
res=0
$REPO_MIRROR --repo=echo --  2>&1 | tee args.out || res=$?
[ "$res" = 125 ]
head -n1 <args.out | grep -qc 'missing repo arguments'

res=0
$REPO_MIRROR --repo=echo --timeout -1 -- hello 2>&1 | tee args.out || res=$?
[ "$res" = 125 ]
head -n1 <args.out | grep -qc 'invalid timeout'

res=0
$REPO_MIRROR --repo=echo --internal-locking=none -- hello 2>&1 | tee args.out || res=$?
[ "$res" = 0 ]

res=0
$REPO_MIRROR --repo=echo --internal-locking=path -- hello 2>&1 | tee args.out || res=$?
[ "$res" = 0 ]

res=0
$REPO_MIRROR --repo=echo --internal-locking=foo -- hello 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'invalid locking'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --list 2>&1 | tee args.out || res=$?
[ "$res" = 0 ]

res=0
$REPO_MIRROR --list 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'missing mirror dir argument'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --repo=echo --list -- hello 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'unexpected additional arguments'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --clean 2>&1 | tee args.out || res=$?
[ "$res" = 0 ]

res=0
$REPO_MIRROR --clean 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'missing mirror dir argument'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --repo=echo --clean -- hello 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'unexpected additional arguments'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --clean-all 2>&1 | tee args.out || res=$?
[ "$res" = 0 ]

res=0
$REPO_MIRROR --clean-all 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'missing mirror dir argument'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --repo=echo --clean-all -- hello 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc 'unexpected additional arguments'
[ "$res" = 125 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --list --debug 3>&1 >&2 2>&3 | tee args.out || res=$?
grep -qc '^DEBUG:' <args.out
[ "$res" = 0 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --list --debug --log-file='&stdout' | tee args.out || res=$?
grep -qc '^DEBUG:' <args.out
[ "$res" = 0 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --list --debug --log-file=args.out
grep -qc '^DEBUG:' <args.out
[ "$res" = 0 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --list --debug --log-file=/undef/args.out 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc "can't open log file"
[ "$res" = 125 ]

res=0
$REPO_MIRROR --repo=/undef -- hello 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc "failed to run command"
[ "$res" = 127 ]

touch nonexec
res=0
$REPO_MIRROR --repo=$PWD/nonexec -- hello 2>&1 | tee args.out || res=$?
head -n1 <args.out | grep -qc "failed to run command"
[ "$res" = 126 ]

res=0
$REPO_MIRROR --mirror-dir=$PWD/repo-mirror --list --id=myid || res=$?
[ "$res" = 0 ]

$REPO_MIRROR --repo=sleep -- 100 >args.out 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
  kill -INT $pid
  sleep 1
done
res=0
wait $pid || res=$?
[ "$res" = 130 ]
cat <args.out
grep -qc "interrupted by signal 2" <args.out
