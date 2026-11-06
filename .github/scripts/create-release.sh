#!/usr/bin/env bash

set -euo pipefail

flags=()
case "$GITHUB_REF_NAME" in
  *-*) flags+=(--prerelease) ;;
esac

gh release create "$GITHUB_REF_NAME" \
  --repo "$GITHUB_REPOSITORY" \
  --title "$GITHUB_REF_NAME" \
  --verify-tag \
  --generate-notes \
  "${flags[@]}"
