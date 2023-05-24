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
SHAS='
{
  "darwin": {
    "amd64": "e2cede1965afa66dc52de7c1cd461227f4ff924f7a2adc9791cf1a699485409f",
    "arm64": "00fc991977232240893ae36dc852366af859214d6e1b2b9e03e93b8f9f0991a7"
  },
  "windows": {
    "amd64": "0aec9ea6b4095250406f8072d959bbea4c29bdcf9f85579f2c6dc915ce75082e",
    "arm64": "262f381041d6ebdf6a8b87fe482077efd9212e7d195a81fe437a2c24afe4d871"
  },
  "linux": {
    "amd64": "38c9a2f484076aeafd9f522efdee40538c31337539bd8c80a29f5c4077314e53",
    "arm64": "735fa1b9bb02ef0ee79dd40c418760687776b44747f43f2e26c3bca4e1fd96f6"
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

curl -sSL -o "${TEMP_DIR}/package.tar.gz" "${URL}"
cd "${TEMP_DIR}"
tar xzf "${TEMP_DIR}/package.tar.gz"

echo "${SHA}  ${TEMP_DIR}/package.tar.gz" > "${TEMP_DIR}/sha.sum"
cat "${TEMP_DIR}/sha.sum"
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"

mv "${TEMP_DIR}/cue" "${TARGET_DIR}/cue"
ln -fs "${TARGET_DIR}/cue" "${BIN_DIR}/cue"
