#!/bin/bash
set -euo pipefail

: "${PACT_BROKER_BASE_URL:?Set PACT_BROKER_BASE_URL to the URL of your Pact Broker}"

GIT_COMMIT=${GIT_COMMIT:-$(git rev-parse HEAD)}
GIT_BRANCH=${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}

# Authenticate with a token (e.g. PactFlow) or username/password (OSS broker)
if [ -n "${PACT_BROKER_TOKEN:-}" ]; then
  AUTH_ARGS=(--broker-token "${PACT_BROKER_TOKEN}")
else
  AUTH_ARGS=(--broker-username "${PACT_BROKER_USERNAME:-}" --broker-password "${PACT_BROKER_PASSWORD:-}")
fi

pact-broker publish pacts \
  --branch "${GIT_BRANCH}" \
  --consumer-app-version "${GIT_COMMIT}" \
  --broker-base-url "${PACT_BROKER_BASE_URL}" \
  "${AUTH_ARGS[@]}"

echo "Pact contract publishing complete!"
echo "Head over to ${PACT_BROKER_BASE_URL}/pacts/provider/GettingStartedOrderApi/consumer/GettingStartedOrderWeb/version/${GIT_COMMIT}"
echo "to see your published contracts."
