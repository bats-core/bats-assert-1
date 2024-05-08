#!/usr/bin/env bats

load test_helper

bats_require_minimum_version 1.5.0

#
# assert_equals_golden
# Literal matching
#

@test "assert_equals_golden: succeeds if output and golden match" {
  run printf 'a'
  run assert_equals_golden "$output" <(printf 'a')
  assert_test_pass
}

@test "assert_equals_golden: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_equals_golden "$output" <(printf 'a\nb\nc')
  assert_test_pass
}

@test "assert_equals_golden: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_equals_golden "$output" <(printf 'a\n')
  assert_test_pass
}

@test "assert_equals_golden: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_equals_golden "$output" <(printf 'a\nb\nc\n')
  assert_test_pass
}

@test "assert_equals_golden: fails if output and golden do not match" {
  run printf 'b'
  run assert_equals_golden "$output" <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_equals_golden: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf 'a\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a

actual output (1 lines):
a
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf 'a\nb\nc\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (3 lines):
a
b
c

actual output (3 lines):
a
b
c
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
a

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf 'a\nb\nc')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (3 lines):
a
b
c
actual output (3 lines):
a
b
c

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_equals_golden "$output" <(printf '\n')

  assert_test_pass
}

@test "assert_equals_golden: fails if output is and golden are empty" {
  run :
  run assert_equals_golden "$output" <(:)

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_equals_golden: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_equals_golden --allow-empty "$output" <(:)

  assert_test_pass
}

@test "assert_equals_golden: succeeds if output is and golden are empty when allowed - kept empty lines" {
  run --keep-empty-lines :
  run assert_equals_golden --allow-empty "$output" <(:)

  assert_test_pass
}

@test "assert_equals_golden: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --allow-empty "$output" <(:)

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (0 lines):

actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails if output is empty with newline golden" {
  run :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf '\n')

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails if output is empty with newline golden - kept empty lines" {
  run --keep-empty-lines :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden "$output" <(printf '\n')

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden: fails with too few parameters" {
  run assert_equals_golden

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Incorrect number of arguments: 0. Expected 2 arguments.
--
ERR_MSG
}

@test "assert_equals_golden: fails with too many parameters" {
  run assert_equals_golden a b c

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Incorrect number of arguments: 3. Expected 2 arguments.
--
ERR_MSG
}

@test "assert_equals_golden: fails with empty golden file path" {
  run assert_equals_golden 'abc' ''

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file path was not given or it was empty.
--
ERR_MSG
}

@test "assert_equals_golden: fails with nonexistent golden file" {
  run assert_equals_golden 'abc' some/path/this_file_definitely_does_not_exist.txt

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file was not found. File path: 'some/path/this_file_definitely_does_not_exist.txt'
--
ERR_MSG
}

@test "assert_equals_golden: fails with non-openable golden file" {
  run assert_equals_golden 'abc' .

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Failed to read golden file. File path: '.'
--
ERR_MSG
}

@test "assert_equals_golden: '--' stops parsing options" {
  run assert_equals_golden -- '--diff' <(printf '%s' '--diff')

  assert_test_pass
}

@test "assert_equals_golden: fails due to literal (non-wildcard) matching by default" {
  run printf 'b'
  run assert_equals_golden "$output" <(printf '*')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
*
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_equals_golden: fails due to literal (non-regex) matching by default" {
  run printf 'b'
  run assert_equals_golden "$output" <(printf '.*')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
.*
actual output (1 lines):
b
--
ERR_MSG
}

#
# assert_equals_golden
# Literal matching with stdin
#

@test "assert_equals_golden --stdin: succeeds if output and golden match" {
  run printf 'a'
  run assert_equals_golden --stdin <(printf 'a') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if output and golden match with '-' arg" {
  run printf 'a'
  run assert_equals_golden - <(printf 'a') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_equals_golden --stdin <(printf 'a\nb\nc') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if multiline output and golden match with '-' arg" {
  run printf 'a\nb\nc'
  run assert_equals_golden - <(printf 'a\nb\nc') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_equals_golden --stdin <(printf 'a\n') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if output and golden match and contain trailing newline with '-' arg" {
  run --keep-empty-lines printf 'a\n'
  run assert_equals_golden - <(printf 'a\n') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_equals_golden --stdin <(printf 'a\nb\nc\n') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if multiline output and golden match and contain trailing newline with '-' arg" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_equals_golden - <(printf 'a\nb\nc\n') < <(printf "$output")
  assert_test_pass
}

