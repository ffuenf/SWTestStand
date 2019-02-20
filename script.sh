#!/usr/bin/env bash
set -e
set -x

function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
    rm -rf ${WORKSPACE}/build
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

${BUILDENV}/dependencies.sh

${BUILDENV}/shopware.sh

cd ${BUILDENV}/shopware/custom/plugins/${PLUGIN_NAME}

if [ ! -z $PHPCS ] ; then
  php $HOME/.cache/bin/phpcs --config-set ignore_warnings_on_exit true
  php $HOME/.cache/bin/phpcs
fi

mv ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini.disabled ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini
phpenv rehash;

if [ -f tests/phpunit.xml ]
then
    $HOME/.cache/bin/phpunit -c tests/phpunit.xml --coverage-clover=${WORKSPACE}/build/logs/coverage.clover --colors -d display_errors=1
fi

if [ -f tests/phpunit_unit.xml ]
then
    $HOME/.cache/bin/phpunit -c tests/phpunit_unit.xml --coverage-clover=${WORKSPACE}/build/logs/coverage_unit.clover --colors -d display_errors=1
fi

$HOME/.cache/bin/phpspec run --format dot

echo "Exporting code coverage results to scrutinizer-ci"
cd ${WORKSPACE}
if [ ! -z $SCRUTINIZER_ACCESS_TOKEN ] ; then
  php -f $HOME/.cache/bin/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover ${WORKSPACE}/build/logs/coverage.clover
else
  php -f $HOME/.cache/bin/ocular code-coverage:upload --format=php-clover ${WORKSPACE}/build/logs/coverage.clover
fi

echo "Done."