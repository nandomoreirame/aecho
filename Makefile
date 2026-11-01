.PHONY: test lint install uninstall

PREFIX ?= $(HOME)/.local

test:
	bats tests

lint:
	shellcheck aecho install.sh

install:
	./install.sh --prefix "$(PREFIX)"

uninstall:
	./install.sh --prefix "$(PREFIX)" --uninstall
