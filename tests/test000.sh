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

TEST_CASE="repo-mirror dependencies test"

# Ouput some system infos for debug
echo "uname -a: $(uname -a)"
echo "free -m: $(free -m)"
echo "cpus: $(cat /proc/cpuinfo 2>/dev/null | grep -c '^processor' || true)"

# Check if net is accessible
wget http://www.google.com -O google.html

# Check whether git is installed
which git
git --version

# Check whether repo is installed (skip as not working on python 3)
if ! is_python3; then
  which repo
  mkdir repo-test
  pushd repo-test >/dev/null
  # init will fail as url is not specified, though it is fine for getting the repo version
  repo init || true
  repo --version
  popd >/dev/null
fi
