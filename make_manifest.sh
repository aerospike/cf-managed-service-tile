set -e

template_prefix="aerospike-managed-service"

infrastructure=$1
STEMCELL_OS=${STEMCELL_OS:-ubuntu}

if [ "$infrastructure" != "vsphere" ] && \
   [ "$infrastructure" != "warden" ] ; then
  echo "usage: ./make_manifest.sh <warden|vsphere> "
  exit 1
fi

shift

BOSH_STATUS=$(bosh status)
DIRECTOR_UUID=$(echo "$BOSH_STATUS" | grep UUID | awk '{print $2}')
DIRECTOR_CPI=$(echo "$BOSH_STATUS" | grep CPI | awk '{print $2}')
DIRECTOR_NAME=$(echo "$BOSH_STATUS" | grep Name | awk '{print $2}')

NAME=${NAME:-$template_prefix-$DIRECTOR_CPI}

echo $NAME

function latest_uploaded_stemcell {
  bosh stemcells | grep bosh | grep $STEMCELL_OS | awk -F'|' '{ print $2, $3 }' | sort -nr -k2 | head -n1 | awk '{ print $1 }'
}

STEMCELL=${STEMCELL:-$(latest_uploaded_stemcell)}

echo $STEMCELL

templates=$(dirname $0)/templates
release=$templates/..
tmpdir=$release/tmp

echo $tmpdir

mkdir -p $tmpdir
cp $templates/stub-normal.yml $tmpdir/stub-with-uuid.yml

perl -pi -e "s/PLACEHOLDER-DIRECTOR-UUID/$DIRECTOR_UUID/g" $tmpdir/stub-with-uuid.yml
perl -pi -e "s/NAME/$NAME/g" $tmpdir/stub-with-uuid.yml
perl -pi -e "s/STEMCELL/$STEMCELL/g" $tmpdir/stub-with-uuid.yml

spiff merge \
  $templates/deployment.yml \
  $templates/jobs.yml \
  $templates/aerospikeserver-properties.yml \
  $templates/infrastructure-${infrastructure}.yml \
  $tmpdir/stub-with-uuid.yml \
  $* > $tmpdir/$NAME-manifest.yml

mv $tmpdir/$NAME-manifest.yml .
rm -rf $tmpdir

echo ""
echo "Generated bosh deployment manifest for ${infrastructure}:  $NAME-manifest.yml"

bosh deployment $NAME-manifest.yml
bosh status