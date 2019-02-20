#!/usr/bin/env bash
set -e
set -x

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
HOME=`dirname "${ABSPATH}"`
SHOPWARE_DIRECTORY="${HOME}/shopware"
PLUGIN_DIRECTORY="${SHOPWARE_DIRECTORY}/custom/plugins"

echo
echo "----------------------"
echo "- Ffuenf SWTestStand -"
echo "----------------------"
echo
echo "Installing ${SHOPWARE_VERSION} in ${HOME}/shopware"
echo

cd ${HOME}

git clone https://github.com/shopware/shopware.git ${SHOPWARE_DIRECTORY} --branch ${SHOPWARE_VERSION}
ant -f ${SHOPWARE_DIRECTORY}/build/build.xml -Dapp.host=localhost -Ddb.user=travis -Ddb.host=127.0.0.1 -Ddb.name=shopware build-unit
mv ${WORKSPACE}/build/dependencies/FfuenfCommon ${PLUGIN_DIRECTORY}/FfuenfCommon
php ${HOME}/shopware/bin/console sw:plugin:refresh
php ${HOME}/shopware/bin/console sw:plugin:install FfuenfCommon
php ${HOME}/shopware/bin/console sw:plugin:activate FfuenfCommon
mv ${TRAVIS_BUILD_DIR} ${PLUGIN_DIRECTORY}/${PLUGIN_NAME}
php ${HOME}/shopware/bin/console sw:plugin:refresh
php ${HOME}/shopware/bin/console sw:plugin:install ${PLUGIN_NAME}
php ${HOME}/shopware/bin/console sw:plugin:activate ${PLUGIN_NAME}

if [ ! -f composer.lock ]
then
    composer install --no-interaction --prefer-dist
fi

cd ${PLUGIN_DIRECTORY}/${PLUGIN_NAME}