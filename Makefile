EMACS ?= emacs

.PHONY: test

test:
	$(EMACS) -Q --batch -L . -l palimpsest-test.el -f ert-run-tests-batch-and-exit
