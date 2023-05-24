#!/usr/bin/env bash

set -eu
set -o pipefail

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "${ARCH}" == "x86_64" ]; then
  ARCH=amd64
fi

PACKAGE_NAME=helm
VERSION="3.12.0"

URL="https://get.helm.sh/helm-v${VERSION}-${OS}-${ARCH}.tar.gz"
SHAS='
{
  "darwin": {
    "amd64": "8223beb796ff19b59e615387d29be8c2025c5d3aea08485a262583de7ba7d708",
    "arm64": "879f61d2ad245cb3f5018ab8b66a87619f195904a4df3b077c98ec0780e36c37"
  },
  "windows": {
    "amd64": "none",
    "arm64": "none"
  },
  "linux": {
    "amd64": "da36e117d6dbc57c8ec5bab2283222fbd108db86c83389eebe045ad1ef3e2c3b",
    "arm64": "658839fed8f9be2169f5df68e55cb2f0aa731a50df454caf183186766800bbd0"
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

curl -sSL -o "${TEMP_DIR}/package" "${URL}"
cd "${TEMP_DIR}"

echo "${SHA}  ${TEMP_DIR}/package" > "${TEMP_DIR}/sha.sum"
cat "${TEMP_DIR}/sha.sum"
shasum -a "${SHA_ALG}" -c "${TEMP_DIR}/sha.sum"
tar xf "${TEMP_DIR}/package"

mv "${OS}-${ARCH}/${PACKAGE_NAME}" "${PACKAGE_NAME}"

mkdir -p "${TARGET_DIR}/bin"
mv "${TEMP_DIR}/${PACKAGE_NAME}" "${TARGET_DIR}/bin/${PACKAGE_NAME}"
chmod 0700 "${TARGET_DIR}/bin/${PACKAGE_NAME}"

ls "${TARGET_DIR}/bin" | while read -r exe; do
  ln -fs "${TARGET_DIR}/bin/${exe}" "${BIN_DIR}/${exe}"
done
