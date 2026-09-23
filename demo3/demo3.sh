#!/bin/bash
set -euo pipefail
source ../helpers.sh

# Pinned by digest to match the pre-recorded ec output (resources/pass-run.txt,
# fail-run.txt), so the demo stays truthful. Re-record those files if you bump this.
IMAGE="quay.io/konflux-ci/ec-golden-image@sha256:ffffb976664b21fa8239a192bdea97ad6f54067dcbecb104bcad4368e9fd7585"

PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEZP/0htjhVt2y0ohjgtIIgICOtQtA
naYJRuLprwIv6FDhZ5yFjYUEtsmoNcW7rx2KM6FOXGsCX3BNc7qhHELT+g==
-----END PUBLIC KEY-----"

echo "$PUBLIC_KEY" > cosign.pub

h1 "Demo 3: Custom policy with ruleData"

show-msg "One rule, different config per team"

pause

show-msg "A Rego rule that restricts which GitHub org the source can come from:"

show-rego rules/github.rego -H14 -H16

pause

show-msg "The allowed org is not hardcoded. It comes from ruleData in the policy config:"

create-file policy.yaml 'sources:
  - policy:
      - ./rules
    ruleData:
      allowed_github_origins: conforma
'

show-yaml policy.yaml -H5

pause

show-msg "Validate with allowed org set to 'conforma' (should pass):"

# Pre-recorded output so the live demo does not wait on the image pull here.
show-pause-fake 'ec validate image \
  --image '"${IMAGE}"' \
  --policy policy.yaml \
  --public-key cosign.pub \
  --ignore-rekor \
  --show-successes \
  --info; \
  echo "Exit code: $?"' "$(cat pass-run.txt)"

h1 "Changing the config"

show-msg "Now change the allowed org to 'acme-org':"

show-run 'yq -i '"'"'.sources[0].ruleData.allowed_github_origins = "acme-org"'"'"' policy.yaml'

show-yaml policy.yaml -H5

pause

show-msg "Same rule, different config. Now it fails:"

# Pre-recorded output so the live demo does not wait on the image pull here.
show-pause-fake 'ec validate image \
  --image '"${IMAGE}"' \
  --policy policy.yaml \
  --public-key cosign.pub \
  --ignore-rekor \
  --info; \
  echo "Exit code: $?"' "$(cat fail-run.txt)"

show-msg "Security team writes the rule once. Product teams tune ruleData."
