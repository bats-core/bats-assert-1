# assert_output
# =============
#
# Summary: Fail if `$output` or `$stderr` (with --use-stderr) does not match the expected output.
#
# Usage: assert_output [-p | -e] [--use-stderr] [- | [--] <expected>]
#
# Options:
#   -p, --partial  Match if `expected` is a substring of `$output` or `$stderr`
#   -e, --regexp   Treat `expected` as an extended regular expression
#   -, --stdin     Read `expected` value from STDIN
#   --use-stderr   Compare against `$stderr` instead of `$output`
#   <expected>     The expected value, substring or regular expression
#
# IO:
#   STDIN - [=$1] expected output
#   STDERR - details, on failure
#            error message, on error
# Globals:
#   output
#   stderr
# Returns:
#   0 - if output matches the expected value/partial/regexp
#   1 - otherwise
#
# This function verifies that a command or function produces the expected output.
# (It is the logical complement of `refute_output`.)
# Output matching can be literal (the default), partial or by regular expression.
# The expected output can be specified either by positional argument or read from STDIN by passing the `-`/`--stdin` flag.
#
# ## Literal matching
#
# By default, literal matching is performed.
# The assertion fails if `$output` does not equal the expected output.
#
#   ```bash
#   @test 'assert_output()' {
#     run echo 'have'
#     assert_output 'want'
#   }
#
#   @test 'assert_output() with pipe' {
#     run echo 'hello'
#     echo 'hello' | assert_output -
#   }
#
#   @test 'assert_output() with herestring' {
#     run echo 'hello'
#     assert_output - <<< hello
#   }
#   ```
#
# On failure, the expected and actual output are displayed.
#
#   ```
#   -- output differs --
#   expected : want
#   actual   : have
#   --
#   ```
#
# ## Existence
#
# To assert that any output exists at all, omit the `expected` argument.
#
#   ```bash
#   @test 'assert_output()' {
#     run echo 'have'
#     assert_output
#   }
#   ```
#
# On failure, an error message is displayed.
#
#   ```
#   -- no output --
#   expected non-empty output, but output was empty
#   --
#   ```
#
# ## Partial matching
#
# Partial matching can be enabled with the `--partial` option (`-p` for short).
# When used, the assertion fails if the expected _substring_ is not found in `$output`.
#
#   ```bash
#   @test 'assert_output() partial matching' {
#     run echo 'ERROR: no such file or directory'
#     assert_output --partial 'SUCCESS'
#   }
#   ```
#
# On failure, the substring and the output are displayed.
#
#   ```
#   -- output does not contain substring --
#   substring : SUCCESS
#   output    : ERROR: no such file or directory
#   --
#   ```
#
# ## Regular expression matching
#
# Regular expression matching can be enabled with the `--regexp` option (`-e` for short).
# When used, the assertion fails if the *extended regular expression* does not match `$output`.
#
# *__Note__:
# The anchors `^` and `$` bind to the beginning and the end (respectively) of the entire output;
# not individual lines.*
#
#   ```bash
#   @test 'assert_output() regular expression matching' {
#     run echo 'Foobar 0.1.0'
#     assert_output --regexp '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
#   }
#   ```
#
# On failure, the regular expression and the output are displayed.
#
#   ```
#   -- regular expression does not match output --
#   regexp : ^Foobar v[0-9]+\.[0-9]+\.[0-9]$
#   output : Foobar 0.1.0
#   --
#   ```
#
# ## Using --use-stderr
#
# The `--use-stderr` option directs `assert_output` to match against `$stderr` instead of `$output`.
# This is useful for verifying error messages or other content written to standard error.
#
#   ```bash
#   @test 'assert_output() with --use-stderr' {
#     run --separate-stderr bash -c 'echo "error message" >&2'
#     assert_output --use-stderr 'error message'
#   }
#   ```
#
# On failure, the expected and actual stderr values are displayed.
assert_output() {
  local -i is_mode_partial=0
  local -i is_mode_regexp=0
  local -i is_mode_nonempty=0
  local -i use_stdin=0
  local -i use_stderr=0

  # Handle options.
  if (( $# == 0 )); then
    is_mode_nonempty=1
  fi

  while (( $# > 0 )); do
    case "$1" in
    -p|--partial) is_mode_partial=1; shift ;;
    -e|--regexp) is_mode_regexp=1; shift ;;
    --use-stderr) use_stderr=1; shift ;;
    -|--stdin) use_stdin=1; shift ;;
    --) shift; break ;;
    *) break ;;
    esac
  done

  if (( use_stderr )); then
    : "${stderr?}"
  else
    : "${output?}"
  fi

  if (( is_mode_partial )) && (( is_mode_regexp )); then
    echo "\`--partial' and \`--regexp' are mutually exclusive" \
    | batslib_decorate 'ERROR: assert_output' \
    | fail
    return $?
  fi

  # Arguments.
  local expected
  if (( use_stdin )); then
    expected="$(cat -)"
  else
    expected="${1-}"
  fi

  # Determine the source of output (stdout or stderr).
  local actual_output
  if (( use_stderr )); then
    actual_output="$stderr"
  else
    actual_output="$output"
  fi

  # Matching.
  if (( is_mode_nonempty )); then
    if [ -z "$actual_output" ]; then
      echo 'expected non-empty output, but output was empty' \
      | batslib_decorate 'no output' \
      | fail
    fi
  elif (( is_mode_regexp )); then
    if [[ '' =~ $expected ]] || (( $? == 2 )); then
      echo "Invalid extended regular expression: \`$expected'" \
      | batslib_decorate 'ERROR: assert_output' \
      | fail
    elif ! [[ $actual_output =~ $expected ]]; then
      batslib_print_kv_single_or_multi 6 \
      'regexp'  "$expected" \
      'output' "$actual_output" \
      | batslib_decorate 'regular expression does not match output' \
      | fail
    fi
  elif (( is_mode_partial )); then
    if [[ $actual_output != *"$expected"* ]]; then
      batslib_print_kv_single_or_multi 9 \
      'substring' "$expected" \
      'output'    "$actual_output" \
      | batslib_decorate 'output does not contain substring' \
      | fail
    fi
  else
    if [[ $actual_output != "$expected" ]]; then
      batslib_print_kv_single_or_multi 8 \
      'expected' "$expected" \
      'actual'   "$actual_output" \
      | batslib_decorate 'output differs' \
      | fail
    fi
  fi
}
