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
# Site script to be executed for activating coverage when running tests
#
# Usage:
#   env PYTHONPATH=$PYTHONPATH:<thisdir> PYTHON_COVERAGE_DIR=<coverage_dir> make check
#
# PYTHON_COVERAGE: must be true for activating coverage
# PYTHON_COVERAGE_DIR: if specified, this dir must exists and
#   contains as input the coverage.rc file and will contain
#   the generated .coverage* files.
#   If not specified, the current execution dir is used.
#

import os, atexit

coverage_enabled = bool(os.getenv("PYTHON_COVERAGE"))

if coverage_enabled:
    import coverage

    def cov_stop():
        cov.stop()
        cov.save()

    if os.getenv("PYTHON_COVERAGE_DIR"):
        coverage_dir = os.getenv("PYTHON_COVERAGE_DIR")
        coverage_file = os.path.join(coverage_dir, ".coverage")
        config_file = os.path.join(coverage_dir, "coverage.rc")
    else:
        coverage_file = ".coverage"
	config_file = "coverage.rc"
    cov = coverage.coverage(
	config_file=config_file,
        data_file=coverage_file,
        include="*/repo-mirror",
        data_suffix=True,
        branch=False)
    cov.start()
    atexit.register(cov_stop)
