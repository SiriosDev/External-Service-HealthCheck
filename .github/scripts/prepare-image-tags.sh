#!/usr/bin/env bash

set -euo pipefail

VERSION="$IMAGE_VERSION"
VERSION_CHANGED=false
if [ "$EVENT_NAME" = "push" ] && [ "$REF_TYPE" = "tag" ]; then
  VERSION_CHANGED=true
fi

CHANNEL_TAG="stable"
if [ "$VERSION" != "latest" ]; then
  case "$VERSION" in
    *-*)
      prerelease="${VERSION#*-}"
      CHANNEL_TAG="${prerelease%%.*}"
      CHANNEL_TAG="${CHANNEL_TAG%%+*}"
      ;;
  esac
fi

dockerhub_image="${DOCKER_USERNAME}/external-service-healthcheck"
ghcr_image="ghcr.io/${IMAGE_OWNER_LC}/external-service-healthcheck"

{
  echo "tags<<EOF"
  echo "${dockerhub_image}:nightly"
  echo "${ghcr_image}:nightly"

  if [ "$VERSION_CHANGED" = "true" ]; then
    core="${VERSION%%[-+]*}"
    IFS='.' read -ra parts <<< "$core"

    derived_tags=()
    for ((i=${#parts[@]}; i>=1; i--)); do
      tag=$(IFS='.'; echo "${parts[*]:0:$i}")
      derived_tags+=("$tag")
    done

    if [ "$CHANNEL_TAG" = "stable" ]; then
      echo "${dockerhub_image}:${VERSION}"
      for tag in "${derived_tags[@]}"; do
        echo "${dockerhub_image}:${tag}"
      done
      echo "${dockerhub_image}:latest"
      echo "${dockerhub_image}:stable"

      echo "${ghcr_image}:${VERSION}"
      for tag in "${derived_tags[@]}"; do
        echo "${ghcr_image}:${tag}"
      done
      echo "${ghcr_image}:latest"
      echo "${ghcr_image}:stable"
    else
      echo "${dockerhub_image}:${VERSION}"
      for tag in "${derived_tags[@]}"; do
        echo "${dockerhub_image}:${tag}"
      done
      echo "${dockerhub_image}:${CHANNEL_TAG}"

      echo "${ghcr_image}:${VERSION}"
      for tag in "${derived_tags[@]}"; do
        echo "${ghcr_image}:${tag}"
      done
      echo "${ghcr_image}:${CHANNEL_TAG}"
    fi
  fi

  echo "EOF"
} >> "$GITHUB_OUTPUT"
