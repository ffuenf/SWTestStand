#!/usr/bin/env bash
set -e
set -x

function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
  fi
}

trap cleanup EXIT

# check if this is a travis environment
if [ ! -z $TRAVIS_BUILD_DIR ] ; then
  WORKSPACE=$TRAVIS_BUILD_DIR
fi

if [ -z $WORKSPACE ] ; then
  echo "No workspace configured, please set your WORKSPACE environment"
  exit
fi

BUILDENV=`mktemp -d /tmp/swteststand.XXXXXXXX`

echo "Using build directory ${BUILDENV}"

git clone https://github.com/ffuenf/SWTestStand "${BUILDENV}"

mkdir -p ${WORKSPACE}/build/logs

${BUILDENV}/dependencies.sh ${WORKSPACE}

${BUILDENV}/shopware.sh

cd ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}

if [ ! -z $PHPCS ] ; then
  php $HOME/.cache/bin/phpcs --config-set ignore_warnings_on_exit true
  php $HOME/.cache/bin/phpcs
fi

mv ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini.disabled ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini
phpenv rehash;

if [ -f ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit.xml ]
then
    $HOME/.cache/bin/phpunit -c ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit.xml --coverage-clover=${WORKSPACE}/build/logs/coverage.clover --colors -d display_errors=1
fi

if [ -f ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit_unit.xml ]
then
    $HOME/.cache/bin/phpunit -c ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit_unit.xml --coverage-clover=${WORKSPACE}/build/logs/coverage_unit.clover --colors -d display_errors=1
fi

echo "Exporting code coverage results to scrutinizer-ci"
cd ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}
if [ ! -z $SCRUTINIZER_ACCESS_TOKEN ] ; then
  if [ -f ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit.xml ]
  then
      php -f $HOME/.cache/bin/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover ${WORKSPACE}/build/logs/coverage.clover
  fi
  if [ -f ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit_unit.xml ]
  then
      php -f $HOME/.cache/bin/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover ${WORKSPACE}/build/logs/coverage_unit.clover
  fi
else
  if [ -f ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit.xml ]
  then
      php -f $HOME/.cache/bin/ocular code-coverage:upload --format=php-clover ${WORKSPACE}/build/logs/coverage_unit.clover
  fi
  if [ -f ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}/tests/phpunit_unit.xml ]
  then
      php -f $HOME/.cache/bin/ocular code-coverage:upload --format=php-clover ${WORKSPACE}/build/logs/coverage_unit.clover
  fi
fi

if [ "$TRAVIS_TAG" != "" ]; then
  RELEASEDIR=`mktemp -d /tmp/${PLUGIN_NAME}-${TRAVIS_TAG}.XXXXXXXX`
  echo "Using release directory ${RELEASEDIR}"
  cd ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}
  rsync -av \
    --exclude='build/' \
    --exclude='.travis/' \
    --exclude='.travis.yml' \
    --exclude='.git/' \
    --exclude='.gitignore' \
    --exclude='.gitmodules' \
    --exclude='build.sh' \
    --exclude='phpunit.xml.dist' \
    --exclude='tests' \
    . ${RELEASEDIR}/${PLUGIN_NAME}/
  cd ${RELEASEDIR}/
  zip -r ${PLUGIN_NAME}-${TRAVIS_TAG}.zip ${PLUGIN_NAME}
  mv ${PLUGIN_NAME}-${TRAVIS_TAG}.zip $WORKSPACE
  tar -czf ${PLUGIN_NAME}-${TRAVIS_TAG}.tar.gz ${PLUGIN_NAME}
  mv ${PLUGIN_NAME}-${TRAVIS_TAG}.tar.gz $WORKSPACE
  rm -rf ${RELEASEDIR}
  echo "Bundled release ${TRAVIS_TAG}"
fi

echo "Done."