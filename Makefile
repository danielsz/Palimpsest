.PHONY:	all test unit ecukes install commpile clean-elc
CASK ?= cask
EMACS ?= emacs

all: test

test: test.unit test.ecukes

test.unit: clean-elc
	${CASK} exec ert-runner

test.ecukes:
	cask exec ecukes

compile:
	${CASK} exec ${EMACS} -Q -batch -f batch-byte-compile palimpsest.el

ert-runner-init:
	${CASK} exec ert-runner init

install:
	${CASK} install

clean-elc:
	rm -f f.elc
