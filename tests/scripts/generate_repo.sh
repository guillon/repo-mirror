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

set -eu
set -o pipefail

dirname=$(dirname "$0")
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

rm -rf "$dir"
mkdir -p "$dir"

# Create manifest header
cat >"$tmpdir"/default.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote fetch="." name="local"/>
  <default remote="local" revision="master"/>

EOF

# Create gits and include them in manifest
for pair in "$@"; do
  project=$(echo "$pair" | cut -f1 -d:)
  path=$(echo "$pair" | cut -f2 -d:)
  [ -n "$path" ] || path="$project"
  "$dirname"/generate_git.sh "$dir"/"$project".git
  echo "  <project name=\"$project\" path=\"$path\"/>" >>"$tmpdir"/default.xml
done

# Create manifest footer
cat >>"$tmpdir"/default.xml <<EOF
</manifest>
EOF

# Create manifests git
"$dirname"/generate_git.sh "$dir"/manifests.git "$tmpdir"/default.xml

