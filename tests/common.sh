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

# common setup for unit tests

set -e

DIRNAME="$(dirname "$(readlink -e "$0")")"
TEST="$(basename "$0")"
SRCDIR="${SRCDIR:-$(readlink -e "$DIRNAME/..")}"
REPO_MIRROR="${REPO_MIRROR:-$SRCDIR/repo-mirror}"
TMPDIR="${TMPDIR:-/tmp}"
KEEPTEST="${KEEPTEST:-0}"
KEEPFAIL="${KEEPFAIL:-0}"
_skipped=0

test_cleanup() {
  : # Override this function in the test if some local cleanup is needed
}

cleanup() {
  local exit=$?
  set +x
  trap - INT QUIT TERM EXIT
  test_cleanup
  cd "$TMPDIR" # ensure not in TMPTEST before cleaning
  [ -d "$TMPTEST" ] && [ "$KEEPTEST" = 0 ] && [ "$KEEPFAIL" = 0 -o $exit = 0 ] && rm -rf "$TMPTEST"
  [ $exit != 0 -o $_skipped = 1 ] || success
  [ $exit = 0 -o $exit -ge 128 ] || failure
  [ $exit = 0 -o $exit -lt 128 ] || interrupted && trap - EXIT && exit $exit
}

exec {_fd_out}>&1 {_fd_err}>&2 >"$TEST.log" 2>&1
trap "cleanup" INT QUIT TERM EXIT

interrupted() {
  set +x
  echo "***INTERRUPTED: $TEST: $TEST_CASE" >&$_fd_out
}

failure() {
  set +x
  local reason=${1+": $1"}
  echo "***FAIL: $TEST: $TEST_CASE$reason" >&$_fd_out
}

success() {
  set +x
  echo "SUCCESS: $TEST: $TEST_CASE" >&$_fd_out
}

skip() {
  set +x
  local reason=${1+": $1"}
  echo "---SKIP: $TEST: $TEST_CASE$reason" >&$_fd_out
  _skipped=1
  exit 0
}

rm -rf "$TEST.dir"
[ "$KEEPTEST" != 0 -o "$KEEPFAIL" != 0 ] || TMPTEST=$(mktemp -d $TMPDIR/repo-mirror.XXXXXX)
[ "$KEEPTEST" = 0 -a "$KEEPFAIL" = 0 ] || TMPTEST=$(mkdir -p "$TEST.dir" && echo "$PWD/$TEST.dir")
[ "$KEEPTEST" = 0 -a "$KEEPFAIL" = 0 ] || echo "Keeping test directory in: $TMPTEST" >&$_fd_out
[ "$DEBUGTEST" = "" ] || PS4='+ $0: ${FUNCNAME+$FUNCNAME :}$LINENO: '
[ "$DEBUGTEST" = "" ] || set -x
cd "$TMPTEST"


