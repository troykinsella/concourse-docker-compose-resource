# concourse-docker-compose-resource

A Concourse CI resource that executes [`docker-compose`](https://docs.docker.com/compose/) 
against a remote host.

See [Docker Hub](https://cloud.docker.com/repository/docker/troykinsella/concourse-docker-compose-resource)
for tagged image versions available.

## Docker Host Resolution

The host name of a remote docker host must be specified by the following configuration, 
and there are several means of supplying this host name. 
This is how a host name is resolved, whereby the first location to provide a host name is utilized:

* Check `params.host` of the `put` step for a host name string
* Check `params.host_file` of the `put` step for a path to a file containing host names
  * Optionally, extract a line number from this file using `params.host_index`
* Check `source.host` of the resource type `source` configuration

## Resource Type Configuration

```bash
resource_types:
- name: docker-compose
  type: docker-image
  source:
    repository: troykinsella/concourse-docker-compose-resource
    tag: latest
```

## Source Configuration

* `ca_certs`: Optional. A list of objects having the following keys.
  Configures CA certificates for docker registry domains.
  * `domain`: The domain of the docker registry.
  * `cert`: The CA certificate for the domain.

  Each entry specifies the x509 CA certificate for the trusted docker registry 
  residing at the specified domain. This is used to validate the certificate of 
  the docker registry when the registry's certificate is signed by a custom 
  authority (or itself).

  The domain should match the first component of repository, including the port. 

* `host`: Optional. The hostname of the Docker host to connect to.
          Note: A host must be supplied either here or via `params.host` or `params.host_file`.
* `port`: Optional. Default: 2376. The port on the Docker host to connect to.
* `registries`: Optional. A list of objects having the following keys.
  Performs a `docker login` to the listed registries in order to pull images from
  private registries, for example. 
  * `host`: 
  * `username`:
  * `password`:
* `verbose`: Optional. Default: false. Enable verbose output from `docker-compose`.

### Example

```bash
resources:
- name: docker-compose
  type: docker-compose
  source:
    host: docker-01.your.org
    registries:
    - host: docker-registry.your.org
      username: you
      password: 1nsecure
    ca_certs:
    - domain: docker-registry.your.org
      cert: |
        -----BEGIN CERTIFICATE-----
        ...
        -----END CERTIFICATE-----
```

## Behaviour

### `check`: No-Op

### `in`: No-Op

### `out`: Execute `docker compose`

#### Parameters

* `command`: Optional. Default: `up`. Specify the command to run with `docker compose`.
  Supported commands are:
  * `down`
  * `kill`
  * `restart`
  * `start`
  * `stop`
  * `up`
* `compose_file`: Optional. Default: `docker-compose.yml`. Specify the name of the Compose file,
  relative to `path`.
* `env`: Optional. Mutually exclusive with `env_file`. A map of key-value pairs which will be made available to the
  `docker compose` execution as environment variables.
* `env_file`: Optional. Mutually exclusive with `env`. A path to a file containing environment variables 
  which will be made available to the `docker-compose` execution.
* `host`: Optional. The hostname of the Docker host to connect to. Takes precedence over `source.host`.
          Note: A host must be supplied either here or via `params.host_file` or `source.host`.
* `host_file`: Optional. The path to a file containing the hostname of the Docker host to connect to.
               This file may have multiple lines in it. See `host_index`.
               Note: A host must be supplied either here or via `params.host` or `source.host`.
* `host_index`: Optional. Default: `1`. The line number (starting at `1`) to extract from `host_file`, if supplied.
* `options`: Optional. Supply command-specific options. Options names correlate to 
  `docker compose` command options.
  * `down` options:
    * `rmi`: String. Remove images. Type must be one of:
      * `all`: Remove all images used by any service.
      * `local`: Remove only images that don't have a
        custom tag set by the `image` field.
    * `volumes`: Boolean. Remove named volumes declared in the `volumes`
      section of the Compose file and anonymous volumes attached to containers.
    * `remove_orphans`: Boolean. Remove containers for services not defined
      in the Compose file.
    * `timeout`: Specify a shutdown timeout in seconds.
  * `kill` options:
    * `signal`: SIGNAL to send to the container.
  * `restart` options:
    * `timeout`: Specify a shutdown timeout in seconds.
  * `start` options: (none)
  * `stop` options:
    * `timeout`: Specify a shutdown timeout in seconds.
  * `up` options:
    * `no_deps`: Boolean. Don't start linked services.
    * `force_recreate`: Boolean. Recreate containers even if their configuration
      and image haven't changed.
    * `no_recreate`: Boolean. If containers already exist, don't recreate
      them. Incompatible with `force_recreate` and `renew-anon-volumes`.
    * `renew-anon-volumes`: Boolean. Recreate anonymous volumes instead of retrieving
      data from the previous containers.
    * `remove_orphans`: Boolean. Remove containers for services not defined
      in the Compose file.
    * `scale`: Object of service name keys to scale integer values. 
       Scale SERVICE to NUM instances. Overrides the `scale` setting in the 
       Compose file if present. For example:
       * ```bash
         scale:
           service_a: 3
           service_b: 1
         ```
     * `timeout`: Use this timeout in seconds for container shutdown when attached or when 
       containers are already running.
* `path`: Optional. The directory in which `docker compose` will be executed.
* `print`: Optional. Default: false. Print the contents of the Compose file.
* `project`: Optional. Specify the project name, which is prepended to container names.
* `pull`: Optional. Default: false. Run `docker compose pull` prior to executing the `command`.
* `services`: Optional. Only relevant to the `kill`, `restart`, `start`, `stop`, and `up` commands. 
  A list of services named in the Compose file on which `docker compose` will operate.
* `wait_before`: Optional. The number of seconds to wait (sleep) before executing `docker compose`.
* `wait_after`: Optional. The number of seconds to wait (sleep) after executing `docker compose`.

#### Example

```bash
# Extends example in Source Configuration

jobs:
- name:
  plan:
  - do:
    - get: code # git resource
    - put: docker-compose
      params:
        command: up
        compose_file: docker-compose.test-deps.yml
        path: code
        services:
        - service_a
        options:
          scale:
            service_a: 1
        wait_after: 3 # Let services come up
    - task: integration tests
      file: ...
      input_mapping:
        source: code
    ensure:
      put: docker-compose
      params:
        command: down
        compose_file: docker-compose.test-deps.yml
        path: code
        options:
          volumes: true
```

## License

MIT © Troy Kinsella
