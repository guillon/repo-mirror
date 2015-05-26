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
DEBUGTEST=
V=

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
	rm -f test*.log test*.dir

distclean: clean

_unittests: $(TESTS:%=%.chk)

$(TESTS:%=%.chk): %.chk: %
	@echo "Executing test: $*"
	$(Q)if [ "$(DEBUGTEST)" = "" ]; then \
	  env DEBUGTEST=$(DEBUGTEST) REPO_MIRROR=$(REPO_MIRROR) ./$*; \
	else \
	  res=0; \
	  env DEBUGTEST=$(DEBUGTEST) REPO_MIRROR=$(REPO_MIRROR) ./$* || res=$$?; \
	  [ $$res = 0 ] || cat $*.log | sed 's/^/  |/'; \
	  exit $$res; \
	fi

.PHONY: help all check clean distclean _unittests $(TESTS:%=%.chk)

ifeq ($(V),)
Q=@
else
Q=
endif
