#!/usr/bin/env bash

set -eu
set -o pipefail

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == "x86_64" ]; then
  ARCH=amd64
fi

PACKAGE_NAME=cue
VERSION=0.5.0

URL="https://github.com/cue-lang/cue/releases/download/v${VERSION}/cue_v${VERSION}_${OS}_${ARCH}.tar.gz"
SHA="$(jq -r ".${OS}.${ARCH}" ${PACKAGE_NAME}-shas.json)"
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

curl -sSL -o "${TEMP_DIR}/package.tar.gz" "${URL}"
cd "${TEMP_DIR}"
tar xzf "${TEMP_DIR}/package.tar.gz"

echo "${SHA}  ${TEMP_DIR}/package.tar.gz" > "${TEMP_DIR}/sha.sum"
cat "${TEMP_DIR}/sha.sum"
ls
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"

mv "${TEMP_DIR}/cue" "${TARGET_DIR}/cue"
ln -fs "${TARGET_DIR}/cue" "${BIN_DIR}/cue"
