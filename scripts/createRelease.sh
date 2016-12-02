#!/bin/sh

function realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
ROOT_DIR=$SCRIPT_DIR/..

if [ "$#" -gt 1 ]; then
  echo "Usage: [<version>]"
  echo " 1st arg (optional): version for the release" 
  echo ""
  exit -1
fi

RELEASE_DIR=$(realpath $ROOT_DIR)

# For use to create final release tarball
source $SCRIPT_DIR/version
if [ "$#" -gt 0 ]; then
  VERSION="$1"
  printf "VERSION=%s\n" $VERSION > $SCRIPT_DIR/version
else
  # Increment current version and save it back out
  perl -i -pe 's/VERSION=\d+\.\d+\.\K(\d+)/ $1+1 /e' $SCRIPT_DIR/version
  source $SCRIPT_DIR/version
fi

RELEASE_NAME=aerospike-enterprise-edition

cd $RELEASE_DIR

echo "Cleanup previous release ..."
rm -rf releases/* dev_releases/* .dev_builds/* .final_builds/*

echo "Creating the release ..."
bosh -n create release --name $RELEASE_NAME --version $VERSION --with-tarball --force 
echo "Done creating the release ..."