@test "assert_equals_golden --stdin: fails if output and golden do not match" {
  run printf 'b'
  run assert_equals_golden --stdin <(printf 'a') < <(printf "$output")

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_equals_golden --stdin: fails if output and golden do not match with '-' arg" {
  run printf 'b'
  run assert_equals_golden - <(printf 'a') < <(printf "$output")

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_equals_golden --stdin: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf 'a\n') < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a

actual output (1 lines):
a
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf 'a\nb\nc\n') < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (3 lines):
a
b
c

actual output (3 lines):
a
b
c
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf 'a') < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
a

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf 'a\nb\nc') < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (3 lines):
a
b
c
actual output (3 lines):
a
b
c

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_equals_golden --stdin <(printf '\n') < <(printf "$output")

  assert_test_pass
}

@test "assert_equals_golden --stdin: fails if output is and golden are empty" {
  run :
  run assert_equals_golden --stdin <(:) < <(printf "$output")

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_equals_golden --stdin: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_equals_golden --stdin --allow-empty <(:) < <(printf "$output")

  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if output is and golden are empty when allowed with '-' arg" {
  run :
  run assert_equals_golden --allow-empty - <(:) < <(printf "$output")

  assert_test_pass
}

@test "assert_equals_golden --stdin: succeeds if output is and golden are empty when allowed - kept empty lines" {
  run --keep-empty-lines :
  run assert_equals_golden --stdin --allow-empty <(:) < <(printf "$output")

  assert_test_pass
}

@test "assert_equals_golden --stdin: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf 'a') < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output is newline with non-empty golden with '-' arg" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden - <(printf 'a') < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):
a
actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin --allow-empty <(:) < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (0 lines):

actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output is newline with allowed empty golden with '-' arg" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --allow-empty - <(:) < <(printf "$output")

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (0 lines):

actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output is empty with newline golden" {
  run :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf '\n') < <(printf "$output")

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output is empty with newline golden with '-' arg" {
  run :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden - <(printf '\n') < <(printf "$output")

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --stdin: fails if output is empty with newline golden - kept empty lines" {
  run --keep-empty-lines :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --stdin <(printf '\n') < <(printf "$output")

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

#
# assert_equals_golden
# Literal matching with diff output
#

@test "assert_equals_golden --diff: succeeds if output and golden match" {
  run printf 'a'
  run assert_equals_golden --diff "$output" <(printf 'a')
  assert_test_pass
}

@test "assert_equals_golden --diff: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_equals_golden --diff "$output" <(printf 'a\nb\nc')
  assert_test_pass
}

@test "assert_equals_golden --diff: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_equals_golden --diff "$output" <(printf 'a\n')
  assert_test_pass
}

@test "assert_equals_golden --diff: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_equals_golden --diff "$output" <(printf 'a\nb\nc\n')
  assert_test_pass
}

@test "assert_equals_golden --diff: fails if output and golden do not match" {
  run printf 'b'
  run assert_equals_golden --diff "$output" <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
1c1
< b
---
> a
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  run assert_equals_golden --diff "$output" <(printf 'a\n')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
1a2
> 
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  run assert_equals_golden --diff "$output" <(printf 'a\nb\nc\n')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
3a4
> 
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_equals_golden --diff "$output" <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
2d1
< 
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_equals_golden --diff "$output" <(printf 'a\nb\nc')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
4d3
< 
--
ERR_MSG
}

@test "assert_equals_golden --diff: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_equals_golden --diff "$output" <(printf '\n')

  assert_test_pass
}

@test "assert_equals_golden --diff: fails if output is and golden are empty" {
  run :
  run assert_equals_golden --diff "$output" <(:)

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_equals_golden --diff: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_equals_golden --diff --allow-empty "$output" <(:)

  assert_test_pass
}

@test "assert_equals_golden --diff: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  run assert_equals_golden --diff "$output" <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
1,2c1
< 
< 
---
> a
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  run assert_equals_golden --diff --allow-empty "$output" <(:)

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
2d1
< 
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails if output is empty with newline golden" {
  run :
  run assert_equals_golden --diff "$output" <(printf '\n')

  assert_test_fail <<'ERR_MSG'

-- value does not match golden --
1a2
> 
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails with too few parameters" {
  run assert_equals_golden --diff

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Incorrect number of arguments: 0. Expected 2 arguments.
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails with too many parameters" {
  run assert_equals_golden --diff a b c

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Incorrect number of arguments: 3. Expected 2 arguments.
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails with empty golden file path" {
  run assert_equals_golden --diff 'abc' ''

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file path was not given or it was empty.
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails with nonexistent golden file" {
  run assert_equals_golden --diff 'abc' some/path/this_file_definitely_does_not_exist.txt

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file was not found. File path: 'some/path/this_file_definitely_does_not_exist.txt'
--
ERR_MSG
}

