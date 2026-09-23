#!/bin/bash
set -euo pipefail
source ../helpers.sh

h1 "Demo 1: Validating structured data with Conforma"

pause

show-msg "A simple YAML file with some animals:"

create-file input.yaml 'animals:
- name: Bluey
  species: dog
- name: Jiji
  species: cat
- name: Daffy
  species: duck
'

show-yaml input.yaml

pause

show-msg "A Conforma policy rule defined in Rego:"

mkdir -p no-cats

create-file no-cats/main.rego 'package main

# METADATA
# title: No cats!
# description: Felines must be disallowed.
# custom:
#   short_name: no_cats
#   solution: Ensure no cats are present in the animal list.
#
deny contains result if {
  some animal in input.animals
  animal.species == "cat"
  result := {
    "code": "main.no_cats",
    "msg": sprintf("A cat named %s was found!", [animal.name]),
  }
}
'

show-rego no-cats/main.rego -H10:12

pause

show-msg "A policy config that points to our rule:"

create-file policy.yaml 'sources:
- policy:
  - ./no-cats
'

show-yaml policy.yaml

pause

show-msg "That is all we need:"

show-run 'tree .'

h1 "Our first violation"

show-msg "Let's run Conforma:"

show-pause-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --info \
  --show-successes; \
  echo "Exit code: $?"'

h1 "Fixing the violation"

show-msg "Replace cat with rabbit:"

show-run 'sed -i "s/cat/rabbit/" input.yaml'

show-yaml input.yaml -H5

pause

show-msg "Run it again:"

show-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --info \
  --show-successes; \
  echo "Exit code: $?"'

h1 "Warnings vs. Violations"

show-msg "Let's add a warning rule:"

append-file no-cats/main.rego '

# METADATA
# title: Duck warning
# description: Beware ducks can be wet and messy
# custom:
#   short_name: duck_alert
#
warn contains result if {
  some animal in input.animals
  animal.species == "duck"
  result := {"code":"main.duck_alert", "msg":"A duck is present!"}
}'

show-rego no-cats/main.rego -r19:

pause

show-msg "Notice the warning in output (warnings are non-blocking):"

show-pause-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --info \
  --show-successes; \
  echo "Exit code: $?"'

h1 "Machine-readable output"

show-msg "Use --output json for CI/CD integration:"

show-pause-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --info \
  --show-successes \
  --output json | jq .'

h1 "Non-strict mode"

show-msg "With --strict=false, violations don't produce a non-zero exit code:"

show-run 'sed -i "s/rabbit/cat/" input.yaml'

show-pause-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --strict=false | head -3; \
  echo "Exit code: $?"'

show-msg "Compare with strict (default):"

show-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --strict | head -3; \
  echo "Exit code: $?"'
