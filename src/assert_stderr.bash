# assert_stderr
# =============
#
# Summary: Fail if `$stderr' does not match the expected stderr.
#
# Usage: assert_stderr [-p | -e] [- | [--] <expected>]
#
# Options:
#   -p, --partial  Match if `expected` is a substring of `$stderr`
#   -e, --regexp   Treat `expected` as an extended regular expression
#   -, --stdin     Read `expected` value from STDIN
#   <expected>     The expected value, substring or regular expression
#
# IO:
#   STDIN - [=$1] expected stderr
#   STDERR - details, on failure
#            error message, on error
# Globals:
#   stderr
# Returns:
#   0 - if stderr matches the expected value/partial/regexp
#   1 - otherwise
#
# Similarly to `assert_output`, this function verifies that a command or function produces the expected stderr.
# (It is the logical complement of `refute_stderr`.)
# The stderr matching can be literal (the default), partial or by regular expression.
# The expected stderr can be specified either by positional argument or read from STDIN by passing the `-`/`--stdin` flag.
#
# ## Literal matching
#
# By default, literal matching is performed.
# The assertion fails if `$stderr` does not equal the expected stderr.
#
#   ```bash
#   echo_err() {
#     echo "$@" >&2
#   }
#
#   @test 'assert_stderr()' {
#     run echo_err 'have'
#     assert_stderr 'want'
#   }
#
#   @test 'assert_stderr() with pipe' {
#     run echo_err 'hello'
#     echo_err 'hello' | assert_stderr -
#   }
#
#   @test 'assert_stderr() with herestring' {
#     run echo_err 'hello'
#     assert_stderr - <<< hello
#   }
#   ```
#
# On failure, the expected and actual stderr are displayed.
#
#   ```
#   -- stderr differs --
#   expected : want
#   actual   : have
#   --
#   ```
#
# ## Existence
#
# To assert that any stderr exists at all, omit the `expected` argument.
#
#   ```bash
#   @test 'assert_stderr()' {
#     run echo_err 'have'
#     assert_stderr
#   }
#   ```
#
# On failure, an error message is displayed.
#
#   ```
#   -- no stderr --
#   expected non-empty stderr, but stderr was empty
#   --
#   ```
#
# ## Partial matching
#
# Partial matching can be enabled with the `--partial` option (`-p` for short).
# When used, the assertion fails if the expected _substring_ is not found in `$stderr`.
#
#   ```bash
#   @test 'assert_stderr() partial matching' {
#     run echo_err 'ERROR: no such file or directory'
#     assert_stderr --partial 'SUCCESS'
#   }
#   ```
#
# On failure, the substring and the stderr are displayed.
#
#   ```
#   -- stderr does not contain substring --
#   substring : SUCCESS
#   stderr    : ERROR: no such file or directory
#   --
#   ```
#
# ## Regular expression matching
#
# Regular expression matching can be enabled with the `--regexp` option (`-e` for short).
# When used, the assertion fails if the *extended regular expression* does not match `$stderr`.
#
# *__Note__:
# The anchors `^` and `$` bind to the beginning and the end (respectively) of the entire stderr;
# not individual lines.*
#
#   ```bash
#   @test 'assert_stderr() regular expression matching' {
#     run echo_err 'Foobar 0.1.0'
#     assert_stderr --regexp '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
#   }
#   ```
#
# On failure, the regular expression and the stderr are displayed.
#
#   ```
#   -- regular expression does not match stderr --
#   regexp : ^Foobar v[0-9]+\.[0-9]+\.[0-9]$
#   stderr : Foobar 0.1.0
#   --
#   ```
assert_stderr() {
  local -i is_mode_partial=0
  local -i is_mode_regexp=0
  local -i is_mode_nonempty=0
  local -i use_stdin=0
  : "${stderr?}"

  # Handle options.
  if (( $# == 0 )); then
    is_mode_nonempty=1
  fi

  while (( $# > 0 )); do
    case "$1" in
    -p|--partial) is_mode_partial=1; shift ;;
    -e|--regexp) is_mode_regexp=1; shift ;;
    -|--stdin) use_stdin=1; shift ;;
    --) shift; break ;;
    *) break ;;
    esac
  done

  if (( is_mode_partial )) && (( is_mode_regexp )); then
    echo "\`--partial' and \`--regexp' are mutually exclusive" \
    | batslib_decorate 'ERROR: assert_stderr' \
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

  # Matching.
  if (( is_mode_nonempty )); then
    if [ -z "$stderr" ]; then
      echo 'expected non-empty stderr, but stderr was empty' \
      | batslib_decorate 'no stderr' \
      | fail
    fi
  elif (( is_mode_regexp )); then
    if [[ '' =~ $expected ]] || (( $? == 2 )); then
      echo "Invalid extended regular expression: \`$expected'" \
      | batslib_decorate 'ERROR: assert_stderr' \
      | fail
    elif ! [[ $stderr =~ $expected ]]; then
      batslib_print_kv_single_or_multi 6 \
      'regexp'  "$expected" \
      'stderr' "$stderr" \
      | batslib_decorate 'regular expression does not match stderr' \
      | fail
    fi
  elif (( is_mode_partial )); then
    if [[ $stderr != *"$expected"* ]]; then
      batslib_print_kv_single_or_multi 9 \
      'substring' "$expected" \
      'stderr'    "$stderr" \
      | batslib_decorate 'stderr does not contain substring' \
      | fail
    fi
  else
    if [[ $stderr != "$expected" ]]; then
      batslib_print_kv_single_or_multi 8 \
      'expected' "$expected" \
      'actual'   "$stderr" \
      | batslib_decorate 'stderr differs' \
      | fail
    fi
  fi
}

