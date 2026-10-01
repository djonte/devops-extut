#!/bin/bash

set -u

readonly TUTORIAL_DIRECTORY="/root/tutorial"
readonly VERIFY_IMAGE="checkov-tutorial:verify"
readonly VERIFY_CONTAINER="checkov-tutorial-verify"

fail() {
  echo "Verification failed: $1" >&2
  exit 1
}

cleanup() {
  docker rm -f "${VERIFY_CONTAINER}" >/dev/null 2>&1 || true
}

health_status() {
  docker inspect \
    --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' \
    "${VERIFY_CONTAINER}" 2>/dev/null
}

wait_for_health() {
  local expected_status="$1"
  local attempts="$2"
  local current_status

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    current_status="$(health_status)"
    if [[ "${current_status}" == "${expected_status}" ]]; then
      return 0
    fi
    sleep 1
  done

  return 1
}

trap cleanup EXIT
cleanup

cd "${TUTORIAL_DIRECTORY}" || fail "tutorial files were not found"

echo "Checking the Dockerfile with Checkov..."
if ! checkov -f Dockerfile --framework dockerfile --skip-download \
  --check CKV_DOCKER_2,CKV_DOCKER_3,CKV_DOCKER_7; then
  fail "the Dockerfile does not pass all three Checkov policies"
fi

echo "Building the fixed image..."
if ! docker build -t "${VERIFY_IMAGE}" .; then
  fail "the Docker image could not be built"
fi

echo "Starting a verification container..."
if ! docker run -d --name "${VERIFY_CONTAINER}" "${VERIFY_IMAGE}" >/dev/null; then
  fail "the container could not be started"
fi

container_uid="$(docker exec "${VERIFY_CONTAINER}" id -u 2>/dev/null)" || \
  fail "the container user could not be inspected"
[[ "${container_uid}" == "10001" ]] || \
  fail "the container must run with user ID 10001, but found ${container_uid}"

container_user="$(docker exec "${VERIFY_CONTAINER}" id -un 2>/dev/null)" || \
  fail "the container user name could not be inspected"
[[ "${container_user}" == "appuser" ]] || \
  fail "the container must run as appuser, but found ${container_user}"

app_owner="$(docker exec "${VERIFY_CONTAINER}" stat -c '%U:%G' /app/app.py 2>/dev/null)" || \
  fail "the application file ownership could not be inspected"
[[ "${app_owner}" == "appuser:appuser" ]] || \
  fail "app.py must be owned by appuser:appuser, but found ${app_owner}"

if docker exec "${VERIFY_CONTAINER}" touch /root/permission-test >/dev/null 2>&1; then
  fail "appuser can write inside /root"
fi

echo "Waiting for Docker to report a healthy container..."
if ! wait_for_health "healthy" 20; then
  fail "expected health=healthy, but found $(health_status)"
fi

if ! docker exec "${VERIFY_CONTAINER}" python -c \
  "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"; then
  fail "the application health endpoint did not respond successfully"
fi

echo "Simulating an application failure..."
if ! docker exec "${VERIFY_CONTAINER}" touch /tmp/app-unhealthy; then
  fail "the controlled failure could not be enabled"
fi

if ! wait_for_health "unhealthy" 30; then
  fail "expected health=unhealthy, but found $(health_status)"
fi

container_running="$(docker inspect --format '{{.State.Running}}' "${VERIFY_CONTAINER}" 2>/dev/null)" || \
  fail "the container state could not be inspected"
[[ "${container_running}" == "true" ]] || \
  fail "the application process stopped during the health-check test"

echo "Verification passed: Checkov, permissions, application response, and health status are correct."
