#!/usr/bin/env bash
set -e
set -x

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