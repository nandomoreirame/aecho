#!/usr/bin/env bats

# Unit tests for install.sh
#
# Run:
#   bats tests
#
# Coverage:
#   - From a clone it copies the local aecho into PREFIX/bin as an executable
#   - Piped (no local aecho next to the script) it downloads from AECHO_URL
#   - A failed download leaves no partial binary behind
#   - --uninstall removes the binary and is a no-op when it is absent
#   - A bin dir missing from PATH gets a warning; bad options fail
#
# Downloads use a file:// AECHO_URL, so the tests never touch the network.

bats_require_minimum_version 1.5.0

SCRIPT="$BATS_TEST_DIRNAME/../install.sh"
AECHO="$BATS_TEST_DIRNAME/../aecho"

setup() {
    PREFIX="$BATS_TEST_TMPDIR/prefix"
}

@test "install: copies the local aecho into PREFIX/bin" {
    run bash "$SCRIPT" --prefix "$PREFIX"
    [ "$status" -eq 0 ]
    [ -x "$PREFIX/bin/aecho" ]
    cmp -s "$AECHO" "$PREFIX/bin/aecho"
}

@test "install: greets with an AECHO banner rendered by the installed binary" {
    run bash "$SCRIPT" --prefix "$PREFIX"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$("$PREFIX/bin/aecho" AECHO)"* ]]
    [[ "$output" == *"Installed $PREFIX/bin/aecho"* ]]
}

@test "install: separates the banner from the command line with a blank line" {
    run --keep-empty-lines bash "$SCRIPT" --prefix "$PREFIX"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "" ]
    [ "${lines[1]}" = "$("$PREFIX/bin/aecho" AECHO | head -n1)" ]
}

@test "install: downloads from AECHO_URL when there is no local aecho" {
    cp "$SCRIPT" "$BATS_TEST_TMPDIR/install.sh"
    AECHO_URL="file://$AECHO" run bash "$BATS_TEST_TMPDIR/install.sh" --prefix "$PREFIX"
    [ "$status" -eq 0 ]
    [ -x "$PREFIX/bin/aecho" ]
    cmp -s "$AECHO" "$PREFIX/bin/aecho"
}

@test "install: works when piped into bash" {
    run bash -c "AECHO_URL='file://$AECHO' bash -s -- --prefix '$PREFIX' < '$SCRIPT'"
    [ "$status" -eq 0 ]
    cmp -s "$AECHO" "$PREFIX/bin/aecho"
}

@test "install: a failed download fails and leaves nothing installed" {
    cp "$SCRIPT" "$BATS_TEST_TMPDIR/install.sh"
    AECHO_URL="file://$BATS_TEST_TMPDIR/missing" run bash "$BATS_TEST_TMPDIR/install.sh" --prefix "$PREFIX"
    [ "$status" -ne 0 ]
    [ ! -e "$PREFIX/bin/aecho" ]
}

@test "install: --uninstall removes the binary" {
    bash "$SCRIPT" --prefix "$PREFIX"
    run bash "$SCRIPT" --prefix "$PREFIX" --uninstall
    [ "$status" -eq 0 ]
    [ ! -e "$PREFIX/bin/aecho" ]
}

@test "install: --uninstall without an installed binary is a no-op" {
    run bash "$SCRIPT" --prefix "$PREFIX" --uninstall
    [ "$status" -eq 0 ]
}

@test "install: warns when the bin dir is not on PATH" {
    PATH="/usr/bin:/bin" run bash "$SCRIPT" --prefix "$PREFIX"
    [ "$status" -eq 0 ]
    [[ "$output" == *"not on your PATH"* ]]
}

@test "install: no warning when the bin dir is on PATH" {
    PATH="$PREFIX/bin:/usr/bin:/bin" run bash "$SCRIPT" --prefix "$PREFIX"
    [ "$status" -eq 0 ]
    [[ "$output" != *"not on your PATH"* ]]
}

@test "install: unknown option fails with usage" {
    run bash "$SCRIPT" --nope
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: install.sh"* ]]
}
