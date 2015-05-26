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
BINDIR=$(abspath ./bin)
DEBUGTEST=
V=

WGET=wget
REPO_DL_URL=http://storage.googleapis.com/git-repo-downloads/repo-1.21

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
	@echo "REPO_MIRROR='$(REPO_MIRROR)' path to repo-mirror to be tested"
	@echo "TESTS='$(TESTS)' explicit list of tests to run"
	@echo "DEBUGTEST='$(DEBUGTEST)' activate output of test trace and log if set "
	@echo "V='$(V)' activate output of make commands if set"


all: _unittests

check: _unittests

clean:
	@echo "Cleaning temp files"
	$(Q)rm -f *.log *.stamp *.tmp *.dir $(BINDIR)/*

distclean: clean

_unittests: $(TESTS:%=%.chk)

$(TESTS:%=%.chk): %.chk: %
	@echo "Executing test: $*"
	$(Q)env PATH="$(BINDIR):$$PATH" DEBUGTEST="$(DEBUGTEST)" REPO_MIRROR="$(REPO_MIRROR)" ./$*

$(TESTS:%=%.chk):  dependencies-repo.stamp

dependencies: dependencies-repo.chk

dependencies-repo.chk: %.chk:
	$(Q)rm -f $*.stamp && $(MAKE) $*.stamp

dependencies-repo.stamp: %.stamp:
	@echo "Downloading repo from $(REPO_DL_URL)"
	$(Q)$(WGET) $(REPO_DL_URL) -O $*.tmp
	$(Q)chmod 755 $*.tmp
	$(Q)mkdir -p $(BINDIR)
	$(Q)mv $*.tmp /$(BINDIR)/repo
	$(Q)touch $*.stamp

.PHONY: help all check clean distclean _unittests $(TESTS:%=%.chk)

ifeq ($(V),)
Q=@
else
Q=
endif
