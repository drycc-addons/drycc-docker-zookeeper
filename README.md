# Apache ZooKeeper packaged by Bitnami

## What is Apache ZooKeeper?

> Apache ZooKeeper provides a reliable, centralized register of configuration data and services for distributed applications.

[Overview of Apache ZooKeeper](https://zookeeper.apache.org)

This project has been forked from [bitnami-docker-zookeeper](https://github.com/bitnami/bitnami-docker-zookeeper),  We mainly modified the dockerfile in order to build the images of amd64 and arm64 architectures. 

Trademarks: This software listing is packaged by Bitnami. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

## TL;DR

```console
$ docker run --name zookeeper quay.io/drycc-addons/zookeeper:latest
```

### Docker Compose

```yaml
version: '2'

services:
  zookeeper:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    ports:
      - '2181:2181'
```

## Get this image

The recommended way to get the Drycc Apache ZooKeeper Docker Image is to pull the prebuilt image from the [Container Image Registry](https://quay.io/repository/drycc-addons/zookeeper).

```console
$ docker pull quay.io/drycc-addons/zookeeper:latest
```

To use a specific version, you can pull a versioned tag. You can view the(https://quay.io/repository/drycc-addons/zookeeper?tab=tags) in the Container Image Registry.

```console
$ docker pull quay.io/drycc-addons/zookeeper:[TAG]
```

If you wish, you can also build the image yourself.

```console
docker build -t quay.io/drycc-addons/zookeeper:latest 'https://github.com/drycc-addons/drycc-docker-zookeeper.git#main:3.7.1/debian'
```

## Persisting your data

If you remove the container all your data and configurations will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

**Note!**
If you have already started using Apache ZooKeeper, follow the steps on
[backing up](#backing-up-your-container) and [restoring](#restoring-a-backup) to pull the data from your running container down to your host.

The image exposes a volume at `/drycc/zookeeper` for the Apache ZooKeeper data. For persistence you can mount a directory at this location from your host. If the mounted directory is empty, it will be initialized on the first run.

```console
$ docker run -v /path/to/zookeeper-persistence:/drycc/zookeeper quay.io/drycc-addons/zookeeper:latest
```

or by modifying the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-zookeeper/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  zookeeper:
  ...
    volumes:
      - /path/to/zookeeper-persistence:/drycc/zookeeper
  ...
```

> NOTE: As this is a non-root container, the mounted files and directories must have the proper permissions for the UID `1001`.

## Connecting to other containers

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), a Apache ZooKeeper server running inside a container can easily be accessed by your application containers.

Containers attached to the same network can communicate with each other using the container name as the hostname.

### Using the Command Line

In this example, we will create a Apache ZooKeeper client instance that will connect to the server instance that is running on the same docker network as the client.

#### Step 1: Create a network

```console
$ docker network create app-tier --driver bridge
```

#### Step 2: Launch the Apache ZooKeeper server instance

Use the `--network app-tier` argument to the `docker run` command to attach the Apache ZooKeeper container to the `app-tier` network.

```console
$ docker run -d --name zookeeper-server \
    --network app-tier \
    quay.io/drycc-addons/zookeeper:latest
```

#### Step 3: Launch your Apache ZooKeeper client instance

Finally we create a new container instance to launch the Apache ZooKeeper client and connect to the server created in the previous step:

```console
$ docker run -it --rm \
    --network app-tier \
    quay.io/drycc-addons/zookeeper:latest zkCli.sh -server zookeeper-server:2181  get /
```

### Using Docker Compose

When not specified, Docker Compose automatically sets up a new network and attaches all deployed services to that network. However, we will explicitly define a new `bridge` network named `app-tier`. In this example we assume that you want to connect to the Apache ZooKeeper server from your own custom application image which is identified in the following snippet by the service name `myapp`.

```yaml
version: '2'

networks:
  app-tier:
    driver: bridge

services:
  zookeeper:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    networks:
      - app-tier
  myapp:
    image: 'YOUR_APPLICATION_IMAGE'
    networks:
      - app-tier
```

> **IMPORTANT**:
>
> 1. Please update the `YOUR_APPLICATION_IMAGE` placeholder in the above snippet with your application image
> 2. In your application container, use the hostname `zookeeper` to connect to the Apache ZooKeeper server

Launch the containers using:

```console
$ docker-compose up -d
```

## Configuration

The configuration can easily be setup with the Bitnami Apache ZooKeeper Docker image using the following environment variables:

 - `ZOO_PORT_NUMBER`: Apache ZooKeeper client port. Default: **2181**
 - `ZOO_SERVER_ID`: ID of the server in the ensemble. Default: **1**
 - `ZOO_TICK_TIME`: Basic time unit in milliseconds used by Apache ZooKeeper for heartbeats. Default: **2000**
 - `ZOO_PRE_ALLOC_SIZE`': Block size for transaction log file. Default **65536**
 - `ZOO_SNAPCOUNT`: The number of transactions recorded in the transaction log before a snapshot can be taken (and the transaction log rolled). Default **100000**
 - `ZOO_INIT_LIMIT`: Apache ZooKeeper uses to limit the length of time the Apache ZooKeeper servers in quorum have to connect to a leader. Default: **10**
 - `ZOO_SYNC_LIMIT`: How far out of date a server can be from a leader. Default: **5**
 - `ZOO_MAX_CNXNS`: Limits the total number of concurrent connections that can be made to a Apache ZooKeeper server. Setting it to 0 entirely removes the limit. Default: **0**
 - `ZOO_MAX_CLIENT_CNXNS`: Limits the number of concurrent connections that a single client may make to a single member of the Apache ZooKeeper ensemble. Default **60**
 - `ZOO_4LW_COMMANDS_WHITELIST`: List of whitelisted [4LW](https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_4lw) commands. Default **srvr, mntr**
 - `ZOO_SERVERS`: Comma, space or semi-colon separated list of servers. Example: zoo1:2888:3888,zoo2:2888:3888 or if specifying server IDs zoo1:2888:3888::1,zoo2:2888:3888::2. No defaults.
 - `ZOO_CLIENT_USER`: User that will use Apache ZooKeeper clients to auth. Default: No defaults.
 - `ZOO_CLIENT_PASSWORD`: Password that will use Apache ZooKeeper clients to auth. No defaults.
 - `ZOO_CLIENT_PASSWORD_FILE`: Absolute path to a file that contains the password that will be used by Apache ZooKeeper clients to perform authentication. No defaults.
 - `ZOO_SERVER_USERS`: Comma, semicolon or whitespace separated  list of user to be created.  Example: user1,user2,admin. No defaults
 - `ZOO_SERVER_PASSWORDS`: Comma, semicolon or whitespace separated list of passwords to assign to users when created. Example: pass4user1, pass4user2, pass4admin. No defaults
 - `ZOO_SERVER_PASSWORDS_FILE`: Absolute path to a file that contains a comma, semicolon or whitespace separated list of passwords to assign to users when created. Example: pass4user1, pass4user2, pass4admin. No defaults
 - `ZOO_ENABLE_AUTH`: Enable Apache ZooKeeper auth. It uses SASL/Digest-MD5. Default: **no**
 - `ZOO_RECONFIG_ENABLED`: Enable Apache ZooKeeper Dynamic Reconfiguration. Default: **no**
 - `ZOO_LISTEN_ALLIPS_ENABLED`: Listen for connections from its peers on all available IP addresses. Default: **no**
 - `ZOO_AUTOPURGE_INTERVAL`: The time interval in hours for which the autopurge task is triggered. Set to a positive integer (1 and above) to enable auto purging of old snapshots and log files. Default: **0**
 - `ZOO_MAX_SESSION_TIMEOUT`: Maximum session timeout in milliseconds that the server will allow the client to negotiate. Default: **40000**
 - `ZOO_AUTOPURGE_RETAIN_COUNT`: When auto purging is enabled, Apache ZooKeeper retains the most recent snapshots and the corresponding transaction logs in the dataDir and dataLogDir respectively to this number and deletes the rest. Minimum value is 3. Default: **3**
 - `ZOO_HEAP_SIZE`: Size in MB for the Java Heap options (Xmx and XMs). This env var is ignored if Xmx an Xms are configured via `JVMFLAGS`. Default: **1024**
 - `ZOO_ENABLE_PROMETHEUS_METRICS`: Expose Prometheus metrics. Default: **no**
 - `ZOO_PROMETHEUS_METRICS_PORT_NUMBER`: Port where a Jetty server will expose Prometheus metrics. Default: **7000**
 - `ALLOW_ANONYMOUS_LOGIN`: If set to true, Allow to accept connections from unauthenticated users. Default: **no**
 - `ZOO_LOG_LEVEL`: Apache ZooKeeper log level. Available levels are: `ALL`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`, `OFF`, `TRACE`. Default: **INFO**
 - `JVMFLAGS`: Default JVMFLAGS for the Apache ZooKeeper process. No defaults
 - `ZOO_TLS_CLIENT_ENABLE`: Enable tls for client communication. Default: **false**
 - `ZOO_TLS_PORT_NUMBER`: Zookeeper TLS port. Default: 3181
 - `ZOO_TLS_CLIENT_KEYSTORE_FILE`: KeyStore file: Default: No Defaults
 - `ZOO_TLS_CLIENT_KEYSTORE_PASSWORD`: KeyStore file password. This can be an environment variable. It will be evaluated by bash. No Defaults
 - `ZOO_TLS_CLIENT_TRUSTSTORE_FILE`: TrustStore file: Default: No Defaults
 - `ZOO_TLS_CLIENT_TRUSTSTORE_PASSWORD`: TrustStore file password. This can be an environment variable. It will be evaluated by bash. No Defaults
 - `ZOO_TLS_CLIENT_AUTH`: Specifies options to authenticate TLS connections from clients. Available values are: `none`, `want`, `need`. Default: **need**
 - `ZOO_TLS_QUORUM_ENABLE`: Enable tls for quorum communication. Default: **false**
 - `ZOO_TLS_QUORUM_KEYSTORE_FILE`: KeyStore file: Default: No Defaults
 - `ZOO_TLS_QUORUM_KEYSTORE_PASSWORD`: KeyStore file password. This can be an environment variable. It will be evaluated by bash. No Defaults
 - `ZOO_TLS_QUORUM_TRUSTSTORE_FILE`: TrustStore file: Default: No Defaults
 - `ZOO_TLS_QUORUM_TRUSTSTORE_PASSWORD`: TrustStore file password. This can be an environment variable. It will be evaluated by bash. No Defaults
 - `ZOO_TLS_QUORUM_CLIENT_AUTH`: Specifies options to authenticate TLS connections from clients. Available values are: `none`, `want`, `need`. Default: **need**
 - `ZOO_ENABLE_ADMIN_SERVER`: Enable [admin server](https://zookeeper.apache.org/doc/r3.5.7/zookeeperAdmin.html#sc_adminserver). Default: **yes**
 - `ZOO_ADMIN_SERVER_PORT_NUMBER`: [Admin server](https://zookeeper.apache.org/doc/r3.5.7/zookeeperAdmin.html#sc_adminserver) port. Default: **8080**

```console
$ docker run --name zookeeper -e ZOO_SERVER_ID=1 quay.io/drycc-addons/zookeeper:latest
```

or modify the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-zookeeper/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  zookeeper:
  ...
    environment:
      - ZOO_SERVER_ID=1
  ...
```

### Configuration
The image looks for configuration in the `conf/` directory of `/opt/drycc/zookeeper`.

```console
$ docker run --name zookeeper -v /path/to/zoo.cfg:/opt/drycc/zookeeper/conf/zoo.cfg  quay.io/drycc-addons/zookeeper:latest
```

After that, your changes will be taken into account in the server's behaviour.

#### Step 1: Run the Apache ZooKeeper image

Run the Apache ZooKeeper image, mounting a directory from your host.

```console
$ docker run --name zookeeper -v /path/to/zoo.cfg:/opt/drycc/zookeeper/conf/zoo.cfg quay.io/drycc-addons/zookeeper:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  zookeeper:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    ports:
      - '2181:2181'
    volumes:
      - /path/to/zoo.cfg:/opt/drycc/zookeeper/conf/zoo.cfg
```

#### Step 2: Edit the configuration

Edit the configuration on your host using your favorite editor.

```console
vi /path/to/zoo.cfg
```

#### Step 3: Restart Apache ZooKeeper

After changing the configuration, restart your Apache ZooKeeper container for changes to take effect.

```console
$ docker restart zookeeper
```

or using Docker Compose:

```console
$ docker-compose restart zookeeper
```

### Security

Authentication based on SASL/Digest-MD5 can be easily enabled by passing the `ZOO_ENABLE_AUTH` env var.
When enabling the Apache ZooKeeper authentication, it is also required to pass the list of users and passwords that will
be able to login.

> Note: Authentication is enabled using the CLI tool `zkCli.sh`. Therefore, it's necessary to set
`ZOO_CLIENT_USER` and `ZOO_CLIENT_PASSWORD` environment variables too.

```console
$ docker run -it -e ZOO_ENABLE_AUTH=yes \
               -e ZOO_SERVER_USERS=user1,user2 \
               -e ZOO_SERVER_PASSWORDS=pass4user1,pass4user2 \
               -e ZOO_CLIENT_USER=user1 \
               -e ZOO_CLIENT_PASSWORD=pass4user1 \
               quay.io/drycc-addons/zookeeper
```

or modify the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-zookeeper/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  zookeeper:
  ...
    environment:
      - ZOO_ENABLE_AUTH=yes
      - ZOO_SERVER_USERS=user1,user2
      - ZOO_SERVER_PASSWORDS=pass4user1,pass4user2
      - ZOO_CLIENT_USER=user1
      - ZOO_CLIENT_PASSWORD=pass4user1
  ...
```

### Setting up a Apache ZooKeeper ensemble

A Apache ZooKeeper (https://zookeeper.apache.org/doc/r3.1.2/zookeeperAdmin.html) cluster can easily be setup with the Bitnami Apache ZooKeeper Docker image using the following environment variables:

 - `ZOO_SERVERS`: Comma, space or semi-colon separated list of servers.This can be done with or without specifying the ID of the server in the ensemble. No defaults. Examples:
  - without Server ID - zoo1:2888:3888,zoo2:2888:3888
  - with Server ID - zoo1:2888:3888::1,zoo2:2888:3888::2

For reliable Apache ZooKeeper service, you should deploy Apache ZooKeeper in a cluster known as an ensemble. As long as a majority of the ensemble are up, the service will be available. Because Apache ZooKeeper requires a majority, it is best to use an odd number of machines. For example, with four machines Apache ZooKeeper can only handle the failure of a single machine; if two machines fail, the remaining two machines do not constitute a majority. However, with five machines Apache ZooKeeper can handle the failure of two machines.

You have to use 0.0.0.0 as the host for the server. More concretely, if the ID of the zookeeper1 container starting is 1, then the ZOO_SERVERS environment variable has to be 0.0.0.0:2888:3888,zookeeper2:2888:3888,zookeeper3:2888:3888 or if the ID of zookeeper servers are non-sequential then they need to be specified 0.0.0.0:2888:3888::2,zookeeper2:2888:3888::4.zookeeper3:2888:3888::6

See below:

Create a Docker network to enable visibility to each other via the docker container name

```console
$ docker network create app-tier --driver bridge
```

#### Step 1: Create the first node

The first step is to create one  Apache ZooKeeper instance.

```console
$ docker run --name zookeeper1 \
  --network app-tier \
  -e ZOO_SERVER_ID=1 \
  -e ZOO_SERVERS=0.0.0.0:2888:3888,zookeeper2:2888:3888,zookeeper3:2888:3888 \
  -p 2181:2181 \
  -p 2888:2888 \
  -p 3888:3888 \
  quay.io/drycc-addons/zookeeper:latest
```

#### Step 2: Create the second node

Next we start a new Apache ZooKeeper container.

```console
$ docker run --name zookeeper2 \
  --network app-tier \
  -e ZOO_SERVER_ID=2 \
  -e ZOO_SERVERS=zookeeper1:2888:3888,0.0.0.0:2888:3888,zookeeper3:2888:3888 \
  -p 2181:2181 \
  -p 2888:2888 \
  -p 3888:3888 \
  quay.io/drycc-addons/zookeeper:latest
```

#### Step 3: Create the third node

Next we start another new Apache ZooKeeper container.

```console
$ docker run --name zookeeper3 \
  --network app-tier \
  -e ZOO_SERVER_ID=3 \
  -e ZOO_SERVERS=zookeeper1:2888:3888,zookeeper2:2888:3888,0.0.0.0:2888:3888 \
  -p 2181:2181 \
  -p 2888:2888 \
  -p 3888:3888 \
  quay.io/drycc-addons/zookeeper:latest
```
You now have a two node Apache ZooKeeper cluster up and running. You can scale the cluster by adding/removing slaves without incurring any downtime.

With Docker Compose the ensemble can be setup using:

```yaml
version: '2'

services:
  zookeeper1:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    ports:
      - '2181'
      - '2888'
      - '3888'
    volumes:
      - /path/to/zookeeper-persistence:/drycc/zookeeper
    environment:
      - ZOO_SERVER_ID=1
      - ZOO_SERVERS=0.0.0.0:2888:3888,zookeeper2:2888:3888,zookeeper3:2888:3888
  zookeeper2:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    ports:
      - '2181'
      - '2888'
      - '3888'
    volumes:
      - /path/to/zookeeper-persistence:/drycc/zookeeper
    environment:
      - ZOO_SERVER_ID=2
      - ZOO_SERVERS=zookeeper1:2888:3888,0.0.0.0:2888:3888,zookeeper3:2888:3888
  zookeeper3:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    ports:
      - '2181'
      - '2888'
      - '3888'
    volumes:
      - /path/to/zookeeper-persistence:/drycc/zookeeper
    environment:
      - ZOO_SERVER_ID=3
      - ZOO_SERVERS=zookeeper1:2888:3888,zookeeper2:2888:3888,0.0.0.0:2888:3888
```

### Start Zookeeper with TLS

```
docker run --name zookeeper \
  -v /path/to/domain.key:/drycc/zookeeper/certs/domain.key:ro
  -v /path/to/domain.crs:/drycc/zookeeper/certs/domain.crs:ro
  -e ALLOW_EMPTY_PASSWORD=yes \
  -e ZOO_TLS_CLIENT_ENABLE=yes \
  -e ZOO_TLS_CLIENT_KEYSTORE_FILE=/drycc/zookeeper/certs/domain.key\
  -e ZOO_TLS_CLIENT_TRUSTSTORE_FILE=/drycc/zookeeper/certs/domain.crs\
  quay.io/drycc-addons/zookeeper:latest
```

## Logging

The Bitnami Apache ZooKeeper Docker image sends the container logs to the `stdout`. To view the logs:

```console
$ docker logs zookeeper
```

or using Docker Compose:

```console
$ docker-compose logs zookeeper
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

## Maintenance

### Backing up your container

To backup your data, follow these simple steps:

#### Step 1: Stop the currently running container

```console
$ docker stop zookeeper
```

or using Docker Compose:

```console
$ docker-compose stop zookeeper
```

#### Step 2: Run the backup command

We need to mount two volumes in a container we will use to create the backup: a directory on your host to store the backup in, and the volumes from the container we just stopped so we can access the data.

```console
$ docker run --rm -v /path/to/zookeeper-backups:/backups --volumes-from zookeeper busybox \
  cp -a /quay.io/drycc-addons/zookeeper:latest /backups/latest
```

or using Docker Compose:

```console
$ docker run --rm -v /path/to/zookeeper-backups:/backups --volumes-from `docker-compose ps -q zookeeper` busybox \
  cp -a /quay.io/drycc-addons/zookeeper:latest /backups/latest
```

### Restoring a backup

Restoring a backup is as simple as mounting the backup as volumes in the container.

```console
$ docker run -v /path/to/zookeeper-backups/latest:/drycc/zookeeper quay.io/drycc-addons/zookeeper:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  zookeeper:
    image: 'quay.io/drycc-addons/zookeeper:latest'
    ports:
      - '2181:2181'
    volumes:
      - /path/to/zookeeper-backups/latest:/drycc/zookeeper
```

### Upgrade this image

Bitnami provides up-to-date versions of Apache ZooKeeper, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container.

#### Step 1: Get the updated image

```console
$ docker pull quay.io/drycc-addons/zookeeper:latest
```

or if you're using Docker Compose, update the value of the image property to
`quay.io/drycc-addons/zookeeper:latest`.

#### Step 2: Stop and backup the currently running container

Before continuing, you should backup your container's data, configuration and logs.

Follow the steps on [creating a backup](#backing-up-your-container).

#### Step 3: Remove the currently running container

```console
$ docker rm -v zookeeper
```

or using Docker Compose:


```console
$ docker-compose rm -v zookeeper
```

#### Step 4: Run the new image

Re-create your container from the new image, [restoring your backup](#restoring-a-backup) if necessary.

```console
$ docker run --name zookeeper quay.io/drycc-addons/zookeeper:latest
```

or using Docker Compose:

```console
$ docker-compose up zookeeper
```

## Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/drycc-addons/drycc-docker-zookeeper/issues), or submit a [pull request](https://github.com/drycc/drycc-addons-docker-zookeeper/pulls) with your contribution.

## Issues

If you encountered a problem running this container, you can file an [issue](https://github.com/drycc-addons/drycc-docker-zookeeper/issues/new). For us to provide better support, be sure to include the following information in your issue:

- Host OS and version
- Docker version (`docker version`)
- Output of `docker info`
- Version of this container
- The command you used to run the container, and any relevant output you saw (masking any sensitive information)
