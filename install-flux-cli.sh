#!/usr/bin/env bash

set -eu
set -o pipefail


OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == x86_64 ]; then
  ARCH=amd64
fi

PACKAGE_NAME=flux
VERSION=0.41.2

URL="https://github.com/fluxcd/flux2/releases/download/v${VERSION}/flux_${VERSION}_${OS}_${ARCH}.tar.gz"
SHA="13f5ab2a93812c26c6b921274c40451d1b29a259da4e9c4d38b112cc4dad562a"
SHA_ALG=256

BIN_DIR="${HOME}/local/bin"
TARGET="${HOME}/local/out/${PACKAGE_NAME}-${VERSION}"
TEMP_DIR="${HOME}/temp/builds/build-${PACKAGE_NAME}-${VERSION}-$(date +"%Y%m%d%H%M%S")"
mkdir -p "${TEMP_DIR}"


echo "OS: ${OS}"
echo "ARCH: ${ARCH}"
echo "PACKAGE_NAME: ${PACKAGE_NAME}"
echo "VERSION: ${VERSION}"
echo "URL: ${URL}"
echo "SHA: ${SHA}"
echo "SHA_ALG: ${SHA_ALG}"
echo "TARGET: ${TARGET}"
echo "TEMP_DIR: ${TEMP_DIR}"

cleanup() {
  echo "cleanup"
  rm -rf "${TEMP_DIR}"
}

trap cleanup EXIT INT QUIT TERM

curl -sSL -o "${TEMP_DIR}/package.tar.gz" "${URL}"
cd "${TEMP_DIR}"
tar xf "${TEMP_DIR}/package.tar.gz"

echo "${SHA}  ${TEMP_DIR}/package.tar.gz" > "${TEMP_DIR}/sha.sum"
cat "${TEMP_DIR}/sha.sum"
ls
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"

mkdir -p "${TARGET}/bin"
mv "${PACKAGE_NAME}" "${TARGET}/bin/${PACKAGE_NAME}"

ls "${TARGET}/bin" | while read -r exe; do
  ln -s "${TARGET}/bin/${exe}" "${BIN_DIR}/${exe}"
done
