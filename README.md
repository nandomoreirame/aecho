# aecho

`echo`, but as a big block-letter banner: one Bash file, no figlet, no dependencies.

```console
$ aecho "Hello!"
█   █ █████ █     █      ███  █
█   █ █     █     █     █   █ █
█████ ████  █     █     █   █ █
█   █ █     █     █     █   █
█   █ █████ █████ █████  ███  █
```

## Why

You want a loud header in a script's output, a terminal greeting or a "BUILD OK" you can spot from across the room. The usual tool, `figlet` (or `toilet`), is not installed on most machines and containers, so a script that calls it breaks or needs an extra package step. `aecho` is a single Bash file with its own font: copy it anywhere Bash 4 runs and it works.

Status: early (0.1.0). The font and flags may still change.

## Features

- Behaves like `echo`: arguments are joined with spaces, and it reads stdin when called without them.
- Long text wraps at word boundaries to fit your terminal instead of breaking the art.
- Portuguese text just works: `ação` renders as `ACAO` instead of garbage.
- Swap the `█` for any character (`-c '#'`) for logs or fonts without block glyphs.

## Install

Requires Bash 4 or newer and a UTF-8 terminal. Tested on Linux (glibc).

From a clone:

```bash
git clone https://github.com/nandomoreirame/aecho.git
cd aecho
./install.sh
aecho --version
```

Or in one line, without cloning (read [install.sh](install.sh) first, it is 90 lines):

```bash
curl -fsSL https://raw.githubusercontent.com/nandomoreirame/aecho/main/install.sh | bash
```

Both install to `~/.local/bin/aecho` and warn if that directory is not on your `PATH`. For a system-wide install use `sudo ./install.sh --prefix /usr/local`. Remove it with `./install.sh --uninstall` (same `--prefix` you installed with).

## Usage

```bash
aecho "Deploy done"           # banner from arguments
git branch --show-current | aecho   # banner from stdin
aecho -c '#' "Olá, 2026"      # custom fill character
```

```console
$ aecho -c '#' "Olá, 2026"
 ###  #      ###         ####   ###  ####   ###
#   # #     #   #            # #  ##     # #
#   # #     #####         ###  # # #  ###  ####
#   # #     #   #  #     #     ##  # #     #   #
 ###  ##### #   # #      #####  ###  #####  ###
```

| Flag | Default | Effect |
|---|---|---|
| `-c CHAR` | `█` | Fill character (first character of `CHAR`). |
| `-h`, `--help` | | Show usage. |
| `-v`, `--version` | | Print the version. |
| `--` | | End of options, so the text may start with `-`. |

Behavior worth knowing:

- **Characters:** A to Z, 0 to 9, space and `! ? . , : ; - _ + = ' " / ( ) * # < >`. Lowercase letters render in uppercase, accented letters (`á ã ç é õ ...`) use their base letter, and anything else renders as `?`.
- **Line breaks:** each input line becomes its own banner, separated by a blank line.
- **Width:** text wraps at `$COLUMNS`, then the terminal width from `tput cols`, then 80. A single word wider than that is printed unbroken.
- **Exit codes:** `0` on success, `2` for an unknown option.

### install.sh options

| Option | Default | Effect |
|---|---|---|
| `--prefix DIR` | `~/.local` | Installs to `DIR/bin/aecho`. |
| `--uninstall` | | Removes `DIR/bin/aecho`. |
| `AECHO_URL` (env) | `main` branch on GitHub | Where to download `aecho` when there is no local copy next to `install.sh`. |

## Development

```bash
make lint   # shellcheck aecho install.sh
make test   # bats tests
```

Tests use [bats-core](https://github.com/bats-core/bats-core) 1.5 or newer and never touch the network (downloads are tested with a `file://` URL). CI runs both targets on every push and pull request.

## Security

`aecho` reads its arguments or stdin and writes to stdout. It opens no files, makes no network calls and runs no external command except `tput cols` (terminal width) and `cat` (help text).

`install.sh` writes only to `PREFIX/bin` (default `~/.local/bin`, no root needed). From a clone it copies the local file and makes no network call. Without a clone it downloads `aecho` over HTTPS from the `main` branch of this repository, or from `AECHO_URL` if you set it. The download is not pinned to a release or checksum, so it trusts whatever `main` holds at that moment; it only rejects a file that does not start with a Bash shebang. If that matters to you, clone, review and run `./install.sh` instead of piping `curl` into `bash`.

Report vulnerabilities privately through [GitHub security advisories](https://github.com/nandomoreirame/aecho/security/advisories/new).

## Contributing

Issues and pull requests are welcome, new glyphs included. Keep glyphs 5 rows tall, add a test in [tests/aecho.bats](tests/aecho.bats), and run `make lint test` before opening the PR.

## Acknowledgements

Inspired by [FIGlet](http://www.figlet.org/), which has done this with real fonts since 1991.

## License

[MIT](LICENSE) © Fernando Moreira Costa
