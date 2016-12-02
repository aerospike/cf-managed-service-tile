pushd ..
  bosh  deployment development/cf-deployment-manifest.yml
  bosh -n delete deployment aerospike-managed-service
  bosh -n delete release aerospike-managed-service
  rm -rf dev_releases
  bosh create release --force --with-tarball --version 0.1.2
  bosh upload release
  bosh -n deploy
popd