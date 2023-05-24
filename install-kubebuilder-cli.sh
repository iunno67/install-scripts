#!/usr/bin/env bash

set -eu
set -o pipefail

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == "x86_64" ]; then
  ARCH=amd64
fi

PACKAGE_NAME=kubebuilder
VERSION=3.10.0

URL="https://github.com/kubernetes-sigs/kubebuilder/releases/download/v${VERSION}/kubebuilder_${OS}_${ARCH}"
SHAS='
{
  "darwin": {
    "amd64": "f27ac711e33ba794398ea6bd5b7447fc297f4c0f8c7a6bd01755f22e515cbf3a",
    "arm64": "6d47e6d15508738b07da360529baefc246e589b0ebe8d54a6a8818a30ca24e90"
  },
  "linux": {
    "amd64": "d9ba5517a8cc8acaa9cf46c62525db7c5b2d3fd160618904a7796491e3f1ea21",
    "arm64": "7ac513787b4870e3a390b711fffb7d7e519638335f8338abba32f5796c047252"
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
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"
mkdir -p "${TARGET_DIR}/bin"
mv "${TEMP_DIR}/exe" "${TARGET_DIR}/bin/${PACKAGE_NAME}"
chmod +x "${TARGET_DIR}/bin/${PACKAGE_NAME}"

ls "${TARGET_DIR}/bin" | while read -r exe; do
  ln -fs "${TARGET_DIR}/bin/${exe}" "${BIN_DIR}/${exe}"
done
