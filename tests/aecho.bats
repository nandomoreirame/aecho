#!/usr/bin/env bats

# Unit tests for aecho
#
# Run:
#   bats tests
#
# Coverage:
#   - Arguments are joined with spaces like echo and rendered as a 5-row banner
#   - Lowercase and pt-BR accented letters render as their uppercase base glyph
#   - Unknown characters fall back to the '?' glyph instead of failing
#   - Text is read from stdin when no argument is given
#   - Each input line becomes its own banner block
#   - Words wrap to the terminal width (COLUMNS) instead of overflowing
#   - -c swaps the fill character; -h prints usage; -v prints the version;
#     bad options fail

bats_require_minimum_version 1.5.0

SCRIPT="$BATS_TEST_DIRNAME/../aecho"

@test "aecho: renders a single letter as a 5-row glyph" {
    run bash "$SCRIPT" H
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 5 ]
    [ "${lines[0]}" = "█   █" ]
    [ "${lines[2]}" = "█████" ]
    [ "${lines[4]}" = "█   █" ]
}

@test "aecho: separates glyphs with one blank column and trims trailing spaces" {
    run bash "$SCRIPT" HI
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "█   █ ███" ]
    [ "${lines[2]}" = "█████  █" ]
}

@test "aecho: joins multiple arguments with a space like echo" {
    run bash "$SCRIPT" H I
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "█   █     ███" ]
}

@test "aecho: lowercase and accented letters map to the uppercase glyph" {
    run bash "$SCRIPT" "hi"
    [ "$status" -eq 0 ]
    [ "$output" = "$(bash "$SCRIPT" "HI")" ]

    run bash "$SCRIPT" "ção"
    [ "$output" = "$(bash "$SCRIPT" "CAO")" ]
}

@test "aecho: unknown characters render as '?'" {
    run bash "$SCRIPT" "~"
    [ "$status" -eq 0 ]
    [ "$output" = "$(bash "$SCRIPT" "?")" ]
}

@test "aecho: reads stdin when called without arguments" {
    run bash -c "printf 'HI' | bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$output" = "$(bash "$SCRIPT" HI)" ]
}

@test "aecho: each input line becomes its own block separated by a blank line" {
    run --keep-empty-lines bash -c "printf 'H\nI\n' | bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 11 ]
    [ "${lines[0]}" = "█   █" ]
    [ "${lines[5]}" = "" ]
    [ "${lines[6]}" = "███" ]
}

@test "aecho: wraps words that do not fit in COLUMNS" {
    COLUMNS=12 run --keep-empty-lines bash "$SCRIPT" "HI HI"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 11 ]
    [ "${lines[0]}" = "█   █ ███" ]
    [ "${lines[6]}" = "█   █ ███" ]
}

@test "aecho: -c replaces the fill character" {
    run bash "$SCRIPT" -c '#' H
    [ "$status" -eq 0 ]
    [ "${lines[2]}" = "#####" ]
}

@test "aecho: -h prints usage" {
    run bash "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: aecho"* ]]
}

@test "aecho: -v prints the version" {
    run bash "$SCRIPT" -v
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^aecho\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "aecho: unknown option fails with usage on stderr" {
    run bash "$SCRIPT" -z
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: aecho"* ]]
}

@test "aecho: -- lets text start with a dash" {
    run --keep-empty-lines bash "$SCRIPT" -- -
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 5 ]
    [ "${lines[2]}" = "████" ]
}
