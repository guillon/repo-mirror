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
# Usage: report_coverage_html.sh
#

set -eu
set -o pipefail

SRCDIR=$(dirname "$(readlink -e "$0")")
PYTHON_COVERAGE_DIR="${PYTHON_COVERAGE_DIR:-$PWD}"

[ -d "$PYTHON_COVERAGE_DIR" ]

cd "$PYTHON_COVERAGE_DIR"

coverage html -d html --rcfile="$SRCDIR"/coverage.rc
