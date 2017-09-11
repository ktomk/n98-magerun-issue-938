#!/bin/bash
#
# test-stand for the broken magento installer
#
set -euo pipefail
IFS=$'\n\t'

# magerun source directory
DIR_SRC_MAGERUN="../../build-mageruns/n98-magerun"

# magerun command
# magerun cmd in README.md: "./bin/n98-magerun-1.98.0.phar"
CMD_MAGERUN="${DIR_SRC_MAGERUN}/bin/n98-magerun"

# directory to clone into and URI to clone from
DIR_CLONE="n98-magerun-1-98-0-broken"

# magerun installation folder (inside the clone, fixed)
DIR_INSTALL="htdocs"

if [[ ! -d "${DIR_CLONE}" ]]; then
  git clone https://github.com/convenient/n98-magerun-1-98-0-broken "${DIR_CLONE}"
fi
cd "${DIR_CLONE}"

# create magerun stop-file
echo "${DIR_CLONE}/${DIR_INSTALL}" > "../.n98-magerun"

# clear out downloaded Magento if it already exists
if [[ -f "./${DIR_INSTALL}/app/Mage.php" ]]; then
  rm -rf "./${DIR_INSTALL}"
  git reset --hard HEAD
fi

# build n98-magerun.phar
function build_magerun() {
  (
    cd "${DIR_SRC_MAGERUN}"
    ./build.sh
    chmod +x n98-magerun.phar
  )
  CMD_MAGERUN="${DIR_SRC_MAGERUN}/n98-magerun.phar"
}


# build_magerun
echo "magerun cmd: ${CMD_MAGERUN}"

${CMD_MAGERUN} --version

# install magento + apply magento installer "patch"
if [[ -d "vendor" ]]; then
  rm -rf "vendor"
fi
composer install -o --no-interaction


# "install" magento, initialize via magerun
${CMD_MAGERUN} install --useDefaultConfigParams=yes \
  --magentoVersionByName="magento-mirror-1.9.3.4" \
  --noDownload --forceUseDb \
  --installSampleData=no \
  --dbHost="127.0.0.1:3306" --dbUser="root" --dbPass="" --dbName="show_magerun_bug" \
  --baseUrl="http://example.com/" --installationFolder="${DIR_INSTALL}"


# demonstrate the fail
${CMD_MAGERUN}
