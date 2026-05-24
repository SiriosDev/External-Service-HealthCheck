#!/bin/sh

SERVICE="${TARGET_SERVICE}"

if [ -z "$SERVICE" ]; then
  echo "TARGET_SERVICE not set"
  exit 1
fi

STATUS=$(docker inspect "$SERVICE" \
  --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' 2>/dev/null)

if [ "$STATUS" = "healthy" ]; then
  exit 0
else
  echo "Service $SERVICE status: $STATUS"
  exit 1
fi
