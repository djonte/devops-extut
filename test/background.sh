#!/bin/bash

set -euo pipefail

readonly CHECKOV_VERSION="3.3.8"
readonly CHECKOV_ARCHIVE="/tmp/checkov-${CHECKOV_VERSION}.zip"
readonly CHECKOV_DIRECTORY="/opt/checkov-${CHECKOV_VERSION}"
readonly CHECKOV_SHA256="7f9f62eb3812fee7cb9c570503a266a599f5458b362fe581c14dcf4a44027bd4"
readonly CHECKOV_URL="https://github.com/bridgecrewio/checkov/releases/download/${CHECKOV_VERSION}/checkov_linux_X86_64.zip"

setup_failed() {
  touch /tmp/tutorial-setup-failed
}

trap setup_failed ERR

if ! command -v checkov >/dev/null 2>&1; then
  curl --fail --location --silent --show-error "${CHECKOV_URL}" --output "${CHECKOV_ARCHIVE}"
  echo "${CHECKOV_SHA256}  ${CHECKOV_ARCHIVE}" | sha256sum --check --status
  mkdir -p "${CHECKOV_DIRECTORY}"
  python3 -m zipfile --extract "${CHECKOV_ARCHIVE}" "${CHECKOV_DIRECTORY}"
  install -m 0755 "${CHECKOV_DIRECTORY}/dist/checkov" /usr/local/bin/checkov
fi

touch /tmp/tutorial-ready
