# concourse-docker-compose-resource

A Concourse CI resource that executes [`docker-compose`](https://docs.docker.com/compose/) 
against a remote host.

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

* `host`: Required. The hostname of the Docker host to connect to.
* `port`: Optional. Default: 2376. The port on the Docker host to connect to.
* `verbose`: Optional. Default: false. Echo the `docker-compose` command, 
   and enable verbose output from `docker-compose`.

### Example

```bash
resources:
- name: docker-compose
  type: docker-compose
  source:
    host: docker-01.your.org
```

## Behaviour

### `check`: No-Op

### `in`: No-Op

### `out`: Execute `docker-compose`

#### Parameters

* `command`: Optional. Default: `up`. Specify the command to run with `docker-compose`.
  Supported commands are: `up`, and `down`.
* `compose_file`: Optional. Default: `docker-compose.yml`. Specify the name of the Compose file,
  relative to `path`.
* `options`: Optional. Supply command-specific options. Options names correlate to 
  `docker-compose` command options.
  Supported options for `up`:
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
  Supported options for `down`:
  * `rmi`: String. Remove images. Type must be one of:
    * `all`: Remove all images used by any service.
    * `local`: Remove only images that don't have a
      custom tag set by the `image` field.
  * `volumes`: Boolean. Remove named volumes declared in the `volumes`
    section of the Compose file and anonymous volumes attached to containers.
  * `remove_orphans`: Boolean. Remove containers for services not defined
    in the Compose file.
* `path`: Optional. The directory in which `docker-compose` will be executed.
* `print`: Optional. Default: false. Print the contents of the Compose file.
* `services`: Optional. Only relevant to the `up` command. A list of services named in 
  the Compose file that `docker-compose` will being up.
* `wait_before`: Optional. The number of seconds to wait (sleep) before executing `docker-compose`.
* `wait_after`: Optional. The number of seconds to wait (sleep) after executing `docker-compose`.

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
