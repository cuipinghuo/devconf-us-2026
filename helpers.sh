#!/bin/bash
set -euo pipefail

# Create a file with given content
function create-file() {
  local filename="$1"
  local content="$2"
  echo "$content" > "$filename"
}

# Append to a file
function append-file() {
  local filename="$1"
  local content="$2"
  echo "$content" >> "$filename"
}

# Replace a file with given content
function replace-file() {
  local filename="$1"
  local content="$2"
  echo "$content" > "$filename"
}

# Pretty print any file with syntax highlighting
function show-file() {
  local filename="$1"
  shift
  show-cmd "cat $filename"
  run-cmd "bat -n $filename $*"
}

# Pretty print yaml
function show-yaml() {
  local filename="$1"
  shift
  show-cmd "cat $filename"
  run-cmd "yq . $filename | bat -n -l yaml $*"
}

# Pretty print json
function show-json() {
  local filename="$1"
  shift
  show-cmd "cat $filename"
  run-cmd "jq . $filename | bat -n -l json $*"
}

# Pretty print rego
function show-rego() {
  local filename="$1"
  shift
  show-cmd "cat $filename"
  run-cmd "ec opa fmt < $filename | bat -n -l rego $*"
}

# Section heading
function h1() {
  if [ "${_first:-1}" = 1 ]; then
    _first=0
  else
    pause
  fi

  local text="$1"
  local line=$(sed 's/./─/g' <<< "$text")

  echo "╭─$line─╮"
  echo "┝ $text ┥"
  echo "╰─$line─╯"
}

# Show a command, pause, then run it
function show-pause-run() {
  local cmd="$1"
  shift
  show-cmd "$cmd"
  pause
  run-cmd "$cmd" "$@"
}

# Show a command, then run it immediately
function show-run() {
  local cmd="$1"
  shift
  show-cmd "$cmd"
  echo ""
  run-cmd "$cmd" "$@"
}

# Wait for the user to press enter
function pause() {
  echo
  read -p "$(ansi lightblue)Hit Enter to continue$(ansi reset)"
  echo
}

# Eval a command line
function run-cmd() {
  set +e
  local cleaned_cmd=$(echo "$1" | sed 's/\\\s*#.*/\\/g')
  shift

  if [ $# -gt 0 ]; then
    eval "$cleaned_cmd" | bat -n "$@"
  else
    eval "$cleaned_cmd"
  fi

  set -e
}

# Pretty-print a command line
function show-cmd() {
  printf "%s\n" "$1"
}

# Pretty-print a message
function show-msg() {
  printf "───────────────────────────────────────────────────\n\n$(ansi purple)💬 %s$(ansi reset)\n" "$1"
}

# Color output
ansi() {
  local code="$1"
  case "$code" in
    reset)        code="0"    ;;
    red)          code="0;31" ;;
    green)        code="0;32" ;;
    purple)       code="0;35" ;;
    lightblue)    code="1;34" ;;
    yellow)       code="1;33" ;;
  esac

  printf '\e[%sm' "$code"
}

# Set up a clean workspace
setup-workdir() {
  local workdir="./workspace"
  rm -rf "$workdir"
  mkdir -p "$workdir"
  if [ -d "resources" ]; then
    cp -r resources/* "$workdir/"
  fi
  cd "$workdir"
}

setup-workdir
