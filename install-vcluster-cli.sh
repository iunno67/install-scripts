#!/usr/bin/env bash

set -eu
set -o pipefail

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == "x86_64" ]; then
  ARCH=amd64
fi

PACKAGE_NAME=vcluster
VERSION=0.15.0

URL="https://github.com/loft-sh/vcluster/releases/download/v${VERSION}/vcluster-${OS}-${ARCH}"
SHAS='
{
  "darwin": {
    "amd64": "f5c94f4e08190b7e37fb549d7e35fbf6c43a2449136bbaf368bd2299531f9c32",
    "arm64": "b41e9d161c3b0ae6dabccd21fc2b36b7c876bb815b3d039d15331e439135d690"
  },
  "windows": {
    "amd64": "todo",
    "arm64": "todo"
  },
  "linux": {
    "amd64": "e80ff494d705324b9a9f8a8998402a687f47fe219e0a6d0a50e06a851591bbdf",
    "arm64": "16a8446435dca29957d01e4c886ef87010f7f2b14c6a114e792528ab1d457a9c"
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
