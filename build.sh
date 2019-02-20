#!/usr/bin/env bash
set -e
set -x

PLUGIN_NAME=$1
commit=$2
if [ -z ${commit} ]; then
    commit=$(git tag --sort=-creatordate | head -1)
    if [ -z ${commit} ]; then
        commit="master";
    fi
fi

rm -rf ${PLUGIN_NAME} ${PLUGIN_NAME}-*.zip

if [ "$TRAVIS_TAG" != "" ]; then
  RELEASEDIR=`mktemp -d /tmp/${PLUGIN_NAME}-${TRAVIS_TAG}.XXXXXXXX`
  echo "Using release directory ${RELEASEDIR}"
  cd $WORKSPACE
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