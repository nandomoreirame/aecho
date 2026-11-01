# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## [0.1.0] - 2026-11-01

### Added

- Add `aecho`, a single Bash file that prints text as a 5-row block-letter banner with no figlet or other dependency.
- Read text from arguments (joined like `echo`) or from stdin, with one banner per input line.
- Wrap long text at word boundaries to `$COLUMNS` or the terminal width.
- Render lowercase and pt-BR accented letters with their uppercase base glyph, and unknown characters as `?`.
- Add `-c CHAR` to swap the fill character, plus `-h` and `-v`.
- Add `install.sh` to install into `~/.local/bin` (or `--prefix DIR`) from a clone or via `curl | bash`, with `--uninstall` and an AECHO banner as a post-install smoke test.
- Add a README with install, usage, flags and security notes, under the MIT license.
- Add CI that runs shellcheck and the bats test suite on every push and pull request.

---
