#!/bin/sh

function realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
ROOT_DIR=$SCRIPT_DIR/..

RELEASE_DIR=$(realpath $ROOT_DIR)

if [ "$#" -gt 1 ]; then
  echo "Usage: [<version>]"
  echo " 1st arg (optional): version for the tile" 
  echo ""
  exit -1
fi

source $SCRIPT_DIR/tile_version
if [ "$#" -gt 0 ]; then
  TILE_VERSION="$1"
  printf "TILE_VERSION=%s\n" $TILE_VERSION > $SCRIPT_DIR/tile_version
else
  # Increment current version and save it back out
  perl -i -pe 's/TILE_VERSION=\d+\.\d+\.\K(\d+)/ $1+1 /e' $SCRIPT_DIR/tile_version
  source $SCRIPT_DIR/tile_version
fi
source $SCRIPT_DIR/version

TILE=Aerospike-EE-Managed-Service-v${TILE_VERSION}.pivotal
RELEASE_TARFILE=$ROOT_DIR/dev_releases/*/*.tgz

TEMPLATES_DIR=$ROOT_DIR/templates
TILE_FILE_FULL_PATH=`ls $TEMPLATES_DIR/cf-managed-service-tile.erb`

mkdir -p tmp
pushd tmp
#Dont bundle the stemcell into the .pivotal Tile file as the stemcell must already be available in the Ops Mgr or needs to be imported
  mkdir -p metadata releases migrations/v1
  migrations_timestamp=`date +"%Y%m%d%H%M"`

  cp $TEMPLATES_DIR/*migration.js migrations/v1/${migrations_timestamp}_migration.js
  ruby $SCRIPT_DIR/generateYml.rb $TILE_VERSION $VERSION $TILE_FILE_FULL_PATH > metadata/cf-managed-service-tile.yml

  cp $RELEASE_TARFILE releases

  # Ignore bundling the stemcell as most often the Ops Mgr carries the stemcell.
  # If Ops Mgr complains of missing stemcell, change the version specified inside the tile to the one that Ops mgr knows about

  #if [ ! -e "stemcells/$BOSH_STEMCELL_FILE" ]; then
  #  curl -k $BOSH_STEMCELL_LOCATION/$BOSH_STEMCELL_FILE -o stemcells/$BOSH_STEMCELL_FILE
  #fi
  zip -r ${TILE} metadata releases migrations
  mv ${TILE} ..
popd

rm -rf tmp