@test "assert_equals_golden --diff: fails with non-openable golden file" {
  run assert_equals_golden --diff 'abc' .

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Failed to read golden file. File path: '.'
--
ERR_MSG
}

@test "assert_equals_golden --diff: '--' stops parsing options" {
  run assert_equals_golden --diff -- '--diff' <(printf '%s' '--diff')

  assert_test_pass
}

#
# assert_equals_golden
# Regex matching
#

@test "assert_equals_golden --regexp: succeeds if output and golden match" {
  run printf 'a'
  run assert_equals_golden --regexp "$output" <(printf 'a')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_equals_golden --regexp "$output" <(printf 'a\nb\nc')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_equals_golden --regexp "$output" <(printf 'a\n')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_equals_golden --regexp "$output" <(printf 'a\nb\nc\n')
  assert_test_pass
}

@test "assert_equals_golden --regexp: fails if output and golden do not match" {
  run printf 'b'
  run assert_equals_golden --regexp "$output" <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
a
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf 'a\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
a

actual output (1 lines):
a
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf 'a\nb\nc\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (3 lines):
a
b
c

actual output (3 lines):
a
b
c
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
a
actual output (1 lines):
a

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf 'a\nb\nc')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (3 lines):
a
b
c
actual output (3 lines):
a
b
c

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_equals_golden --regexp "$output" <(printf '\n')

  assert_test_pass
}

@test "assert_equals_golden --regexp: fails if output is and golden are empty" {
  run :
  run assert_equals_golden --regexp "$output" <(:)

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_equals_golden --regexp: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_equals_golden --regexp --allow-empty "$output" <(:)

  assert_test_pass
}

@test "assert_equals_golden --regexp: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
a
actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp --allow-empty "$output" <(:)

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (0 lines):

actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails if output is empty with newline golden" {
  run :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf '\n')

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails with too few parameters" {
  run assert_equals_golden --regexp

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Incorrect number of arguments: 0. Expected 2 arguments.
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with too many parameters" {
  run assert_equals_golden --regexp a b c

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Incorrect number of arguments: 3. Expected 2 arguments.
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with empty golden file path" {
  run assert_equals_golden --regexp 'abc' ''

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file path was not given or it was empty.
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with nonexistent golden file" {
  run assert_equals_golden --regexp 'abc' some/path/this_file_definitely_does_not_exist.txt

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Golden file was not found. File path: 'some/path/this_file_definitely_does_not_exist.txt'
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with non-openable golden file" {
  run assert_equals_golden --regexp 'abc' .

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Failed to read golden file. File path: '.'
--
ERR_MSG
}

@test "assert_equals_golden --regexp: '--' stops parsing options" {
  run assert_equals_golden --regexp -- '--diff' <(printf '%s' '--diff')

  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with special characters" {
  run printf '[.?+'
  run assert_equals_golden --regexp "$output" <(printf '\\[\\.\\?\\+')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with non-specific matching regex" {
  run printf 'a'
  run assert_equals_golden --regexp "$output" <(printf '.')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline non-specific exact matching regex" {
  run printf 'a\nb'
  run assert_equals_golden --regexp "$output" <(printf '...')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline non-specific greedy matching regex" {
  run printf 'abc\nxyz'
  run assert_equals_golden --regexp "$output" <(printf '.*')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline non-specific non-newline matching regex" {
  run printf 'abc\nxyz'
  run assert_equals_golden --regexp "$output" <(printf '[^\\n]+\n[^\\n]+')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with specific matching regex" {
  run printf 'a'
  run assert_equals_golden --regexp "$output" <(printf '[a]')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline specific matching regex" {
  run printf 'a\nb'
  run assert_equals_golden --regexp "$output" <(printf '[a]\n[b]')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline specific repeating matching regex" {
  run printf 'aabbcc\nxxyyzz'
  run assert_equals_golden --regexp "$output" <(printf '[abc]+\n[xyz]+')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline specific matching regex with trailing newlines" {
  run --keep-empty-lines printf 'aabbcc\nxxyyzz\n\n'
  run assert_equals_golden --regexp "$output" <(printf '[abc]+\n[xyz]+\n\n')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline specific matching regex with special characters" {
  run printf 'aabbcc\n[.?+\nxxyyzz'
  run assert_equals_golden --regexp "$output" <(printf '[abc]+\n\\[\\.\\?\\+\n[xyz]+')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline specific matching regex with special characters and trailing newlines" {
  run --keep-empty-lines printf 'aabbcc\n[.?+\nxxyyzz\n\n'
  run assert_equals_golden --regexp "$output" <(printf '[abc]+\n\\[\\.\\?\\+\n[xyz]+\n\n')
  assert_test_pass
}

