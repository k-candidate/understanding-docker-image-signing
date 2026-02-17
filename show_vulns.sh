#!/bin/bash

IMAGE=$1

cosign verify-attestation --key cosign.pub --type vuln $1 | \
    jq -r '.payload' | \
    base64 -d | \
    jq '
        .predicate |
        if .scanner.result.Results[].Vulnerabilities | length > 0 then
            .scanner.result.Results[].Vulnerabilities[] |
            {VulnerabilityID, PkgName, InstalledVersion, FixedVersion, Title, Description, Severity}
        else
            "no vulns found in the signed attestation"
        end
    '
