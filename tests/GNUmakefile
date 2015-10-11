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
srcdir:=$(dir $(firstword $(MAKEFILE_LIST)))
testdir:=.
REPO_MIRROR:=$(abspath $(srcdir)../repo-mirror)
TESTS:=$(sort $(notdir $(wildcard $(srcdir)test*.sh)))
DEBUGTEST=
KEEPTEST=
KEEPFAIL=
V=
COVERAGE=
COVERAGE_HTML=
STRICT_COVERAGE=0

PYTHON_COVERAGE_DIR=$(abspath $(testdir))/coverage
ifneq ($(COVERAGE),)
PYTHON_COVERAGE=1
COVERAGE_OPTS=PYTHONPATH=$(PYTHONPATH):$(abspath $(srcdir))/coverage
COVERAGE_OPTS+=PYTHON_COVERAGE=$(PYTHON_COVERAGE)
COVERAGE_OPTS+=PYTHON_COVERAGE_DIR=$(PYTHON_COVERAGE_DIR)
endif

LOCAL_BUILD=$(abspath ./build)
LOCAL_PREFIX=$(abspath ./local)
LOCAL_BINDIR=$(LOCAL_PREFIX)/bin
WGET=wget
DEPENDENCIES_BINFILE=repo
DEPENDENCIES_GNUPKG=parallel
DEPENDENCIES=$(DEPENDENCIES_BINFILE) $(DEPENDENCIES_GNUPKG)
DL_URL_repo=http://storage.googleapis.com/git-repo-downloads/repo-1.21
DL_URL_parallel=http://ftp.gnu.org/gnu/parallel/parallel-20150522.tar.bz2

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
	@echo "DEBUGTEST='$(DEBUGTEST)' activate output of test trace and log if set"
	@echo "KEEPFAIL='$(KEEPFAIL)' keep test dir locally if the test fails when set"
	@echo "KEEPTEST='$(KEEPTEST)' always keep test dir locally when set"
	@echo "COVERAGE='$(COVERAGE)' activate coverage of test trace and log if set"
	@echo "STRICT_COVERAGE='$(STRICT_COVERAGE)' fail if not 100% line covered "
	@echo "V='$(V)' activate output of make commands if set"


all: _unittests

check: _unittests

clean:
	@echo "Cleaning temp files"
	$(Q)rm -rf *.log *.stamp *.tmp *.dir $(LOCAL_PREFIX) $(LOCAL_BUILD) $(PYTHON_COVERAGE_DIR)/.coverage* $(PYTHON_COVERAGE_DIR)/coverage.txt $(PYTHON_COVERAGE_DIR)/html


distclean: clean

_unittests:
	$(Q)[ "$(COVERAGE)" = "" ] || (rm -rf $(PYTHON_COVERAGE_DIR)/.coverage* $(PYTHON_COVERAGE_DIR)/coverage.txt && mkdir -p $(PYTHON_COVERAGE_DIR))
	$(Q)$(MAKE) $(TESTS:%=%.chk)
	$(Q)[ "$(COVERAGE)" = "" ] || (cd $(PYTHON_COVERAGE_DIR) && coverage combine)
	$(Q)[ "$(COVERAGE_HTML)" = "" ] || (cd $(PYTHON_COVERAGE_DIR) && ./report_coverage_html.sh)
	$(Q)[ "$(COVERAGE)" = "" ] || (cd $(PYTHON_COVERAGE_DIR) && env STRICT_COVERAGE=$(STRICT_COVERAGE) ./check_coverage.sh)

$(TESTS:%=%.chk): %.chk: %
	@echo "Executing test: $*"
	$(Q)env PATH="$(LOCAL_BINDIR):$$PATH" DEBUGTEST="$(DEBUGTEST)" REPO_MIRROR="$(REPO_MIRROR)" $(COVERAGE_OPTS) ./$*

$(TESTS:%=%.chk):  $(DEPENDENCIES:%=dependencies-%.stamp)

dependencies: $(DEPENDENCIES:%=dependencies-%.chk)

$(DEPENDENCIES:%=dependencies-%.chk): dependencies-%.chk:
	$(Q)rm -f dependencies-$*.stamp && $(MAKE) dependencies-$*.stamp

$(DEPENDENCIES_BINFILE:%=dependencies-%.stamp): dependencies-%.stamp:
	@echo "Downloading $* from $(DL_URL_$*)"
	$(Q)$(WGET) $(DL_URL_$*) -O dependencies-$*.tmp
	$(Q)chmod 755 dependencies-$*.tmp
	$(Q)mkdir -p $(LOCAL_BINDIR)
	$(Q)mv dependencies-$*.tmp /$(LOCAL_BINDIR)/$*
	$(Q)touch dependencies-$*.stamp

$(DEPENDENCIES_GNUPKG:%=dependencies-%.stamp): dependencies-%.stamp:
	@echo "Downloading $* from $(DL_URL_$*)"
	$(Q)$(WGET) $(DL_URL_$*) -O dependencies-$*.tmp
	$(Q)rm -rf $(LOCAL_BUILD)/$*
	$(Q)mkdir -p $(LOCAL_BUILD)/$*
	$(Q)tar xf dependencies-$*.tmp --strip-component=1 -C $(LOCAL_BUILD)/$*
	$(Q)rm -f dependencies-$*.tmp
	$(Q)(cd $(LOCAL_BUILD)/$* && ./configure --prefix=$(LOCAL_PREFIX))
	$(Q)(cd $(LOCAL_BUILD)/$* && make all)
	$(Q)(cd $(LOCAL_BUILD)/$* && make install)
	$(Q)touch dependencies-$*.stamp

.PHONY: help all check clean distclean _unittests $(TESTS:%=%.chk) dependencies $(DEPENDENCIES:%=dependencies-%.chk)

ifeq ($(V),)
Q=@
else
Q=
endif
