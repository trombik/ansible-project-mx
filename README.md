# MTA for `trombik.org`

This project manages MTA for `trombik.org`.

This file explains general overview of the project. Please see [docs](docs/)
directory for details.

The project is managed by a `Rakefile`, which provides most of common
operations, such as deploying and testing. Available targets can be shown by:

```console
> bundle exec rake -T
```

## Requirements

* nodejs and npm
* ruby 2.6.x
* bundler
* Virtualbox
* Vagrant
* python 3
* terraform

## Environment variables

### `ANSIBLE_VAULT_PASSWORD_FILE`

Set `ANSIBLE_VAULT_PASSWORD_FILE` to path to `ansible` `vault` password file.

### `ANSIBLE_ENVIRONMENT`

The project has two environments. To choose environment, set
`ANSIBLE_ENVIRONMENT` variable. If the environment variable is not defined, it
defaults to `virtualbox`.

#### `virtualbox`

The `virtualbox` environment is a test environment on `virtualbox`. The
environment is isolated from external network, completely running on your
local machine.

#### `prod`

The `prod` environment is the live, production environment.

## Usage

To deploy in an environment run `up` and `provision` targets.

```console
> bundle exec rake up provision
```

To perform all test from scratch, run `test` target.

```console
> bundle exec rake test
```

To perform unit tests, run `test:serverspec:all` target.

```console
> bundle exec rake test:serverspec:all
```

To perform integration tests, run `test:integration:all` target.

```console
> bundle exec rake test:integration:all
```

## Overview of nodes

### `virtualbox` environment

#### `mx1.trombik.org`

The MTA, and authoritative DNS server.