@test "assert_equals_golden --regexp: succeeds with multiline start-end matching regex" {
  run printf 'abc\ndef\nxyz'
  run assert_equals_golden --regexp "$output" <(printf 'abc\n.*xyz')
  assert_test_pass
}

@test "assert_equals_golden --regexp: fails with non-specific non-matching regex - too many" {
  run printf 'a'
  run assert_equals_golden --regexp "$output" <(printf '..')

  assert_test_fail <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
..
actual output (1 lines):
a
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with non-specific non-matching regex - too few" {
  run printf 'ab'
  run assert_equals_golden --regexp "$output" <(printf '.')

  assert_test_fail <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
.
actual output (1 lines):
ab
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with specific non-matching regex" {
  run printf 'a'
  run assert_equals_golden --regexp "$output" <(printf '[b]')

  assert_test_fail <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (1 lines):
[b]
actual output (1 lines):
a
--
ERR_MSG
}

@test "assert_equals_golden --regexp: fails with multiline specific matching regex with extra trailing newlines" {
  run --keep-empty-lines printf 'aabbcc\nxxyyzz\n\n'
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf '[abc]+\n[xyz]+')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (2 lines):
[abc]+
[xyz]+
actual output (3 lines):
aabbcc
xxyyzz


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails with multiline specific matching regex with missing trailing newlines" {
  run printf 'aabbcc\nxxyyzz'
  run --keep-empty-lines assert_equals_golden --regexp "$output" <(printf '[abc]+\n[xyz]+\n\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- value does not match regexp golden --
golden contents (3 lines):
[abc]+
[xyz]+


actual output (2 lines):
aabbcc
xxyyzz
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_equals_golden --regexp: fails if regex golden is not a valid extended regular expression" {
  run assert_equals_golden --regexp "$output" <(printf '[.*')

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Invalid extended regular expression in golden file: `[.*'
--
ERR_MSG
}

#
# assert_equals_golden
# Misc Error Handling
#

@test "assert_equals_golden: fails with --regexp --diff" {
  run assert_equals_golden --regexp --diff 'abc' <(printf 'abc')

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
`--diff' not supported with `--regexp'
--
ERR_MSG
}

@test "assert_equals_golden: fails with unknown option" {
  run assert_equals_golden --not-a-real-option 'abc' <(printf 'abc')

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_equals_golden --
Unsupported flag '--not-a-real-option'.
--
ERR_MSG
}

#
# assert_output_equals_golden
# Literal matching
#

@test "assert_output_equals_golden: succeeds if output and golden match" {
  run printf 'a'
  run assert_output_equals_golden <(printf 'a')
  assert_test_pass
}

@test "assert_output_equals_golden: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_output_equals_golden <(printf 'a\nb\nc')
  assert_test_pass
}

@test "assert_output_equals_golden: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_output_equals_golden <(printf 'a\n')
  assert_test_pass
}

@test "assert_output_equals_golden: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_output_equals_golden <(printf 'a\nb\nc\n')
  assert_test_pass
}

@test "assert_output_equals_golden: fails if output and golden do not match" {
  run printf 'b'
  run assert_output_equals_golden <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_output_equals_golden: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf 'a\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):
a

actual output (1 lines):
a
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf 'a\nb\nc\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (3 lines):
a
b
c

actual output (3 lines):
a
b
c
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):
a
actual output (1 lines):
a

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf 'a\nb\nc')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (3 lines):
a
b
c
actual output (3 lines):
a
b
c

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_output_equals_golden <(printf '\n')

  assert_test_pass
}

@test "assert_output_equals_golden: fails if output is and golden are empty" {
  run :
  run assert_output_equals_golden <(:)

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_output_equals_golden: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_output_equals_golden --allow-empty <(:)

  assert_test_pass
}

@test "assert_output_equals_golden: succeeds if output is and golden are empty when allowed - kept empty lines" {
  run --keep-empty-lines :
  run assert_output_equals_golden --allow-empty <(:)

  assert_test_pass
}

@test "assert_output_equals_golden: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):
a
actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --allow-empty <(:)

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (0 lines):

actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails if output is empty with newline golden" {
  run :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf '\n')

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails if output is empty with newline golden - kept empty lines" {
  run --keep-empty-lines :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden <(printf '\n')

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden: fails with too few parameters" {
  run assert_output_equals_golden

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Incorrect number of arguments: 0. Expected 1 argument.
--
ERR_MSG
}

@test "assert_output_equals_golden: fails with too many parameters" {
  run assert_output_equals_golden a b c

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Incorrect number of arguments: 3. Expected 1 argument.
--
ERR_MSG
}

@test "assert_output_equals_golden: fails with empty golden file path" {
  run assert_output_equals_golden ''

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file path was not given or it was empty.
--
ERR_MSG
}

@test "assert_output_equals_golden: fails with nonexistent golden file" {
  run assert_output_equals_golden some/path/this_file_definitely_does_not_exist.txt

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file was not found. File path: 'some/path/this_file_definitely_does_not_exist.txt'
--
ERR_MSG
}

@test "assert_output_equals_golden: fails with non-openable golden file" {
  run assert_output_equals_golden .

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Failed to read golden file. File path: '.'
--
ERR_MSG
}

@test "assert_output_equals_golden: '--' stops parsing options" {
  run printf '%s' '--diff'
  run assert_output_equals_golden -- <(printf '%s' '--diff')

  assert_test_pass
}

@test "assert_output_equals_golden: fails due to literal (non-wildcard) matching by default" {
  run printf 'b'
  run assert_output_equals_golden <(printf '*')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):
*
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_output_equals_golden: fails due to literal (non-regex) matching by default" {
  run printf 'b'
  run assert_output_equals_golden <(printf '.*')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
golden contents (1 lines):
.*
actual output (1 lines):
b
--
ERR_MSG
}

#
# assert_output_equals_golden
# Literal matching with diff output
#

@test "assert_output_equals_golden --diff: succeeds if output and golden match" {
  run printf 'a'
  run assert_output_equals_golden  --diff <(printf 'a')
  assert_test_pass
}

@test "assert_output_equals_golden --diff: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_output_equals_golden --diff <(printf 'a\nb\nc')
  assert_test_pass
}

@test "assert_output_equals_golden --diff: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_output_equals_golden --diff <(printf 'a\n')
  assert_test_pass
}

@test "assert_output_equals_golden --diff: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_output_equals_golden --diff <(printf 'a\nb\nc\n')
  assert_test_pass
}

@test "assert_output_equals_golden --diff: fails if output and golden do not match" {
  run printf 'b'
  run assert_output_equals_golden --diff <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
1c1
< b
---
> a
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  run assert_output_equals_golden --diff <(printf 'a\n')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
1a2
> 
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  run assert_output_equals_golden --diff <(printf 'a\nb\nc\n')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
3a4
> 
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_output_equals_golden --diff <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
2d1
< 
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_output_equals_golden --diff <(printf 'a\nb\nc')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
4d3
< 
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_output_equals_golden --diff <(printf '\n')

  assert_test_pass
}

@test "assert_output_equals_golden --diff: fails if output is and golden are empty" {
  run :
  run assert_output_equals_golden --diff <(:)

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_output_equals_golden --diff --allow-empty <(:)

  assert_test_pass
}

@test "assert_output_equals_golden --diff: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  run assert_output_equals_golden --diff <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
1,2c1
< 
< 
---
> a
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  run assert_output_equals_golden --diff --allow-empty <(:)

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
2d1
< 
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails if output is empty with newline golden" {
  run :
  run assert_output_equals_golden --diff <(printf '\n')

  assert_test_fail <<'ERR_MSG'

-- output does not match golden --
1a2
> 
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails with too few parameters" {
  run assert_output_equals_golden --diff

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Incorrect number of arguments: 0. Expected 1 argument.
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails with too many parameters" {
  run assert_output_equals_golden --diff a b c

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Incorrect number of arguments: 3. Expected 1 argument.
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails with empty golden file path" {
  run assert_output_equals_golden --diff ''

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file path was not given or it was empty.
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails with nonexistent golden file" {
  run assert_output_equals_golden --diff some/path/this_file_definitely_does_not_exist.txt

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file was not found. File path: 'some/path/this_file_definitely_does_not_exist.txt'
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: fails with non-openable golden file" {
  run assert_output_equals_golden --diff .

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Failed to read golden file. File path: '.'
--
ERR_MSG
}

@test "assert_output_equals_golden --diff: '--' stops parsing options" {
  run printf '%s' '--diff'
  run assert_output_equals_golden --diff -- <(printf '%s' '--diff')

  assert_test_pass
}

#
# assert_output_equals_golden
# Regex matching
#

