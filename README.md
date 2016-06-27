## Aerospike Managed Service for Pivotal Cloud Foundry

This project implements a managed service tile which can be installed into Pivotal Cloud Foundry. The tile will manage the creation of an Aerospike database cluster and also handle creating/binding services to applications.

### Requirements

The project requires [spiff](https://github.com/cloudfoundry-incubator/spiff) to be installed and also depends on the [Aerospike Service Broker project](https://github.com/aerospike/cf-aerospike-service-broker). Additionally, it requires a binary install version of the Aerospike DB (community or enterprise) along with the Aerospike tools.

### Build

The project currently supports either a bosh-lite or vSphere deploy. Follow these steps to build the tile:
1. Download the aerospike.tgz and aerospike-tools.tgz binary install packages and put them in the ```resources``` directory
2. Clone the [Aerospike Service Broker project](https://github.com/aerospike/cf-aerospike-service-broker) and follow the instructions on building the Service Broker. Copy the service broker Spring Boot jar file to the ```resources``` directory
3. Install the [spiff](https://github.com/cloudfoundry-incubator/spiff/releases) binaries and be sure they are included in the PATH environment variable
4. Run ```./make_manifest warden|vsphere``` (use warden for Bosh-lite or vsphere for vSphere)
5. Run ```./createRelease``` to create the bosh release
6. Run ```./createTile``` to create the pivotal tile

The tile will be created in the root directory with a name like: ```Aerospike-Managed-Service-vX.X.X.pivotal```. This file can be uploaded into Pivotal Cloud Foundry.

### Example Application

There is an [example application](https://github.com/aerospike/cf-example-application.git) which demonstrates how to get the database parameters from the Service Broker.

