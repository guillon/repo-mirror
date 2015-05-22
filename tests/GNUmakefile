#
# Copyright (c) STMicroelectronics 2014
#
# This file is part of git-mirror.
#
# git-mirror is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License v2.0
# as published by the Free Software Foundation
#
# git-mirror is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# v2.0 along with git-mirror. If not, see <http://www.gnu.org/licenses/>.
#

SHELL=/bin/sh
REPO_MIRROR:=$(abspath ../repo-mirror)
TESTS:=$(wildcard test*.sh)

help:
	@echo "usage: make TARGET [PARAMETERS]"
	@echo
	@echo "where TARGET is one of:"
	@echo "make all       : run unit tests"
	@echo "make check     : same as make all"
	@echo "make clean     : clean build and tests"
	@echo "make distclean : clean evrything"
	@echo
	@echo "where PAREMETERS is one of (current values):"
	@echo "PTIMEOUT=$(PTIMEOUT)"
	@echo "TESTS=$(TESTS)"


all: _unittests

check: _unittests

clean:
	rm -f test*.out test*.err test*.dir

distclean: clean

_unittests: $(TESTS:%=%.chk)

$(TESTS:%=%.chk): %.chk: %
	env REPO_MIRROR=$(REPO_MIRROR) ./$*

.PHONY: help all check clean distclean _unittests $(TESTS:%=%.chk)
