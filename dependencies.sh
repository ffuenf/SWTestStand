#!/usr/bin/env bash
set -e
set -x

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
HOME=`dirname "${ABSPATH}"`

mkdir -p ${HOME}/build/dependencies
if [ ! -d ${HOME}/build/dependencies/FfuenfCommon ] ; then
  git clone https://github.com/ffuenf/FfuenfCommon ${HOME}/build/dependencies
fi