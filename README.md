## Aerospike Managed Service for Pivotal Cloud Foundry

This project implements a managed service tile which can be installed into Pivotal Cloud Foundry. The tile will manage the creation of an Aerospike database cluster and also handle creating/binding services to applications.

### Requirements

The project  depends on the [Aerospike Service Broker project](https://github.com/aerospike/cf-aerospike-service-broker). Additionally, it requires a binary install version of the Aerospike DB (community or enterprise) along with the Aerospike tools. It also requires the [Pivotal Tile Generator](https://github.com/cf-platform-eng/tile-generator) project.

### Build

The project currently supports either a bosh-lite or vSphere deploy. Follow these steps to build the tile:


1. Install tile-generator
2. Download the aerospike enterprise tgz file and add them into the ```resources/aerospike_server directory```
3. Run ```bosh add-blob name-of-ee-aerospike.tgz name-of-ee-aerospike.tgz``` From the ```resources/aerospike_server``` directory.
4. run ```createRelease.sh``` from the ```resources/aerospike_server/scripts``` directory. This will generate a file named aerospike_server-#.#.#.tgz
5. Clone the [Aerospike Service Broker project](https://github.com/aerospike/cf-aerospike-service-broker) and follow the instructions on building the Service Broker. Copy the service broker Spring Boot jar file to the ```resources``` directory

6. Edit the tile.yml file to point to the correct versions of the server release and service broker jar
7. Run ```tile build``` from the root directory of this project
8. This will create an ```aerospike-enterprise-edition-X.X.X.pivotal``` file in the product directory. This is the service broker tile that can be imported into Pivotal Cloud Foundry.


### Example Application

There is an [example application](https://github.com/aerospike/cf-example-application.git) which demonstrates how to get the database parameters from the Service Broker.

