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

SHELL=/bin/sh
REPO_MIRROR:=$(abspath ../repo-mirror)
TESTS:=$(wildcard test*.sh)
DEBUGTEST=
V=

BINDIR=$(abspath ./bin)
WGET=wget
DEPENDENCIES=repo
DL_URL_repo=http://storage.googleapis.com/git-repo-downloads/repo-1.21


help:
	@echo "usage: make TARGET [PARAMETERS]"
	@echo
	@echo "where TARGET is one of:"
	@echo "make all       : run unit tests"
	@echo "make check     : same as make all"
	@echo "make clean     : clean build and tests"
	@echo "make distclean : clean evrything"
	@echo "make dependencies : force download of all dependencies"
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

dependencies: $(DEPENDENCIES:%=dependencies-%.chk)

$(DEPENDENCIES:%=dependencies-%.chk): dependencies-%.chk:
	$(Q)rm -f dependencies-$*.stamp && $(MAKE) dependencies-$*.stamp

$(DEPENDENCIES:%=dependencies-%.stamp): dependencies-%.stamp:
	@echo "Downloading $* from $(DL_URL_$*)"
	$(Q)$(WGET) $(DL_URL_$*) -O dependencies-$*.tmp
	$(Q)chmod 755 dependencies-$*.tmp
	$(Q)mkdir -p $(BINDIR)
	$(Q)mv dependencies-$*.tmp /$(BINDIR)/$*
	$(Q)touch dependencies-$*.stamp

.PHONY: help all check clean distclean _unittests $(TESTS:%=%.chk) dependencies $(DEPENDENCIES:%=dependencies-%.chk)

ifeq ($(V),)
Q=@
else
Q=
endif
