#!/bin/bash
set -euo pipefail
source ../helpers.sh

IMAGE="quay.io/konflux-ci/ec-golden-image:latest"

# Fetch the latest commit SHA from the golden container repo
GIT_REPO="conforma/golden-container"
# Pinned to match the pre-recorded ec output (resources/honest-run.txt, bad-run.txt),
# so the demo runs fully offline. Re-record those files if you bump this.
GIT_SHA="6d86393776731b09c3a45aa233fe7f1edbabdc5f"

PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEZP/0htjhVt2y0ohjgtIIgICOtQtA
naYJRuLprwIv6FDhZ5yFjYUEtsmoNcW7rx2KM6FOXGsCX3BNc7qhHELT+g==
-----END PUBLIC KEY-----"

echo "$PUBLIC_KEY" > cosign.pub

h1 "Demo 2: Validating a real container image"

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

show-msg "The default policy has 170+ rules. For this demo we focus on the source-correlation package."

create-file policy.yaml 'sources:
  - name: Source correlation only
    policy:
      - github.com/conforma/policy//policy/lib
      - github.com/conforma/policy//policy/release
    config:
      include:
        - slsa_source_correlated
      exclude: []
'

show-yaml policy.yaml -H8

pause

show-msg "Validate the honest snapshot (source matches the signed provenance):"

# Pre-recorded output so the live demo does not wait on the image pull here.
show-pause-fake 'ec validate image \
  --images snapshot.json \
  --policy policy.yaml \
  --public-key cosign.pub \
  --ignore-rekor \
  --show-successes \
  --info; \
  echo "Exit code: $?"' "$(cat honest-run.txt)"

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

# Pre-recorded output so the live demo does not wait on the image pull here.
show-pause-fake 'ec validate image \
  --images bad-snapshot.json \
  --policy policy.yaml \
  --public-key cosign.pub \
  --ignore-rekor \
  --info; \
  echo "Exit code: $?"' "$(cat bad-run.txt)"

show-msg "Signed does not mean trusted. Without policy enforcement, this mismatch flies through."
