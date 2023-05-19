#!/usr/bin/env bash

set -eu
set -o pipefail


OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == x86_64 ]; then
  ARCH=amd64
fi

PACKAGE_NAME=kind
VERSION=0.18.0

URL="https://github.com/kubernetes-sigs/kind/releases/download/v${VERSION}/kind-${OS}-${ARCH}"
SHA="705c722b0a87c9068e183f6d8baecd155a97a9683949ca837c2a500c9aa95c63"
SHA_ALG=256

BIN_DIR="${HOME}/local/bin"
TARGET_DIR="${HOME}/local/out/${PACKAGE_NAME}-${VERSION}"
TEMP_DIR="${HOME}/temp/builds/build-${PACKAGE_NAME}-${VERSION}-$(date +"%Y%m%d%H%M%S")"
mkdir -p "${TEMP_DIR}"


echo "OS: ${OS}"
echo "ARCH: ${ARCH}"
echo "PACKAGE_NAME: ${PACKAGE_NAME}"
echo "VERSION: ${VERSION}"
echo "URL: ${URL}"
echo "SHA: ${SHA}"
echo "SHA_ALG: ${SHA_ALG}"
echo "TARGET_DIR: ${TARGET_DIR}"
echo "TEMP_DIR: ${TEMP_DIR}"

cleanup() {
  echo "cleanup"
  rm -rf "${TEMP_DIR}"
}

trap cleanup EXIT INT QUIT TERM

rm -rf "${TEMP_DIR}"
rm -rf "${TARGET_DIR}"

mkdir -p "${TEMP_DIR}"
mkdir -p "${BIN_DIR}"
mkdir -p "${TARGET_DIR}"

curl -sSL -o "${TEMP_DIR}/${PACKAGE_NAME}" "${URL}"
cd "${TEMP_DIR}"

echo "${SHA}  ${TEMP_DIR}/${PACKAGE_NAME}" > "${TEMP_DIR}/sha.sum"
cat "${TEMP_DIR}/sha.sum"
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"
chmod +x "${PACKAGE_NAME}"

mkdir -p "${TARGET_DIR}/bin"
mv "${PACKAGE_NAME}" "${TARGET_DIR}/bin/${PACKAGE_NAME}"

ls "${TARGET_DIR}/bin" | while read -r exe; do
  ln -fs "${TARGET_DIR}/bin/${exe}" "${BIN_DIR}/${exe}"
done
