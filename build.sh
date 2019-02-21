#!/usr/bin/env bash
set -e
set -x

commit=$1
if [ -z ${commit} ]; then
    commit=$(git tag --sort=-creatordate | head -1)
    if [ -z ${commit} ]; then
        commit="master";
    fi
fi

if [ $TRAVIS_TAG != '' ]; then
  RELEASEDIR=`mktemp -d /tmp/$PLUGIN_NAME-$TRAVIS_TAG.XXXXXXXX`
  echo "Using release directory ${RELEASEDIR}"
  cd ${TRAVIS_BUILD_DIR}
  rsync -av \
    --exclude='build/' \
    --exclude='.travis/' \
    --exclude='.travis.yml' \
    --exclude='.git/' \
    --exclude='.gitignore' \
    --exclude='.gitmodules' \
    --exclude='tests' \
    . ${RELEASEDIR}/$PLUGIN_NAME/
  cd ${RELEASEDIR}/
  zip -r $PLUGIN_NAME-$TRAVIS_TAG.zip $PLUGIN_NAME
  mv $PLUGIN_NAME-$TRAVIS_TAG.zip ${TRAVIS_BUILD_DIR}
  tar -czf $PLUGIN_NAME-$TRAVIS_TAG.tar.gz $PLUGIN_NAME
  mv $PLUGIN_NAME-$TRAVIS_TAG.tar.gz ${TRAVIS_BUILD_DIR}
  rm -rf ${RELEASEDIR}
  echo "Bundled release $TRAVIS_TAG"
fi