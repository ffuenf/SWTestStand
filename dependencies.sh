#!/usr/bin/env bash
set -e
set -x

mkdir -p ${WORKSPACE}/build/dependencies
if [ ! -d ${WORKSPACE}/build/dependencies/FfuenfCommon ] ; then
  git clone https://github.com/ffuenf/FfuenfCommon ${WORKSPACE}/build/dependencies
fi