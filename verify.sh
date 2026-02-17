#!/bin/bash
IMAGE=$1

echo "Verifying signature..."
cosign verify --key cosign.pub $IMAGE || exit 1

echo "Checking provenance..."
PROVENANCE=$(cosign verify-attestation --key cosign.pub --type slsaprovenance $IMAGE | jq -r '.payload' | base64 -d | jq '.predicate.SLSA')
REPO=$(echo "$PROVENANCE" | jq -r '.metadata."https://mobyproject.org/buildkit@v1#metadata".vcs.source // empty | if type == "string" and (startswith("https://") or startswith("git@")) then . else "unknown" end')
COMMIT=$(echo "$PROVENANCE" | jq -r '.metadata."https://mobyproject.org/buildkit@v1#metadata".vcs.revision // empty | if type == "string" and length > 0 then . else "unknown" end')
echo "Built from repo: $REPO"
echo "Built from commit: $COMMIT"

echo "Checking vulnerabilities..."
VULNS=$(cosign verify-attestation --key cosign.pub --type vuln $IMAGE | jq -r '.payload' | base64 -d | jq '.predicate')
CRITICAL=$(echo $VULNS | jq '[.scanner.result.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length')
echo "Critical vulnerabilities: $CRITICAL"

if [ "$CRITICAL" -gt 0 ]; then
  echo "Image has critical vulnerabilities. Review before deploying."
  exit 1
fi

echo "All checks passed."