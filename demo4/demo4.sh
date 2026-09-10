#!/bin/bash
set -euo pipefail
source ../helpers.sh

h1 "Grace periods with effective_on"

show-msg "Deploy new rules as warnings first. They become violations on a date you pick."

pause

show-msg "A simple input file:"

create-file input.yaml 'service:
  name: my-app
  version: 1.0.0
'

show-yaml input.yaml

pause

show-msg "A rule with effective_on set to a future date:"

mkdir -p rules

create-file rules/future.rego 'package main

# METADATA
# title: Future requirement
# description: This rule will be enforced starting 2099-01-01.
# custom:
#   short_name: future_check
#   effective_on: "2099-01-01T00:00:00Z"
#   solution: Prepare for this upcoming requirement.
#
deny contains result if {
  result := {
    "code": "main.future_check",
    "msg": "This will be required in the future",
  }
}
'

show-rego rules/future.rego -H8

pause

create-file policy.yaml 'sources:
- policy:
  - ./rules
'

h1 "Running today"

show-msg "The rule fires as a WARNING because effective_on has not arrived yet:"

show-pause-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --info \
  --show-successes; \
  echo "Exit code: $?"'

h1 "Simulating the future"

show-msg "Use --effective-time to simulate what happens after the date:"

show-pause-run 'ec validate input \
  --file input.yaml \
  --policy policy.yaml \
  --info \
  --effective-time 2100-01-01T12:00:00Z; \
  echo "Exit code: $?"'

show-msg "Same rule, same data. Today it warns, on the date it blocks. No flag-day surprises."
