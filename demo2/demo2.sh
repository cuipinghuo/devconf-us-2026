#!/bin/bash
set -euo pipefail
source ../helpers.sh

IMAGE="quay.io/konflux-ci/ec-golden-image:latest"

# Fetch the latest commit SHA from the golden container repo
GIT_REPO="conforma/golden-container"
GIT_SHA=$(curl -s "https://api.github.com/repos/${GIT_REPO}/commits?per_page=1" | jq -r '.[0].sha')

PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEZP/0htjhVt2y0ohjgtIIgICOtQtA
naYJRuLprwIv6FDhZ5yFjYUEtsmoNcW7rx2KM6FOXGsCX3BNc7qhHELT+g==
-----END PUBLIC KEY-----"

echo "$PUBLIC_KEY" > cosign.pub

h1 "Validating a real container image"

show-msg "We are validating a real image built in Konflux with real signatures and attestations"

pause

show-msg "The application snapshot (how Konflux describes what to validate):"

create-file snapshot.json '{
  "components": [
    {
      "name": "golden-container",
      "containerImage": "'"${IMAGE}"'",
      "source": {
        "git": {
          "url": "https://github.com/'"${GIT_REPO}"'",
          "revision": "'"${GIT_SHA}"'"
        }
      }
    }
  ]
}'

show-json snapshot.json

pause

show-msg "Validate against the default Conforma policy:"

show-pause-run 'ec validate image \
  --json-input snapshot.json \
  --policy github.com/conforma/config//default \
  --public-key cosign.pub \
  --ignore-rekor \
  --show-successes \
  --info; \
  echo "Exit code: $?"'

h1 "Source correlation attack"

show-msg "Now let's lie about where the source code came from..."

pause

create-file bad-snapshot.json '{
  "components": [
    {
      "name": "golden-container",
      "containerImage": "'"${IMAGE}"'",
      "source": {
        "git": {
          "url": "https://github.com/miscreant/mischief",
          "revision": "cafebabe"
        }
      }
    }
  ]
}'

show-msg "We claim the image was built from miscreant/mischief:"

show-json bad-snapshot.json -H8:9

pause

show-msg "The signature is valid. The attestation is valid. But the source does not match:"

show-pause-run 'ec validate image \
  --json-input bad-snapshot.json \
  --policy github.com/conforma/config//default \
  --public-key cosign.pub \
  --ignore-rekor \
  --info; \
  echo "Exit code: $?"'

show-msg "Signed does not mean trusted. Without policy enforcement, this mismatch flies through."
