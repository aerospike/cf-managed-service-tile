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

RELEASE_NAME=aerospike_server
RELEASE_TAR_NAME="$RELEASE_NAME-$VERSION.tgz"
# Before running this, it's necessary to add the server tar to the blob store
# e.g bosh add-blob ee-enterprise-edition.tgz ee-enterprise-edition.tgz

cd $RELEASE_DIR

echo "Cleanup previous release ..."
rm -rf releases/* dev_releases/* .dev_builds/* .final_builds/*

echo "Creating the release ..."
bosh -n create-release --name $RELEASE_NAME --version $VERSION --tarball $RELEASE_TAR_NAME --force --sha2
echo "Done creating the release ..."
echo "Moving the tar file to the release directory"
cp $RELEASE_TAR_NAME dev_releases/*/

