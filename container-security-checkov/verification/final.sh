#!/bin/bash

set -u

readonly TUTORIAL_DIRECTORY="/root/tutorial"
readonly IMAGE="checkov-tutorial:fixed"
readonly CONTAINER="checkov-tutorial"
readonly CHECKOV_LOG="/tmp/checkov-final-verification.log"

fail() {
  echo "Verification failed: $1" >&2
  exit 1
}

health_status() {
  docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' \
    "${CONTAINER}" 2>/dev/null
}

wait_for_health() {
  local expected="$1"
  local attempts="$2"

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    [[ "$(health_status)" == "${expected}" ]] && return 0
    sleep 1
  done

  return 1
}

cd "${TUTORIAL_DIRECTORY}" || fail "tutorial files were not found"

echo "Checking the Dockerfile policies..."
if ! checkov -f Dockerfile --framework dockerfile --skip-download \
  --check CKV_DOCKER_2,CKV_DOCKER_3,CKV_DOCKER_7 \
  >"${CHECKOV_LOG}" 2>&1; then
  cat "${CHECKOV_LOG}" >&2
  fail "the Dockerfile does not pass all three Checkov policies"
fi

docker image inspect "${IMAGE}" >/dev/null 2>&1 || \
  fail "the fixed image was not built"

docker inspect "${CONTAINER}" >/dev/null 2>&1 || \
  fail "the tutorial container is not running"

container_image="$(docker inspect --format '{{.Config.Image}}' "${CONTAINER}" 2>/dev/null)" || \
  fail "the container image could not be inspected"
[[ "${container_image}" == "${IMAGE}" ]] || \
  fail "the container must use ${IMAGE}, but found ${container_image}"

container_uid="$(docker exec "${CONTAINER}" id -u 2>/dev/null)" || \
  fail "the container user could not be inspected"
[[ "${container_uid}" != "0" ]] || \
  fail "the container must run as a non-root user"

container_user="$(docker exec "${CONTAINER}" id -un 2>/dev/null)" || \
  fail "the container user name could not be inspected"
[[ "${container_user}" == "appuser" ]] || \
  fail "the container must run as appuser, but found ${container_user}"

app_owner="$(docker exec "${CONTAINER}" stat -c '%U:%G' /app/app.py 2>/dev/null)" || \
  fail "the application file ownership could not be inspected"
[[ "${app_owner}" == "appuser:appuser" ]] || \
  fail "app.py must be owned by appuser:appuser, but found ${app_owner}"

if docker exec "${CONTAINER}" touch /root/permission-test >/dev/null 2>&1; then
  fail "appuser can write inside /root"
fi

if ! wait_for_health "healthy" 20; then
  fail "expected health=healthy, but found $(health_status)"
fi

docker exec "${CONTAINER}" touch /tmp/app-unhealthy || \
  fail "the controlled application failure could not be enabled"

if ! wait_for_health "unhealthy" 30; then
  fail "expected health=unhealthy, but found $(health_status)"
fi

docker exec "${CONTAINER}" rm /tmp/app-unhealthy || \
  fail "the controlled application failure could not be removed"

if ! wait_for_health "healthy" 20; then
  fail "expected recovery to health=healthy, but found $(health_status)"
fi

docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
echo "Verification passed: the Dockerfile and container behavior are correct."