@test "assert_output_equals_golden --regexp: succeeds if output and golden match" {
  run printf 'a'
  run assert_output_equals_golden  --regexp <(printf 'a')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds if multiline output and golden match" {
  run printf 'a\nb\nc'
  run assert_output_equals_golden --regexp <(printf 'a\nb\nc')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds if output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\n'
  run assert_output_equals_golden --regexp <(printf 'a\n')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds if multiline output and golden match and contain trailing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  run assert_output_equals_golden --regexp <(printf 'a\nb\nc\n')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: fails if output and golden do not match" {
  run printf 'b'
  run assert_output_equals_golden --regexp <(printf 'a')

  assert_test_fail <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
a
actual output (1 lines):
b
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails if output and golden do not match due to extra trailing newline" {
  run printf 'a'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf 'a\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
a

actual output (1 lines):
a
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails if multiline output and golden do not match due to extra trailing newline" {
  run printf 'a\nb\nc'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf 'a\nb\nc\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (3 lines):
a
b
c

actual output (3 lines):
a
b
c
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails if output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
a
actual output (1 lines):
a

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails if multiline output and golden do not match due to extra missing newline" {
  run --keep-empty-lines printf 'a\nb\nc\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf 'a\nb\nc')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (3 lines):
a
b
c
actual output (3 lines):
a
b
c

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: succeeds if output is newline with newline golden" {
  run --keep-empty-lines printf '\n'
  run assert_output_equals_golden --regexp <(printf '\n')

  assert_test_pass
}

@test "assert_output_equals_golden --regexp: fails if output is and golden are empty" {
  run :
  run assert_output_equals_golden --regexp <(:)

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file contents is empty. This may be an authoring error. Use `--allow-empty` if this is intentional.
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: succeeds if output is and golden are empty when allowed" {
  run :
  run assert_output_equals_golden --regexp --allow-empty <(:)

  assert_test_pass
}

@test "assert_output_equals_golden --regexp: fails if output is newline with non-empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf 'a')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
a
actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails if output is newline with allowed empty golden" {
  run --keep-empty-lines printf '\n'
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp --allow-empty <(:)

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (0 lines):

actual output (1 lines):


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails if output is empty with newline golden" {
  run :
  # Need to use `--keep-empty-lines` so that `${#lines[@]}` and `num_lines` can match in `assert_test_fail`.
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf '\n')

  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):


actual output (0 lines):

--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails with too few parameters" {
  run assert_output_equals_golden --regexp

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Incorrect number of arguments: 0. Expected 1 argument.
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with too many parameters" {
  run assert_output_equals_golden --regexp a b c

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Incorrect number of arguments: 3. Expected 1 argument.
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with empty golden file path" {
  run assert_output_equals_golden --regexp ''

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file path was not given or it was empty.
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with nonexistent golden file" {
  run assert_output_equals_golden --regexp some/path/this_file_definitely_does_not_exist.txt

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Golden file was not found. File path: 'some/path/this_file_definitely_does_not_exist.txt'
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with non-openable golden file" {
  run assert_output_equals_golden --regexp .

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Failed to read golden file. File path: '.'
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: '--' stops parsing options" {
  run printf '%s' '--diff'
  run assert_output_equals_golden --regexp -- <(printf '%s' '--diff')

  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with special characters" {
  run printf '[.?+'
  run assert_output_equals_golden --regexp <(printf '\\[\\.\\?\\+')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with non-specific matching regex" {
  run printf 'a'
  run assert_output_equals_golden --regexp <(printf '.')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline non-specific exact matching regex" {
  run printf 'a\nb'
  run assert_output_equals_golden --regexp <(printf '...')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline non-specific greedy matching regex" {
  run printf 'abc\nxyz'
  run assert_output_equals_golden --regexp <(printf '.*')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline non-specific non-newline matching regex" {
  run printf 'abc\nxyz'
  run assert_output_equals_golden --regexp <(printf '[^\\n]+\n[^\\n]+')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with specific matching regex" {
  run printf 'a'
  run assert_output_equals_golden --regexp <(printf '[a]')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline specific matching regex" {
  run printf 'a\nb'
  run assert_output_equals_golden --regexp <(printf '[a]\n[b]')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline specific repeating matching regex" {
  run printf 'aabbcc\nxxyyzz'
  run assert_output_equals_golden --regexp <(printf '[abc]+\n[xyz]+')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline specific matching regex with trailing newlines" {
  run --keep-empty-lines printf 'aabbcc\nxxyyzz\n\n'
  run assert_output_equals_golden --regexp <(printf '[abc]+\n[xyz]+\n\n')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline specific matching regex with special characters" {
  run printf 'aabbcc\n[.?+\nxxyyzz'
  run assert_output_equals_golden --regexp <(printf '[abc]+\n\\[\\.\\?\\+\n[xyz]+')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline specific matching regex with special characters and trailing newlines" {
  run --keep-empty-lines printf 'aabbcc\n[.?+\nxxyyzz\n\n'
  run assert_output_equals_golden --regexp <(printf '[abc]+\n\\[\\.\\?\\+\n[xyz]+\n\n')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: succeeds with multiline start-end matching regex" {
  run printf 'abc\ndef\nxyz'
  run assert_output_equals_golden --regexp <(printf 'abc\n.*xyz')
  assert_test_pass
}

