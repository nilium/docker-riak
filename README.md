# docker-riak

This repository contains a Dockerfile that will build Riak into a Ubuntu 16.04
Xenial image, starting a Riak server.


Building
--------

To build the Docker image, run `make` (or `make docker`). The build can take
some time, as it involves building both Erlang and Riak from source.

You can alter the resulting image with the following Makefile variables:

| Variable             | Default                   | Description
| -                    | -                         | -
| `DOCKER`             | `docker`                  | The Docker executable. Can set to `img` or another CLI-compatible tool.
| `DOCKER_REGISTRY`    | `index.docker.io/kochava` | The registry to target.
| `DOCKER_IMAGE`       | `riak`                    | The image repository.
| `DOCKER_TAG`         | `latest`                  | The image tag.
| `DOCKER_FLAGS`       | (empty)                   | Additional flags to pass to `docker build`.


Starting Riak
-------------

To start Riak, you can create a simple container with `docker run`:

```
# Create a network:
$ docker network create riak

# Start node riak-1:
$ docker run --detach --network riak --env RIAK_NODENAME=riak@riak-1. --name riak-1 kochava/riak
```

To then start a second node and join it to the cluster, you would do the
following:

```
# Start node riak-2:
$ docker run --detach --network riak --env RIAK_NODENAME=riak@riak-2. --name riak-2 kochava/riak

# Join the cluster:
$ docker exec -it riak-2 riak-admin cluster join riak@riak-1.

# Check the cluster plan:
$ docker exec -it riak-2 riak-admin cluster plan

# Commit the cluster plan:
$ docker exec -it riak-2 riak-admin cluster commit

# Check riak-1's memberships:
$ docker exec -it riak-1 riak-admin status | grep ring_members
ring_members : ['riak@riak-1.','riak@riak-2.']
```


Configuration
-------------

### riak.conf

The riak.conf can be modified in two ways:

1.  Mount a riak.conf as `/usr/local/riak/etc/riak.conf`. Optionally set
    `RIAK_SKIP_DOCKER_CONF=1` via environment variables to skip ignore any
    additional `RIAK_` variables present in the environment.

2.  Set `RIAK_` environment variables, which will be appended to the riak.conf
    in the container. If you've mounted a riak.conf into the container, avoid
    using `RIAK_` variables, since this could modify the file that was mounted.

    The variables and the config key they correspond to are listed in a table
    below.

### advanced.conf

If modifying advanced.conf, you must mount it into the container or build
a derived image from it. There is currently no option to configure its options
via environment variables.

### Cluster Operations

Riak's bin dir is in the container's PATH. You can run `riak-admin`, `riak`, and
other commands using `docker exec`. Note that running `riak stop` will stop
Riak, but that runsv will start it afterward.

### Stopping the Container

Because the container uses `runsv`, if you start it in interactive mode,
a <kbd>Ctrl-C</kbd> will send an interrupt signal to runsv, which will
diligently send it to Riak.

Instead, you need to either send a terminate signal to runsv or use `docker stop
$CONTAINER` (which will send a terminate signal for you). You can also use
`docker exec $CONTAINER sv x`, which will also instruct runsv to exit.

### RIAK\_\* Environment Variables

All environment variables defined in [riak.conf.vars](./riak.conf.vars), if set,
will modify riak.conf by setting the associated riak.conf field to its value. If
building the image from scratch, this file can be modified by adding (or
removing) an environment variable to it. It is structured as one line per
variable, with the variable and its associated config key separated by
whitespace.

Exercise caution when using this with bind-mounted riak.conf files, as it will
append lines to the file unless you set `RIAK_SKIP_DOCKER_CONF=1`.

The variables `RIAK_NODENAME` and `RIAK_DISTRIBUTED_COOKIE` are always set to
their default values (`riak@127.0.0.1` and `riak`, respectively) unless
overridden.
