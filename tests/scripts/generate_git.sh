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

#
# Generates a populated bare git in a new directory.
# The Generated git is a simple tree with a README
# and optional additional files that can be used/cloned
# for testing purpose.
#
# usage: generate-git <bare_git_path> [added files...]
#
# Example:
# $ ./generate-git test.git default.xml
# $ git clone test.git test
#

set -eu
set -o pipefail

dir=${1?}
shift
function cleanup() 
{
  local code=$?
  trap - INT TERM QUIT EXIT
  [ ! -d "${tmpdir:-}" ] || rm -rf "$tmpdir"
  exit $code
}
trap cleanup INT TERM QUIT EXIT

tmpdir=$(mktemp -d)

# Clean and create bare empty git
rm -rf "$dir"
mkdir -p "$dir"
pushd "$dir" >/dev/null
git init --bare --quiet
popd >/dev/null

# Create working git
pushd "$tmpdir" >/dev/null
git init --quiet
echo "Test GIT tree $dir" >README
[ $# = 0 ] || cp -a "$@" .
git add --all
git commit --quiet -m "$(<README)"
popd >/dev/null

# Push to bare git
res=0
# Need to redirect stderr to make it fully quiet (--quiet does not make remote quiet as well)
env GIT_DIR="$tmpdir/.git" git push --quiet "file://$(readlink -e "$dir")" master 2>$tmpdir/push.err || res=$?
cat <$tmpdir/push.err >&2
exit $res