@test "assert_output_equals_golden --regexp: fails with non-specific non-matching regex - too many" {
  run printf 'a'
  run assert_output_equals_golden --regexp <(printf '..')

  assert_test_fail <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
..
actual output (1 lines):
a
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with non-specific non-matching regex - too few" {
  run printf 'ab'
  run assert_output_equals_golden --regexp <(printf '.')

  assert_test_fail <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
.
actual output (1 lines):
ab
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with specific non-matching regex" {
  run printf 'a'
  run assert_output_equals_golden --regexp <(printf '[b]')

  assert_test_fail <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (1 lines):
[b]
actual output (1 lines):
a
--
ERR_MSG
}

@test "assert_output_equals_golden --regexp: fails with multiline specific matching regex with extra trailing newlines" {
  run --keep-empty-lines printf 'aabbcc\nxxyyzz\n\n'
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf '[abc]+\n[xyz]+')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix output "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (2 lines):
[abc]+
[xyz]+
actual output (3 lines):
aabbcc
xxyyzz


--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails with multiline specific matching regex with missing trailing newlines" {
  run printf 'aabbcc\nxxyyzz'
  run --keep-empty-lines assert_output_equals_golden --regexp <(printf '[abc]+\n[xyz]+\n\n')

  # TODO(https://github.com/bats-core/bats-support/issues/11): Fix golden "lines" count in expected message.
  # Need to use variable to match trailing end lines caused by using `--keep-empty-lines`.
  expected="$(cat <<'ERR_MSG'

-- output does not match regexp golden --
golden contents (3 lines):
[abc]+
[xyz]+


actual output (2 lines):
aabbcc
xxyyzz
--

ERR_MSG
    printf '.')"
  expected="${expected%.}"
  assert_test_fail "$expected"
}

@test "assert_output_equals_golden --regexp: fails if regex golden is not a valid extended regular expression" {
  run assert_output_equals_golden --regexp <(printf '[.*')

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Invalid extended regular expression in golden file: `[.*'
--
ERR_MSG
}

#
# assert_output_equals_golden
# Misc Error Handling
#

@test "assert_output_equals_golden: fails with --regexp --diff" {
  run assert_output_equals_golden --regexp --diff <(printf 'abc')

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
`--diff' not supported with `--regexp'
--
ERR_MSG
}

@test "assert_output_equals_golden: fails with unknown option" {
  run assert_output_equals_golden --not-a-real-option <(printf 'abc')

  assert_test_fail <<'ERR_MSG'

-- ERROR: assert_output_equals_golden --
Unsupported flag '--not-a-real-option'.
--
ERR_MSG
}

#
# Automatic golden file updating
#

@test "auto-update: assert_equals_golden: updates golden for failure" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$tested_output" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run printf "$tested_output"
  run assert_equals_golden "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_equals_golden: failure if golden file is not writable" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]
  chmod a-w "$temp_golden_file"

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden "$output" "$temp_golden_file"

  assert_test_fail <<ERR_MSG

-- FAIL: assert_equals_golden --
Failed to write into golden file during update: '$temp_golden_file'.
--
ERR_MSG
}

@test "auto-update: assert_equals_golden: updates golden for failure multiline with trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc\ndef\nghi\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$(printf "$tested_output")" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_equals_golden "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_equals_golden --regexp: updates golden for failure" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$tested_output" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run printf "$tested_output"
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_equals_golden --regexp: failure if golden file is not writable" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]
  chmod a-w "$temp_golden_file"

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_fail <<ERR_MSG

-- FAIL: assert_equals_golden --
Failed to write into golden file during update: '$temp_golden_file'.
--
ERR_MSG
}

