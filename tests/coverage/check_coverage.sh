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
# Usage: check_coverage.sh
#

set -eu
set -o pipefail

SRCDIR=$(dirname "$(readlink -e "$0")")
STRICT_COVERAGE="${STRICT_COVERAGE:-0}"
PYTHON_COVERAGE_DIR="${PYTHON_COVERAGE_DIR:-$PWD}"

[ -d "$PYTHON_COVERAGE_DIR" ]

cd "$PYTHON_COVERAGE_DIR"

# look at uncovered code (not ignoring #pragma uncovered)
coverage report --rcfile="$SRCDIR"/coverage.rc > coverage.txt

uncovered=$(cat coverage.txt | tail -1 | awk '{print ($3)}')

if [ "$uncovered" -ne 0 ]; then
    # print lines not covered and not ignored using pragma
    echo "COVERAGE_ERROR: non covered code:"
    while read line; do
	[ `echo $line | grep "%" | wc -l` -eq 0 ] \
	    && continue
	[ `echo $line | grep TOTAL | wc -l` -ne 0 ] \
	    && continue
	[ `echo $line | grep "100.0%" | wc -l` -ne 0 ] \
	    && continue
	module=$(basename $(echo "$line" | awk '{ print $1 }'))
	cover=$(echo "$line" | awk '{ print $NF }')
	echo "  partially covered module: $module, cover: $cover"
    done < coverage.txt
fi

echo "check_coverage_status: $uncovered"

[ "$STRICT_COVERAGE" != 1 ] || exit $uncovered
