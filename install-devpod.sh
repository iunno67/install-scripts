#!/usr/bin/env bash

set -eu
set -o pipefail

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == "x86_64" ]; then
  ARCH=amd64
fi

PACKAGE_NAME=devpod
VERSION=0.2.1

URL="https://github.com/loft-sh/devpod/releases/download/v${VERSION}/devpod-${OS}-${ARCH}"
SHAS='
{
  "darwin": {
    "amd64": "TODO",
    "arm64": "83ae8796363d5bc638458500cb6e25ad3592bc89c8aa7f5ed0705314e6a3f326"
  },
  "linux": {
    "amd64": "TODO",
    "arm64": "TODO"
  }
}'
SHA="$(echo "${SHAS}" | jq -r ".${OS}.${ARCH}")"
SHA_ALG=256

TEMP_DIR="${HOME}/temp/builds/build-${PACKAGE_NAME}-${VERSION}-$(date +"%Y%m%d%H%M%S")"
TARGET_DIR="${HOME}/local/out/${PACKAGE_NAME}-${VERSION}"
BIN_DIR="${HOME}/local/bin"

echo "OS: ${OS}"
echo "ARCH: ${ARCH}"
echo "PACKAGE_NAME: ${PACKAGE_NAME}"
echo "VERSION: ${VERSION}"
echo "URL: ${URL}"
echo "SHA: ${SHA}"
echo "SHA_ALG: ${SHA_ALG}"
echo "TEMP_DIR: ${TEMP_DIR}"
echo "TARGET_DIR: ${TARGET_DIR}"
echo "BIN_DIR: ${BIN_DIR}"

cleanup() {
  rm -rf "${TEMP_DIR}"
}

trap cleanup EXIT INT QUIT TERM

rm -rf "${TEMP_DIR}"
rm -rf "${TARGET_DIR}"

mkdir -p "${TEMP_DIR}"
mkdir -p "${BIN_DIR}"
mkdir -p "${TARGET_DIR}"

curl -sSL -o "${TEMP_DIR}/exe" "${URL}"
cd "${TEMP_DIR}"

echo "${SHA}  ${TEMP_DIR}/exe" > "${TEMP_DIR}/sha.sum"
cat "${TEMP_DIR}/sha.sum"
shasum -a "${SHA_ALG}" "${TEMP_DIR}/exe"
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"
mkdir -p "${TARGET_DIR}/bin"
mv "${TEMP_DIR}/exe" "${TARGET_DIR}/bin/${PACKAGE_NAME}"
chmod +x "${TARGET_DIR}/bin/${PACKAGE_NAME}"

ls "${TARGET_DIR}/bin" | while read -r exe; do
  ln -fs "${TARGET_DIR}/bin/${exe}" "${BIN_DIR}/${exe}"
done