@test "auto-update: assert_equals_golden --regexp: updates golden for failure multiline with trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc\ndef\nghi\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$(printf "$tested_output")" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_equals_golden --regexp: updates golden for failure multiline with regex and trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf '[^a].[op]\n[d-l]{3}' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf '[^a].[op]\n[d-l]{3}')" ]

  tested_output='abc\ndef\nghi\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  cat "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf 'abc\n[d-l]{3}\n[d-l]{3}\n[d-l]{3}\n\n[^a].[op]\n\n')" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_equals_golden --regexp: updates golden for failure multiline with regex and special chars" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf '[^a].[op]\n[d-l]{3}' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf '[^a].[op]\n[d-l]{3}')" ]

  tested_output='abc\ndef\nghi\n].{\njkl\n\nmno'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  cat "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf 'abc\n[d-l]{3}\n[d-l]{3}\n\\]\\.\\{\n[d-l]{3}\n\n[^a].[op]')" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_equals_golden --regexp: updates golden for failure multiline with regex, special chars, and trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf '[^a].[op]\n[d-l]{3}' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf '[^a].[op]\n[d-l]{3}')" ]

  tested_output='abc\ndef\nghi\n].{\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  cat "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf 'abc\n[d-l]{3}\n[d-l]{3}\n\\]\\.\\{\n[d-l]{3}\n\n[^a].[op]\n\n')" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_equals_golden --regexp "$output" "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden: updates golden for failure" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$tested_output" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run printf "$tested_output"
  run assert_output_equals_golden "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden: failure if golden file is not writable" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]
  chmod a-w "$temp_golden_file"

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden "$temp_golden_file"

  assert_test_fail <<ERR_MSG

-- FAIL: assert_output_equals_golden --
Failed to write into golden file during update: '$temp_golden_file'.
--
ERR_MSG
}

@test "auto-update: assert_output_equals_golden: updates golden for failure multiline with trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc\ndef\nghi\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$(printf "$tested_output")" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_output_equals_golden "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden --regexp: updates golden for failure" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$tested_output" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run printf "$tested_output"
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden --regexp: failure if golden file is not writable" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]
  chmod a-w "$temp_golden_file"

  tested_output='abc'

  run printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_fail <<ERR_MSG

-- FAIL: assert_output_equals_golden --
Failed to write into golden file during update: '$temp_golden_file'.
--
ERR_MSG
}

@test "auto-update: assert_output_equals_golden --regexp: updates golden for failure multiline with trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf 'wrong output' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = 'wrong output' ]

  tested_output='abc\ndef\nghi\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  [ "$(cat "$temp_golden_file")" = "$(printf "$tested_output")" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden --regexp: updates golden for failure multiline with regex and trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf '[^a].[op]\n[d-l]{3}' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf '[^a].[op]\n[d-l]{3}')" ]

  tested_output='abc\ndef\nghi\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  cat "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf 'abc\n[d-l]{3}\n[d-l]{3}\n[d-l]{3}\n\n[^a].[op]\n\n')" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden --regexp: updates golden for failure multiline with regex and special chars" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf '[^a].[op]\n[d-l]{3}' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf '[^a].[op]\n[d-l]{3}')" ]

  tested_output='abc\ndef\nghi\n].{\njkl\n\nmno'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  cat "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf 'abc\n[d-l]{3}\n[d-l]{3}\n\\]\\.\\{\n[d-l]{3}\n\n[^a].[op]')" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_pass
}

@test "auto-update: assert_output_equals_golden --regexp: updates golden for failure multiline with regex, special chars, and trailing newlines" {
  temp_golden_file="$(mktemp -t "bats_test_${BATS_TEST_NUMBER}.XXXXXXXX.txt")"
  [ -f "$temp_golden_file" ]
  printf '[^a].[op]\n[d-l]{3}' > "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf '[^a].[op]\n[d-l]{3}')" ]

  tested_output='abc\ndef\nghi\n].{\njkl\n\nmno\n\n'

  run --keep-empty-lines printf "$tested_output"
  BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE=1
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_fail <<'ERR_MSG'

-- FAIL: assert_output_equals_golden --
Golden file updated after mismatch.
--
ERR_MSG

  cat "$temp_golden_file"
  [ "$(cat "$temp_golden_file")" = "$(printf 'abc\n[d-l]{3}\n[d-l]{3}\n\\]\\.\\{\n[d-l]{3}\n\n[^a].[op]\n\n')" ]
  unset BATS_ASSERT_UPDATE_GOLDENS_ON_FAILURE
  run --keep-empty-lines printf "$tested_output"
  run assert_output_equals_golden --regexp "$temp_golden_file"

  assert_test_pass
}
